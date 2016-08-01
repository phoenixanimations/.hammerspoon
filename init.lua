-- DEBUG: hs.inspect.inspect
-- For certain apps you could disable keybindings. 
-- for i,v in pairs(t) do print(i,v) end
-- hs.help("")
-- Don't forget you have shift + f1 and just f1
-- Maybe re add redshift?
-- Maybe add in mouse that anything you hover over becomes focused without having to click. 
-- Add quick focus
-- Maybe when you switch to different applications that use f1 the hotkeys change from just f1 to alt+cmd+ctrl + f1 
-- Make your own spaces. 
-- function GetWindow () Alert(Win():application():name()) end
-- hs.hotkey.bind(cmdAltCtrl,"1",GetWindow)
-- Remember the Helium timer effect, you can set a timer to make it so when you hold a key down for a long time it switches states.

spaces = require("hs._asm.undocumented.spaces")
bluetooth = require("hs._asm.undocumented.bluetooth")
----------------------------------------------------------
----------------------------------------------------------
--------------------------Config--------------------------
----------------------------------------------------------
----------------------------------------------------------
hs.window.animationDuration = 0
hs.window.setFrameCorrectness = false
hs.hints.hintChars = {"1", "2", "3", "Q", "W", "E", "A", "S", "D", "Z", "X", "C", "R", "T", "Y", "F", "G", "H", "V", "B", "N", "U", "J", "M", "I", "K"}

----------------------------------------------------------
----------------------------------------------------------
-----------------------Hammerspoon------------------------
----------------------------------------------------------
----------------------------------------------------------
function Alert (message, seconds)
	local _seconds = seconds or 2
	hs.alert.show(tostring(message),_seconds)
end

function BindAlert (message, seconds)
	return function () Alert(message,seconds) end
end

function Console ()
	hs.toggleConsole()
	-- hs.consoleOnTop(true)
end

function Timer (seconds,func)
	hs.timer.doAfter(seconds, func)
end

----------------------------------------------------------
----------------------------------------------------------
-------------------------Error----------------------------
----------------------------------------------------------
----------------------------------------------------------
function NullError (object)
	if object == nil then 
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
	if NullError(win) then 
		Alert("Window doesn't Exist") 
		return true 
	end 

	if Win():application():name() == "Adobe Illustrator CS6"  then
		Alert("Adobe Illustrator CS6 is not supported")
		return true
	end

	if Win():application():name() == "Flash" then 
		Alert("Ahahahaha... Hahaha... Hehehehe...")
		return true
	end

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
	if w == nil then w = Win():frame().w end
	if h == nil then h = Win():frame().h end

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

function FullScreen ()
	Adjust (0,0,ScreenFrame().w,ScreenFrame().h)
end

local CenterScreenState = 0
function CenterScreen ()
	if CenterScreenState == 0 then SquareWindow(.2) end
	if CenterScreenState == 1 then SquareWindow(.5) end
	if CenterScreenState == 2 then SquareWindow(.6) end
	if CenterScreenState == 3 then SquareWindow(.7) end
	if CenterScreenState == 4 then SquareWindow(.8) end
	if CenterScreenState == 5 then SquareWindow(.85) end
	if CenterScreenState == 6 then SquareWindow(.95) end

	CenterScreenState = CenterScreenState + 1
	if CenterScreenState > 7 then 
		CenterScreenState = 0 
		FullScreen()
	end
end

function ResetCenterScreenState ()
	CenterScreenState = 0
	Alert("Center Screen State = 0")
end

function BindHalfWindow (x,y,w,h)
	return function ()
		Adjust (x * ScreenFrame().w , y * ScreenFrame().h, w * ScreenFrame().w , h * ScreenFrame().h)
	end
end

function BindFourthWindow (x,y,w,h)
	return BindHalfWindow (x,y,w,h)
end

----------------------------------------------------------
------------------------Helium----------------------------
------------------------Syrnia----------------------------
----------------------------------------------------------
local HeliumState = 0
local HeliumDebugState = false

function HeliumAlert (message, time)
	if HeliumDebugState then Alert(message,time) end
