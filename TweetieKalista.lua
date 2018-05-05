-- SHAMELESS COPY OF KYPOS AND SIKAKAS SCRIPT :-P

local Heroes = {"Kalista"}
if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require "HPred"

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 24
local barYOffset = -8
local Version,Author,LVersion = "v1.0","Tweetieshy","8.3"
local EDMG = {}

local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
elseif FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'
	PrintChat("Collision library loaded")
end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

---------------------------------------------------------------------------------------
-- Kalista
---------------------------------------------------------------------------------------

class "Kalista"

local HeroIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/aa/KalistaSquare.png"

function Kalista:LoadSpells()

	Q = {Range = 1150, Width = 40, Delay = 0.35, Speed = 1200, Collision = true, aoe = false, Type = "line"}
	E = {Range = 1000, Delay = 0.25}
	R = {Range = 1200, Width = 160, Delay = 1.35, Speed = 2000, Collision = false, aoe = false, Type = "circular"}

end

function Kalista:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Kalista", name = "Tweetieshy's Kalista", leftIcon = HeroIcon})
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Combo:MenuElement({id = "MinionQ", name = "Use Q Minion Combo", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})

	self.Menu:MenuElement({id = "Clear", name = "Clear", type = MENU})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Clear:MenuElement({id = "ECount", name = "Use E on X minions", value = 3, min = 1, max = 7, step = 1})
	self.Menu.Clear:MenuElement({id = "MinionQ", name = "Use Q Minion Combo", value = true})
	self.Menu.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	self.Menu.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})

	self.Menu:MenuElement({id = "isCC", name = "CC Settings", type = MENU})
	self.Menu.isCC:MenuElement({id = "UseQ", name = "Q", value = true})	
	
	self.Menu:MenuElement({id = "Misc", name = "Misc", type = MENU})
	self.Menu.Misc:MenuElement({id = "AutoE", name = "Auto E", value = true})
	self.Menu.Misc:MenuElement({id = "AutoJungleE", name = "Auto E on Jungle and Objectives", value = true})
	self.Menu.Misc:MenuElement({id = "AutoESlow", name = "Auto E for Slows (with resets)", value = true})
	self.Menu.Misc:MenuElement({id = "PrecisionRune", name = "Precision Combat Rune", drop = {"None", "Coup de Grace", "Cut Down", "Last Stand"}})
	-- self.Menu.Misc:MenuElement({id = "QWall", name = "Q Walljump", key = string.byte("T")})


	self.Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	--Q
	self.Menu.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    self.Menu.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	self.Menu.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    self.Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--Q Walljump
	self.Menu.Drawings:MenuElement({id = "WJ", name = "Draw Walljump Circles", type = MENU})
    self.Menu.Drawings.WJ:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.WJ:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.WJ:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	
	self.Menu.Drawings:MenuElement({id = "DrawQMinionCombo", name = "Draw Q Combo on Minion", value = true})
	self.Menu.Drawings:MenuElement({id = "DrawDamage", name = "Draw damage on Champ", value = true})
	self.Menu.Drawings:MenuElement({id = "DrawDamageMinion", name = "Draw damage on Minions", value = true})
    self.Menu.Drawings:MenuElement({id = "HPColor", name = "HP Color", color = Draw.Color(200, 255, 255, 255)})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

