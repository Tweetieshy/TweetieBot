Hi,

This is kinda the BETA of my first own script i ever wrote on lua base or even GoS External

Downloadlink: gos://lexraw.githubusercontent.com/Tweetieshy/TweetieBot/master/TweetieBot.lua

newest Readme: https://github.com/Tweetieshy/TweetieBot/blob/master/Readme.txt

The intention of programming the bot was
1. Farming Blue Essence
2. Dont get banned because of intentional feeding or obvious botting

What its not supposed to do:
1. Play better then a player overall
2. Carry games or climb any rank for you


There are some Prerequisites that have to be meet:
Eternal Prediction
ICs Orbwalker (no other will work)
Make sure all configurations in ICs are set and correct (especially hold hotkey)
turn on "center sceen on champion"

Features:
Basic Farming, not great, but sufficient (depends on ICs Orbwalker performance actually)
Autobuy (and check what of that he already has)
Autolevel
Walk to desired lane (configurable)
Trading back when he is able to
Attempting kill and chase when enemy is low
Using Spells for Trading and Kill (not very smart, no combo logic)
Recalling when can buy next major item or is low under tower
He can kite a bit, even tho the logic for that is not very good
He flees from high health champions coming too close, minions that are attacking him or when he drops low (or at least he tries)
Avoids enemy Turrets
Script update speed will take the same frequency as movement delay configured in ICs
He uses summoners in attempt to rescue himself
It is compatible with ExtEvade to a certain degree, but not optimized for it.

Known Flaws:
He does not buy potions, neither use them (not implemented)
Does not know anything about danger zones, he will chase low enemys even when they are protected by other enemys, till he is low himself (or dead)
Does not follow team into teamfights, when they arent happening in his way anyway
Does only know one Itemset yet (configured for ADCs)
He is mostly tested and optimized with ADCs
It can't do Championselect / automatically start games etc, thats a limitation of GoS External i cant change
It cant chat (even tho it was planned) due to API restrictions Feretorix implemented

Missing/Suggested features:
Jungle help at game start if top or bot
Switching lanes automatically
More itemsets for different roles selectable / Itemmanager?
Teamfighting follow


Usage:
On game start the bot is deactivated by default.

Use this time to check your configuration of TweetieBot, especially level up keys etc.
Configure him how he shall level.

Configure the script on/off hotkey, useful to deactivate it fast if something goes wrong or you want take control again for another reason.
If you configured it, use the hotkey to start the bot, keep lol window as active window (GoS Ext doesnt work with lol minimized, you should know that).

Bot now starts to buy and walk to configured lane and... well... does his thing.


