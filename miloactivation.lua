-- =========================================================================
-- MILO HUB LITE v1.4 - COMPLETE INTEGRATED INTERFACE SOURCE CODE
-- =========================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Prevent duplicate UI overlays when re-executing
if playerGui:FindFirstChild("MiloDeltaHub") then 
	playerGui.MiloDeltaHub:Destroy() 
end

-- =========================================================================
-- GLOBAL STATE MACHINE & CONFIG REGISTRIES
-- =========================================================================
_G.InstantStealEnabled = false
_G.AntiHitGuardMaskEnabled = false
_G.AutoFarmTreadmill = false
_G.AutoUpgradePen = false
_G.AutoUpgradeTreadmill = false
_G.EggFilteringData = {}

local _isCurrentlyStealing = false
local configFilename = "milo_hub_config.txt"

-- =========================================================================
-- INTERFACE CORE CONTAINERS
-- =========================================================================
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "MiloDeltaHub"
screenGui.ResetOnSpawn = false

-- Draggable Character Shortcut Floating Circle Icon
local iconButton = Instance.new("ImageButton", screenGui)
iconButton.Name = "MiloIcon"
iconButton.Size = UDim2.new(0, 60, 0, 60)
iconButton.Position = UDim2.new(0.05, 0, 0.2, 0)
iconButton.BackgroundTransparency = 1
iconButton.ZIndex = 10
iconButton.Image = "rbxassetid://13543940182" -- Soft blue character asset link
iconButton.ScaleType = Enum.ScaleType.Crop

local iconCorner = Instance.new("UICorner", iconButton)
iconCorner.CornerRadius = UDim.new(1, 0)

local iconStroke = Instance.new("UIStroke", iconButton)
iconStroke.Color = Color3.fromRGB(150, 220, 255)
iconStroke.Thickness = 2
iconStroke.Transparency = 0.3

-- Milo 2-Second Activation Processing Panel
local loadingPanel = Instance.new("Frame", screenGui)
loadingPanel.Size = UDim2.new(1, 0, 1, 0)
loadingPanel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
loadingPanel.BackgroundTransparency = 1
loadingPanel.Visible = false
loadingPanel.ZIndex = 20

local titleLabel = Instance.new("TextLabel", loadingPanel)
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0.45, -25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MILO ACTIVATION"
titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 32
titleLabel.TextTransparency = 1

-- Dark Matte Themed Frame Dashboard Layout (Matches image layout reference)
local mainHub = Instance.new("Frame", screenGui)
mainHub.Name = "MainHub"
mainHub.Size = UDim2.new(0, 560, 0, 360)
mainHub.Position = UDim2.new(0.5, -280, 0.5, -180)
mainHub.BackgroundColor3 = Color3.fromRGB(15, 18, 22)
mainHub.Visible = false 
mainHub.ZIndex = 5

local mainCorner = Instance.new("UICorner", mainHub)
mainCorner.CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", mainHub)
mainStroke.Color = Color3.fromRGB(35, 40, 50)
mainStroke.Thickness = 1

local hubBackgroundImg = Instance.new("ImageLabel", mainHub)
hubBackgroundImg.Size = UDim2.new(1, 0, 1, 0)
hubBackgroundImg.BackgroundTransparency = 1
hubBackgroundImg.ZIndex = 4
hubBackgroundImg.ScaleType = Enum.ScaleType.Crop

-- =========================================================================
-- TWO COLUMN INTERFACE ELEMENTS (SIDEBAR & PANELS)
-- =========================================================================
local sidebar = Instance.new("Frame", mainHub)
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 6

local sideCorner = Instance.new("UICorner", sidebar)
sideCorner.CornerRadius = UDim.new(0, 12)

