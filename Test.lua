-- MacOS-Style GUI Library for Roblox (single-file)
-- Version: 1.0.0
-- Author: Generated
-- Notes: ดีไซน์แนว macOS — titlebar, traffic lights, rounded corners, shadow, draggable (mobile+PC)
-- Usage:
-- local MacLib = loadstring(game:HttpGet("INSERT_RAW_URL_TO_THIS_FILE"))()
-- local win = MacLib:CreateWindow({Title = "My App", Size = UDim2.new(0,400,0,260)})
-- win:AddLabel("Hello world")
-- win:AddButton("Click me", function() print("clicked") end)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local MacLib = {}
MacLib.__index = MacLib

-- defaults
local DEFAULT_WINDOW_SIZE = UDim2.new(0,420,0,280)
local DEFAULT_BG_COLOR = Color3.fromRGB(242,242,247) -- light mac background
local TITLEBAR_HEIGHT = 36
local CORNER_RADIUS = 12

-- helper
local function round(n) return math.floor(n+.5) end
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function createCorner(uix, radius)
    -- Roblox doesn't have direct corner objects in all clients; use UIStroke/Corner for supported
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = uix
    return corner
end

local function makeShadow(parent)
    -- simple shadow using ImageLabel with blur-like PNG might be better, but we use a semi-transparent frame
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5,0.5)
    shadow.Size = UDim2.new(1,24,1,24)
    shadow.Position = UDim2.new(0.5,0.5,0.5,0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Parent = parent
    local sCorner = createCorner(shadow, CORNER_RADIUS+6)
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, -24, 1, -24)
    inner.Position = UDim2.new(0,12,0,12)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel = 0
    inner.Parent = shadow
    return shadow
end

local function tween(obj, props, time, style, direction)
    local info = TweenInfo.new(time or 0.18, Enum.EasingStyle[style or "Quad"], Enum.EasingDirection[direction or "Out"])
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- Root GUI
local function getOrCreateScreenGui(name)
    local player = game:GetService("Players").LocalPlayer
    local gui = player:FindFirstChildOfClass("PlayerGui")
    local root = gui:FindFirstChild(name)
    if root then return root end
    root = Instance.new("ScreenGui")
    root.Name = name
    root.ResetOnSpawn = false
    root.Parent = gui
    return root
end

-- Save & load positions (simple, stores in file if available)
local function savePosition(key, data)
    pcall(function()
        if writefile then
            writefile("maclib_"..key..".json", HttpService:JSONEncode(data))
        end
    end)
end
local function loadPosition(key)
    local ok, out = pcall(function()
        if isfile and isfile("maclib_"..key..".json") then
            return HttpService:JSONDecode(readfile("maclib_"..key..".json"))
        end
    end)
    return out
end

-- Window class
local Window = {}
Window.__index = Window

function Window:MakeDraggable(wrap, handle)
    handle = handle or wrap
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        wrap.Position = newPos
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = wrap.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Window:SetPosition(pos)
    if typeof(pos) == "UDim2" then
        self.Frame.Position = pos
        savePosition(self._saveKey or self.Title, {X = pos.X.Offset, Y = pos.Y.Offset})
    end
end