local Pos1 ={
Vector(9500,45,2808), Vector(9600,50,3100),
Vector(9322,-71,4508), Vector(9058,52,4634),

Vector(9434,63,2142), Vector(9572,49,2408), 
Vector(8272,51,2908), Vector(8144,52,3160), 
Vector(5874,52,2008), Vector(5766,50,1756), 
Vector(4774,51,3408), Vector(4524,96,3258), 
Vector(2924,96,4608), Vector(3074,96,4558), 
Vector(3168,54,4866), Vector(3024,57,6108), 
Vector(3156,52,6362), Vector(3774,52,7408), 
Vector(3674,52,7706), Vector(2552,52,9188), 
Vector(2874,51,9206), Vector(3242,51,9680), 
Vector(3524,-57,9706), Vector(3274,-65,10306), 
Vector(3074,54,10056), Vector(3322,-65,10174), 
Vector(3774,-6,9156), Vector(4084,-66,9280), 
Vector(5074,-71,10006), Vector(5128,-71,9698), 
Vector(4278,-71,10264), Vector(4474,-71,10456), 
Vector(5724,56,10806), Vector(5478,-71,10658), 
Vector(6024,53,9806), Vector(6054,-48,9492), 
Vector(8608,50,9646), 
Vector(8772,52,9356), Vector(10192,50,9076), 
Vector(10122,52,9356), Vector(10772,63,8506), 
Vector(10608,64,8686), Vector(11222,52,7856), 
Vector(11122,62,8156), Vector(11624,63,8678), 
Vector(11772,50,8856), Vector(11772,54,8106), 
Vector(12072,52,8106), Vector(11094,52,7208), 
Vector(11108,52,7506), Vector(10866,52,7204), 
Vector(10792,52,7484), Vector(11672,52,6508), 
Vector(11638,51,6204), Vector(11972,52,5658), 
Vector(12250,52,5542), Vector(11844,-71,4408), 
Vector(12058,53,4552), Vector(11562,-71,4816), 
Vector(11772,52,4958), Vector(11569,52,5240), 
Vector(11328,-59,5290), Vector(10672,-71,4508), 
Vector(10436,-71,4402), Vector(7280,53,5890), 
Vector(7156,57,5594), Vector(4024,52,6408), 
Vector(4266,52,6230), Vector(3532,51,7012), 
Vector(3548,51,6948), Vector(3674,52,6708), 
Vector(7472,52,6258), Vector(7740,-39,6392), 
Vector(7980,50,5930), Vector(8078,-71,6200), 
Vector(8268,19,5800), Vector(8266,-71,6054), 
Vector(7140,-47,8296), Vector(7322,53,8462), 
Vector(6870,-70,8616), Vector(7106,53,8644), 
Vector(6772,53,8976), Vector(6544,-71,8860),
Vector(12170,91,10240), Vector(12114,57,9980), 
Vector(11556,91,10442), Vector(11574,91,10456), 
Vector(11476,52,10160), Vector(10172,91,12156), 
Vector(9874,54,12128), Vector(10322,93,11606), 
Vector(10022,52,11556), Vector(2688,96,4664), 
Vector(2764,53,4950), Vector(4934,52,2856), Vector(4732,96,2794),
Vector(5002,52,2166), Vector(4748,96,2056),
Vector(7264,52,5900), Vector(7174,58,5608)
}

local Pos2 ={
Vector(8772,52,9356), Vector(10192,50,9076), 
Vector(10122,52,9356), Vector(10772,63,8506), 
Vector(10608,64,8686), Vector(11222,52,7856), 
Vector(11122,62,8156), Vector(11624,63,8678), 
Vector(11772,50,8856), Vector(11772,54,8106), 
Vector(12072,52,8106), Vector(11094,52,7208), 
Vector(11108,52,7506), Vector(10866,52,7204), 
Vector(10792,52,7484), Vector(11672,52,6508), 
Vector(11638,51,6204), Vector(11972,52,5658), 
Vector(12250,52,5542), Vector(11844,-71,4408), 
Vector(12058,53,4552), Vector(11562,-71,4816), 
Vector(11772,52,4958), Vector(11569,52,5240), 
Vector(11328,-59,5290), Vector(10672,-71,4508), 
Vector(10436,-71,4402), Vector(7280,53,5890), 
Vector(7156,57,5594), Vector(4024,52,6408), 
Vector(4266,52,6230), Vector(3532,51,7012), 
Vector(3548,51,6948), Vector(3674,52,6708), 
Vector(7472,52,6258), Vector(7740,-39,6392), 
Vector(7980,50,5930), Vector(8078,-71,6200), 
Vector(8268,19,5800), Vector(8266,-71,6054), 
Vector(7140,-47,8296), Vector(7322,53,8462), 
Vector(6870,-70,8616), Vector(7106,53,8644), 
Vector(6772,53,8976), Vector(6544,-71,8860),
Vector(12170,91,10240), Vector(12114,57,9980), 
Vector(11556,91,10442), Vector(11574,91,10456), 
Vector(11476,52,10160), Vector(10172,91,12156), 
Vector(9874,54,12128), Vector(10322,93,11606), 
Vector(10022,52,11556), Vector(2688,96,4664), 
Vector(2764,53,4950), Vector(4934,52,2856), Vector(4732,96,2794),
Vector(5002,52,2166), Vector(4748,96,2056),
Vector(7264,52,5900), Vector(7174,58,5608)
}

