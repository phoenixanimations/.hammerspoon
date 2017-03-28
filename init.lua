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
-- hs.hotkey.bind({},"1",GetWindow)
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
hs.hints.showTitleThresh = 10
hs.hints.hintChars = {"1", "2", "3", "Q", "W", "E", "A", "S", "D", "Z", "X", "C", "R", "T", "Y", "F", "G", "H", "V", "B", "N", "U", "J", "M", "I", "K"}

----------------------------------------------------------
----------------------------------------------------------
-----------------------Hammerspoon------------------------
----------------------------------------------------------
----------------------------------------------------------
function formatUpToX(s, x, indent)
  x = x or 79
  indent = indent or ""
  local t = {""}
  local function cleanse(s) return s:gsub("@x%d%d%d",""):gsub("@r","") end
  for prefix, word, suffix, newline in s:gmatch("([ \t]*)(%S*)([ \t]*)(\n?)") do
    if #(cleanse(t[#t])) + #prefix + #cleanse(word) > x and #t > 0 then
      table.insert(t, word..suffix) -- add new element
    else -- add to the last element
      t[#t] = t[#t]..prefix..word..suffix
    end
    if #newline > 0 then table.insert(t, "") end
  end
  return indent..table.concat(t, "\n"..indent)
end

function Alert (message, seconds)
	local _seconds = seconds or 2
	hs.alert.show(tostring(formatUpToX(message, 100)),_seconds)
end

function BindAlert (message, seconds)
	return function () Alert(message,seconds) end
end

function Console ()
	hs.toggleConsole()
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
function bindWindowHints (windows,callback,allowNonStandard)
	return function () hs.hints.windowHints(windows,callback,allowNonStandard) end
end

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
	if x == nil then x = Win():frame().x end
	if y == nil then y = Win():frame().y end
	if w == nil then w = Win():frame().w end
	if h == nil then h = Win():frame().h end

	if x == 0 and Win():screen() == hs.screen.primaryScreen() then 
		frame.x = x + ScreenFrame().x - 4
		frame.w = w + 4
	else
		frame.x = x + ScreenFrame().x
		frame.w = w
	end

	frame.y = y + ScreenFrame().y
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

local ResetFullScreenFrame = nil
local ResetFullScreenWindow = nil
function FullScreen ()
	if (Win():frame().w >= ScreenFrame().w) and (Win():frame().h == ScreenFrame().h) and not (ResetFullScreenFrame == nil) and (ResetFullScreenWindow == Win()) then 
		Win():setFrame(ResetFullScreenFrame)
		ResetFullScreenFrame = nil
		ResetFullScreenWindow = nil
		return
	else
		ResetFullScreenWindow = Win()
		ResetFullScreenFrame = Win():frame()
		Adjust(0,0,ScreenFrame().w, ScreenFrame().h)
	end
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
local HeliumWidth = 0
local HeliumHeight = 0
function HeliumAlert (message, time)
	if HeliumDebugState then Alert(message,time) end
end

function HeliumWidthHeight ()
	if HeliumState < 5 then 
		HeliumWidth = 60
		HeliumHeight = 50
	else
		HeliumWidth = 200
		HeliumHeight = 190
	end
end

function HeliumScroll ()
	MouseWheel(-1000,-1000)
	if HeliumState == 1 then MouseWheel(568,406,true) -- Fishing
	elseif HeliumState == 2 then MouseWheel(568,420,true) -- Woodcutting
	elseif HeliumState == 3 then MouseWheel(454,68,true) -- Walking
	elseif HeliumState == 4 then MouseWheel(361,68,true) -- Sailing
	elseif HeliumState == 5 then -- Combat
		MouseWheel(202,122,true)
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
	hs.mouse.setAbsolutePosition(point)
end

-- Bind:
local resetFrame = nil
local previousWindow
local heliumScreenReset = true
function HeliumScreen ()
	LaunchApplication ("Helium")
	local mouse = hs.mouse.getAbsolutePosition()
	if heliumScreenReset then
		resetFrame = Win():frame()
		FullScreen()
		heliumScreenReset = false
	else
		Win():setFrame(resetFrame) 
		MouseFollowsHelium ()
		HeliumScroll ()
		heliumScreenReset = true
	end
	hs.mouse.setAbsolutePosition(mouse)
end

function HeliumFollowsMouse ()
	LaunchApplication ("Helium")
	local point = hs.mouse.getAbsolutePosition()
	HeliumState = HeliumState + 1
	HeliumWidthHeight()
	Adjust (point.x - 30 - ScreenFrame().x,point.y - 30 - ScreenFrame().y,HeliumWidth,HeliumHeight)
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
function Focus (direction, candidate, frontmost, strict)
	return function ()
		if direction == "North" then
			hs.window.filter.defaultCurrentSpace:focusWindowNorth(candidate,frontmost,strict)
		end

		if direction == "South" then
			hs.window.filter.defaultCurrentSpace:focusWindowSouth(candidate,frontmost,strict)
		end

		if direction == "East" then
			hs.window.filter.defaultCurrentSpace:focusWindowEast(candidate,frontmost,strict)
		end
		
		if direction == "West" then
			hs.window.filter.defaultCurrentSpace:focusWindowWest(candidate,frontmost,strict)
		end
	end
end

local setFocusState = {}
local lastWindow = {}
local setAdvanceFocusState = {}
local setAdvanceFocusRectangle = {}
local setAdvanceFocusWindowNumber = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

function AdvanceCustomFocus (i)
	if not (type(setAdvanceFocusState[i]) == type({})) then
		setAdvanceFocusState[i] = {}
		setAdvanceFocusRectangle[i] = {}
	end

	if setAdvanceFocusState[i][setAdvanceFocusWindowNumber[i]] == nil then
		setAdvanceFocusState[i][setAdvanceFocusWindowNumber[i]] = Win()
		setAdvanceFocusRectangle[i][setAdvanceFocusWindowNumber[i]] = Win():frame()
		Alert("Set: " .. tostring("Window ") .. tostring(setAdvanceFocusWindowNumber[i]))
		setAdvanceFocusWindowNumber[i] = setAdvanceFocusWindowNumber[i] + 1
		for num=2, #setAdvanceFocusState[i] do
			if (setAdvanceFocusState[i][1] == Win()) then
				setAdvanceFocusWindowNumber[i] = 1
			end
		end
	else
		for i2=1,#setAdvanceFocusState[i] do
			setAdvanceFocusState[i][i2]:focus()
			setAdvanceFocusState[i][i2]:setFrame(setAdvanceFocusRectangle[i][i2])
		end
	end
end

function CustomFocus (i) 
	if setFocusState[i] == nil then 
		setFocusState[i] = Win()
		lastWindow[i] = Win()
		Alert ("Set: " .. tostring(setFocusState[i]))
	end

	if not (Win() == setFocusState[i]) then 
		lastWindow[i] = Win() 
		setFocusState[i]:focus()

		if not (Win() == setFocusState[i]) then
			lastWindow[i] = nil
			setFocusState[i] = nil
			Alert ("Custom Focused [" .. tostring(i) .. "] is null")
		end
		
	elseif Win() == setFocusState[i] then 
		lastWindow[i]:focus()
	end
end

function LastWindowFocus () 
	hs.window.orderedWindows()[#hs.window.orderedWindows()]:focus()
end

function BindCustomFocus (i)
	return function ()
		CustomFocus(i)
	end
end

function BindAdvanceCustomFocus (i)
	return function ()
		AdvanceCustomFocus(i)
	end 
end

function BindResetFocusState (i)
	return function ()
		setFocusState[i] = nil
		Alert ("Custom Focused [" .. tostring(i) .. "] is null")
	end
end

function BindResetAdvanceFocusState (i)
	return function ()
		setAdvanceFocusState[i] = nil
		setAdvanceFocusRectangle[i] = nil
		setAdvanceFocusWindowNumber[i] = 1
		Alert ("Advance Custom Focused [" .. tostring(i) .. "] is null")
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
	if bluetooth.power() then
		hs.notify.new({title="Bluetooth", informativeText="Bluetooth is enabled", hasActionButton = false}):send()
		Alert("Bluetooth: " .. "is enabled")
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

	if (hour > 12 or hour == 12) then
		hour = hour - 12
		am = "pm"
	end

	if (hour == 12) then
		hour = "00"
	end

	return "Date: " .. os.date("%m/%d/%Y: %A, %B") ..
		   "\nTime: " .. os.date("%I:%M") .. am, 
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
	GetBluetooth()

	local Text = ""

	if hs.battery.isCharging() then 
		if hs.battery.percentage() == 100 then ChargeCondition = "Set me free" end
		ChangeChargeMessage (90,100,"Almost there")
		ChangeChargeMessage (80,90,"Climbing the ladder of success")
		ChangeChargeMessage (50,80,"Climbing the mountain of success")
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
		ChangeChargeMessage (60,80,"What happened? Where am I?")
		ChangeChargeMessage (50,60,"How low can I go?")
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
local MotivationTime = 20

function Motivation ()
	MotivationState = math.random(20)
	if MotivationState == 1 then Alert("Amateurs sit and wait for inspiration, the rest of us just get up and go to work.",MotivationTime)
	elseif MotivationState == 2  then Alert("All men dream, but not equally. Those who dream by night in the dusty recesses of their minds, wake in the day to find that it was vanity: but the dreamers of the day are dangerous men, for they may act on their dreams with open eyes, to make them possible.",MotivationTime)
	elseif MotivationState == 3  then Alert("I cannot remember a night so dark as to have hindered the coming day: nor a storm so furious or dreadful as to prevent the return of warm sunshine and a cloudless sky. But beloved ones do remember that this is not your rest; that in this world you have no abiding place or continuing city. To God and his infinite mercy I always commend you.",MotivationTime)
	elseif MotivationState == 4  then Alert("There is no substitute for hard work.",MotivationTime)
	elseif MotivationState == 5  then Alert("Focused, hard work is the real key to success. Keep your eyes on the goal, and just keep taking the next step towards completing it.",MotivationTime)
	elseif MotivationState == 6  then Alert("You want to know how I did it? This is how I did it, I never saved anything for the swim back.",MotivationTime)
	elseif MotivationState == 7  then Alert("Eighty percent of success is showing up.",MotivationTime)
	elseif MotivationState == 8  then Alert("The best time to plant a tree is 20 years ago. The second best time is now.",MotivationTime)
	elseif MotivationState == 9  then Alert("We don't make movies to make money, we make money to make more movies.",MotivationTime)
	elseif MotivationState == 10 then Alert("A person who chases two rabbits catches neither.",MotivationTime)
	elseif MotivationState == 11 then Alert("If there is no wind, row.",MotivationTime)
	elseif MotivationState == 12 then Alert("Man cannot remake himself without suffering for he is both the marble and the sculptor.",MotivationTime)
	elseif MotivationState == 13 then Alert("A smooth sea never made a skilled sailor.",MotivationTime)
	elseif MotivationState == 14 then Alert("Your future self is watching you right now through your memories.",MotivationTime)
	elseif MotivationState == 15 then Alert("Why worry?  If you have done the very best you can. Worrying won't make it any better. If you want to be successful, respect one rule - never let failure take control of you. Everybody has gone through something that has changed them in a way that they could never go back to the person they once were. Relations are like electric currents, wrong connections will give you shocks throughtout your life, but the right ones will light you up.",MotivationTime)
	elseif MotivationState == 16 then Alert("In '95 I had $7 bucks. By '96 I was wrestling in flea markets for $40 bucks a night (God bless Waffle House).. To #25 on FORBES Top 100 Most Powerful. Some of you out there might be going thru your own '$7 bucks in your pocket' situation.. Embrace the grind, lower your shoulder and keep drivin' thru that motherf*cker. Change will come.",MotivationTime)
	elseif MotivationState == 17 then Alert("There is an art, it says, or rather, a knack to flying. The knack lies in learning how to throw yourself at the ground and miss.",MotivationTime)
	elseif MotivationState == 18 then Alert("It is no coincidence that in no known language does the phrase 'As pretty as an Airport' appear.",MotivationTime)
	elseif MotivationState == 19 then Alert("He felt that his whole life was some kind of dream and he sometimes wondered whose it was and whether they were enjoying it.",MotivationTime)
	elseif MotivationState == 20 then Alert("In my heart I planted a philosophical seed: “what man wills, he can do”… and now I am watering that seed with my endless tears. Wahhhh",MotivationTime)
	else Alert("Woo!")
	end
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

hs.hotkey.bind(cmdAltCtrl,"up",nil,BindHalfWindow(0,0,1,.5))
hs.hotkey.bind(cmdAltCtrl,"down",nil,BindHalfWindow(0,.5,1,.5))
hs.hotkey.bind(cmdAltCtrl,"left",nil,BindHalfWindow(0,0,.5,1))
hs.hotkey.bind(cmdAltCtrl,"right",nil,BindHalfWindow(.5,0,.5,1))

hs.hotkey.bind(shiftCmdAltCtrl,"right",nil,BindFourthWindow(.5,0,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"left",nil,BindFourthWindow(0,.5,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"down",nil,BindFourthWindow(.5,.5,.5,.5))
hs.hotkey.bind(shiftCmdAltCtrl,"up",nil,BindFourthWindow(0,0,.5,.5))

--Transfer Window to monitor
hs.hotkey.bind(cmdAltCtrl,",",BindTransferWindow("West"))
hs.hotkey.bind(cmdAltCtrl,".",BindTransferWindow("East"))

--Nudge
hs.hotkey.bind(cmdAltCtrl,"w",Nudge(0,-20),nil,Nudge(0,-100))
hs.hotkey.bind(cmdAltCtrl,"s",Nudge(0,20),nil,Nudge(0,100))
hs.hotkey.bind(cmdAltCtrl,"a",Nudge(-20,0),nil,Nudge(-100,0))
hs.hotkey.bind(cmdAltCtrl,"d",Nudge(20,0),nil,Nudge(100,0))

hs.hotkey.bind(cmdAltCtrl,"t",Nudge(0,-1),nil,Nudge(0,-5))
hs.hotkey.bind(cmdAltCtrl,"g",Nudge(0,1),nil,Nudge(0,5))
hs.hotkey.bind(cmdAltCtrl,"f",Nudge(-1,0),nil,Nudge(-5,0))
hs.hotkey.bind(cmdAltCtrl,"h",Nudge(1,0),nil,Nudge(5,0))

--Resize
hs.hotkey.bind(shiftCmdAltCtrl,"w",Resize(0,-10),nil,Resize(0,-50))
hs.hotkey.bind(shiftCmdAltCtrl,"s",Resize(0,10),nil,Resize(0,50))
hs.hotkey.bind(shiftCmdAltCtrl,"a",Resize(-10,0),nil,Resize(-50,0))
hs.hotkey.bind(shiftCmdAltCtrl,"d",Resize(10,0),nil,Resize(50,0))

hs.hotkey.bind(shiftCmdAltCtrl,"t",Resize(0,-1),nil,Resize(0,-5))
hs.hotkey.bind(shiftCmdAltCtrl,"g",Resize(0,1),nil,Resize(0,5))
hs.hotkey.bind(shiftCmdAltCtrl,"f",Resize(-1,0),nil,Resize(-5,0))
hs.hotkey.bind(shiftCmdAltCtrl,"h",Resize(1,0),nil,Resize(5,0))

--Focus
hs.hotkey.bind(cmdAltCtrl,"i",Focus("North", nil, true, true))
hs.hotkey.bind(cmdAltCtrl,"k",Focus("South", nil, true, true))
hs.hotkey.bind(cmdAltCtrl,"j",Focus("West", nil, true, true))
hs.hotkey.bind(cmdAltCtrl,"l",Focus("East", nil, true, true))

hs.hotkey.bind(shiftCmdAltCtrl,"i",Focus("North", nil, false, false))
hs.hotkey.bind(shiftCmdAltCtrl,"k",Focus("South", nil, false, false))
hs.hotkey.bind(shiftCmdAltCtrl,"j",Focus("West", nil, false, false))
hs.hotkey.bind(shiftCmdAltCtrl,"l",Focus("East", nil, false, false))

--Custom Focus
hs.hotkey.bind(cmdAltCtrl,"f1",BindAdvanceCustomFocus(1))
hs.hotkey.bind(cmdAltCtrl,"f2",BindAdvanceCustomFocus(2))
hs.hotkey.bind(cmdAltCtrl,"f3",BindAdvanceCustomFocus(3))
hs.hotkey.bind(cmdAltCtrl,"f4",BindAdvanceCustomFocus(4))
hs.hotkey.bind(cmdAltCtrl,"f5",BindAdvanceCustomFocus(5))
hs.hotkey.bind(cmdAltCtrl,"f6",BindAdvanceCustomFocus(6))
hs.hotkey.bind(cmdAltCtrl,"f7",BindAdvanceCustomFocus(7))
hs.hotkey.bind(cmdAltCtrl,"f8",BindAdvanceCustomFocus(8))
hs.hotkey.bind(cmdAltCtrl,"f9",BindAdvanceCustomFocus(9))
hs.hotkey.bind(cmdAltCtrl,"f10",BindAdvanceCustomFocus(10))
hs.hotkey.bind(cmdAltCtrl,"f11",BindAdvanceCustomFocus(11))

hs.hotkey.bind(shiftCmdAltCtrl,"f1",BindResetAdvanceFocusState(1))
hs.hotkey.bind(shiftCmdAltCtrl,"f2",BindResetAdvanceFocusState(2))
hs.hotkey.bind(shiftCmdAltCtrl,"f3",BindResetAdvanceFocusState(3))
hs.hotkey.bind(shiftCmdAltCtrl,"f4",BindResetAdvanceFocusState(4))
hs.hotkey.bind(shiftCmdAltCtrl,"f5",BindResetAdvanceFocusState(5))
hs.hotkey.bind(shiftCmdAltCtrl,"f6",BindResetAdvanceFocusState(6))
hs.hotkey.bind(shiftCmdAltCtrl,"f7",BindResetAdvanceFocusState(7))
hs.hotkey.bind(shiftCmdAltCtrl,"f8",BindResetAdvanceFocusState(8))
hs.hotkey.bind(shiftCmdAltCtrl,"f9",BindResetAdvanceFocusState(9))
hs.hotkey.bind(shiftCmdAltCtrl,"f10",BindResetAdvanceFocusState(10))
hs.hotkey.bind(shiftCmdAltCtrl,"f11",BindResetAdvanceFocusState(11))

hs.hotkey.bind(cmdAltCtrl,"f12",LastWindowFocus)

hs.hotkey.bind(cmdAltCtrl,"e",BindCustomFocus(5),nil,BindResetFocusState(5))
hs.hotkey.bind(shiftCmdAltCtrl,"e",BindCustomFocus(6),nil,BindResetFocusState(6))
hs.hotkey.bind(cmdAltCtrl,"q",BindCustomFocus(7),nil,BindResetFocusState(7))
hs.hotkey.bind(shiftCmdAltCtrl,"q",BindCustomFocus(8),nil,BindResetFocusState(8))

hs.hotkey.bind(cmdAltCtrl,"pad7",BindCustomFocus(9),nil,BindResetFocusState(9))
hs.hotkey.bind(cmdAltCtrl,"pad8",BindCustomFocus(10),nil,BindResetFocusState(10))
hs.hotkey.bind(cmdAltCtrl,"pad9",BindCustomFocus(11),nil,BindResetFocusState(11))
hs.hotkey.bind(cmdAltCtrl,"pad4",BindCustomFocus(12),nil,BindResetFocusState(12))
hs.hotkey.bind(cmdAltCtrl,"pad5",BindCustomFocus(13),nil,BindResetFocusState(13))
hs.hotkey.bind(cmdAltCtrl,"pad6",BindCustomFocus(14),nil,BindResetFocusState(14))
hs.hotkey.bind(cmdAltCtrl,"pad1",BindCustomFocus(15),nil,BindResetFocusState(15))
hs.hotkey.bind(cmdAltCtrl,"pad2",BindCustomFocus(16),nil,BindResetFocusState(16))
hs.hotkey.bind(cmdAltCtrl,"pad3",BindCustomFocus(17),nil,BindResetFocusState(17))
hs.hotkey.bind(cmdAltCtrl,"pad0",BindCustomFocus(18),nil,BindResetFocusState(18))

--Bluetooth
hs.hotkey.bind(cmdAltCtrl,"b", ToggleBluetooth)

--Battery Notification
hs.hotkey.bind({}, "f12", BatteryNotification)
hs.hotkey.bind({"shift"}, "f12", TimeNotification)

--Motivation
hs.hotkey.bind(shiftCmdAltCtrl,"escape",HeliumFollowsMouse,nil,hs.alert.closeAll)
hs.hotkey.bind(cmdAltCtrl,"escape",HeliumScreen,nil,hs.alert.closeAll)

--Mouse
hs.hotkey.bind(cmdAltCtrl, "m", MouseHighlight,nil,ResetMouse(false))
hs.hotkey.bind(shiftCmdAltCtrl, "m", ResetMouse(true))

--Applications 
hs.hotkey.bind(cmdAltCtrl, "p", BindLaunchApplication("Digital Color Meter"))
hs.hotkey.bind(cmdAltCtrl, "\\", BindLaunchApplication("Finder"))
hs.hotkey.bind(cmdAltCtrl, "y", BindLaunchApplication("/Users/Getpeanuts/Library/Services/youtube-dl.app/"))

--Hints
hs.hotkey.bind(cmdAltCtrl, "space", bindWindowHints(nil,nil,true))
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

-- MultipleNewSpaces(3)
GetBluetooth()
Greetings()