end

function HeliumScroll ()
	HeliumState = HeliumState + 1
	MouseWheel(-1000,-1000)
	if HeliumState == 1 then MouseWheel(568,406,true) -- Fishing
	elseif HeliumState == 2 then MouseWheel(568,420,true) -- Woodcutting
	elseif HeliumState == 3 then MouseWheel(454,68,true) -- Walking
	elseif HeliumState == 4 then MouseWheel(360,68,true) -- Sailing
	else
		HeliumState = 0
		HeliumAlert ("Reset")
	end	
	HeliumAlert (HeliumState)
end

function MouseFollowsHelium ()
	local point = {}
	LaunchApplication ("Helium")
	
	point["x"] = Win():frame().x + 20
	point["y"] = Win():frame().y + 30
	hs.mouse.set(point)
end

-- Bind:
function HeliumResetScreenScroll (windowFrame)
	return function () 
		Win():setFrame(windowFrame) 
		MouseFollowsHelium ()
		MouseWheel(568,406,true)
	end
end

function HeliumScreen ()
	LaunchApplication ("Helium")
	local windowFrame = Win():frame()

	if (windowFrame.w == 60) and (windowFrame.h == 50) then
		FullScreen()
		Alert ("0")
		hs.timer.doAfter(1, BindAlert("1"))
		hs.timer.doAfter(2, BindAlert("2"))
		hs.timer.doAfter(3, BindAlert("3"))
		hs.timer.doAfter(4, BindAlert("END"))
		hs.timer.doAfter(6, HeliumResetScreenScroll(windowFrame))
	else
		Alert("Press cmd + alt + ctrl + esc") 
	end
	
end

function HeliumFollowsMouse ()
	LaunchApplication ("Helium")
	local point = hs.mouse.getAbsolutePosition()
	Adjust (point.x - 30 - ScreenFrame().x,point.y - 30 - ScreenFrame().y,60,50)
	HeliumScroll ()
end

----------------------------------------------------------
---------------------Swap Windows-------------------------
----------------------------------------------------------
local window = {}
local changeWindow = 1

function SetWindows ()
	window[changeWindow] = Win ()
	Alert("Window " .. tostring(changeWindow) .. " = " .. tostring(window[changeWindow]))
	
	changeWindow = changeWindow + 1
	if changeWindow > 2 then changeWindow = 1 end
end

function SwapWindows ()
	if not (window[1] == nil) and not (window[2] == nil) and not (window[1] == window[2]) then 
		local tempFrame = window[1]:frame()
		window[1]:setFrame(window[2]:frame())
		window[2]:setFrame(tempFrame)
		window[1]:focus()
		window[2]:focus()
	else
		if (window[1] == window[2]) then Alert("Window 1 == Window 2") end
		if (window[1] == nil) then Alert("Window 1 is Null") end
		if (window[2] == nil) then Alert("Window 2 is Null") end
	end
end

----------------------------------------------------------
--------Transfer Windows to Different Monitor-------------
----------------------------------------------------------
function TransferWindow (direction)
	if direction == "Right" or direction == "East" then Win():moveOneScreenEast(false,true) end
	if direction == "Left" or direction == "West" then Win():moveOneScreenWest(false,true)  end
end

function BindTransferWindow (direction)
	return function ()
		TransferWindow(direction)
	end
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

function Resize (w,h)
	return function ()
		if NullErrorWindow () then return end
		local frame = Win():frame()
		frame.w = frame.w + w
		frame.h = frame.h + h
		Win():setFrame(frame)
	end
end

----------------------------------------------------------
------------------------Focus-----------------------------
----------------------------------------------------------
function Focus (direction)
	return function ()
		if direction == "North" then
			hs.window.filter.defaultCurrentSpace:focusWindowNorth(nil,true,true)
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

local setFocusState = {}
local lastWindow = {}

function CustomFocus (i) 
	if setFocusState[i] == nil then 
		setFocusState[i] = Win()
		lastWindow[i] = Win()
		Alert ("Set: " .. tostring(setFocusState[i]))
	end

	if not (Win() == setFocusState[i]) then 
		lastWindow[i] = Win() 
		setFocusState[i]:focus()
		
	elseif Win() == setFocusState[i] then 
		lastWindow[i]:focus()
	end