local Pos3 ={
Vector(4266,52,6230), Vector(3532,51,7012), 
Vector(3548,51,6948), Vector(3674,52,6708), 
Vector(7472,52,6258), Vector(7740,-39,6392), 
Vector(7980,50,5930), Vector(8078,-71,6200), 
Vector(8268,19,5800), Vector(8266,-71,6054), 
Vector(7140,-47,8296), Vector(7322,53,8462), 
Vector(6870,-70,8616), Vector(7106,53,8644), 
Vector(6772,53,8976), Vector(6544,-71,8860),
Vector(12170,91,10240), Vector(12114,57,9980), 
Vector(11556,91,10442), Vector(11574,91,10456), 
Vector(11476,52,10160), Vector(10172,91,12156), 
Vector(9874,54,12128), Vector(10322,93,11606), 
Vector(10022,52,11556), Vector(2688,96,4664), 
Vector(2764,53,4950), Vector(4934,52,2856), Vector(4732,96,2794),
Vector(5002,52,2166), Vector(4748,96,2056),
Vector(7064,50,5500), Vector(7820,40,5908)
}

function Kalista:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end	

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function Kalista:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
	if self.Menu.Combo.comboActive:Value() then
		self:Combo()
	end
	if self.Menu.Clear.clearActive:Value() then
		self:Clear()
	end
	if self.Menu.Lasthit.lasthitActive:Value() then
		self:Lasthit()
	end		
	
	-- if self.Menu.Misc.QWall:Value() then
		-- self:CastQWall()
	-- end	
	
	--p-rint(myHero.armorPenPercent .. " X " .. myHero.armorPen .. " X " .. myHero.bonusArmorPenPercent)
		
	
		self:AutoJungleE()
		self:KillstealQ()
		self:AutoE()
		self:ESlow()
		self:SpellonCCQ()
end

function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Kalista:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Q.Range then
        return true
        end
    	end
    	return false
end

function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end

function Kalista:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Kalista:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Kalista:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function EnableMovement()
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Kalista:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 650 then
        return true
        end
    	end
    	return false
end

function Kalista:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Kalista:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

function Kalista:PredDmg(target, damage)

	if target.type == Obj_AI_Hero then
		local PrecisionCombatRune = self.Menu.Misc.PrecisionRune:Value()
		if PrecisionCombatRune == 2 then
			if target.health/target.maxHealth < 0.4 then
				damage = damage * 1.07
			end
		elseif PrecisionCombatRune == 3 then
			local healthdifference = target.maxHealth - myHero.maxHealth
			if healthdifference > 150 then
				amount = amount * (1.04 + math.min(healthdifference-150, 2000) / 20 * 0.0008)
			end
		elseif PrecisionCombatRune == 4 then
			local missinghealth = 1 - myHero.health/myHero.maxHealth
			local calculatebonus = missinghealth < 0.4 and 1 or (1.05 + (math.floor(missinghealth*10 - 4)*0.02))
			damage = damage * (calculatebonus < 1.12 and calculatebonus or 1.11)
		end
	end
	
	for i = 1, myHero.buffCount do 
		local buff = myHero:GetBuff(i)
		damage = self:GetHeroBuffDmgChange(buff,damage)
	end	

	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		damage = self:GetEnemyBuffDmgChange(target,buff,damage)
	end	
	
	return damage
