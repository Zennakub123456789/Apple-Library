--[[
    macOS Style UI Library for Roblox - Complete Edition
    สร้างโดย: Replit Agent
    ใช้สำหรับ: Roblox Executor GUI
    สไตล์: macOS Sequoia Inspired
    
    Features:
    - Window, Tabs, Notifications
    - Button, Toggle, Slider, Dropdown
    - TextInput, Keybind, ColorPicker
    - Label, Paragraph, Image, Divider
    - Configuration Saving/Loading
]]

local MacOSLib = {}
MacOSLib.__index = MacOSLib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Configuration Storage
MacOSLib.ConfigFolder = "MacOSLibConfig"
MacOSLib.Flags = {}

-- สีและธีมของ macOS
MacOSLib.Theme = {
    Background = Color3.fromRGB(236, 236, 236),
    SidebarBackground = Color3.fromRGB(220, 220, 220),
    ContentBackground = Color3.fromRGB(255, 255, 255),
    
    CloseButton = Color3.fromRGB(255, 95, 87),
    MinimizeButton = Color3.fromRGB(255, 189, 68),
    MaximizeButton = Color3.fromRGB(40, 201, 64),
    
    PrimaryText = Color3.fromRGB(30, 30, 30),
    SecondaryText = Color3.fromRGB(120, 120, 120),
    
    AccentBlue = Color3.fromRGB(0, 122, 255),
    AccentBlueHover = Color3.fromRGB(10, 132, 255),
    
    Border = Color3.fromRGB(200, 200, 200),
    DividerLine = Color3.fromRGB(210, 210, 210),
}

local function addCorner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = element
    return corner
end

