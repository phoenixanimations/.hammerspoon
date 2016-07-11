-- DEBUG: hs.inspect.inspect
-- For certain apps you could disable keybindings. 
-- for i,v in pairs(t) do print(i,v) end
-- Show only opened applications 
-- Motivation button
--hs.help("")
--Don't forget you have shift + f3 and just f3
--Maybe re add redshift?

spaces = require("hs._asm.undocumented.spaces")
----------------------------------------------------------
----------------------------------------------------------
--------------------------Config--------------------------
----------------------------------------------------------
----------------------------------------------------------
hs.window.animationDuration = 0
hs.window.setFrameCorrectness = false

----------------------------------------------------------
----------------------------------------------------------
-----------------------Hammerspoon------------------------
----------------------------------------------------------
----------------------------------------------------------
function Alert (message)
	hs.alert.show(message)
end

----------------------------------------------------------
----------------------------------------------------------
-------------------------Error----------------------------
----------------------------------------------------------
----------------------------------------------------------
function NullError (object)
	if not object then 
		Alert("Object: " .. tostring(object) .. "is null")
		return true
	end
	return false
end

----------------------------------------------------------
----------------------------------------------------------
--------------------Window Manipulation-------------------
----------------------------------------------------------
----------------------------------------------------------

----------------------------------------------------------
--------------------------Null----------------------------
----------------------------------------------------------
function NullErrorWindow ()
	local win = hs.window.focusedWindow()
	if NullError(win) then return true end
	return false
end

----------------------------------------------------------
--------------------Global Variables----------------------
----------------------------------------------------------
function Win ()
	return hs.window.focusedWindow()
end

function ScreenFrame ()
	return Win():screen():frame()
end

----------------------------------------------------------
-------------------------Size-----------------------------
----------------------------------------------------------
function Adjust (x,y,w,h)
	if NullErrorWindow () then return end
	local frame = Win():frame()

	frame.x = x + ScreenFrame().x
	frame.y = y + ScreenFrame().y
	frame.w = w
	frame.h = h

	Win():setFrame(frame)
end

function SquareWindow (size)
	Adjust (0,
			0,
			ScreenFrame().w * size,
			ScreenFrame().h * size)
	Win():centerOnScreen()
end

----------------------------------------------------------
------------------Size: hs.hotkey.bind--------------------
----------------------------------------------------------
function FullScreen ()
	Adjust (0,0,ScreenFrame().w,ScreenFrame().h)
end

local CenterScreenState = 0
function CenterScreen ()
	if CenterScreenState == 0 then SquareWindow(.5) end
	if CenterScreenState == 1 then SquareWindow(.6) end
	if CenterScreenState == 2 then SquareWindow(.7) end
	if CenterScreenState == 3 then SquareWindow(.8) end
	if CenterScreenState == 4 then SquareWindow(.85) end
	if CenterScreenState == 5 then SquareWindow(.95) end

	CenterScreenState = CenterScreenState + 1
	if CenterScreenState > 6 then CenterScreenState = 0 end
end

function HalfWindow (x,y,w,h)
	return function ()
		Adjust (x * ScreenFrame().w , y * ScreenFrame().h, w * ScreenFrame().w , h * ScreenFrame().h)
	end
end

function FourthWindow (x,y,w,h)
	return HalfWindow (x,y,w,h)
end

----------------------------------------------------------
------------------------Nudge-----------------------------
----------------------------------------------------------
function Nudge (x,y)
	return function ()
		if NullErrorWindow () then return end
		local frame = Win():frame()
		frame.x = frame.x + x
		frame.y = frame.y + y
		Win():setFrame(frame)
		Win():ensureIsInScreenBounds()
	end
end

