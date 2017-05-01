--[[
$Id: Config.lua 11 2017-04-12 12:10:11Z arith $
]]
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
-- Functions
local _G = getfenv(0)
local pairs = _G.pairs
-- Libraries
local string, format = string, format
-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...
local LibStub = _G.LibStub;
local addon = LibStub("AceAddon-3.0"):GetAddon(private.addon_name)
local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name)

local AceConfigReg = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local LibDialog = LibStub("LibDialog-1.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return addon.db.profile[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		addon.db.profile[key] = value
		addon:Refresh()
	end
end

local character_data_list = {}
local function get_character_data_listMenu()
	local serverkey, server_value, charkey, char_value
	local list = {}
	local factionstr, faction_icon, colorCode
	local i = 1
	
	for serverkey, server_value in pairs(Accountant_ClassicSaveData) do
		for charkey, char_value in pairs(Accountant_ClassicSaveData[serverkey]) do
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"].faction) then
				factionstr = Accountant_ClassicSaveData[serverkey][charkey]["options"].faction
				faction_icon = "|TInterface\\PVPFrame\\PVP-Currency-"..factionstr..":0:0|t%s - %s"
			end
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"].class) then
				local class = Accountant_ClassicSaveData[serverkey][charkey]["options"].class;
				colorCode = "|c"..RAID_CLASS_COLORS[class]["colorStr"];
			end
			list[i] = format(colorCode..faction_icon.."|r", serverkey, charkey)
			character_data_list[i] = { serverkey, charkey }
			
			i = i + 1
		end
	end
	return list
end

local function to_confirm_character_removal(value)
	local selected_srv  = character_data_list[value][1];
	local selected_char  = character_data_list[value][2];
	local faction_icon = "";
	local class_color = "";

	if (Accountant_ClassicSaveData[selected_srv][selected_char]["options"].faction) then
		local factionstr = Accountant_ClassicSaveData[selected_srv][selected_char]["options"].faction;
		faction_icon = "|TInterface\\PVPFrame\\PVP-Currency-"..factionstr..":0:0|t";
	end
	if (Accountant_ClassicSaveData[selected_srv][selected_char]["options"].class) then
		local classToken = Accountant_ClassicSaveData[selected_srv][selected_char]["options"].class;
		class_color = "|c"..RAID_CLASS_COLORS[classToken]["colorStr"];
	end

	-- Confirm box
	LibDialog:Register("ACCLOC_CHARREMOVE", {
		text = L["The selected character is about to be removed.\nAre you sure you want to remove the following character from Accountant Classic?"].."\n|r"..faction_icon..class_color..selected_srv.." - "..selected_char,
		buttons = {
			{
				text = OKAY,
				on_click = function() addon:CharacterRemovalProceed(selected_srv, selected_char); end,
			},
			{
				text = CANCEL,
				on_click = function(self, mouseButton, down) LibDialog:Dismiss("ACCLOC_CHARREMOVE"); end,
			},
		},
		show_while_dead = true,
		hide_on_escape = true,
		is_exclusive = true,
		show_during_cinematic = false,
		
	});
	LibDialog:Spawn("ACCLOC_CHARREMOVE");
end


local options, moduleOptions = nil, {}

local function getOptions()
	if not options then
		options = {
			type = "group",
			name = L["Accountant Classic"],
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["Options"],
					get = optGetter,
					set = optSetter,
					args = {
						intro = {
							order = 0,
							type = "description",
							name = L["A basic tool to track your monetary incomings and outgoings within WoW."],
						},
						group1 = {
							order = 10,
							type = "group",
							name = L["Minimap Button Settings"],
							inline = true,
							args = {
								minimapButton = {
									order = 12,
									type = "toggle",
									name = L["Show minimap button"],
									get = function()
										return not addon.db.profile.minimap.hide
									end,
									set = AccountantClassic_ButtonToggle,
								},
								showmoneyonbutton = {
									order = 13,
									type = "toggle",
									name = L["Show money"],
									desc = L["Show money on minimap button's tooltip"],
								},
								showsessiononbutton = {
									order = 14,
									type = "toggle",
									name = L["Show session info"],
									desc = L["Show session info on minimap button's tooltip"],
								},
							},
						},
						group2 = {
							order = 21,
							type = "group",
							name = L["LDB Display Settings"],
							inline = true,
							args = {
								ldbDisplayType = {
									order = 22,
									type = "select",
									name = L["LDB Display Type"],
									desc = L["Data type to be displayed on LDB"],
									values = function()
										local menu = { 
											L["Total"],
											L["This Session"],
											L["Today"],
											L["This Week"],
											L["This Month"],
										}
										return menu
									end,
								},
							},
						},
						group3 = {
							order = 31,
							type = "group",
							name = L["General and Data Display Format Settings"],
							inline = true,
							args = {
								showmoneyinfo = {
									order = 32,
									type = "toggle",
									name = L["Show money on screen"],
									width = "double",
								},
								resetButtonPos = {
									order = 32.1,
									type = "execute",
									name = L["Reset position"],
									desc = L["Reset money frame's position"],
									func = function()
										AccountantClassicMoneyInfoFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 10, -80)
									end,
								},

								showintrotip = {
									order = 33,
									type = "toggle",
									name = L["Display Instruction Tips"],
									desc = L["Toggle whether to display minimap button or floating money frame's operation tips."],
									width = "full",
								},
								breakupnumbers = {
									order = 34,
									type = "toggle",
									name = L["Converts a number into a localized string, grouping digits as required."],
									width = "full",
								},
								cross_server = {
									order = 35,
									type = "toggle",
									name = L["Show all realms' characters info"],
									desc = L["Enable to show all characters' money info from all realms. Disable to only show current realm's character info."],
									width = "full",
									set = function(info, value)
										addon.db.profile.cross_server = value
										addon:PopulateCharacterList()
									end,
								},
								trackzone = {
									order = 36,
									type = "toggle",
									name = L["Track location of incoming / outgoing money"],
									desc = L["Enable to track the location of each incoming / outgoing money and also show the breakdown info while mouse hover each of the expenditure."],
									width = "full",
								},
								tracksubzone = {
									order = 36.1,
									type = "toggle",
									name = L["Also track subzone info"],
									desc = L["Enable to also track on the subzone info. For example: Suramar - Sanctum of Order"],
									width = "full",
								},
								weekstart = {
									order = 37,
									type = "select",
									name = L["Start of Week"],
									values = function()
										local ACC_WEEKDAYS = { WEEKDAY_SUNDAY, WEEKDAY_MONDAY, WEEKDAY_TUESDAY, WEEKDAY_WEDNESDAY, WEEKDAY_THURSDAY, WEEKDAY_FRIDAY, WEEKDAY_SATURDAY };

										return ACC_WEEKDAYS
									end,
								},
								dateformat = {
									order = 38,
									type = "select",
									name = L["Select the date format:"],
									desc = L["Date format showing in \"All Chars\" and \"Week\" tabs"],
									values = function()
										return addon.constants.dateformats
									end,
								},
							},
						},
						group4 = {
							order = 41,
							type = "group",
							name = L["Main Frame's Scale and Alpha Settings"],
							inline = true,
							args = {
								scale = {
									order = 42,
									type = "range",
									name = L["Accountant Classic Frame's Scale"],
									min = 0.5, max = 1.75, bigStep = 0.02,
									isPercent = true,
									width = "full",
								},
								alpha = {
									order = 43,
									type = "range",
									name = L["Accountant Classic Frame's Transparency"],
									min = 0.1, max = 1, bigStep = 0.1,
									isPercent = true,
									width = "full",
								},
							},
						},
						group5 = {
							order = 51,
							type = "group",
							name = L["Onscreen Actionbar's Scale and Alpha Settings"],
							inline = true,
							args = {
								infoscale = {
									order = 52,
									type = "range",
									name = L["Accountant Classic Floating Info's Scale"],
									min = 0.5, max = 3, bigStep = 0.1,
									isPercent = true,
									width = "full",
								},
								infoalpha = {
									order = 53,
									type = "range",
									name = L["Accountant Classic Floating Info's Transparency"],
									min = 0.1, max = 1, bigStep = 0.1,
									isPercent = true,
									width = "full",
								},
							},
						},
						group6 = {
							order = 61,
							type = "group",
							name = L["Character Data's Removal"],
							inline = true,
							args = {
								deleteData = {
									order = 62,
									type = "select",
									name = L["Select the character to be removed:"],
									desc = L["The selected character's Accountant Classic data will be removed."],
									width = "double",
									values = function()
										local menu = get_character_data_listMenu()
										return menu
									end,
									set = function(info, value)
										to_confirm_character_removal(value)
										InterfaceOptionsFrame:Hide()
									end,
								},
							},
						},
					},
				},
			},
		}
		for k,v in pairs(moduleOptions) do
			options.args[k] = (type(v) == "function") and v() or v
		end
	end
	
	return options
