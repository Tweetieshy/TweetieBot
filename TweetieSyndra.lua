if myHero.charName ~= "Syndra" then return end

local version = 0.21
local SUMM_IGN = {Range = 600}

local Q = {Range = 800,Delay = 0.25, Radius = 90, Speed = 1600,Type = "Circle",CastTime = 0}
local W = {Range = 950,Delay = 0.5, Radius = 160, Speed = 1500,Type = "Circle", CastTime = 0}
local E = {Range = 700, Delay = 0.25, Speed = 2500, Radius = 60,CastTime = 0 }
local R = {Range = 675, CastTime = 0}
local QE = {Range = 1250,Delay = 0.6, Radius = 100, Speed = 2000,CastTime = 0}
local LastQ = 0

local IgnitedTarget = nil
local R_CD = 0

local function EnableOrb()
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetAttack(true)
		_G.SDK.Orbwalker:SetMovement(true)
	end
	if _G.GOS then
		_G.GOS.BlockMovement = false
		_G.GOS.BlockAttack  = false
	end
	if EOW then
		EOW:SetMovements(true)
		EOW:SetMovements(true)
	end
end

local function DisableOrb()
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetAttack(false)
		_G.SDK.Orbwalker:SetMovement(false)
	end
	if _G.GOS then
		_G.GOS.BlockMovement = true
		_G.GOS.BlockAttack  = true
	end
	if EOW then
		EOW:SetMovements(false)
		EOW:SetMovements(false)
	end
end

local spellcast = {state = 1, mouse = mousePos}

function CastSpell(hk,pos,delay)
	if spellcast.state == 2 then return end
	if ExtLibEvade and ExtLibEvade.Evading then return end
	
	spellcast.state = 2
	DisableOrb()
	spellcast.mouse = mousePos
	DelayAction(function() Control.SetCursorPos(pos) end, 0.01) 
	if true then
		DelayAction(function() 
			Control.KeyDown(hk)
			Control.KeyUp(hk)
		end, 0.015)
		DelayAction(function()
			Control.SetCursorPos(spellcast.mouse)
		end,0.2)
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.3)
	else
		
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.01)
	end
end


local UpdateSphere = false
local Balls = {}
local Ts = nil
local Pred = nil
local ComboDamage = {}

local function GetManaPercentage(unit)
	return unit.mana/unit.maxMana
end
local function GetHPPercentage(unit)
	return unit.health/unit.maxHealth
end

local function isReady(slot)
	return myHero:GetSpellData(slot).currentCd == 0 and myHero:GetSpellData(slot).level > 0 and myHero:GetSpellData(slot).mana <= myHero.mana
end

local function isValidTarget(obj,range)
	range = range and range or math.huge
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and not obj.isImmortal and obj.distance <= range
end

local function CalcMagicalDamage(source, target, amount)
  local mr = target.magicResist
  local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
  end
  return value * amount
end
local function GetDistanceSqr(p1, p2)
    assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
    p2 = p2 or myHero.pos
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

local function GetDistance(p1, p2)
    return math.sqrt(GetDistanceSqr(p1, p2))
end

local function ValidTarget(unit,range,from)
	from = from or myHero.pos
	range = range or math.huge
	return unit and unit.valid and not unit.dead and unit.visible and unit.isTargetable and GetDistanceSqr(unit.pos,from) <= range*range
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in pairs(objects) do
        local hit = CountObjectsNearPos(object.pos, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
        if GetDistanceSqr(pos, object.pos) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

local Attack = true
local Move = true
local LastMove = 0
local State = 1
local Mouse
local function EnableOrb()
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetAttack(true)
		_G.SDK.Orbwalker:SetMovement(true)
	end
	if _G.GOS then
		_G.GOS.BlockMovement = false
		_G.GOS.BlockAttack  = false
	end
end

local function DisableOrb()
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetAttack(false)
		_G.SDK.Orbwalker:SetMovement(false)
	end
	if _G.GOS then
		_G.GOS.BlockMovement = true
		_G.GOS.BlockAttack  = true
	end
end

local spellcast = {state = 1, mouse = mousePos}

function CastSpell(hk,pos,delay)
	if spellcast.state == 2 then return end
	spellcast.state = 2
	DisableOrb()
	spellcast.mouse = mousePos
	DelayAction(function() Control.SetCursorPos(pos) end, 0.01) 
	if true then
		DelayAction(function() 
			--print("keydown")
			Control.KeyDown(hk)
			Control.KeyUp(hk)
		end, 0.012)
		DelayAction(function()
			Control.SetCursorPos(spellcast.mouse)
		end,0.15)
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.1)
	else
		
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.01)
	end