end

function BindCustomFocus (i)
	return function ()
		CustomFocus(i)
	end
end

function BindResetFocusState (i)
	return function ()
		setFocusState[i] = nil
		Alert ("Custom Focused [" .. tostring(i) .. "] is null")
	end
end

----------------------------------------------------------
----------------------------------------------------------
---------------------Mouse Manipulation-------------------
----------------------------------------------------------
----------------------------------------------------------
function MoveMouse (x,y,absolute)
	mouse = {}
	mouse["x"] = x
	mouse["y"] = y
	if absolute == nil then absolute = false end
	if absolute then 
		hs.mouse.setAbsolutePosition(mouse)
	else
		hs.mouse.setRelativePosition(mouse)
	end
end

function MouseWheel (x,y,unit,mods)
	if mods == nil then mods = {} end
	if unit == nil then unit = "line" end
	if unit == true then unit = "pixel" else unit = "line" end
	hs.eventtap.event.newScrollEvent({-x,0},mods,unit):post()
	hs.eventtap.event.newScrollEvent({0,-y},mods,unit):post()
end

----------------------------------------------------------
-------------------Circle around Mouse--------------------
----------------------------------------------------------
--------------Taken from Hammerspoon docs-----------------
----------------------------------------------------------
--Rewrite so circle follows mouse change shape/color of circle/square 
local mouseCircle = nil
local mouseCircleTimer = nil

function MouseHighlight()
	if mouseCircle then 
		mouseCircle:delete()
		if mouseCircleTimer then 
			mouseCircleTimer:stop()
		end
	end
	mousepoint = hs.mouse.getAbsolutePosition()
	mouseCircle = hs.drawing.circle(
		hs.geometry.rect(mousepoint.x - 40, mousepoint.y - 40, 80, 80))
	mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
	mouseCircle:setFill(false)
	mouseCircle:setStrokeWidth(5)
	mouseCircle:show()

	mouseCircleTimer = hs.timer.doAfter(3, function () mouseCircle:delete() end)
end

----------------------------------------------------------
-------------------------Reset Mouse----------------------
----------------------------------------------------------
function ResetMouse (absolute)
	return function ()
		MoveMouse(ScreenFrame().w * .5, ScreenFrame ().h * .5,absolute)
		MouseHighlight()
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
------------------------New Space-------------------------
----------------------------------------------------------
function NewSpace (Number)
	for i = 1, Number, 1 do
		spaces.createSpace(spaces.mainScreenUUID(), true)
	end
end

function MultipleNewSpaces (Number)
	local AddSpace = 0

	if spaces.layout()[spaces.mainScreenUUID()] == nil then 
		hs.notify.new({title="Spaces", informativeText="Function MultipleNewSpaces: spaces.layout()[...] == nil", hasActionButton = false}):send()
		return 
	end

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
-------------------------Bluetooth------------------------
----------------------------------------------------------
----------------------------------------------------------
function ToggleBluetooth ()
	local bluetoothPower = bluetooth.power()
	bluetooth.power(not bluetoothPower)
	Alert ("Bluetooth: " .. tostring(bluetooth.power()))
end

function GetBluetooth ()
	Alert("Bluetooth: " .. tostring(bluetooth.power()))
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

	if (hour > 12 or hour == 12) then
		hour = hour - 12
		am = "pm"
	end

	if (hour == 12) then
		hour = "00"
	end

	return "Date: " .. AddZero(month) .. "/" .. AddZero(day) .. "/" .. year .. 
		   "\nTime: " .. hour .. ":" .. AddZero(min) .. " " .. am, 
		   {hour, min, day, month, year}
end

function TimeNotification ()
	local Subconscious = ""
	local Text = Time () --.. "\n" .. "Subconscious:" .. Subconscious
	hs.notify.new({title="Date & Time", informativeText=Text, hasActionButton = false}):send() --:setIdImage("/Users/Getpeanuts/Desktop/icon.png")
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
-----------------------Motivation-------------------------
----------------------------------------------------------
----------------------------------------------------------
local MotivationState = 0