----------------------------------------------------------
------------------------Focus-----------------------------
----------------------------------------------------------
function Focus (direction)
	return function ()
		if direction == "North" then
			hs.window.filter.defaultCurrentSpace:focusWindowEast(nil,true,true)
		end

		if direction == "South" then
			hs.window.filter.defaultCurrentSpace:focusWindowSouth(nil,true,true)
		end

		if direction == "East" then
			hs.window.filter.defaultCurrentSpace:focusWindowEast(nil,true,true)
		end
		
		if direction == "West" then
			hs.window.filter.defaultCurrentSpace:focusWindowWest(nil,true,true)
		end
	end
end

----------------------------------------------------------
----------------------------------------------------------
-------------------------Spaces---------------------------
----------------------------------------------------------
----------------------------------------------------------
local killallDock = false

function ToggleKillallDock ()
	killallDock = not killallDock 
	hs.alert.show("KillallDock: " .. tostring(killallDock))
end

function LeftSpace ()
	local SpacesArrayLength = #spaces.layout()[spaces.mainScreenUUID()]
	for i = 1,SpacesArrayLength,1
		do
		if spaces.layout()[spaces.mainScreenUUID()][1] == spaces.query(spaces.masks.currentSpaces)[1]
			then hs.alert.show("END") break
		end
		if 	spaces.layout()[spaces.mainScreenUUID()][i] == spaces.query(spaces.masks.currentSpaces)[1]
			then spaces.changeToSpace(spaces.layout()[spaces.mainScreenUUID()][i - 1],killallDock) hs.window.focusedWindow():focusWindowEast() hs.window.focusedWindow():focusWindowWest() break
		end
	end
end

function RightSpace ()
	local SpacesArrayLength = #spaces.layout()[spaces.mainScreenUUID()]
	for i = 1,SpacesArrayLength,1
		do
		if spaces.layout()[spaces.mainScreenUUID()][SpacesArrayLength] == spaces.query(spaces.masks.currentSpaces)[1]
			then hs.alert.show("END") break
		end
		if 	spaces.layout()[spaces.mainScreenUUID()][i] == spaces.query(spaces.masks.currentSpaces)[1]
			then spaces.changeToSpace(spaces.layout()[spaces.mainScreenUUID()][i + 1],killallDock) hs.window.focusedWindow():focusWindowEast() hs.window.focusedWindow():focusWindowWest() break
		end
	end
end

----------------------------------------------------------
----------------------------------------------------------
--------------------------Time----------------------------
----------------------------------------------------------
----------------------------------------------------------
--Maybe have funny comments for day and time. Day changes once a day time changes every hour or something
--Add image support
function AddZero (num)
	if (num < 10) then
		return "0" .. tostring(num)
	else
		return tostring(num) 
	end
end

function Time ()
	local hour = (os.date("*t"))["hour"]
	local min = (os.date("*t"))["min"]
	local day = (os.date("*t"))["day"]
	local month = (os.date("*t"))["month"]
	local year = (os.date("*t"))["year"]
	local am = "am"

	if (hour > 12) then
		hour = hour - 12
		am = "pm"
	end

	return "Date: " .. AddZero(day) .. "." .. AddZero(month) .. "." .. year .. 
		   "\nTime: " .. hour .. ":" .. AddZero(min) .. am, 
		   {hour, min, day, month, year}
end

function TimeNotification ()
	local Subconscious = ""
	local Text = Time () --.. "\n" .. "Subconscious:" .. Subconscious
	hs.notify.new({title="Date & Time", informativeText=Text, hasActionButton = false}):send()
end

----------------------------------------------------------
----------------------------------------------------------
------------------------Battery---------------------------
----------------------------------------------------------
----------------------------------------------------------
local ChargeCondition = ""

function ChangeChargeMessage (a,b, message)
	if hs.battery.percentage() >= a and hs.battery.percentage() < b then ChargeCondition = message end
end