end

local SyndraMenu = MenuElement({type = MENU, id = "SyndraMenu", name = "Tweetie's Syndra", leftIcon = "http://ddragon.leagueoflegends.com/cdn/7.1.1/img/champion/Syndra.png"})
--[[Key]]
SyndraMenu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
SyndraMenu.Key:MenuElement({id = "ComboKey", name = "Combo Key",key = 32 })
SyndraMenu.Key:MenuElement({id = "HarassKey", name = "Harass Key",key = string.byte("C") })
SyndraMenu.Key:MenuElement({id = "ClearKey", name = "Clear Key",key = string.byte("V") })
--[[Combo]]
SyndraMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
SyndraMenu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
SyndraMenu.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
SyndraMenu.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
SyndraMenu.Combo:MenuElement({id = "UseQE", name = "Use QE", value = true})
SyndraMenu.Combo:MenuElement({id = "UseR", name = "Use R", value = true})

SyndraMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
SyndraMenu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true})
SyndraMenu.Harass:MenuElement({id = "Mana", name = "Min Mana (%)", value = 60,min = 0, max = 100, step = 1})

SyndraMenu:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
SyndraMenu.Clear:MenuElement({id = "UseSpell", name = "Use Spells", key = string.byte("T"),toggle = true})
SyndraMenu.Clear:MenuElement({id = "UseQ", name = "Use Q", value = false})
SyndraMenu.Clear:MenuElement({id = "QHit", name = "Q hits x minions", value = 2,min = 1, max = 10, step = 1})
SyndraMenu.Clear:MenuElement({id = "UseW", name = "Use W", value = false})

SyndraMenu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
SyndraMenu.Misc:MenuElement({id = "GrabPet", name = "Auto Grab Pets", value = true})
SyndraMenu.Misc:MenuElement({id = "ForceR", name = "Force R", key = string.byte("R")})
SyndraMenu.Misc:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true})

SyndraMenu:MenuElement({type = MENU, id = "Drawing", name = "Draw Settings"})
SyndraMenu.Drawing:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
SyndraMenu.Drawing:MenuElement({id = "DrawW", name = "Draw W Range", value = false})
SyndraMenu.Drawing:MenuElement({id = "DrawE", name = "Draw E Range", value = false})
SyndraMenu.Drawing:MenuElement({id = "DrawR", name = "Draw R Range", value = false})
SyndraMenu.Drawing:MenuElement({id = "DrawQE", name = "Draw QE Range", value = true})
SyndraMenu.Drawing:MenuElement({id = "DrawBall", name = "Draw Balls", value = true})
SyndraMenu.Drawing:MenuElement({id = "DrawDmg", name = "Draw Combo Dmg", value = false})

function GetTarget(range)
	
	local result = nil
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if isValidTarget(hero,range) and hero.isEnemy then
			local dmgtohero = CalcMagicalDamage(myHero,hero,200)
			local tokill = hero.health/dmgtohero
			if tokill > N or result == nil then
				result = hero
			end
		end
	end
	return result
end

function CastQ(target)
	local qPos = target:GetPrediction(Q.Speed,Q.Delay)
	CastSpell(HK_Q,qPos)