end


function addon:OpenOptions() 
	-- open the profiles tab before, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.General)
	InterfaceOptionsFrame:Raise()
end

local function giveProfiles()
	return AceDBOptions:GetOptionsTable(addon.db)
end

function addon:SetupOptions()
	self.optionsFrames = {}

	-- setup options table
	AceConfigReg:RegisterOptionsTable(L["Accountant Classic"], getOptions)
	self.optionsFrames.General = AceConfigDialog:AddToBlizOptions(L["Accountant Classic"], nil, nil, "general")

	self:RegisterModuleOptions("Profiles", giveProfiles, L["Profile Options"])

	-- Add in the about panel to the Bliz options (not a part of the ace3 config)
	if LibStub:GetLibrary("LibAboutPanel", true) then
		self.optionsFrames["About"] = LibStub:GetLibrary("LibAboutPanel").new(L["Accountant Classic"], addon.Name)
	end
end

-- Description: Function which extends our options table in a modular way
-- Expected result: add a new modular options table to the modularOptions upvalue as well as the Blizzard config
-- Input:
--		name		: index of the options table in our main options table
--		optionsTable	: the sub-table to insert
--		displayName	: the name to display in the config interface for this set of options
-- Output: None.
function addon:RegisterModuleOptions(name, optionTbl, displayName)
	moduleOptions[name] = optionTbl
	self.optionsFrames[name] = AceConfigDialog:AddToBlizOptions(L["Accountant Classic"], displayName, L["Accountant Classic"], name)
end