function Motivation ()
	if MotivationState == 0 then Alert("Amateurs sit and wait for inspiration, the rest of us just get up and go to work.",360)
	elseif MotivationState == 1 then Alert("All men dream, but not equally. Those who dream by night in the dusty recesses of their minds, \nwake in the day to find that it was vanity: but the dreamers of the day are dangerous men, \nfor they may act on their dreams with open eyes, to make them possible.",360)
	elseif MotivationState == 2 then Alert("I cannot remember a night so dark as to have hindered the coming day: \nnor a storm so furious or dreadful as to prevent the return of warm sunshine and a cloudless sky. \nBut beloved ones do remember that this is not your rest; that in this world you have no abiding place or continuing city. \nTo God and his infinite mercy I always commend you.",360)
	elseif MotivationState == 3 then Alert("There is no substitute for hard work.",360)
	elseif MotivationState == 4 then Alert("Focused, hard work is the real key to success. \nKeep your eyes on the goal, and \njust keep taking the next step towards completing it.",360)
	elseif MotivationState == 5 then Alert("Opportunities are usually disguised as hard work, \nso most people don't recognize them.",360)
	elseif MotivationState == 6 then Alert("It's hard to beat a person who never gives up.",360)
	elseif MotivationState == 7 then Alert("The mind is everything. What you think you become.",360)
	elseif MotivationState == 8 then Alert("Eighty percent of success is showing up.",360)
	elseif MotivationState == 9 then Alert("Fall seven times and stand up eight.",360)
	elseif MotivationState == 10 then Alert("The best time to plant a tree is 20 years ago. \nThe second best time is now.",360)
	elseif MotivationState == 11 then Alert("We don't make movies to make money, \nwe make money to make more movies.",360)
	elseif MotivationState == 12 then Alert("A person who chases two rabbits catches neither.",360)
	elseif MotivationState == 13 then Alert("Inspiration exists, but it has to find you working.",360)
	elseif MotivationState == 14 then Alert("If there is no wind, row.",360)
	elseif MotivationState == 15 then Alert("Man cannot remake himself without suffering for he is both the marble and the sculptor.",360)
	elseif MotivationState == 16 then Alert("A smooth sea never made a skilled sailor.",360)
	elseif MotivationState == 17 then Alert("Your future self is watching you right now through your memories.",360)
	elseif MotivationState == 18 then Alert("Why worry?  If you have done the very best you can. Worrying won't make it any better. \nIf you want to be successful, respect one rule - never let failure take control of you. \nEverybody has gone through something that has changed them in a way\n that they could never go back to the person they once were.\n Relations are like electric currents, wrong connections will give you shocks throughtout your life, \nbut the right ones will light you up.",360)
	elseif MotivationState == 19 then Alert("In '95 I had $7 bucks. By '96 I was wrestling in flea markets for $40 bucks a night (God bless Waffle House).. \nTo #25 on FORBES Top 100 Most Powerful. \nSome of you out there might be going thru your own '$7 bucks in your pocket' situation..\n Embrace the grind, lower your shoulder and keep drivin' thru that motherf*cker. \nChange will come.",360)
	elseif MotivationState == 20 then Alert("There is an art, it says, or rather, a knack to flying. \nThe knack lies in learning how to throw yourself at the ground and miss.",360)
	elseif MotivationState == 21 then Alert("It is no coincidence that in no known language does the phrase 'As pretty as an Airport' appear.",360)
	elseif MotivationState == 22 then Alert("He felt that his whole life was some kind of dream \nand he sometimes wondered whose it was and whether they were enjoying it.",360)
	else Alert("Woo!")
	end

	MotivationState = math.random(22)
end

----------------------------------------------------------
----------------------------------------------------------
----------------------Applescript-------------------------
----------------------------------------------------------
----------------------------------------------------------
local HideUnopenAppsState = false

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
-----------------------Applications-----------------------
----------------------------------------------------------
function LaunchApplication (application)
	local applescriptText = 'tell application "' .. application .. '" to activate' 
	hs.applescript(applescriptText)
