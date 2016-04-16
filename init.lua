--Import:
spaces = require("hs._asm.undocumented.spaces")
--Configs:
hs.window.animationDuration = 0

--iPad
local function duet (watcher)
	if watcher.productName == "iPad" and watcher.eventType == "added" then
		hs.application.open("duet")
	end 

	if watcher.productName == "iPad" and watcher.eventType == "removed" then 
		if hs.application.get("duet") ~= nil then
			hs.application.get("duet"):kill()
		end	
	end
end

hs.usb.watcher.new(duet):start()

--iTunes
local iTunesHotKeysOn = false
hs.hotkey.bind({"ctrl","alt","cmd"},"m", function ()
	iTunesHotKeysOn = not iTunesHotKeysOn
    hs.alert.show("iTunes Hotkeys: "..tostring(iTunesHotKeysOn))
	end)

hs.hotkey.bind({},"f8", function ()
	if (iTunesHotKeysOn) then
		hs.itunes.playpause()
	end
end)

--Window management:
local function Adjust(x, y, w, h)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local max = win:screen():frame()

    f.w = math.floor(max.w * w)
    f.h = math.floor(max.h * h)
    f.x = math.floor((max.w * x) + max.x)
    f.y = math.floor((max.h * y) + max.y)

    win:setFrame(f)
  end
end

local function AdjustCenterTop(w, h, y)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local max = win:screen():frame()

    f.w = math.floor(max.w * w)
    f.h = math.floor(max.h * h)
    f.x = math.floor((max.w / 2) - (f.w / 2))
    f.y = max.y + y
    win:setFrame(f)
  end
end

local function SetWindow (w,h,x,y)
	return function ()
	    local win = hs.window.focusedWindow()
	    if not win then return end
	    local f = win:frame()
	    f.w = w
	    f.h = h
	    f.x = x
	    f.y = y
	    win:setFrame(f)
	end
end

-- top half
hs.hotkey.bind({"ctrl","alt","cmd"}, "up", Adjust(0, 0, 1, 0.5))

-- right half
hs.hotkey.bind({"ctrl","alt","cmd"}, "right", Adjust(0.5, 0, 0.5, 1))

-- bottom half
hs.hotkey.bind({"ctrl","alt","cmd"}, "down", Adjust(0, 0.5, 1, 0.5))

-- left half
hs.hotkey.bind({"ctrl","alt","cmd"}, "left", Adjust(0, 0, 0.5, 1))

-- top left
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "up", Adjust(0, 0, 0.5, 0.5))

-- top right
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "right", Adjust(0.5, 0, 0.5, 0.5))

-- bottom right
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "down", Adjust(0.5, 0.5, 0.5, 0.5))

-- bottom left
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "left", Adjust(0, 0.5, 0.5, 0.5))

-- fullscreen
hs.hotkey.bind({"ctrl","alt","cmd"}, "1", AdjustCenterTop(.5, .5,200))
hs.hotkey.bind({"ctrl","alt","cmd"}, "2", AdjustCenterTop(.75, .75,120))
hs.hotkey.bind({"ctrl","alt","cmd"}, "3", SetWindow(1024,768,200,70))
hs.hotkey.bind({"ctrl","alt","cmd"}, "4", AdjustCenterTop(1, 1,0))

--Nudge Mode by Mattvh:
--http://github.com/mattvh
hs.hotkey.bind({"ctrl","alt","cmd"}, "n", function ()
    local mode = hs.hotkey.modal.new({"ctrl","alt","cmd"}, "n")
    local modeUIOutline = {}


    --
    -- Enter mode
    --
    function mode:entered()
        hs.alert.show('Nudge Mode: On')
        local screens = hs.screen.allScreens()
        for index, screen in pairs(screens) do
            local id = screen:id()
            modeUIOutline[id] = hs.drawing.rectangle(screen:frame())
            modeUIOutline[id]:setStrokeColor({["red"]=155,["blue"]=193,["green"]=226,["alpha"]=0.8})
            modeUIOutline[id]:setFill(false)
            modeUIOutline[id]:setStrokeWidth(3)
            modeUIOutline[id]:show()
        end
    end


    --
    -- Exit mode
    --
    function mode:exited()
        for id, outline in pairs(modeUIOutline) do
            outline:delete()
            modeUIOutline[id] = nil
        end
        hs.alert.show('Nudge Mode: Off')
    end


    --
    -- Nudge windows
    --
    function nudge(x, y)

        local s = hs.screen.mainScreen():frame()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        -- Update window frame
        f.x = f.x + x
        f.y = f.y + y

        -- Apply changes and snap the window to screen edges
        win:setFrame(f)
        win:ensureIsInScreenBounds()

    end


    --
    -- Resize windows
    --
    function resize(x, y)
        local win = hs.window.focusedWindow()
        local f = win:frame()
        f.w = f.w + x
        f.h = f.h + y
        win:setFrame(f)
    end

    --
    -- Keybinds
    --
    mode:bind({}, 'escape', function() mode:exit() end)
    mode:bind({}, 'return', function() mode:exit() end)
    mode:bind({}, 'space', function() mode:exit() end)
    
    mode:bind({'ctrl','alt','shift'}, 'left',  function() nudge(-5, 0) end)
    mode:bind({'ctrl','alt','shift'}, 'right', function() nudge(5, 0) end)
    mode:bind({'ctrl','alt','shift'}, 'up',    function() nudge(0, -5) end)
    mode:bind({'ctrl','alt','shift'}, 'down',  function() nudge(0, 5) end)

    mode:bind({'ctrl','alt'}, 'left', function() nudge(-50, 0) end)
    mode:bind({'ctrl','alt'}, 'right', function() nudge(50, 0) end)
    mode:bind({'ctrl','alt'}, 'up', function() nudge(0, -50) end)
    mode:bind({'ctrl','alt'}, 'down', function() nudge(0, 50) end)
 	
 	mode:bind({'alt'}, 'left',  function() resize(-50, 0) end)
    mode:bind({'alt'}, 'right', function() resize(50, 0) end)
    mode:bind({'alt'}, 'up',    function() resize(0, -50) end)
    mode:bind({'alt'}, 'down',  function() resize(0, 50) end)

    mode:bind({'alt','shift'}, 'left',  function() resize(-25, 0) end)
    mode:bind({'alt','shift'}, 'right', function() resize(25, 0) end)
    mode:bind({'alt','shift'}, 'up',    function() resize(0, -25) end)
    mode:bind({'alt','shift'}, 'down',  function() resize(0, 25) end)

    mode:bind({'alt','cmd'}, 'up', function() hs.window.focusedWindow():focusWindowNorth() end)
    mode:bind({'alt','cmd'}, 'down', function() hs.window.focusedWindow():focusWindowSouth() end)
    mode:bind({'alt','cmd'}, 'right', function()  hs.window.focusedWindow():focusWindowEast() end)
    mode:bind({'alt','cmd'}, 'left', function() hs.window.focusedWindow():focusWindowWest() end)

end)