function BatteryNotification () --This should be cleaned up to to a switch case.
	local Text = ""

	if hs.battery.isCharging() then 
		if hs.battery.percentage() == 100 then ChargeCondition = "Set me free" end
		ChangeChargeMessage (90,100,"Almost there")
		ChangeChargeMessage (50,90,"Climbing the mountain of success")
		ChangeChargeMessage (30,50,"Feeling a little better")
        ChangeChargeMessage (20,30,"Started at the bottom, still at the bottom")
		ChangeChargeMessage (10,20,"I saw the tunnel")
		ChangeChargeMessage (0,10,"Jesus that was close")
	end

	if not hs.battery.isCharging() then 
		if hs.battery.percentage() == 100 then ChargeCondition = "Let me be free" end
		ChangeChargeMessage (90,100,"What a nice time I'm having")
		ChangeChargeMessage (88,90,"I don't understand empathy")
		ChangeChargeMessage (80,88,"I found a quarter")
		ChangeChargeMessage (50,80,"How low can I go?")
		ChangeChargeMessage (45,50,"Maybe plug me in for a little bit?")
        ChangeChargeMessage (30,45,"I'm having a good time")
		ChangeChargeMessage (10,30,"Just a flesh wound")
        ChangeChargeMessage (6,10,"Goodbye cruel world")
        ChangeChargeMessage (4,6,"Hello darkness my old friend")
        ChangeChargeMessage (3,4,"Dreams in which I'm dying")
        ChangeChargeMessage (2,3,"Are the best I've ever had")
        ChangeChargeMessage (0,2,"I hope one day I wake up")
	end

    Text =  "Percent: " .. tostring(hs.battery.percentage()) ..
		   "\nCondition: " .. tostring(ChargeCondition)

    hs.notify.new({title="Battery", informativeText=Text, hasActionButton = false}):send()
end

----------------------------------------------------------
----------------------------------------------------------
------------------------New Space-------------------------
----------------------------------------------------------
----------------------------------------------------------
local AddSpace = 0

function NewSpace (Number)
	for i = 1, Number, 1 do
		spaces.createSpace(spaces.mainScreenUUID(), true)
	end
end

function MultipleNewSpaces (Number)
	local FindDesktopSpace = #spaces.layout()[spaces.mainScreenUUID()]

	for i = 1,FindDesktopSpace,1
		do
		local CurrentSpaceID = spaces.spaceType(spaces.layout()[spaces.mainScreenUUID()][i])
		if CurrentSpaceID == 0 then 
			AddSpace = AddSpace + 1
		end
	end

	if (AddSpace < Number) then
		local AmountOfDesktopsToAdd = Number - AddSpace
		NewSpace(AmountOfDesktopsToAdd)
	end
end

----------------------------------------------------------
----------------------------------------------------------
-----------------------Motivation-------------------------
----------------------------------------------------------
----------------------------------------------------------
local MotivationState = 0

function Motivation ()
	if MotivationState == 0 then Alert("hi")
	elseif MotivationState == 1 then Alert("Hello")
	else Alert("what")
	end

	MotivationState = MotivationState + 1
	if MotivationState > 3 then MotivationState = 0 end
end

----------------------------------------------------------
----------------------------------------------------------
----------------------Applescript-------------------------
----------------------------------------------------------
----------------------------------------------------------
local HideUnopenAppsState = true

function HideUnopenApps ()
	if HideUnopenAppsState then 
		Alert ("Dock: Opened Apps")
	else 
		Alert ("Dock: All Apps")
	end

	local applescriptText = ''
	
	if HideUnopenAppsState then
		applescriptText = 'do shell script "defaults write com.apple.dock static-only -bool TRUE && killall Dock"' 
	else 
		applescriptText = 'do shell script "defaults write com.apple.dock static-only -bool FALSE && killall Dock"'
	end
	
	hs.applescript(applescriptText)
	HideUnopenAppsState = not HideUnopenAppsState
end


local ShowAllFilesState = true

function ShowAllFiles ()
	Alert ("Show all files = " .. tostring(ShowAllFilesState))

	local applescriptText = ''

	if ShowAllFilesState then 
		applescriptText = 'do shell script "defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"'
	else
		applescriptText = 'do shell script "defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"'
	end

	hs.applescript(applescriptText)
	ShowAllFilesState = not ShowAllFilesState
end