end

function BindLaunchApplication (application)
	return function () 
		LaunchApplication(application)
	end
end

----------------------------------------------------------
------------------Multiple Applications-------------------
----------------------------------------------------------
function LoadMultipleApps (Applications)
	if type(Applications) == not "table" then 
		Alert("Error: LoadMultipleApps, Applications not a 'table'")
		return
	end

	local SpaceState = 1
	local NumberOfSpaces = #Applications + 1

	while SpaceState < NumberOfSpaces do
		LaunchApplication (Applications[SpaceState])
		SpaceState = SpaceState + 1
	end
end

function AutoSortApps ()
	local SpaceState = 1
	local NumberOfSpaces = #hs.window.orderedWindows()
	local WindowState = #hs.window.orderedWindows()
	local WindowTable = hs.window.orderedWindows()
	if WindowState > 15 then Alert("Can't auto sort more than 15 windows") return end

	MultipleNewSpaces(NumberOfSpaces)

	while SpaceState < NumberOfSpaces + 1 do
		WindowTable[WindowState]:spacesMoveTo(spaces.layout()[spaces.mainScreenUUID()][SpaceState])
		SpaceState = SpaceState + 1
		WindowState = WindowState - 1
	end
	Alert("Auto Sort: Complete")	
end

function BindLoadMultipleApps (Applications)
	return function ()
		LoadMultipleApps(Applications)
	end
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
hs.hotkey.bind(shiftCmdAltCtrl,"r",Console)

--Window Management
hs.hotkey.bind(cmdAltCtrl,"`",nil,FullScreen)
hs.hotkey.bind(shiftCmdAltCtrl,"`",nil,CenterScreen,ResetCenterScreenState)
hs.hotkey.bind(cmdAltCtrl,"escape",HeliumFollowsMouse,nil,nil) --HeliumScrollDebug)
hs.hotkey.bind(shiftCmdAltCtrl,"escape",HeliumScreen,nil,nil) --HeliumScrollDebug)

hs.hotkey.bind(cmdAltCtrl,"up",nil,BindHalfWindow(0,0,1,.5))
hs.hotkey.bind(cmdAltCtrl,"down",nil,BindHalfWindow(0,.5,1,.5))
hs.hotkey.bind(cmdAltCtrl,"left",nil,BindHalfWindow(0,0,.5,1))
hs.hotkey.bind(cmdAltCtrl,"right",nil,BindHalfWindow(.5,0,.5,1))