end

function Kalista:GetEnemyBuffDmgChange(target,buff,damage)


	if buff.count <= 0 or buff.duration <= 0 then
		return damage
	end	
		
	if string.find(buff.name:lower(), "presstheattackdamag") then
		return damage*(1.08  + (myHero.levelData.lvl-1)/18 * 0.04)
	end
	
	if (string.find(buff.name:lower(), "boneplating.lua") or string.find(buff.name:lower(), "boneplatingcd.lua") and buff.duration == 0) and target.type == Obj_AI_Hero then
		damage = damage - (20 + (target.levelData.lvl-1)/18 * 30)
	end

	if buff.name:lower() == "ferocioushowl" then
		return damage*(1-(0.55+(target:GetSpellData(_R).level-1)*0.1))
	end
	
	if buff.name:lower() == "dianashield" then
		return damage-(40+(target:GetSpellData(_W).level-1)*15+target.ap*0.3)
	end

	if buff.name:lower() == "rivenfeint" then
		return damage-(95+(target:GetSpellData(_E).level-1)*30+target.bonusDamage)
	end
	
	if buff.name:lower() == "ryzeqshield" then
		return damage-(90+(target:GetSpellData(_Q).level-1)*30+target.ap*0.6+(target.maxMana-800)*0.03) -- roughly
	end
	
	if buff.name:lower() == "sonawshield" then
		return damage-(25+(target:GetSpellData(_W).level-1)*25+target.ap*0.3)
	end
	
	if buff.name:lower() == "udyrturtleactivation" then
		return damage-(60+(target:GetSpellData(_W).level-1)*35+target.ap*0.5)
	end
	
	if buff.name:lower() == "victorpowertransfer" then
		return damage-(23+(target.levelData.lvl-1)*4+target.ap*0.16)
	end
	
	if buff.name:lower() == "viwproc" then
		return damage-(target.maxHealth*0.1					)
	end
	
	if buff.name:lower() == "sionwshieldstacks" then
		return damage-buff.count
	end
	
	if buff.name:lower() == "warwicke" then
		return damage-(1-(0.35+(target:GetSpellData(_E).level-1)*0.05))
	end

	if buff.name:lower() == "taunt" then
		return damage-(1-(0.5)) -- Sry for static value, dont have shen/rammus
	end
	
	if buff.name:lower() == "lissandrarself" then
		return 0
	end
	
	if buff.name:lower() == "undyingrage" then
		return 0
	end
	
	if buff.name:lower() == "kindredrnodeathbuff" then
		return 0
	end

	if buff.name:lower() == "taricr" then
		return 0
	end

	if buff.type == 17 and buff.count > 0 then -- intervention etc
		return 0
	end

	if buff.type == 15 and buff.count > 0 then -- parry etc
		return 0
	end

	if buff.type == 4 and buff.count > 0 then -- sivir spellshield etc
		return 0
	end
	
	if buff.type == 2 and buff.count > 1 then --  general shields
		return damage-buff.count
	end
	
	return damage
end

function Kalista:GetHeroBuffDmgChange(buff,damage)
		
	if buff.count <= 0 or buff.duration <= 0 then
		return damage
	end
	
	-- Exhaust, Press the attack, challenging smite
	if buff.name:lower() == "summonerexhaustdebuff" then
		return damage*0.6
	end
	
	if buff.name:lower() == "itemsmitechallenge" then
		return damage*0.8
	end

	if buff.name:lower() == "itemphantomdancerdebuff" then
		return damage*0.88
	end


		
	return damage
end

-----------------------------
-- DRAWINGS
-----------------------------