function Window:AddLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -24, 0, 22)
    lbl.Position = UDim2.new(0,12,0,60 + (#self._children*28))
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(30,30,30)
    lbl.Parent = self.Content
    table.insert(self._children, lbl)
    return lbl
end

function Window:AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Size = UDim2.new(1, -24, 0, 34)
    btn.Position = UDim2.new(0,12,0,60 + (#self._children*40))
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    createCorner(btn, 8)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(20,20,20)
    btn.Parent = self.Content
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
        tween(btn, {BackgroundColor3 = Color3.fromRGB(240,240,245)}, 0.06, "Quad", "Out")
        wait(0.06)
        tween(btn, {BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.12, "Quad", "Out")
    end)
    table.insert(self._children, btn)
    return btn
end

function Window:AddToggle(text, default, callback)
    default = default or false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 34)
    frame.Position = UDim2.new(0,12,0,60 + (#self._children*40))
    frame.BackgroundTransparency = 1
    frame.Parent = self.Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(30,30,30)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local togg = Instance.new("TextButton")
    togg.Size = UDim2.new(0,44,0,24)
    togg.Position = UDim2.new(1,-44,0,5)
    togg.AnchorPoint = Vector2.new(1,0)
    togg.BackgroundColor3 = Color3.fromRGB(230,230,235)
    togg.BorderSizePixel = 0
    createCorner(togg, 12)
    togg.Parent = frame

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,18,0,18)
    dot.Position = UDim2.new(default and 1 or 0, (default and -20) or 4, 0, 3)
    dot.BackgroundColor3 = default and Color3.fromRGB(80,200,120) or Color3.fromRGB(255,255,255)
    dot.BorderSizePixel = 0
    createCorner(dot, 9)
    dot.Parent = togg

    local state = default
    local function setState(v)
        state = v
        if state then
            tween(dot, {Position = UDim2.new(1, -20, 0, 3)}, 0.14)
            dot.BackgroundColor3 = Color3.fromRGB(80,200,120)
            togg.BackgroundColor3 = Color3.fromRGB(200,245,210)
        else
            tween(dot, {Position = UDim2.new(0,4,0,3)}, 0.14)
            dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            togg.BackgroundColor3 = Color3.fromRGB(230,230,235)
        end
        pcall(callback, state)
    end

    togg.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    setState(default)
    table.insert(self._children, frame)
    return frame
end

function Window:AddSlider(text, min, max, default, callback)
    min = min or 0; max = max or 100; default = default or min
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 48)
    frame.Position = UDim2.new(0,12,0,60 + (#self._children*52))
    frame.BackgroundTransparency = 1
    frame.Parent = self.Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,18)
    label.BackgroundTransparency = 1
    label.Text = text .. "  " .. tostring(default)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(30,30,30)
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,12)
    bar.Position = UDim2.new(0,0,0,24)
    bar.BackgroundColor3 = Color3.fromRGB(235,235,240)
    bar.BorderSizePixel = 0
    createCorner(bar, 6)
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max-min),0,1,0)
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = Color3.fromRGB(80,150,255)
    createCorner(fill, 6)
    fill.Parent = bar

    local dragging = false
    local function setVal(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local val = min + rel*(max-min)
        fill.Size = UDim2.new(rel,0,1,0)
        label.Text = text .. "  " .. math.floor(val)
        pcall(callback, val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setVal(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setVal(input.Position.X)
        end
    end)

    table.insert(self._children, frame)
    return frame
end

function Window:AddDropdown(title, values, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 34)
    frame.Position = UDim2.new(0,12,0,60 + (#self._children*40))
    frame.BackgroundTransparency = 1
    frame.Parent = self.Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(30,30,30)
    label.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0.4,0,1,0)
    box.Position = UDim2.new(1,-box.Size.X.Offset,0,0)
    box.AnchorPoint = Vector2.new(1,0)
    box.Text = "Select"
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.BackgroundColor3 = Color3.fromRGB(255,255,255)
    box.BorderSizePixel = 0
    createCorner(box, 8)
    box.Parent = frame

    local listOpen = false
    local listFrame
    local function openList()
        if listOpen then return end
        listOpen = true
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0, box.AbsoluteSize.X, 0, math.min(#values*28, 200))
        listFrame.Position = box.AbsolutePosition + Vector2.new(0, box.AbsoluteSize.Y + 6)
        listFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
        listFrame.BorderSizePixel = 0
        createCorner(listFrame, 10)
        listFrame.Parent = self.Root

        for i,v in ipairs(values) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1,0,0,28)
            item.Position = UDim2.new(0,0,0,(i-1)*28)
            item.Text = v
            item.Font = Enum.Font.Gotham
            item.TextSize = 13
            item.BackgroundTransparency = 1
            item.Parent = listFrame
            item.MouseButton1Click:Connect(function()
                box.Text = v
                pcall(callback, v)
                listFrame:Destroy()
                listOpen = false
            end)
        end
    end

    box.MouseButton1Click:Connect(openList)
    table.insert(self._children, frame)
    return frame
end

-- constructor
function MacLib:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "App"
    local size = opts.Size or DEFAULT_WINDOW_SIZE
    local saveKey = opts.SaveKey or title

    local root = getOrCreateScreenGui("MacLibRoot")

    local main = Instance.new("Frame")
    main.Name = title:gsub("%s+","_")
    main.Size = size
    main.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    main.AnchorPoint = Vector2.new(0,0)
    main.BackgroundColor3 = DEFAULT_BG_COLOR
    main.BorderSizePixel = 0
    main.ZIndex = 10
    main.Parent = root

    createCorner(main, CORNER_RADIUS)

    -- shadow
    local shadow = makeShadow(main)
    shadow.ZIndex = main.ZIndex - 1

    -- Titlebar
    local titlebar = Instance.new("Frame")
    titlebar.Size = UDim2.new(1,0,0,TITLEBAR_HEIGHT)
    titlebar.Position = UDim2.new(0,0,0,0)
    titlebar.BackgroundTransparency = 1
    titlebar.BorderSizePixel = 0
    titlebar.Parent = main

    local tbLabel = Instance.new("TextLabel")
    tbLabel.Size = UDim2.new(1,0,1,0)
    tbLabel.BackgroundTransparency = 1
    tbLabel.Text = title
    tbLabel.Font = Enum.Font.GothamSemibold
    tbLabel.TextSize = 15
    tbLabel.TextColor3 = Color3.fromRGB(25,25,25)
    tbLabel.Parent = titlebar

    -- traffic lights
    local lights = Instance.new("Frame")
    lights.Size = UDim2.new(0,80,0,20)
    lights.Position = UDim2.new(0,12,0,8)
    lights.BackgroundTransparency = 1
    lights.Parent = titlebar

    local function makeLight(col)
        local l = Instance.new("Frame")
        l.Size = UDim2.new(0,14,0,14)
        l.BackgroundColor3 = col
        l.BorderSizePixel = 0
        createCorner(l, 8)
        return l
    end

    local closeB = makeLight(Color3.fromRGB(255,95,86))
    closeB.Parent = lights
    closeB.Position = UDim2.new(0,0,0,0)

    local miniB = makeLight(Color3.fromRGB(255,189,46))
    miniB.Parent = lights
    miniB.Position = UDim2.new(0,20,0,0)

    local maxB = makeLight(Color3.fromRGB(39,201,63))
    maxB.Parent = lights
    maxB.Position = UDim2.new(0,40,0,0)

    -- content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,1, -TITLEBAR_HEIGHT)
    content.Position = UDim2.new(0,0,0,TITLEBAR_HEIGHT)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- scrolling container (in case of overflow)
    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0,8)
    uiList.Parent = content

    -- store
    local selfWin = setmetatable({}, Window)
    selfWin.Frame = main
    selfWin.Title = title
    selfWin.Content = content
    selfWin.Root = root
    selfWin._children = {}
    selfWin._saveKey = saveKey

    -- draggable
    -- allow dragging from titlebar
    selfWin:MakeDraggable(main, titlebar)

    -- traffic lights behaviors
    closeB.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            main:Destroy()
        end
    end)
    miniB.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(main, {Size = UDim2.new(0,200,0,40)}, 0.18)
            wait(0.9)
            if main and main.Destroy then main:Destroy() end
        end
    end)
    maxB.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local scr = root.AbsoluteSize
            tween(main, {Position = UDim2.new(0.5, -main.AbsoluteSize.X/2, 0.5, -main.AbsoluteSize.Y/2)}, 0.18)
        end
    end)

    -- persist position if possible
    local stored = loadPosition(saveKey)
    if stored and stored.X and stored.Y then
        local pos = UDim2.new(0, stored.X, 0, stored.Y)
        main.Position = pos
    end

    -- expose API
    function selfWin:Close()
        if main then main:Destroy() end
    end
    function selfWin:SetPositionManual(x,y)
        main.Position = UDim2.new(0, x, 0, y)
        savePosition(saveKey, {X = x, Y = y})
    end

    -- convenience builders
    function selfWin:AddLabel(text) return Window.AddLabel(selfWin, text) end
    function selfWin:AddButton(text, cb) return Window.AddButton(selfWin, text, cb) end
    function selfWin:AddToggle(text, def, cb) return Window.AddToggle(selfWin, text, def, cb) end
    function selfWin:AddSlider(t,min,max,def,cb) return Window.AddSlider(selfWin,t,min,max,def,cb) end
    function selfWin:AddDropdown(t,vals,cb) return Window.AddDropdown(selfWin,t,vals,cb) end

    return selfWin
end

-- convenience: quick window
function MacLib:Window(opts)
    return self:CreateWindow(opts)
end

return setmetatable(MacLib, {__call = function(_,...) return MacLib:CreateWindow(...) end})