----------------------------------------------------------
----------------------------------------------------------
----------------------Key Bindings------------------------
----------------------------------------------------------
----------------------------------------------------------
local shiftCmdAltCtrl = {"cmd","alt","ctrl","shift"}
local cmdAltCtrl = {"cmd","alt","ctrl"}

--Hammerspoon
hs.hotkey.bind(cmdAltCtrl,"r",hs.reload)
hs.hotkey.bind(shiftCmdAltCtrl,"r",hs.toggleConsole)

--Window Management
hs.hotkey.bind(cmdAltCtrl,"`",nil,FullScreen)
hs.hotkey.bind(shiftCmdAltCtrl,"`",nil,CenterScreen)

hs.hotkey.bind(cmdAltCtrl,"up",nil,HalfWindow(0,0,1,.5))
hs.hotkey.bind(cmdAltCtrl,"down",nil,HalfWindow(0,.5,1,.5))
hs.hotkey.bind(cmdAltCtrl,"left",nil,HalfWindow(0,0,.5,1))
hs.hotkey.bind(cmdAltCtrl,"right",nil,HalfWindow(.5,0,.5,1))

hs.hotkey.bind(shiftCmdAltCtrl,"right",nil,   FourthWindow(.5,0,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"left",nil, FourthWindow(0,.5,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"down",nil, FourthWindow(.5,.5,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"up",nil,FourthWindow(0,0,.5,.5))

--Nudge
hs.hotkey.bind(cmdAltCtrl,"t",Nudge(0,-10),nil,Nudge(0,-5))
hs.hotkey.bind(cmdAltCtrl,"g",Nudge(0,10),nil,Nudge(0,5))
hs.hotkey.bind(cmdAltCtrl,"f",Nudge(-10,0),nil,Nudge(-5,0))
hs.hotkey.bind(cmdAltCtrl,"h",Nudge(10,0),nil,Nudge(5,0))

hs.hotkey.bind(shiftCmdAltCtrl,"t",Nudge(0,-100),nil,Nudge(0,-20))
hs.hotkey.bind(shiftCmdAltCtrl,"g",Nudge(0,100),nil,Nudge(0,20))
hs.hotkey.bind(shiftCmdAltCtrl,"f",Nudge(-100,0),nil,Nudge(-20,0))
hs.hotkey.bind(shiftCmdAltCtrl,"h",Nudge(100,0),nil,Nudge(20,0))

--Focus
hs.hotkey.bind(cmdAltCtrl,"w",Focus("North"))
hs.hotkey.bind(cmdAltCtrl,"s",Focus("South"))
hs.hotkey.bind(cmdAltCtrl,"a",Focus("West"))
hs.hotkey.bind(cmdAltCtrl,"d",Focus("East"))

--Spaces
hs.hotkey.bind({"ctrl","shift"}, "up", ToggleKillallDock) 
hs.hotkey.bind({"ctrl","shift"},"left", LeftSpace)
hs.hotkey.bind({"ctrl","shift"},"right", RightSpace)

--Battery Notification
hs.hotkey.bind({}, "f12", BatteryNotification)
hs.hotkey.bind({"shift"}, "f12", TimeNotification)

--Motivation
hs.hotkey.bind(cmdAltCtrl,"m",Motivation)

--Applescript
hs.hotkey.bind(cmdAltCtrl,"f3",HideUnopenApps)
hs.hotkey.bind(cmdAltCtrl,"f4",ShowAllFiles)

--Hints
hs.hotkey.bind(cmdAltCtrl, "space", hs.hints.windowHints)

----------------------------------------------------------
----------------------------------------------------------
----------------------At Start Up-------------------------
----------------------------------------------------------
----------------------------------------------------------
function Greetings ()
	local random = math.random(6)
	if random == 0 or random == 1 or random == 2 or random == 3 then Alert ("Ladybug")
	elseif random == 4 then Alert ("Ready to rock")
	elseif random == 5 then Alert ("Good times; keep rollin'")
	else Alert ("Impossible")
	end
end

MultipleNewSpaces(2)
Greetings()