function Kalista:Draw()
	if self.Menu.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, Q.Range, self.Menu.Drawings.Q.Width:Value(), self.Menu.Drawings.Q.Color:Value()) end
	if self.Menu.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, E.Range, self.Menu.Drawings.E.Width:Value(), self.Menu.Drawings.E.Color:Value()) end

	
	if self.Menu.Drawings.DrawQMinionCombo:Value() then
		local target = CurrentTarget(Q.Range)
		if target then
			local ThrowOK = nil
			local minionpos = nil
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, false, Q.Type )
			
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				local barPos = minion.hpBar
				if minion and minion.isEnemy and not minion.dead and barPos.onScreen and minion.visible and target.visible and target.hpBar.onScreen then
					local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHero.pos, castpos, minion.pos)
					local linePoint = Vector(pointSegment.x,minion.pos.y,pointSegment.z)
					local w = Q.Width + minion.boundingRadius
						
					if isOnSegment and linePoint:DistanceTo(minion.pos) < w and castpos:DistanceTo(myHero.pos) > minion.pos:DistanceTo(myHero.pos) then
							
						local QDamage = (self:CanCast(_Q) and getdmg("Q",minion,myHero) or 0)
						if HasBuff(minion, "kalistaexpungemarker") and QDamage > minion.health and HitChance > 0.30 then
							if ThrowOK ~= false then 
								minionpos = minion.pos
								ThrowOK = true	
							end
						else
							ThrowOK = false
						end
					end	
				end
			end
			
			if ThrowOK then
				Draw.Circle(minionpos,50,Draw.Color(200,0,255,0))
				Draw.Line(myHero.pos:To2D(), minionpos:To2D(),Draw.Color(200,0,255,0))
				--self:CastSpell(HK_Q, castpos)
			end
		end
	end

	if self.Menu.Drawings.DrawDamage:Value() then
			for i, hero in pairs(self:GetEnemyHeroes()) do
				local barPos = hero.hpBar
				if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
					local EDamage = (self:CanCast(_E) and self:EDMG(hero) or 0)

					if EDamage > 0 then
						local percentage = tostring(0.1*math.floor(1000*EDamage/(hero.health))).."%"
						Draw.Text(percentage,20,hero.pos:To2D())
						--Draw.Text(EDamage,30,(hero.pos - Vector(0,50,0)):To2D())									
					end
					
					if EDamage > hero.health then
						Draw.Text("KILLABLE", 34, hero.pos2D.x, hero.pos2D.y-20,Draw.Color(200,0,255,0))	
					else
						local percentHealthAfterDamage = math.max(0, hero.health - EDamage) / hero.maxHealth
						local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
						local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
						Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, self.Menu.Drawings.HPColor:Value())
					end
				end
			end
	end

	if self.Menu.Drawings.DrawDamageMinion:Value() then
		for i = 1, Game.MinionCount() do
		  local minion = Game.Minion(i)
			local barPos = minion.hpBar
				if minion and minion.isEnemy and not minion.dead and barPos.onScreen and minion.visible then
					local EDamage = (self:CanCast(_E) and self:EDMG(minion) or 0)
					local percentage = tostring(0.1*math.floor(1000*EDamage/(minion.health))).."%"
					if HPred:IsInRange(myHero.pos, minion.pos, E.Range) and HasBuff(minion, "kalistaexpungemarker") then
						Draw.Text(percentage,20,minion.pos:To2D())
						--Draw.Text(EDamage,30,(minion.pos - Vector(0,50,0)):To2D())
					end
				end
		end
	end
				
	if self.Menu.Drawings.WJ.Enabled:Value() then
		for i=1,39,1 do
			if myHero.pos:DistanceTo(Pos1[i]) < 1700 then
				Draw.Circle(Pos1[i],40,self.Menu.Drawings.WJ.Width:Value(), self.Menu.Drawings.WJ.Color:Value())
			else if myHero.pos:DistanceTo(Pos2[i]) < 1700 then
					Draw.Circle(Pos2[i],40,self.Menu.Drawings.WJ.Width:Value(), self.Menu.Drawings.WJ.Color:Value())
				else if myHero.pos:DistanceTo(Pos3[i]) < 1700 then
					Draw.Circle(Pos3[i],40,self.Menu.Drawings.WJ.Width:Value(), self.Menu.Drawings.WJ.Color:Value())
					end
				end
			end
		end
	end

