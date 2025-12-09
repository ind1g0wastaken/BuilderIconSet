local HttpService = game:GetService("HttpService")
local iconUrl = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/Icon.lua" -- Replace with your actual URL

local iconTable = nil

local function getAllIcons()
	local success, response = pcall(HttpService.GetAsync, HttpService, iconUrl)

	if success and response then
		return response
	else
		warn("Failed to fetch content:", response)
		return nil
	end
end

local code = getAllIcons()

if code then
	local loaded = loadstring(code)
	iconTable = loaded()
else
	warn("Couldn't fetch Roblox's icons. Are HTTP requests enabled for this game?")
end

local iconSet: {[string]: string} = require(script.Parent.IconSet) -- This is old, I forgot to remove this line from the code but I'm leaving it here to make it accurate to the scripts in the .rbxmx file
local interface = script.Parent.Interface

local iconFormat = `<font family="rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json">%s</font>`

local toolbar = plugin:CreateToolbar("Indigo's Plugins")
local iconButton = toolbar:CreateButton(
	"toggle-ui",
	"Toggles the UI. It will appear in the bottom left of your screen.",
	"rbxassetid://119610312021517",
	"Builder Icons"
)

local excludeList = require(script.Exclude)

interface.Parent = game.CoreGui
interface.Enabled = false

local uiVisible = false

iconButton.Click:Connect(function()
	uiVisible = not uiVisible
	iconButton:SetActive(uiVisible)
	
	interface.Enabled = uiVisible
end)

for name, iconString in iconTable do
	if table.find(excludeList, name) then
		continue
	end
	
	local richTextTag = string.format(iconFormat, iconString)
	
	local newTemp = interface.Container.IconList.IconTemp:Clone()
	newTemp.Parent = interface.Container.IconList
	newTemp.Name = name
	
	newTemp.Icon.Text = richTextTag
	newTemp.CopyArea.Text = richTextTag
	newTemp.CopyArea.TextEditable = false
	newTemp.CopyArea.ClearTextOnFocus = false
	
	newTemp.IconName.Text = name
	
	newTemp.Visible = true
end

function search(query: string)
	local lowercaseQuery = string.lower(query)
	
	for i, v in pairs(interface.Container.IconList:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "IconTemp" then
			if query ~= "" then
				local iconName = string.lower(v.Name)
				if string.find(iconName, lowercaseQuery) then
					v.Visible = true
				else
					v.Visible = false
				end
			else
				v.Visible = true
			end
		end
	end
end

interface.Container.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
	search(interface.Container.SearchBar.Text)
end)
