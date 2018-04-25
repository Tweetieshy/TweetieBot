Hi,

This is kinda the BETA of my first own script i ever wrote on lua base or even GoS External

Downloadlink: gos://lexraw.githubusercontent.com/Tweetieshy/TweetieBot/master/TweetieBot.lua

newest Readme: https://github.com/Tweetieshy/TweetieBot/blob/master/Readme.txt


		FAQ

	Whats the intention of this Bot?
		
		1. Farming Blue Essence
		2. Leveling
		3. Afk playing
		4. Dont get banned because of intentional feeding or obvious botting

	What is is NOT supposed to do ?!
		1. Play better then a player overall
		2. Carry games or climb any rank for you


	Are there any prerequisites?		

		Eternal Prediction
		ICs Orbwalker (no other will work)
		Make sure all configurations in ICs are set and correct (especially hold hotkey)


	What are the Fetures implemented?

		Basic Farming, not great, but sufficient (depends on ICs Orbwalker performance actually)
		Autobuy (and check what of that he already has)
		Autolevel with simple configurable Priority
		Walk to desired lane (configurable)
		Trading back when he is able to
		Attempting kill and chase when enemy is low
		Using Spells for Trading and Kill (not very smart, no combo logic)
		Recalling when can buy next major item or is low under tower
		He can kite a bit, even tho the logic for that is not very good
		He flees from high health champions coming too close, minions that are attacking him or when he drops low (or at least he tries)
		Avoids enemy Turrets (most of time)
		Script update speed will take the same frequency as movement delay configured in ICs, i recommend not higher then 250 since its not needed higher and higher frequencies make it maybe more detectable by RIOT while not adding any value.
		He uses summoners in attempt to rescue himself
		It is compatible with ExtEvade to a certain degree, but not optimized for it.


	Any known Flaws / Bugs / Features missing?

		He does not buy potions, neither use them (not implemented)
		Does not know anything about danger zones, he will chase low enemys even when they are protected by other enemys, till he is low himself (or dead)
		Does not follow team into teamfights, when they arent happening in his way anyway
		Does only know one Itemset yet (configured for ADCs)
		It can't do Championselect / automatically start games etc, thats a limitation of GoS External i cant change
		It cant chat (even tho it was planned, and implemented) due to API restrictions Feretorix implemented, functionality has been disabled for stability reasons


	Are there any suggested/planned Features?

		Jungle help at game start if top or bot
		Switching lanes automatically
		More itemsets for different roles selectable / Itemmanager?
		Teamfighting follow


	Are there Features we never gonna see
		
		Even though it's tempting support for Championscripts or AIOs will not be natively supported.
		You can try to deactivate the BOTs own spellcasting and try if it works for you, but its not natively supported and wont be in future as well through complexity reasons and the intention for what the bot was made.
		Which is essence farming, while championscripts are intended to improve gameplay to get ranks, which is not the bots intention.

	On which champs i can use this Bot for?
		
		The bot was intended to be OMNI-Champ, so it should he able to handle every champ.
		Unfortunately this is too complex and too much work to test. I suggest you to just try it out. 
		There is a lane changer inbuilt where you can easily change the lane the bot should play in.
		
		The bot works best with long range Autohitbased ADC (Ashe, Jinx, Caitlyn etc.) and is mostly tested with ADC.
		I encourage you to experiment nevertheless.
		
		As i said i expect best results with ADCs.
		All other long range AP which dont use channeled Q, W or E should work fine too.
		Worst expected performance it with any Melee champ, since the "danger radius" is based on the champs AA range, so melee champions wont recognize being harased by a higher range champion.

	How do I use TweetieBot?

		On game start the bot is deactivated by default.

		Use this time to check your configuration of TweetieBot, especially level up keys etc.
		Configure him how he shall level.

		Configure the script on/off hotkey, useful to deactivate it fast if something goes wrong or you want take control again for another reason.
		If you configured it, use the hotkey to start the bot, keep lol window as active window (GoS Ext doesnt work with lol minimized, you should know that).

		Turn on "center sceen on champion" before you start script.

		Activate the script by pressing the activation Hotkey

		Bot now starts to buy and walk to configured lane and... well... does his thing.

		If you want do something while Bot runs, first deactivate it with the activation Hotkey.

		It is possible to start playing a game normally and after a certain time activating Bot, 
		even though item recognition will not work properly if you didnt follow the buy order of the bot or other strange behaviours may occur, including getting stuck in terrain.