local function addPadding(element, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = element
    return padding
end

function MacOSLib:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "macOS Window"
    local windowSize = config.Size or UDim2.new(0, 900, 0, 600)
    local configFileName = config.ConfigFileName or nil
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MacOSLibrary"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui
    
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = windowSize
    mainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    mainWindow.BackgroundColor3 = MacOSLib.Theme.Background
    mainWindow.BorderSizePixel = 0
    mainWindow.Parent = screenGui
    addCorner(mainWindow, 12)
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = 0
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Parent = mainWindow
    
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 240, 1, 0)
    sidebar.BackgroundColor3 = MacOSLib.Theme.SidebarBackground
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainWindow
    
    local sidebarHeader = Instance.new("Frame")
    sidebarHeader.Name = "SidebarHeader"
    sidebarHeader.Size = UDim2.new(1, 0, 0, 52)
    sidebarHeader.BackgroundColor3 = MacOSLib.Theme.SidebarBackground
    sidebarHeader.BorderSizePixel = 0
    sidebarHeader.Parent = sidebar
    
    local sidebarHeaderCorner = Instance.new("UICorner")
    sidebarHeaderCorner.CornerRadius = UDim.new(0, 12)
    sidebarHeaderCorner.Parent = sidebarHeader
    
    local sidebarHeaderCover = Instance.new("Frame")
    sidebarHeaderCover.Size = UDim2.new(1, 0, 0, 12)
    sidebarHeaderCover.Position = UDim2.new(0, 0, 1, -12)
    sidebarHeaderCover.BackgroundColor3 = MacOSLib.Theme.SidebarBackground
    sidebarHeaderCover.BorderSizePixel = 0
    sidebarHeaderCover.Parent = sidebarHeader
    
    local trafficLightsContainer = Instance.new("Frame")
    trafficLightsContainer.Name = "TrafficLights"
    trafficLightsContainer.Size = UDim2.new(0, 70, 0, 20)
    trafficLightsContainer.Position = UDim2.new(0, 12, 0, 16)
    trafficLightsContainer.BackgroundTransparency = 1
    trafficLightsContainer.Parent = sidebarHeader
    
    local trafficButtons = {
        {Name = "Close", Color = MacOSLib.Theme.CloseButton, Position = 0},
        {Name = "Minimize", Color = MacOSLib.Theme.MinimizeButton, Position = 20},
        {Name = "Maximize", Color = MacOSLib.Theme.MaximizeButton, Position = 40}
    }
    
    for _, btn in ipairs(trafficButtons) do
        local button = Instance.new("TextButton")
        button.Name = btn.Name
        button.Size = UDim2.new(0, 12, 0, 12)
        button.Position = UDim2.new(0, btn.Position, 0, 4)
        button.BackgroundColor3 = btn.Color
        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        button.Parent = trafficLightsContainer
        addCorner(button, 6)
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
                math.min(255, btn.Color.R * 255 + 20),
                math.min(255, btn.Color.G * 255 + 20),
                math.min(255, btn.Color.B * 255 + 20)
            )}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = btn.Color}):Play()
        end)
        
        if btn.Name == "Close" then
            button.MouseButton1Click:Connect(function()
                screenGui:Destroy()
            end)
        elseif btn.Name == "Minimize" then
            button.MouseButton1Click:Connect(function()
                mainWindow.Visible = not mainWindow.Visible
            end)
        end
    end
    
    local contentColumn = Instance.new("Frame")
    contentColumn.Name = "ContentColumn"
    contentColumn.Size = UDim2.new(1, -240, 1, 0)
    contentColumn.Position = UDim2.new(0, 240, 0, 0)
    contentColumn.BackgroundColor3 = MacOSLib.Theme.ContentBackground
    contentColumn.BorderSizePixel = 0
    contentColumn.Parent = mainWindow
    
    local contentHeader = Instance.new("Frame")
    contentHeader.Name = "ContentHeader"
    contentHeader.Size = UDim2.new(1, 0, 0, 52)
    contentHeader.BackgroundColor3 = MacOSLib.Theme.ContentBackground
    contentHeader.BorderSizePixel = 0
    contentHeader.Parent = contentColumn
    
    local contentHeaderCorner = Instance.new("UICorner")
    contentHeaderCorner.CornerRadius = UDim.new(0, 12)
    contentHeaderCorner.Parent = contentHeader
    
    local contentHeaderCover = Instance.new("Frame")
    contentHeaderCover.Size = UDim2.new(1, 0, 0, 12)
    contentHeaderCover.Position = UDim2.new(0, 0, 1, -12)
    contentHeaderCover.BackgroundColor3 = MacOSLib.Theme.ContentBackground
    contentHeaderCover.BorderSizePixel = 0
    contentHeaderCover.Parent = contentHeader
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = MacOSLib.Theme.PrimaryText
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = contentHeader
    
    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Name = "SidebarScroll"
    sidebarScroll.Size = UDim2.new(1, 0, 1, -52)
    sidebarScroll.Position = UDim2.new(0, 0, 0, 52)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.BorderSizePixel = 0
    sidebarScroll.ScrollBarThickness = 4
    sidebarScroll.ScrollBarImageColor3 = MacOSLib.Theme.Border
    sidebarScroll.Parent = sidebar
    addPadding(sidebarScroll, 8, 8, 12, 12)
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0, 4)
    sidebarList.Parent = sidebarScroll
    
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "ContentScroll"
    contentScroll.Size = UDim2.new(1, 0, 1, -52)
    contentScroll.Position = UDim2.new(0, 0, 0, 52)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 6
    contentScroll.ScrollBarImageColor3 = MacOSLib.Theme.Border
    contentScroll.Parent = contentColumn
    addPadding(contentScroll, 24, 24, 24, 24)
    
    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 16)
    contentList.Parent = contentScroll
    
    local dragging = false
    local dragInput, mousePos, framePos
    
    local function setupDragging(element)
        element.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = mainWindow.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        element.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
    end
    
    setupDragging(sidebarHeader)
    setupDragging(contentHeader)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            mainWindow.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    sidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, sidebarList.AbsoluteContentSize.Y + 24)
    end)
    
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 48)
    end)
    
    local WindowAPI = {
        ScreenGui = screenGui,
        MainWindow = mainWindow,
        Sidebar = sidebarScroll,
        ContentArea = contentScroll,
        TitleLabel = titleLabel,
        ConfigFileName = configFileName,
        Tabs = {}
    }
    
    function WindowAPI:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or "rbxassetid://0"
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentScroll
        
        local tabList = Instance.new("UIListLayout")
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Padding = UDim.new(0, 16)
        tabList.Parent = tabContent
        
        tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, tabList.AbsoluteContentSize.Y + 48)
        end)
        
        local sidebarItem = MacOSLib:CreateSidebarItem(sidebarScroll, {
            Text = tabName,
            Icon = tabIcon,
            Callback = function()
                for _, tab in pairs(WindowAPI.Tabs) do
                    tab.Content.Visible = false
                end
                tabContent.Visible = true
                titleLabel.Text = tabName
            end
        })
        
        if #WindowAPI.Tabs == 0 then
            tabContent.Visible = true
            titleLabel.Text = tabName
            sidebarItem:Select()
        end
        
        local TabAPI = {
            Content = tabContent,
            SidebarItem = sidebarItem
        }
        
        function TabAPI:AddButton(config)
            return MacOSLib:CreateButton(tabContent, config)
        end
        
        function TabAPI:AddToggle(config)
            return MacOSLib:CreateToggle(tabContent, config)
        end
        
        function TabAPI:AddSlider(config)
            return MacOSLib:CreateSlider(tabContent, config)
        end
        
        function TabAPI:AddTextInput(config)
            return MacOSLib:CreateTextInput(tabContent, config)
        end
        
        function TabAPI:AddDropdown(config)
            return MacOSLib:CreateDropdown(tabContent, config)
        end
        
        function TabAPI:AddKeybind(config)
            return MacOSLib:CreateKeybind(tabContent, config)
        end
        
        function TabAPI:AddColorPicker(config)
            return MacOSLib:CreateColorPicker(tabContent, config)
        end
        
        function TabAPI:AddLabel(config)
            return MacOSLib:CreateLabel(tabContent, config)
        end
        
        function TabAPI:AddParagraph(config)
            return MacOSLib:CreateParagraph(tabContent, config)
        end
        
        function TabAPI:AddImage(config)
            return MacOSLib:CreateImage(tabContent, config)
        end
        
        function TabAPI:AddDivider()
            return MacOSLib:CreateDivider(tabContent)
        end
        
        function TabAPI:AddSection(title)
            return MacOSLib:CreateSectionHeader(tabContent, title)
        end
        
        table.insert(WindowAPI.Tabs, TabAPI)
        return TabAPI
    end
    
    function WindowAPI:Notify(config)
        return MacOSLib:Notify(config)
    end
    
    function WindowAPI:SaveConfig()
        if not WindowAPI.ConfigFileName then return end
        
        local configData = {}
        for flag, value in pairs(MacOSLib.Flags) do
            configData[flag] = value
        end
        
        local success, result = pcall(function()
            writefile(MacOSLib.ConfigFolder .. "/" .. WindowAPI.ConfigFileName .. ".json", 
                HttpService:JSONEncode(configData))
        end)
        
        if success then
            MacOSLib:Notify({
                Title = "Configuration Saved",
                Content = "Settings saved successfully!",
                Duration = 3
            })
        end
    end
    
    function WindowAPI:LoadConfig()
        if not WindowAPI.ConfigFileName then return end
        
        local success, result = pcall(function()
            return readfile(MacOSLib.ConfigFolder .. "/" .. WindowAPI.ConfigFileName .. ".json")
        end)
        
        if success and result then
            local configData = HttpService:JSONDecode(result)
            for flag, value in pairs(configData) do
                MacOSLib.Flags[flag] = value
            end
        end
    end
    
    if configFileName then
        if not isfolder(MacOSLib.ConfigFolder) then
            makefolder(MacOSLib.ConfigFolder)
        end
        WindowAPI:LoadConfig()
    end
    
    return WindowAPI