end

function IsValidTarget(unit, range, onScreen)
    local range = range or 20000
    
    return unit and unit.distance <= range and not unit.dead and unit.valid and unit.visible and unit.isTargetable and not (onScreen and not unit.pos2D.onScreen)
end

function Combo()

	if isReady(3) and SyndraMenu.Combo.UseR:Value() then
		local target = GetTarget(R.Range)

		if target and SyndraMenu.Misc.UseIgnite:Value() and IgniteReady() and target.distance < SUMM_IGN.Range and (GetDamage("R",target) + GetEnemyIgniteDmg(target)) > target.health and GetDamage("R",target) <= target.health then
			IgnitedTarget = target
			UseSmartIgniteTarget(target)
		end
		
		if IgnitedTarget then
			Control.CastSpell(HK_R,IgnitedTarget)
			IgnitedTarget = nil
		end
		
		if target and GetDamage("R",target) > target.health then
			Control.CastSpell(HK_R,target)
		end
	end
	
	if isReady(0) and SyndraMenu.Combo.UseQ:Value() then
		local qTarget = GetTarget(Q.Range)
		if qTarget then
			CastQ(qTarget)
			return
		end
	end
	
	if isReady(2) and SyndraMenu.Combo.UseE:Value() then
		for i = 1, Game.HeroCount()  do
			local hero = Game.Hero(i)
			if hero.isEnemy and isValidTarget(hero, 2000) then
				for id, ball in pairs(Balls) do
					if GetDistanceSqr(ball.pos,myHero.pos) < E.Range*E.Range then
						local enemyPos = hero:GetPrediction(E.Speed,E.Delay)
						local endPos = ball.pos  + (ball.pos - myHero.pos):Normalized()*1250
						local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(ball.pos,endPos,enemyPos)
						if isOnSegment and GetDistanceSqr(pointSegment,enemyPos) < (E.Radius + 90)*(E.Radius + 90) then
							CastSpell(HK_E,ball.pos)
						end
					end
				end
			end		
		end
	end
	if isReady(1) then
		local wTarget = GetTarget(W.Range)
		if wTarget and myHero:GetSpellData(1).toggleState == 2 then --W2
			local wPos = wTarget:GetPrediction(W.Speed,W.Delay)
			CastSpell(HK_W,wPos)
		elseif wTarget and myHero:GetSpellData(1).toggleState == 1 then --W1
			local wPos = GrabObject()
			if wPos then
				CastSpell(HK_W,wPos)
			end
		end
	end
	if spellcast.state == 2 then return end
	
	if isReady(0) and isReady(2) and SyndraMenu.Combo.UseQE:Value() then
		local target = GetTarget(QE.Range)
		if target then
			local pos = target:GetPrediction(QE.Speed,0.943)
			pos = myHero.pos + (pos - myHero.pos):Normalized()*(Q.Range - 65)
			Control.SetCursorPos(pos) 
			Control.KeyDown(HK_Q)
			DelayAction(function() Control.KeyDown(HK_E) Control.KeyUp(HK_Q) Control.KeyUp(HK_E) end, 0.25)
		end
	end
	
end

function GrabObject()
	for i, ball in pairs(Balls) do
		if GetDistanceSqr(ball.pos) < W.Range*W.Range then
			return ball.pos
		end
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy and isValidTarget(minion,W.Range-25)  then
			return minion.pos
		end
	end	
end

function Harass()
	if isReady(0) and SyndraMenu.Harass.UseQ:Value() and GetManaPercentage(myHero) > SyndraMenu.Harass.Mana:Value()*0.01 then
		local qTarget = GetTarget(Q.Range)
		if qTarget then
			CastQ(qTarget)
			return
		end
	end
end