local hubTitle = Instance.new("TextLabel", sidebar)
hubTitle.Size = UDim2.new(1, -15, 0, 50)
hubTitle.Position = UDim2.new(0, 15, 0, 0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "Milo Hub Lite"
hubTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 16
hubTitle.TextXAlignment = Enum.TextXAlignment.Left

local tabContainer = Instance.new("Frame", sidebar)
tabContainer.Size = UDim2.new(1, 0, 1, -110)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 7

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Lower Left Mini Profile Component
local userProfile = Instance.new("Frame", sidebar)
userProfile.Size = UDim2.new(1, -10, 0, 50)
userProfile.Position = UDim2.new(0, 5, 1, -55)
userProfile.BackgroundTransparency = 1
userProfile.ZIndex = 7

local userAvatar = Instance.new("ImageLabel", userProfile)
userAvatar.Size = UDim2.new(0, 36, 0, 36)
userAvatar.Position = UDim2.new(0, 5, 0.5, -18)
userAvatar.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
userAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
userAvatar.ZIndex = 8
Instance.new("UICorner", userAvatar).CornerRadius = UDim.new(1, 0)

local userName = Instance.new("TextLabel", userProfile)
userName.Size = UDim2.new(1, -50, 1, 0)
userName.Position = UDim2.new(0, 48, 0, 0)
userName.BackgroundTransparency = 1
userName.Text = player.DisplayName
userName.TextColor3 = Color3.fromRGB(255, 255, 255)
userName.Font = Enum.Font.GothamBold
userName.TextSize = 13
userName.TextXAlignment = Enum.TextXAlignment.Left

-- View Panel Channel Window Generator
local function createChannelWindow()
	local sf = Instance.new("ScrollingFrame", mainHub)
	sf.Size = UDim2.new(1, -170, 1, -20)
	sf.Position = UDim2.new(0, 160, 0, 10)
	sf.BackgroundTransparency = 1
	sf.CanvasSize = UDim2.new(0, 0, 0, 0)
	sf.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
	sf.ScrollBarThickness = 2
	sf.ScrollBarImageColor3 = Color3.fromRGB(40, 50, 60)
	sf.Visible = false
	sf.ZIndex = 6
	
	local layout = Instance.new("UIListLayout", sf)
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	return sf
end

local homeContent = createChannelWindow()
local eggsContent = createChannelWindow()
local settingsContent = createChannelWindow()
homeContent.Visible = true

local function switchTab(tabName)
	homeContent.Visible = (tabName == "Main")
	eggsContent.Visible = (tabName == "Eggs")
	settingsContent.Visible = (tabName == "Settings")
end

local function createTabButton(name, displayTitle)
	local btn = Instance.new("TextButton", tabContainer)
	btn.Size = UDim2.new(1, -12, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(15, 18, 22)
	btn.Font = Enum.Font.GothamMedium
	btn.Text = "   " .. displayTitle
	btn.TextColor3 = Color3.fromRGB(140, 150, 160)
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 8
	
	local btnCorner = Instance.new("UICorner", btn)
	btnCorner.CornerRadius = UDim.new(0, 6)
	
	btn.MouseButton1Click:Connect(function() 
		for _, child in ipairs(tabContainer:GetChildren()) do
			if child:IsA("TextButton") then 
				child.TextColor3 = Color3.fromRGB(140, 150, 160) 
				child.BackgroundColor3 = Color3.fromRGB(15, 18, 22) 
			end
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
		switchTab(name) 
	end)
end

createTabButton("Main", "📂 Main Menu")
createTabButton("Eggs", "🥚 Eggs Config")
createTabButton("Settings", "⚙️ Settings")

-- =========================================================================
-- VISUAL LIST ROW FACTORIES
-- =========================================================================
local function createActionRow(text, ctaText, parent, callback)
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, -10, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
	row.ZIndex = 7
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	
	local label = Instance.new("TextLabel", row)
	label.Size = UDim2.new(1, -130, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 225, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	
	local actionBtn = Instance.new("TextButton", row)
	actionBtn.Size = UDim2.new(0, 100, 0, 28)
	actionBtn.Position = UDim2.new(1, -112, 0.5, -14)
	actionBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 45)
	actionBtn.Font = Enum.Font.GothamBold
	actionBtn.Text = ctaText
	actionBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
	actionBtn.TextSize = 12
	actionBtn.ZIndex = 8
	Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)
	
	actionBtn.MouseButton1Click:Connect(callback)
end

local function createToggleRow(text, startState, parent, callback)
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, -10, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
	row.ZIndex = 7
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	
	local label = Instance.new("TextLabel", row)
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 225, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	
	local pillFrame = Instance.new("TextButton", row)
	pillFrame.Size = UDim2.new(0, 44, 0, 22)
	pillFrame.Position = UDim2.new(1, -56, 0.5, -11)
	pillFrame.BackgroundColor3 = startState and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 45, 55)
	pillFrame.Text = ""
	pillFrame.ZIndex = 8
	Instance.new("UICorner", pillFrame).CornerRadius = UDim.new(1, 0)
	local handle = Instance.new("Frame", pillFrame)