-- Focus windows:
local function focus(direction)
  local fn = "focusWindow" .. (direction:gsub("^%l", string.upper))

  return function()
    local win = hs.window:focusedWindow()
    if not win then return end

    win[fn]()
  end
end

hs.hotkey.bind({"ctrl","alt","cmd"}, "w", focus("north"))
hs.hotkey.bind({"ctrl","alt","cmd"}, "d", focus("east"))
hs.hotkey.bind({"ctrl","alt","cmd"}, "s", focus("south"))
hs.hotkey.bind({"ctrl","alt","cmd"}, "a", focus("west"))

--Grid:
hs.hotkey.bind({"ctrl","alt","cmd"}, "space", function () 
	hs.hints.windowHints()
end)

--Battery:
function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end


hs.hotkey.bind({"ctrl","alt","cmd"}, "b", function ()
    hs.alert.show(
        "Percent: " .. tostring(hs.battery.percentage()) ..
        "\nTime Remaining: " .. "Hours: " .. round(hs.battery.timeRemaining()/60,2) ..
        "\nCondition: " .. tostring(hs.battery.health()) ..
        "\nVolts: " .. tostring(hs.battery.voltage()) .. 
        "\nWalts: " .. tostring(hs.battery.watts())) 
    hs.notify.new({title="Battery", informativeText="Percent: ",soundName = "Glass.aiff", hasActionButton = false})
	end)

local Text = ""
local ChargeCondition = ""

function ChangeChargeMessage (a,b, message)
	if hs.battery.percentage() >= a and hs.battery.percentage() < b then ChargeCondition = message end
end

hs.hotkey.bind({}, "f12", function () 	

	if hs.battery.isCharging() then 
		if hs.battery.percentage() == 100 then ChargeCondition = "Set me free" end
		ChangeChargeMessage (90,100,"Almost there")
		ChangeChargeMessage (50,90,"Climbing to the top")
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

    Text = "Percent: " .. tostring(hs.battery.percentage()) ..
		   "\nCondition: " .. tostring(ChargeCondition)

    hs.notify.new({title="Battery", informativeText=Text, hasActionButton = false}):send()
    end)

--------------------------------------------------
-- Handler directly called by the "low-level" watcher API. marksantcroos 
--------------------------------------------------
pct_prev = nil
function batt_watch_low()
    pct = hs.battery.percentage()
    if pct ~= pct_prev and not hs.battery.isCharging() and pct < 30 then
        hs.alert.show(string.format(
        "Plug-in the power, only %d%% left!!", pct))
    end
    pct_prev = pct
end
--------------------------------------------------

hs.battery.watcher.new(batt_watch_low):start()

--Spaces:
local killallDock = false

hs.hotkey.bind({"ctrl","alt","cmd"}, "delete", function () killallDock = not killallDock hs.alert.show("KillallDock: " .. tostring(killallDock))
 end) 
hs.hotkey.bind({"ctrl","shift"},"left", function () 
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

end)

hs.hotkey.bind({"ctrl","shift"},"right", function ()
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
end)

-- Move Window to Assigned Space
hs.hotkey.bind({"ctrl","alt","cmd"},"f3", function ()



end) 

-- Load Desktops: 
local AddSpace = 0

function CreateMultipleSpaces (Number)
	for i = 1, Number, 1 do
		spaces.createSpace(spaces.mainScreenUUID(), true)
	end
end

function LoadDesktops (Number)
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
		CreateMultipleSpaces(AmountOfDesktopsToAdd)
	end
end

function LoadFourDesktops ()
	LoadDesktops(2)
end

-- Redshift:
local wfRedshift=hs.window.filter.new({VLC={focused=true},Photos={focused=true},loginwindow={visible=true,allowRoles='*'}},'wf-redshift')
local IsRedshiftOn = true
hs.hotkey.bind({"ctrl","alt","cmd"},'f1',function () 
        IsRedshiftOn = not IsRedshiftOn     
        if (IsRedshiftOn)
            then hs.redshift.start(2800,'21:00','7:00','4h',false,wfRedshift)
        else  hs.redshift.stop()
        end
        hs.alert.show('Redshift: '..tostring(IsRedshiftOn)) 
end)

-- Reload Hammerspoon:
hs.hotkey.bind({"ctrl","alt","cmd"},"R", function()
	hs.reload()
end)

--Auto Load: 
LoadFourDesktops()
hs.alert.show("Ready to rock")