end

function MacOSLib:CreateSidebarItem(parent, config)
    config = config or {}
    local itemText = config.Text or "Item"
    local itemIcon = config.Icon or "rbxassetid://0"
    local callback = config.Callback or function() end
    
    local item = Instance.new("TextButton")
    item.Name = itemText
    item.Size = UDim2.new(1, 0, 0, 32)
    item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    item.BackgroundTransparency = 1
    item.BorderSizePixel = 0
    item.Text = ""
    item.AutoButtonColor = false
    item.Parent = parent
    addCorner(item, 6)
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 8, 0, 6)
    icon.BackgroundTransparency = 1
    icon.Image = itemIcon
    icon.ImageColor3 = MacOSLib.Theme.AccentBlue
    icon.Parent = item
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 36, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = itemText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = item
    
    local isSelected = false
    
    item.MouseEnter:Connect(function()
        if not isSelected then
            TweenService:Create(item, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.85
            }):Play()
        end
    end)
    
    item.MouseLeave:Connect(function()
        if not isSelected then
            TweenService:Create(item, TweenInfo.new(0.15), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)
    
    local function selectItem()
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") and child ~= item then
                local childLabel = child:FindFirstChild("Label")
                local childIcon = child:FindFirstChild("Icon")
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                }):Play()
                if childLabel then
                    TweenService:Create(childLabel, TweenInfo.new(0.2), {
                        TextColor3 = MacOSLib.Theme.PrimaryText
                    }):Play()
                end
                if childIcon then
                    TweenService:Create(childIcon, TweenInfo.new(0.2), {
                        ImageColor3 = MacOSLib.Theme.AccentBlue
                    }):Play()
                end
            end
        end
        
        isSelected = true
        TweenService:Create(item, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            BackgroundColor3 = MacOSLib.Theme.AccentBlue
        }):Play()
        TweenService:Create(label, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        callback()
    end
    
    item.MouseButton1Click:Connect(selectItem)
    item.Select = selectItem
    
    return item
end

function MacOSLib:CreateSectionHeader(parent, title)
    local header = Instance.new("TextLabel")
    header.Name = "SectionHeader"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = MacOSLib.Theme.PrimaryText
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = parent
    
    return header
end

function MacOSLib:CreateButton(parent, config)
    config = config or {}
    local buttonText = config.Text or "Button"
    local callback = config.Callback or function() end
    
    local button = Instance.new("TextButton")
    button.Name = buttonText
    button.Size = UDim2.new(0, 140, 0, 32)
    button.BackgroundColor3 = MacOSLib.Theme.AccentBlue
    button.BorderSizePixel = 0
    button.Text = buttonText
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = parent
    addCorner(button, 6)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = MacOSLib.Theme.AccentBlueHover
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = MacOSLib.Theme.AccentBlue
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

function MacOSLib:CreateToggle(parent, config)
    config = config or {}
    local toggleText = config.Text or "Toggle"
    local defaultValue = config.Default or false
    local flag = config.Flag
    local callback = config.Callback or function() end
    
    if flag and MacOSLib.Flags[flag] ~= nil then
        defaultValue = MacOSLib.Flags[flag]
    end
    
    local container = Instance.new("Frame")
    container.Name = "ToggleContainer"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = toggleText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local switchFrame = Instance.new("TextButton")
    switchFrame.Name = "Switch"
    switchFrame.Size = UDim2.new(0, 42, 0, 24)
    switchFrame.Position = UDim2.new(1, -42, 0.5, -12)
    switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    switchFrame.BorderSizePixel = 0
    switchFrame.Text = ""
    switchFrame.AutoButtonColor = false
    switchFrame.Parent = container
    addCorner(switchFrame, 12)
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switchFrame
    addCorner(knob, 10)
    
    local toggled = defaultValue
    
    local function updateToggle()
        if toggled then
            TweenService:Create(switchFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = MacOSLib.Theme.AccentBlue
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -22, 0, 2)
            }):Play()
        else
            TweenService:Create(switchFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
        
        if flag then
            MacOSLib.Flags[flag] = toggled
        end
    end
    
    updateToggle()
    
    switchFrame.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        callback(toggled)
    end)
    
    return container