hs.hotkey.bind(shiftCmdAltCtrl,"right",nil,BindFourthWindow(.5,0,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"left",nil,BindFourthWindow(0,.5,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"down",nil,BindFourthWindow(.5,.5,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"up",nil,BindFourthWindow(0,0,.5,.5))

--Swap Windows
hs.hotkey.bind(cmdAltCtrl,"tab",SwapWindows)
hs.hotkey.bind(shiftCmdAltCtrl,"tab",SetWindows)

--Transfer Window to monitor
hs.hotkey.bind(cmdAltCtrl,",",BindTransferWindow("West"))
hs.hotkey.bind(cmdAltCtrl,".",BindTransferWindow("East"))

--Nudge
hs.hotkey.bind(cmdAltCtrl,"t",Nudge(0,-10),nil,Nudge(0,-5))
hs.hotkey.bind(cmdAltCtrl,"g",Nudge(0,10),nil,Nudge(0,5))
hs.hotkey.bind(cmdAltCtrl,"f",Nudge(-10,0),nil,Nudge(-5,0))
hs.hotkey.bind(cmdAltCtrl,"h",Nudge(10,0),nil,Nudge(5,0))

hs.hotkey.bind(shiftCmdAltCtrl,"t",Nudge(0,-100),nil,Nudge(0,-20))
hs.hotkey.bind(shiftCmdAltCtrl,"g",Nudge(0,100),nil,Nudge(0,20))
hs.hotkey.bind(shiftCmdAltCtrl,"f",Nudge(-100,0),nil,Nudge(-20,0))
hs.hotkey.bind(shiftCmdAltCtrl,"h",Nudge(100,0),nil,Nudge(20,0))

--Resize
hs.hotkey.bind(shiftCmdAltCtrl,"w",Resize(0,-10),nil,Resize(0,-50))
hs.hotkey.bind(shiftCmdAltCtrl,"s",Resize(0,10),nil,Resize(0,50))
hs.hotkey.bind(shiftCmdAltCtrl,"a",Resize(-10,0),nil,Resize(-50,0))
hs.hotkey.bind(shiftCmdAltCtrl,"d",Resize(10,0),nil,Resize(50,0))

--Focus
hs.hotkey.bind(cmdAltCtrl,"w",Focus("North"))
hs.hotkey.bind(cmdAltCtrl,"s",Focus("South"))
hs.hotkey.bind(cmdAltCtrl,"a",Focus("West"))
hs.hotkey.bind(cmdAltCtrl,"d",Focus("East"))

--Custom Focus
hs.hotkey.bind(cmdAltCtrl,"e",BindCustomFocus(1),nil,BindResetFocusState(1))
hs.hotkey.bind(cmdAltCtrl,"f1",BindCustomFocus(2),nil,BindResetFocusState(2))
hs.hotkey.bind(cmdAltCtrl,"f2",BindCustomFocus(3),nil,BindResetFocusState(3))
hs.hotkey.bind(shiftCmdAltCtrl,"e",BindCustomFocus(4),nil,BindResetFocusState(4))

--Spaces
hs.hotkey.bind({"ctrl","shift"}, "up", ToggleKillallDock) 
hs.hotkey.bind({"ctrl","shift"},"left", LeftSpace)
hs.hotkey.bind({"ctrl","shift"},"right", RightSpace)

--Bluetooth
hs.hotkey.bind(cmdAltCtrl,"b", ToggleBluetooth)

--Battery Notification
hs.hotkey.bind({}, "f12", BatteryNotification)
hs.hotkey.bind({"shift"}, "f12", TimeNotification)

--Motivation
hs.hotkey.bind(shiftCmdAltCtrl,"f12",Motivation,nil,hs.alert.closeAll)
hs.hotkey.bind(cmdAltCtrl,"f12",Motivation,nil,hs.alert.closeAll)

--Applescript
hs.hotkey.bind(cmdAltCtrl,"f3",HideUnopenApps)
hs.hotkey.bind(cmdAltCtrl,"f4",ShowAllFiles)

--Mouse
hs.hotkey.bind(cmdAltCtrl, "m", MouseHighlight,nil,ResetMouse(false))
hs.hotkey.bind(shiftCmdAltCtrl, "m", ResetMouse(true))

--Applications 
hs.hotkey.bind(cmdAltCtrl, "-", BindLaunchApplication("Adobe Illustrator"))
hs.hotkey.bind(cmdAltCtrl, "=", BindLaunchApplication("Adobe After Effects CS6"))
hs.hotkey.bind(cmdAltCtrl, "\\", BindLaunchApplication("Finder"))
hs.hotkey.bind(cmdAltCtrl, "[", BindLaunchApplication("StoryMill"))
hs.hotkey.bind(cmdAltCtrl, "]", BindLaunchApplication("SourceTree"))
hs.hotkey.bind(cmdAltCtrl, ";", BindLaunchApplication("iTunes"))
hs.hotkey.bind(cmdAltCtrl, "'", BindLaunchApplication("Maya"))

--Load Multiple Applications
local ApplicationTable = {"Adobe Illustrator","Adobe After Effects CS6","Preview","StoryMill","HyperPlan","SourceTree","iTunes","iTunes Alarm","Activity Monitor","Time Sink"}
hs.hotkey.bind(cmdAltCtrl, "delete", BindLoadMultipleApps(ApplicationTable))
hs.hotkey.bind(shiftCmdAltCtrl, "delete", AutoSortApps)

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

MultipleNewSpaces(3)
GetBluetooth()
Greetings()