end

function Kalista:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function Kalista:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

-----------------------------
-- BUFFS
-----------------------------

function Kalista:IsImmobileTarget(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24) and buff.count > 0 then
				return true
			end
		end
		return false	
	end
	
function Kalista:EStacks(unit)
	if not unit then return 0 end
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name and buff.name:lower() == "kalistaexpungemarker" and buff.count > 0 and buff.expireTime >= Game.Timer() then
			return buff.count
		end
	end
	return 0
end

function Kalista:EnemyCCD(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and (buff.type == 5 or buff.type == 8 or buff.type == 10 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			return true
		end
	end
	return false
end

-----------------------------
-- COMBO
-----------------------------

function Kalista:MinionQCombo()
	local target = CurrentTarget(Q.Range)
	if target then
		local color = Draw.Color(200,255,0,0)
		local Collisions = 0
		local ThrowOK = nil
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, false, Q.Type )
		
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local barPos = minion.hpBar
			if minion and minion.isEnemy and not minion.dead and barPos.onScreen and minion.visible and target.visible and target.hpBar.onScreen then
				local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHero.pos, castpos, minion.pos)
				local linePoint = Vector(pointSegment.x,minion.pos.y,pointSegment.z)
				local w = Q.Width + minion.boundingRadius
					
				if isOnSegment and linePoint:DistanceTo(minion.pos) < w and castpos:DistanceTo(myHero.pos) > minion.pos:DistanceTo(myHero.pos) and castpos:DistanceTo(minion.pos) < castpos:DistanceTo(myHero.pos) then
						
					local QDamage = (self:CanCast(_Q) and getdmg("Q",minion,myHero) or 0)
					if HasBuff(minion, "kalistaexpungemarker") and QDamage > minion.health and HitChance > 0.30 then
						if ThrowOK ~= false then ThrowOK = true	end
					else
						ThrowOK = false
					end
				end	
			end
		end
		
		if ThrowOK then
			self:CastSpell(HK_Q, castpos)
		end
	end
end

function Kalista:Combo()
	if self.Menu.Combo.MinionQ:Value() then
		self:MinionQCombo()
	end
end

function Kalista:AutoE()
	if not self.Menu.Misc.AutoE:Value() then
		return
	end

	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and isValidTarget(t,E.Range) and self:EDMG(t) >= t.health then
			Control.CastSpell(HK_E)
		end
	end

	if myHero.health < myHero.maxHealth*0.4 then
		HPred:CalculateIncomingDamage()
		if HPred:GetIncomingDamage(myHero) > myHero.health then
			Control.CastSpell(HK_E)
		end
	end

end

function Kalista:AutoJungleE()
	if not self.Menu.Misc.AutoJungleE:Value() then
		return
	end

	for i = 1, Game.MinionCount() do
		local t = Game.Minion(i)
		if t.team == 300 and isValidTarget(t,E.Range) and self:EDMG(t) >= t.health then
			Control.CastSpell(HK_E)
		end
	end
end

function Kalista:ESlow()
	if not 	self.Menu.Misc.AutoESlow:Value() then
		return
	end
	
	local ECastReset = false
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.isEnemy and isValidTarget(minion,E.Range) and HasBuff(minion, "kalistaexpungemarker") then
			local damage = (self:CanCast(_E) and self:EDMG(minion) or 0)
			if damage >= minion.health then
				ECastReset = true
			end
		end
	end
	
	if not ECastReset then
		return
	end

	for i = 1, Game.HeroCount() do
		local t  = Game.Hero(i)
		if isValidTarget(t,E.Range) and t.isEnemy and not self:EnemyCCD(t) and self:EDMG(t) >= 0 and HasBuff(t, "kalistaexpungemarker")then
			Control.CastSpell(HK_E)
			return
		end
	end
	