end

function MacOSLib:CreateSlider(parent, config)
    config = config or {}
    local sliderText = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local flag = config.Flag
    local callback = config.Callback or function() end
    
    if flag and MacOSLib.Flags[flag] ~= nil then
        default = MacOSLib.Flags[flag]
    end
    
    local container = Instance.new("Frame")
    container.Name = "SliderContainer"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = sliderText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = MacOSLib.Theme.SecondaryText
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, 0, 0, 6)
    sliderBack.Position = UDim2.new(0, 0, 0, 30)
    sliderBack.BackgroundColor3 = MacOSLib.Theme.Border
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = container
    addCorner(sliderBack, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = MacOSLib.Theme.AccentBlue
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    addCorner(sliderFill, 3)
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBack
    addCorner(sliderKnob, 8)
    
    local dragging = false
    local currentValue = default
    
    local function updateSlider(input)
        local pos = (input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        
        local rawValue = min + (max - min) * pos
        currentValue = math.floor(rawValue / increment + 0.5) * increment
        currentValue = math.clamp(currentValue, min, max)
        
        valueLabel.Text = tostring(currentValue)
        
        local normalizedPos = (currentValue - min) / (max - min)
        sliderFill.Size = UDim2.new(normalizedPos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(normalizedPos, -8, 0.5, -8)
        
        if flag then
            MacOSLib.Flags[flag] = currentValue
        end
        
        callback(currentValue)
    end
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return container
end

function MacOSLib:CreateTextInput(parent, config)
    config = config or {}
    local placeholderText = config.Placeholder or "Enter text..."
    local defaultText = config.Default or ""
    local flag = config.Flag
    local callback = config.Callback or function() end
    
    if flag and MacOSLib.Flags[flag] ~= nil then
        defaultText = MacOSLib.Flags[flag]
    end
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "TextInputFrame"
    inputFrame.Size = UDim2.new(1, 0, 0, 36)
    inputFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    inputFrame.BorderSizePixel = 1
    inputFrame.BorderColor3 = MacOSLib.Theme.Border
    inputFrame.Parent = parent
    addCorner(inputFrame, 6)
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -16, 1, 0)
    textBox.Position = UDim2.new(0, 8, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = defaultText
    textBox.PlaceholderText = placeholderText
    textBox.TextColor3 = MacOSLib.Theme.PrimaryText
    textBox.PlaceholderColor3 = MacOSLib.Theme.SecondaryText
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 13
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    textBox.FocusLost:Connect(function()
        if flag then
            MacOSLib.Flags[flag] = textBox.Text
        end
        callback(textBox.Text)
    end)
    
    return textBox
end

function MacOSLib:CreateDropdown(parent, config)
    config = config or {}
    local dropdownText = config.Text or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2"}
    local default = config.Default or options[1]
    local flag = config.Flag
    local callback = config.Callback or function() end
    
    if flag and MacOSLib.Flags[flag] ~= nil then
        default = MacOSLib.Flags[flag]
    end
    
    local container = Instance.new("Frame")
    container.Name = "DropdownContainer"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = dropdownText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 0, 32)
    dropdownButton.Position = UDim2.new(0, 0, 0, 24)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    dropdownButton.BorderSizePixel = 1
    dropdownButton.BorderColor3 = MacOSLib.Theme.Border
    dropdownButton.Text = ""
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = container
    addCorner(dropdownButton, 6)
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -40, 1, 0)
    selectedLabel.Position = UDim2.new(0, 12, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = default
    selectedLabel.TextColor3 = MacOSLib.Theme.PrimaryText
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.TextSize = 13
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = dropdownButton
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = MacOSLib.Theme.SecondaryText
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = dropdownButton
    
    local optionsList = Instance.new("Frame")
    optionsList.Name = "OptionsList"
    optionsList.Size = UDim2.new(1, 0, 0, #options * 32)
    optionsList.Position = UDim2.new(0, 0, 0, 58)
    optionsList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    optionsList.BorderSizePixel = 1
    optionsList.BorderColor3 = MacOSLib.Theme.Border
    optionsList.Visible = false
    optionsList.ZIndex = 10
    optionsList.Parent = container
    addCorner(optionsList, 6)
    
    local optionsListLayout = Instance.new("UIListLayout")
    optionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsListLayout.Parent = optionsList
    
    local isOpen = false
    
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 32)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = MacOSLib.Theme.PrimaryText
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 13
        optionButton.AutoButtonColor = false
        optionButton.Parent = optionsList
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0.9
            optionButton.BackgroundColor3 = MacOSLib.Theme.AccentBlue
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            optionsList.Visible = false
            isOpen = false
            arrow.Text = "▼"
            container.Size = UDim2.new(1, 0, 0, 60)
            
            if flag then
                MacOSLib.Flags[flag] = option
            end
            
            callback(option)
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsList.Visible = isOpen
        arrow.Text = isOpen and "▲" or "▼"
        
        if isOpen then
            container.Size = UDim2.new(1, 0, 0, 60 + #options * 32)
        else
            container.Size = UDim2.new(1, 0, 0, 60)
        end
    end)
    
    return container
end

function MacOSLib:CreateKeybind(parent, config)
    config = config or {}
    local keybindText = config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.E
    local flag = config.Flag
    local callback = config.Callback or function() end
    
    if flag and MacOSLib.Flags[flag] ~= nil then
        default = MacOSLib.Flags[flag]
    end
    
    local container = Instance.new("Frame")
    container.Name = "KeybindContainer"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = keybindText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0, 90, 0, 28)
    keybindButton.Position = UDim2.new(1, -90, 0.5, -14)
    keybindButton.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    keybindButton.BorderSizePixel = 1
    keybindButton.BorderColor3 = MacOSLib.Theme.Border
    keybindButton.Text = default.Name
    keybindButton.TextColor3 = MacOSLib.Theme.PrimaryText
    keybindButton.Font = Enum.Font.GothamMedium
    keybindButton.TextSize = 12
    keybindButton.AutoButtonColor = false
    keybindButton.Parent = container
    addCorner(keybindButton, 6)
    
    local currentKey = default
    local listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keybindButton.Text = "..."
        keybindButton.BackgroundColor3 = MacOSLib.Theme.AccentBlue
        keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keybindButton.Text = currentKey.Name
            keybindButton.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
            keybindButton.TextColor3 = MacOSLib.Theme.PrimaryText
            listening = false
            
            if flag then
                MacOSLib.Flags[flag] = currentKey
            end
            
            callback(currentKey)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not listening and input.KeyCode == currentKey then
            callback(currentKey)
        end
    end)
    
    return container