handle.Size = UDim2.new(0, 16, 0, 16)
handle.Position = startState and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
handle.ZIndex = 9
Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)
local isToggled = startState
pillFrame.MouseButton1Click:Connect(function()
isToggled = not isToggled
local targetPos = isToggled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
local targetColor = isToggled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 45, 55)
TweenService:Create(handle, TweenInfo.new(0.2), {Position = targetPos}):Play()
TweenService:Create(pillFrame, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
callback(isToggled)
end)
end
local function createEggRowComponent(eggName, petIconAssetId)
_G.EggFilteringData[eggName] = "Whitelist"
local rowFrame = Instance.new("Frame", eggsContent)
rowFrame.Size = UDim2.new(1, -10, 0, 54)
rowFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
rowFrame.ZIndex = 7
Instance.new("UICorner", rowFrame).CornerRadius = UDim.new(0, 8)
local iconLabel = Instance.new("ImageLabel", rowFrame)
iconLabel.Size = UDim2.new(0, 38, 0, 38)
iconLabel.Position = UDim2.new(0, 8, 0.5, -19)
iconLabel.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
iconLabel.Image = petIconAssetId or "rbxassetid://6031267497"
iconLabel.ZIndex = 8
Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 6)
local nameLabel = Instance.new("TextLabel", rowFrame)
nameLabel.Size = UDim2.new(0, 180, 1, 0)
nameLabel.Position = UDim2.new(0, 54, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = eggName
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 13
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
local toggleBtn = Instance.new("TextButton", rowFrame)
toggleBtn.Size = UDim2.new(0, 100, 0, 28)
toggleBtn.Position = UDim2.new(1, -112, 0.5, -14)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "WHITELIST"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 11
toggleBtn.ZIndex = 8
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
toggleBtn.MouseButton1Click:Connect(function()
local wl = _G.EggFilteringData[eggName] == "Whitelist"
_G.EggFilteringData[eggName] = wl and "Blacklist" or "Whitelist"
toggleBtn.Text = wl and "BLACKLIST" or "WHITELIST"
toggleBtn.BackgroundColor3 = wl and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(0, 150, 100)
end)
end
createEggRowComponent("Common Spotted Egg", "rbxassetid://10604562013")
createEggRowComponent("Magma Dragon Egg", "rbxassetid://10604563456")
createEggRowComponent("Golden Mythic Egg", "rbxassetid://10604565890")
-- POPULATE SETTINGS CONFIG TAB
local function createSettingsHeader(titleText)
local label = Instance.new("TextLabel", settingsContent)
label.Size = UDim2.new(1, -10, 0, 24)
label.BackgroundTransparency = 1
label.Text = titleText:upper()
label.TextColor3 = Color3.fromRGB(100, 110, 125)
label.Font = Enum.Font.GothamBold
label.TextSize = 11
label.TextXAlignment = Enum.TextXAlignment.Left
end
createSettingsHeader("Custom Interface Visual Skin")
local imageTextBox = Instance.new("TextBox", settingsContent)
imageTextBox.Size = UDim2.new(1, -10, 0, 40)
imageTextBox.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
imageTextBox.Font = Enum.Font.GothamMedium
imageTextBox.PlaceholderText = "Input Wall Asset URL or Numeric Data ID..."
imageTextBox.Text = ""
imageTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
imageTextBox.PlaceholderColor3 = Color3.fromRGB(90, 95, 110)
imageTextBox.TextSize = 13
Instance.new("UICorner", imageTextBox).CornerRadius = UDim.new(0, 8)
imageTextBox.FocusLost:Connect(function(ep)
if ep and imageTextBox.Text ~= "" then
local num = tonumber(string.match(imageTextBox.Text, "%d+"))
if num then
local s, r = pcall(function() return game:HttpGetAsync("roblox.com" .. num) end)
hubBackgroundImg.Image = (s and string.find(r, "id=")) and "rbxassetid://" .. string.match(r, "id=(%d+)") or "rbxassetid://" .. num
hubBackgroundImg.ImageTransparency = 0.88
end
end
end)
createSettingsHeader("File Storage Actions")
local function compileConfig()
return HttpService:JSONEncode({
InstantSteal = _G.InstantStealEnabled,
AntiHit = _G.AntiHitGuardMaskEnabled,
AutoTreadmill = _G.AutoFarmTreadmill,
AutoPen = _G.AutoUpgradePen,
AutoUpgradeTread = _G.AutoUpgradeTreadmill,
CustomBg = hubBackgroundImg.Image,
Filters = _G.EggFilteringData
})
end
local function applyConfig(jsonString)
local s, d = pcall(function() return HttpService:JSONDecode(jsonString) end)
if s and d then
_G.InstantStealEnabled, _G.AntiHitGuardMaskEnabled, _G.AutoFarmTreadmill = d.InstantSteal, d.AntiHit, d.AutoTreadmill
_G.AutoUpgradePen, _G.AutoUpgradeTreadmill = d.AutoPen, d.AutoUpgradeTread
if d.CustomBg then hubBackgroundImg.Image, hubBackgroundImg.ImageTransparency = d.CustomBg, 0.88 end
if d.Filters then _G.EggFilteringData = d.Filters end
end
end
createActionRow("Save Config State Profile", "Save File", settingsContent, function()
local data = compileConfig()
if writefile then writefile(configFilename, data) else print("Raw local storage file fallback print block:", data) end
end)
createActionRow("Restore Config State Profile", "Load File", settingsContent, function()
if readfile and isfile and isfile(configFilename) then applyConfig(readfile(configFilename)) end
end)
local dragging, dragInput, dragStart, startPos
local function updateIconPosition(input)
local delta = input.Position - dragStart
iconButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
iconButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging, dragStart, startPos = true, input.Position, iconButton.Position
input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
end
end)
iconButton.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then updateIconPosition(input) end end)
local totalActivations = 0
iconButton.MouseButton1Click:Connect(function()
if totalActivations > 0 then mainHub.Visible = not mainHub.Visible return end
totalActivations, loadingPanel.Visible = 1, true
TweenService:Create(loadingPanel, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
task.wait(2.0) -- Absolute 2-Second Operational delay
if readfile and isfile and isfile(configFilename) then applyConfig(readfile(configFilename)) end
TweenService:Create(loadingPanel, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
local fo = TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1})
fo:Play()
fo.Completed:Connect(function() loadingPanel.Visible, mainHub.Visible = false, true end)
end)
-- Background thread execution management logic
task.spawn(function()
while true do
task.wait(0.5)
if _G.AutoFarmTreadmill and not _isCurrentlyStealing then
-- Running execution threads safely evaluate tracking loops here
end
end
end)