end

-----------------------------
-- Clear
-----------------------------

function Kalista:Clear()
	if self.Menu.Clear.MinionQ:Value() then
		self:MinionQCombo()
	end

	if self.Menu.Clear.UseQ:Value() and self:CanCast(_Q) then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and not minion.dead and minion.team == 300 or minion.team ~= myHero.team then
				if self:CanCast(_Q) then 
					if self.Menu.Clear.UseQ:Value() and minion then
						if ValidTarget(minion, Q.Range) and myHero.pos:DistanceTo(minion.pos) < Q.Range and not minion.dead then
							local Qdamage = self:QDMG(minion)
							if Qdamage >= self:HpPred(minion,1) + minion.hpRegen * 1 then
								if minion:GetCollision(40, Q.Range, 0.10) - 1 >= 2 then
									self:CastSpell(HK_Q, minion)
								end
							end
						end
					end
				end
			end
		end
	end
	
	local minions = 0
	for i = 1, Game.MinionCount() do
	local m = Game.Minion(i)
		if m.isEnemy and isValidTarget(m,E.Range) then
			if self:EDMG(m) > m.health then
				minions = minions + 1	
			end
			if minions >= self.Menu.Clear.ECount:Value() then
				Control.CastSpell(HK_E)
			end
		end
	end
	
end


-----------------------------
-- LASTHIT
-----------------------------

function Kalista:Lasthit()
	if self:CanCast(_Q) then
		local level = myHero:GetSpellData(_Q).level	
  		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local Qdamage = self:QDMG(minion)
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(minion, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
			if myHero.pos:DistanceTo(minion.pos) < Q.Range and self.Menu.Lasthit.UseQ:Value() and minion.isEnemy and not minion.dead then
				if Qdamage >= self:HpPred(minion,1) and (HitChance > 0 ) then
			    self:CastSpell(HK_Q,castpos)
				end
			end
		end
	end
end

-----------------------------
-- KILLSTEAL
-----------------------------

function Kalista:QDMG(unit)
    local qdamage = getdmg("Q",unit,myHero)
	qdamage = self:PredDmg(unit, qdamage)
	return qdamage
end

function Kalista:EDMG(unit)

	local damage = 0
	if unit and self:EStacks(unit) > 0 and HPred:CanTarget(unit) and HPred:IsInRange(myHero.pos, unit.pos, E.Range) then
		--Calculate the damage to this specific target
		damage = getdmg("E",unit,myHero)
		damage = self:PredDmg(unit, damage)
		
	end
	return damage - 1 -- Better safe then sorry, fend off some rounding errors
end

function isValidTarget(obj,range)
	range = range and range or math.huge
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.pos:DistanceTo(myHero.pos) <= range
end

-----------------------------
-- Q KS
-----------------------------

function Kalista:KillstealQ()
	local target = CurrentTarget(Q.Range)
	if target == nil then return end
	if self.Menu.Killsteal.UseQ:Value() and target and self:CanCast(_Q) then
		if self:EnemyInRange(Q.Range) then 
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		   	local Qdamage = self:QDMG(target)
			if Qdamage >= self:HpPred(target,1) + target.hpRegen * 1 then
			if (HitChance > 0 ) and self:CanCast(_Q) then
			    Control.CastSpell(HK_Q,castpos)
				end
			end
		end
	end
end

-----------------------------
-- Q Spell on CC
-----------------------------

function Kalista:SpellonCCQ()
    local target = CurrentTarget(Q.Range)
	if target == nil then return end
	if self.Menu.isCC.UseQ:Value() and target and self:CanCast(_Q) then
		if self:EnemyInRange(Q.Range) then 
			local ImmobileEnemy = self:IsImmobileTarget(target)
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
			if ImmobileEnemy then
			if (HitChance > 0.30 ) then
			    Control.CastSpell(HK_Q,castpos)
				end
			end
		end
	end
end


Callback.Add("Load",function() _G[myHero.charName]() end)