end

function MacOSLib:CreateColorPicker(parent, config)
    config = config or {}
    local colorText = config.Text or "Color Picker"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local flag = config.Flag
    local callback = config.Callback or function() end
    
    if flag and MacOSLib.Flags[flag] ~= nil then
        default = MacOSLib.Flags[flag]
    end
    
    local container = Instance.new("Frame")
    container.Name = "ColorPickerContainer"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = colorText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Size = UDim2.new(0, 60, 0, 28)
    colorDisplay.Position = UDim2.new(1, -60, 0.5, -14)
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 1
    colorDisplay.BorderColor3 = MacOSLib.Theme.Border
    colorDisplay.Text = ""
    colorDisplay.AutoButtonColor = false
    colorDisplay.Parent = container
    addCorner(colorDisplay, 6)
    
    local currentColor = default
    
    colorDisplay.MouseButton1Click:Connect(function()
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
        currentColor = Color3.fromRGB(r, g, b)
        colorDisplay.BackgroundColor3 = currentColor
        
        if flag then
            MacOSLib.Flags[flag] = currentColor
        end
        
        callback(currentColor)
    end)
    
    return container
end

function MacOSLib:CreateLabel(parent, config)
    config = config or {}
    local labelText = config.Text or "Label"
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = MacOSLib.Theme.PrimaryText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    return label
end