function Clear()
	if not SyndraMenu.Clear.UseSpell:Value() then return end
	local qMinions = {}
	local wMinions = {}
	local mobs = {}
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  isValidTarget(minion,Q.Range)  then
			if minion.team == 300 then
				mobs[#mobs+1] = minion
			elseif minion.isEnemy  then
				qMinions[#qMinions+1] = minion
			end	
		elseif  isValidTarget(minion,W.Range)  then	
			wMinions[#wMinions+1] = minion
		end
	end	
	if isReady(0) and SyndraMenu.Clear.UseQ:Value() then
		local BestPos, BestHit = GetBestCircularFarmPosition(Q.Range,Q.Radius + 48, qMinions)
		if BestHit >= SyndraMenu.Clear.QHit:Value() then
			Control.CastSpell(HK_Q,BestPos)
		end
	end
	if isReady(1) and SyndraMenu.Clear.UseW:Value() and myHero:GetSpellData(1).toggleState == 2 then
		local BestPos, BestHit = GetBestCircularFarmPosition(W.Range,W.Radius + 48, wMinions)
		if BestHit > 0 then
			Control.CastSpell(HK_W,BestPos)
		end
	elseif isReady(1) and SyndraMenu.Clear.UseW:Value() and myHero:GetSpellData(1).toggleState == 1 then
		local wPos = GrabObject()
		if wPos then
			Control.CastSpell(HK_W,wPos)
		end
	end	
	if #mobs == 0 then return end
	table.sort(mobs,function(a,b) return a.maxHealth > b.maxHealth end)
	local mob = mobs[1]
	if isReady(0) then
		CastQ(mob)
	end
end

function GetMySpheres()
		for i = 0, Game.ObjectCount() do
			local obj = Game.Object(i)
			if obj and not obj.dead and obj.name:find("Seed") then
				Balls[obj.networkID] = obj
			end
		end	
end

--annie's bear etc.

function GrabPets()
	
end

function UpdateTranscendent()
	if not Q.Update and myHero:GetSpellData(0).level == 5 then
		Q.Update = true
	end	
	if not R.Update and myHero:GetSpellData(0).level == 3 then
		R.Update = true
		R.Range = 750
	end
end

function GetBallCount()
	local myballs = 0
	for i, ball in pairs(Balls) do
		if ball and not ball.dead then
			myballs = myballs + 1
		end
	end
	return myballs
end

function GetDamage(spell,target)
	local balls = GetBallCount()
	if balls >= 4 then
		balls = 7
	else
		balls = balls + 3
	end
	
	local dmg = 0
	if spell == "R" then
		dmg = dmg + CalcMagicalDamage(myHero,target,(({90, 135 , 180})[myHero:GetSpellData(_R).level] + 0.2 * myHero.ap)*balls)
	elseif spell == "Q" then
		dmg = dmg + CalcMagicalDamage(myHero,target,(({50, 95 , 140, 185, 230})[myHero:GetSpellData(_Q).level] + 0.65 * myHero.ap))
	elseif spell == "W" then
		dmg = dmg + CalcMagicalDamage(myHero,target,(({70, 110 , 150, 190, 230})[myHero:GetSpellData(_W).level] + 0.7 * myHero.ap))
	elseif spell == "E" then
		dmg = dmg + CalcMagicalDamage(myHero,target,(({70, 115 , 160, 205, 250})[myHero:GetSpellData(_E).level] + 0.6 * myHero.ap))
		if (myHero:GetSpellData(_E).level == 5) then
			dmg = dmg + (250 + 0.6 * myHero.ap) / 5 -- 20% true damage BONUS on lvl 5
		end
	elseif spell == "Ignite" then
		return 50+20*myHero.levelData.lvl
	end
	return dmg
end

function GetDamagePRED(spell,target)
	local balls = GetBallCount()
	if balls >= 3 then
		balls = 7
	else
		balls = balls + 4
	end
	
	local dmg = 0
	if spell == "R" then
		dmg = dmg + CalcMagicalDamage(myHero,target,(({90, 135 , 180})[myHero:GetSpellData(_R).level] + 0.2 * myHero.ap)*balls)
	else
		dmg = GetDamage(spell,target)
	end
	return dmg
end

function GrabSummSpellFromEnemy(target,summName)
local retval = 0;
local spellName = target:GetSpellData(SUMMONER_1).name;
if spellName == summName then 
	retval = SUMMONER_1;
	else
	local spellName = target:GetSpellData(SUMMONER_2).name;
	if spellName == summName then
		retval = SUMMONER_2;
		end
	end
return retval
end

function GetEnemyIgniteDmg(target)

	local DmgIgnite = GetDamage("Ignite",target)-(target.hpRegen*3); -- we substract 5% considering health regen of target

	local SUM_BARRIER = GrabSummSpellFromEnemy(target,"SummonerBarrier");
	if SUM_BARRIER > 0 then
		local SUM_BARRIER = target:GetSpellData(SUM_BARRIER);
		if SUM_BARRIER.currentCd < 5 then
			DmgIgnite = DmgIgnite / 5 * 3 -- Barrier denys potentially 2 seconds of ignites 5 second DOT
		end
	end
	
	local SUM_HEAL = GrabSummSpellFromEnemy(target,"SummonerHeal");
	if SUM_HEAL > 0 then
		local HEAL_DATA = target:GetSpellData(SUM_HEAL);
		if HEAL_DATA.currentCd < 5 then
			local heal_amount = 90 + target.levelData.lvl * (255/18)
			DmgIgnite = DmgIgnite - heal_amount / 2; -- Ignite reduces heals by 50%
		end
	end
	
	local SUM_CLEANSE = GrabSummSpellFromEnemy(target,"SummonerCleanse");
	if SUM_CLEANSE > 0 then
		local SUM_CLEANSE = target:GetSpellData(SUM_CLEANSE);
		if SUM_CLEANSE.currentCd < 5 then
			DmgIgnite = 0; -- cleanse can completely deny our damage
		end
	end
	
return DmgIgnite
end

function GetIgnite()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" then
		return SUMMONER_1
	end
	
	if myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
		return SUMMONER_2
	end
	
	return 0
end

function IgniteReady()
	if GetIgnite() > 0 and isReady(GetIgnite()) then
		return true
	end
	return false
end

function GetTimePassedTillLastCast(spell)
	local cd = myHero:GetSpellData(spell).cd
	local currentCd = myHero:GetSpellData(spell).currentCd
	if (spell == _R) then
		-- Workaround, R MAX Cooldowns seems to be "forgotten" during R on cooldown
		if cd > 0 then
			R_CD = cd
		end
		
		return R_CD - currentCd;
	else
		return cd - myHero:GetSpellData(spell).currentCd;
	end
end

-- Cast on best target with kill and range checks
function UseSmartIgnite()
	local target = GetTarget(SUMM_IGN.Range)
	-- and GetEnemyIgniteDmg(target) >= target.health and (GetTimePassedTillLastCast(_R) > 1.5 or not isReady(3))
	if target and GetEnemyIgniteDmg(target) >= target.health and (GetTimePassedTillLastCast(_R) > 1.5 or not isReady(3)) then -- If R is recently cast we wait with igniting till R dmg is completely applied
		UseSmartIgniteTarget(target)
	end
end

-- Cast on specific target WITHOUT health and range CHECKS
function UseSmartIgniteTarget(target)
	if SyndraMenu.Misc.UseIgnite:Value() and target and IgniteReady() then
		if isValidTarget(target, SUMM_IGN.Range) then
			if GetIgnite() == 4 then 
				CastSpell(HK_SUMMONER_1,target.pos)
			end
			
			if GetIgnite() == 5 then
				CastSpell(HK_SUMMONER_2,target.pos)
			end
			--Control.CastSpell(GetIgnite(), target)
		end
	end
end

Callback.Add('Tick',function() 
	--if true then return end
	
	if myHero:GetSpellData(0).currentCd == 0 then
		UpdateSphere = false
	elseif myHero:GetSpellData(0).currentCd >  0 and not UpdateSphere then
		UpdateSphere = true
		DelayAction(function() GetMySpheres() end,0.75)
	end
	
	UpdateTranscendent()
	
	if SyndraMenu.Key.ComboKey:Value() then
		Combo()
	elseif 	SyndraMenu.Key.HarassKey:Value() then
		Harass()
	elseif SyndraMenu.Key.ClearKey:Value() then
		Clear()
	end
	
	UseSmartIgnite()

	if SyndraMenu.Misc.ForceR:Value() then
		local target = GetTarget(R.Range)
		if target then
			Control.CastSpell(HK_R,target)
		end
	end
end)

local function GetComboDamage(hero)
	local DMG = 0
	
	if isReady(0) then
		DMG = DMG + GetDamagePRED("Q",hero);
	end
	
	if isReady(1) then
		DMG = DMG + GetDamagePRED("W",hero);
	end
	
	if isReady(2) then
		DMG = DMG + GetDamagePRED("E",hero);
	end
	
	if isReady(3) then
		DMG = DMG + GetDamagePRED("R",hero);
	end
	
	if GetIgnite() > 0 and isReady(GetIgnite()) then
		DMG = DMG + GetEnemyIgniteDmg(hero);
	end
	
	return DMG
end

local function DrawDmg()
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.alive and hero.visible and hero.isEnemy and hero.pos2D.onScreen then
		local posTo2D = hero.posTo:ToScreen()
		
		local damage = GetComboDamage(hero)
		
		local qcolor = Draw.Color(240,255,0,0)
		if (damage > hero.health) then
			qcolor = Draw.Color(0xFF00FF00)
		end		
		
		--if GetEnemyIgniteDmg(hero) >= hero.health and (GetTimePassedTillLastCast(_R) > 1.5 or not isReady(3)) then
		--	Draw.Text("Autoignite?!", 25, hero.pos2D.x + 30, hero.pos2D.y - 130, Draw.Color(189, 183, 107, 255))
		--end
		--and target.distance < SUMM_IGN.Range
		--if Ready(3) and SyndraMenu.Misc.UseIgnite:Value() and IgniteReady() and (GetDamage("R",hero) + GetEnemyIgniteDmg(hero)) > hero.health then
		
		if GetComboDamage(hero) > hero.health then
			Draw.Text("Killable", 25, hero.pos2D.x + 30, hero.pos2D.y - 110, Draw.Color(0xFF00FF00))
		end
		
		Draw.Text(math.floor(damage), 20, hero.pos2D.x + 30, hero.pos2D.y - 90, qcolor)
		end
	end
end

Callback.Add("Draw", function()
	if myHero.dead then return end
	
	if SyndraMenu.Drawing.DrawDmg:Value() then
		DrawDmg();
	end
	if SyndraMenu.Drawing.DrawQ:Value() and myHero:GetSpellData(0).level > 0 then
		local qcolor = isReady(0) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.Range,1,qcolor)
	end
	if SyndraMenu.Drawing.DrawR:Value() and myHero:GetSpellData(3).level > 0  then
		local rcolor = isReady(3) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),R.Range,1,rcolor)
	end
	if SyndraMenu.Drawing.DrawE:Value() and myHero:GetSpellData(2).level > 0 then
		local ecolor = isReady(2) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.Range,1,ecolor)
	end
	if SyndraMenu.Drawing.DrawW:Value() and myHero:GetSpellData(1).level > 0 then
		local wcolor = isReady(1) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.Range,1,wcolor)
	end
	
		for i, ball in pairs(Balls) do
			if ball and not ball.dead and SyndraMenu.Drawing.DrawBall:Value() then
				Draw.Circle(ball.pos,80,1, Draw.Color(200, 183, 107, 255))
			else
				Balls[ball.networkID] = nil
			end
		end
	
end)