function MacOSLib:CreateParagraph(parent, config)
    config = config or {}
    local title = config.Title or "Paragraph"
    local content = config.Content or "Content goes here..."
    
    local container = Instance.new("Frame")
    container.Name = "ParagraphContainer"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = MacOSLib.Theme.PrimaryText
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, 0, 0, 35)
    contentLabel.Position = UDim2.new(0, 0, 0, 22)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = MacOSLib.Theme.SecondaryText
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 13
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = container
    
    return container
end

function MacOSLib:CreateImage(parent, config)
    config = config or {}
    local imageId = config.Image or "rbxassetid://0"
    local imageSize = config.Size or UDim2.new(0, 200, 0, 150)
    
    local image = Instance.new("ImageLabel")
    image.Name = "Image"
    image.Size = imageSize
    image.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    image.BorderSizePixel = 1
    image.BorderColor3 = MacOSLib.Theme.Border
    image.Image = imageId
    image.ScaleType = Enum.ScaleType.Fit
    image.Parent = parent
    addCorner(image, 8)
    
    return image
end

function MacOSLib:CreateDivider(parent)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = MacOSLib.Theme.DividerLine
    divider.BorderSizePixel = 0
    divider.Parent = parent
    
    return divider
end

function MacOSLib:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 5
    local icon = config.Icon or "rbxassetid://0"
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "NotificationGui"
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.ResetOnSpawn = false
    notifGui.Parent = game.CoreGui
    
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 320, 0, 80)
    notif.Position = UDim2.new(1, -340, 0, 20)
    notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notif.BorderSizePixel = 0
    notif.Parent = notifGui
    addCorner(notif, 10)
    addPadding(notif, 16, 16, 12, 12)
    
    local notifShadow = Instance.new("ImageLabel")
    notifShadow.BackgroundTransparency = 1
    notifShadow.Position = UDim2.new(0, -10, 0, -10)
    notifShadow.Size = UDim2.new(1, 20, 1, 20)
    notifShadow.ZIndex = 0
    notifShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    notifShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    notifShadow.ImageTransparency = 0.85
    notifShadow.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = MacOSLib.Theme.PrimaryText
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, 0, 0, 35)
    contentLabel.Position = UDim2.new(0, 0, 0, 24)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = MacOSLib.Theme.SecondaryText
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 13
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -340, 0, 20)
    }):Play()
    
    task.wait(duration)
    
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 0, 0, 20)
    }):Play()
    
    task.wait(0.3)
    notifGui:Destroy()
end

return MacOSLib
