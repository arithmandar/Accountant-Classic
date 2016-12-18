--[[
$Id$
]]
--[[
 Accountant
    v2.1 - 2.3:
    By Sabaki (sabaki@gmail.com)
        Updated by: Shadow
        new codes by Shadow and Rophy

	Tracks you incoming / outgoing cash

        Thanks To:
	2006/6/18 Rophy: v2.2 Added gold shared by party

	Thanks To:
	Losimagic, Shrill, Fillet for testing
	Atlas by Razark for the minimap icon code I lifted
	Everyone who commented and voted for the mod on curse-gaming.com
  Thiou for the French loc, Snj & JokerGermany for the German loc
  ---------------------------------------------------------------------
  v2.4 - v2.8:
     Updated by: Arith
     Tntdruid for adding Garrison, Barber shop, Void, and Transform logging in v2.5.22
]]
local LibStub = _G.LibStub
local pairs = _G.pairs
local tonumber = _G.tonumber
local table = _G.table
local string = _G.string

local LibDialog = LibStub("LibDialog-1.0");
local addon = LibStub("AceAddon-3.0"):NewAddon("Accountant_Classic", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Accountant_Classic");
local ACbutton = LibStub("LibDBIcon-1.0")

local AccountantClassic_RepairAllItems_old;
local AccountantClassic_CursorHasItem_old;

local AccountantClassic_Version = GetAddOnMetadata("Accountant_Classic", "Version");
--AccountantClassic_Disabled = false;
local AccountantClassic_Mode = "";
local AccountantClassic_CurrentMoney = 0;
local AccountantClassic_LastSessionMoney = 0;
local AccountantClassic_LastMoney = 0;
local AccountantClassic_Verbose = nil;
local AccountantClassic_GotName = false;
local AccountantClassic_CurrentTab = 1;
local AccountantClassic_LogModes = {"Session", "Day", "PrvDay", "Week", "PrvWeek", "Month", "PrvMonth", "Total" };
local AccountantClassic_LogTypes = {"TRAIN", "TAXI", "TRADE", "AH", "MERCH", "REPAIRS", "MAIL", "QUEST", "LOOT", "OTHER", "VOID", "TRANSMO", "GARRISON", "LFG", "BARBER", "GUILD"};
local AC_SCROLL_LIST = {};
local AC_CURR_LINES = 0;
local AC_CHAR_LINES = 17;
local AC_SELECTED_CHAR_NUM = 1;

local AccountantClassic_Server = GetRealmName();
local AccountantClassic_Player = UnitName("player");
local AccountantClassic_Faction = UnitFactionGroup("player");
local _, AccountantClassic_Class = UnitClass("player");
local isInLockdown = false;
local AC_MNYSTR = nil;
local AC_SHOWALLCHARS = false;

local months = {CalendarGetMonthNames()};
-- Number of Accountant Classic tabs; also the tab number of "All Character"
local AC_TABS = #AccountantClassic_LogModes + 1;

-- NewDB
local AC_NewDB = fales;

local AccountantClassic_Data = {
		["TRAIN"] = 	{Title = L["ACCLOC_TRAIN"]};
		["TAXI"] = 	{Title = L["ACCLOC_TAXI"]};
		["TRADE"] = 	{Title = L["ACCLOC_TRADE"]};
		["AH"] = 	{Title = AUCTIONS};
		["MERCH"] = 	{Title = L["ACCLOC_MERCH"]};
		["REPAIRS"] = 	{Title = L["ACCLOC_REPAIR"]};
		["MAIL"] = 	{Title = L["ACCLOC_MAIL"]};
		["QUEST"] = 	{Title = QUESTS_LABEL};
		["LOOT"] = 	{Title = LOOT};
		["OTHER"] = 	{Title = L["ACCLOC_OTHER"]}; -- Actually we display it as "Unknown"
		["VOID"] =  	{Title = VOID_STORAGE};
		["TRANSMO"] =	{Title = TRANSMOGRIFY};
		["GARRISON"] =	{Title = GARRISON_LOCATION_TOOLTIP.." / "..ORDER_HALL_MISSIONS };
		["LFG"] =	{Title = L["ACCLOC_LFG"]};
		["BARBER"] =	{Title = BARBERSHOP};
		["GUILD"] =	{Title = GUILD};
};

local cdate = date("%d/%m/%y");
local cmonth = date("%m");

local function TableIndex(t,val)
    for k,v in ipairs(t) do 
        if v == val then return k end
    end
end

local AccountantClassicDefaultOptions = {
	showbutton = true, 
	showmoneyinfo = true, 
	showintrotip = true,
	showmoneyonbutton = true,
	showsessiononbutton = true,
	buttonpos = 150, 
	version = AccountantClassic_Version, 
	date = cdate, -- to be used as "today"
	lastsessiondate = cdate,
	-- prvday, 
	weekdate = "", 
	-- prvdateweek, 
	month = cmonth,
	-- prvmonth,
	weekstart = 1, 
	totalcash = 0,
	moneyinfoframe_x = 10,
	moneyinfoframe_y = -80,
	faction = AccountantClassic_Faction,
	class = AccountantClassic_Class,
	dateformat = 1;
	LDBDisplaySessionInfo = false;
};

-- Code by Grayhoof (SCT)
local function AccountantClassic_CloneTable(tablein)	-- Return a copy of the table tablein
	local new_table = {};			-- Create a new table
	local ka, va = next(tablein, nil);	-- The ka is an index of tablein; va = tablein[ka]
	while ka do
		if type(va) == "table" then 
			va = AccountantClassic_CloneTable(va);
		end 
		new_table[ka] = va;
		ka, va = next(tablein, ka);	-- Get next index
	end
	return new_table;
end

-- Cleaning up the database record which brough in from "Accountant"
local function AccountantClassic_CleanUpDB()
	if (Accountant_ClassicSaveData ~= nil) then
		for k,v in pairs(Accountant_ClassicSaveData) do
			if (strfind(k, "-")) then
				Accountant_ClassicSaveData[k] = nil;
			end
		end
	end
end

-- This function is designed for user who have both Accountant and Accountant_Classic installed and Accountant's DB has broken due to DB confliction
-- This function will not be called within Accountant_Classic, this is intended for user to call it manually
function AccountantClassic_CleanUpAccountantDB()
	if (Accountant_SaveData ~= nil) then
		for k,v in pairs(Accountant_SaveData) do
			if (strfind(k, "-")) then
				-- do nothing
			else
				Accountant_SaveData[k] = nil;
			end
		end
	end
	LibDialog:Register("ACCOUNTANT_CONFLICT_CLEANUP", {
		text = L["ACCLOC_CLEANUPACCOUNTANT"],
		width = 500,
		buttons = {
			{
				text = OKAY,
				on_click = ReloadUI,
			},
		},
		show_while_dead = false,
		hide_on_escape = true,
	});
	LibDialog:Spawn("ACCOUNTANT_CONFLICT_CLEANUP");
end

local function AccountantClassic_InitOptions()
	if (Accountant_ClassicSaveData == nil) then
		-- we should no longer need these after v2.07.00
		--[[
		if (Accountant_SaveData ~= nil) then
			local loadable = select(4, GetAddOnInfo("Accountant"));
			local enabled = GetAddOnEnableState(UnitName("player"), GetAddOnInfo("Accountant"));
			if ( (enabled > 0) and loadable ) then
				local myversion = false;
				for k, v in pairs(Accountant_SaveData) do
					-- "Accountant" DB use server-playername as the key. So if Accountant_SaveData exist, and if all the key contains "-", means Accountant_Classic is fresh install
					if (strfind(k, "-")) then
						-- do nothing
					else
						myversion = true;
					end
				end
				if (myversion) then -- Means we detect Accountant (maintained by urnati and thorismud) and therefore we have to skip converting our old data.
					AccountantClassic_DetectConflict();
					return;
				else
					Accountant_ClassicSaveData = {};
				end
			else
				Accountant_ClassicSaveData = AccountantClassic_CloneTable(Accountant_SaveData);
				Accountant_SaveData = nil;
				AccountantClassic_CleanUpDB();
			end
		-- Both Accountant_ClassicSaveData and Accountant_SaveData == nil means this is a fresh install
		else
			Accountant_ClassicSaveData = {};
		end
		]]
		Accountant_ClassicSaveData = {};
	end
	if (Accountant_ClassicSaveData[AccountantClassic_Server] == nil) then
		Accountant_ClassicSaveData[AccountantClassic_Server] = {};
	end
	if (Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player] == nil ) then
		Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player] = {
			options = AccountantClassicDefaultOptions,
			data = { },
		};
		ACC_Print(format(L["ACCLOC_NEWPROFILE"], AccountantClassic_Player));
	else
		ACC_Print(format(L["ACCLOC_LOADPROFILE"], AccountantClassic_Player));
	end
	if (AC_NewDB) then
		if (Accountant_Classic_NewDB == nil) then
			Accountant_Classic_NewDB = {};
		end
		if (Accountant_Classic_NewDB[AccountantClassic_Server] == nil) then
			Accountant_Classic_NewDB[AccountantClassic_Server] = {};
		end
		if (Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player] == nil ) then
			Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player] = {
				data = { },
			};
		end
		if (Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player][cdate] == nil ) then
			Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player]["data"][cdate] = { };
		end
	end

	AccountantClassic_Profile = Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player];

	if (AccountantClassic_Profile["options"].showmoneyinfo == nil) then
		AccountantClassic_Profile["options"].showmoneyinfo = true;
	end
	if (AccountantClassic_Profile["options"].showintrotip == nil) then
		AccountantClassic_Profile["options"].showintrotip = false;
	end
	if (AccountantClassic_Profile["options"].showmoneyonbutton == nil) then
		AccountantClassic_Profile["options"].showmoneyonbutton = true;
	end
	if (AccountantClassic_Profile["options"].showsessiononbutton == nil) then
		AccountantClassic_Profile["options"].showsessiononbutton = true;
	end
	if (AccountantClassic_Profile["options"]["weekstart"] == nil) then
		AccountantClassic_Profile["options"]["weekstart"] = 1;
	end
	if (AccountantClassic_Profile["options"]["dateweek"] == nil) then
		AccountantClassic_Profile["options"]["dateweek"] = AccountantClassic_WeekStart();
	end
	if (AccountantClassic_Profile["options"]["date"] == nil) then
		AccountantClassic_Profile["options"]["date"] = cdate;
	end
	if (AccountantClassic_Profile["options"]["month"] == nil) then
		AccountantClassic_Profile["options"]["month"] = cmonth;
	end
	if (AccountantClassic_Profile["options"].moneyinfoframe_x == nil) then
		AccountantClassic_Profile["options"].moneyinfoframe_x = 10;
		AccountantClassic_Profile["options"].moneyinfoframe_y = -80;
	end
	if (AccountantClassic_Profile["options"].faction == nil) then
		AccountantClassic_Profile["options"].faction = AccountantClassic_Faction;
	end
	if (AccountantClassic_Profile["options"].class == nil) then
		AccountantClassic_Profile["options"].class = AccountantClassic_Class;
	end
	if (AccountantClassic_Profile["options"].dateformat == nil) then
		AccountantClassic_Profile["options"].dateformat = 1;
	end
	if (AccountantClassic_Profile["options"].LDBDisplaySessionInfo == nil) then
		AccountantClassic_Profile["options"].LDBDisplaySessionInfo = false;
	end
	if (AccountantClassic_Profile["options"].lastsessiondate == nil) then
		AccountantClassic_Profile["options"].lastsessiondate = cdate;
	end
end

local AccountantClassic_Events = {
	"PLAYER_LOGIN",
	"ADDON_LOADED",
	-- Garrison
	"GARRISON_MISSION_FINISHED",
	"GARRISON_ARCHITECT_OPENED",
	"GARRISON_ARCHITECT_CLOSED",
	"GARRISON_MISSION_NPC_OPENED",
	"GARRISON_MISSION_NPC_CLOSED",
	"GARRISON_SHIPYARD_NPC_OPENED",
	"GARRISON_SHIPYARD_NPC_CLOSED",
	"GARRISON_UPDATE",
	-- Barber shop
	"BARBER_SHOP_APPEARANCE_APPLIED",
	"BARBER_SHOP_OPEN",
	"BARBER_SHOP_SUCCESS",
	"BARBER_SHOP_CLOSE",
	-- Talent
	"CONFIRM_TALENT_WIPE",
	-- LFG
	"LFG_COMPLETION_REWARD",
	-- VOID
	"VOID_STORAGE_OPEN",
	"VOID_STORAGE_CLOSE",
	-- Transform
	"TRANSMOGRIFY_OPEN",
	"TRANSMOGRIFY_CLOSE",
	-- Merchant
	"MERCHANT_SHOW",
	"MERCHANT_CLOSED",
	"MERCHANT_UPDATE",
	-- Quest
	"QUEST_COMPLETE",
	"QUEST_FINISHED",
	"QUEST_TURNED_IN",
	-- Loot
	"LOOT_OPENED",
	"LOOT_CLOSED",
	-- Taxi
	"TAXIMAP_OPENED",
	"TAXIMAP_CLOSED",
	-- Trade
	"TRADE_SHOW",
	"TRADE_CLOSE",
	-- Mail
	"MAIL_INBOX_UPDATE",
	"MAIL_SHOW",
	"MAIL_CLOSED",
	-- Trainer
	"TRAINER_SHOW",
	"TRAINER_CLOSED",
	-- AH
	"AUCTION_HOUSE_SHOW",
	"AUCTION_HOUSE_CLOSED",
	-- Guild
	"GUILDBANKFRAME_OPENED",
	"GUILDBANKFRAME_CLOSED",
	"GUILDBANK_UPDATE_MONEY",
	"GUILDBANK_UPDATE_WITHDRAWMONEY",
	-- Others
	"CHAT_MSG_MONEY",
	"PLAYER_MONEY",
	"UNIT_NAME_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_REGEN_DISABLED",
};	

-- Minimap button with LibDBIcon-1.0
local Accountant_ClassicMiniMapLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Accountant_Classic", {
	type = "data source",
	text = L["ACCLOC_TITLE"],
	label = L["ACCLOC_TITLE"],
	icon = "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantClassicButton-Up",
	OnClick = function(self, button)
		if button == "LeftButton" then
			AccountantClassic_ButtonOnClick();
		elseif button == "RightButton" then
			AccountantClassicOptions_Toggle();
		end
	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		local title = "|cffffffff"..L["ACCLOC_TITLE"];
		if (Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showmoneyonbutton) then
			title = title.." - "..AccountantClassic_GetFormattedValue(GetMoney());
		end
		tooltip:AddLine(title);
		if (Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showsessiononbutton == true) then
			tooltip:AddLine(AccountantClassic_ShowSessionToolTip());
		end
		if (Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showintrotip == true) then
			tooltip:AddLine(L["ACCLOC_TIP"]);
		end
	end,
})
if ( TitanPanelButton_UpdateButton ) then
	TitanPanelButton_UpdateButton("Accountant_Classic");
end

if myAddOnsList then
	myAddOnsList.Accountant = {name = L["ACCLOC_TITLE"], description = L["ACCLOC_DESC"], version = AccountantClassic_Version, frame = "AccountantClassicFrame", optionsframe = "AccountantClassicOptionsFrame"};
end

function Accountant_Classic_GetButtonText()
	local str = AccountantClassic_GetFormattedValue(GetMoney());
	if (str) then
		return str;
	else
		return L["ACCLOC_TITLE"];
	end
end

function addon:OnInitialize()
	local defaults = {
		global = { },
		profile = {
			minimap = {
				hide = false,
				show = true,
				minimapPos = 153,
			},
			options = AccountantClassicDefaultOptions,
		},
	};

	self.db = LibStub("AceDB-3.0"):New("Accountant_ClassicDB", defaults, true);
	db = self.db.profile;
	if not self.db then
		self:Print("Error: Database not loaded correctly.  Please exit out of WoW and delete the Accountant Classic database file Accountant_Classic.lua) found in: \\World of Warcraft\\WTF\\Account\\<Account Name>>\\SavedVariables\\")
		return
	end
	ACbutton:Register("Accountant_Classic", Accountant_ClassicMiniMapLDB, self.db.profile.minimap);
	self:RegisterChatCommand("accountantbutton", AccountantClassic_ButtonToggle);
	self:RegisterChatCommand("accountant", Accountant_Slash);
	self:RegisterChatCommand("acc", Accountant_Slash);
	AccountantClassicFrame:SetClampedToScreen(true);
end

function addon:Toggle()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	if self.db.profile.minimap.hide then
		ACbutton:Hide("Accountant_Classic")
		AccountantClassic_Profile["options"].showbutton = false;
	else
		ACbutton:Show("Accountant_Classic")
		AccountantClassic_Profile["options"].showbutton = true;
	end
	AccountantClassicOptionsFrameToggleButton:SetChecked(AccountantClassic_Profile["options"].showbutton);
end

function AccountantClassic_ButtonToggle()
	addon:Toggle()
end

function AccountantClassic_ButtonOnClick()
	if AccountantClassicFrame:IsVisible() then
		AccountantClassicFrame:Hide();
	else
		AccountantClassicFrame:Show();
	end
end

function AccountantClassic_DetectConflict()
	DisableAddOn("Accountant");

	LibDialog:Register("ACCOUNTANT_CONFLICT", {
		text = L["ACCLOC_CONFLICT"],
		buttons = {
			{
				text = OKAY,
				on_click = ReloadUI,
			},
		},
		show_while_dead = false,
		hide_on_escape = true,
	});
	LibDialog:Spawn("ACCOUNTANT_CONFLICT");
end

function AccountantClassic_RegisterEvents(self)
        for key, value in pairs( AccountantClassic_Events ) do
            self:RegisterEvent( value );
        end
	self:RegisterForDrag("LeftButton");
end

function AccountantClassic_SetLabels(self)
	-- if current tab is All Chars tab
	if (AccountantClassic_CurrentTab == AC_TABS) then
		AccountantClassicFrameResetButton:Hide();

		AccountantClassicFrameSource:SetText(L["ACCLOC_CHAR"]);
		AccountantClassicFrameIn:SetText(L["ACCLOC_MONEY"]);
		AccountantClassicFrameOut:SetText(L["ACCLOC_UPDATED"]);
		AccountantClassicFrameTotalIn:SetText(L["ACCLOC_TOT_IN"]..":");
		AccountantClassicFrameTotalOut:SetText(L["ACCLOC_TOT_OUT"]..":");
		AccountantClassicFrameTotalFlow:SetText(L["ACCLOC_SUM"]..":");
		AccountantClassicFrameTotalInValue:SetText("");
		AccountantClassicFrameTotalOutValue:SetText("");
		AccountantClassicFrameTotalFlowValue:SetText("");
		for i = 1, 18, 1 do
			_G["AccountantClassicFrameRow"..i.."Title"]:SetText("");
			_G["AccountantClassicFrameRow"..i.."Title"]:SetPoint("TOPLEFT", 3, -2);
			_G["AccountantClassicFrameRow"..i.."In"]:SetText("");
			_G["AccountantClassicFrameRow"..i.."Out"]:SetText("");
		end
		return;
	else
		AccountantClassicFrameResetButton:Show();

		AccountantClassicFrameSource:SetText(L["ACCLOC_SOURCE"]);
		AccountantClassicFrameIn:SetText(L["ACCLOC_IN"]);
		AccountantClassicFrameOut:SetText(L["ACCLOC_OUT"]);
		AccountantClassicFrameTotalIn:SetText(L["ACCLOC_TOT_IN"]..":");
		AccountantClassicFrameTotalOut:SetText(L["ACCLOC_TOT_OUT"]..":");
		AccountantClassicFrameTotalFlow:SetText(L["ACCLOC_NET"]..":");

		-- Row Labels (auto generate)
		local InPos = 1;
		for key,value in pairs(AccountantClassic_Data) do
			AccountantClassic_Data[key].InPos = InPos;
			_G["AccountantClassicFrameRow"..InPos.."Title"]:SetText(AccountantClassic_Data[key].Title);
			_G["AccountantClassicFrameRow"..InPos.."Title"]:SetPoint("TOPLEFT", 3, -2);
			InPos = InPos + 1;
		end

		-- Set the header
		local name = AccountantClassicFrame:GetName();
		local header = _G[name.."TitleText"];
		if ( header ) then
			header:SetText(L["ACCLOC_TITLE"]);
		end
	end
end

local function AccountantClassic_SettleTabText()
	AccountantClassicFrameTab1:SetText(L["ACCLOC_SESS"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab1, 20);
	
	AccountantClassicFrameTab2:SetText(L["ACCLOC_DAY"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab2, 20);
	
	AccountantClassicFrameTab3:SetText(L["ACCLOC_PRVDAY"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab3, 20);
	
	AccountantClassicFrameTab4:SetText(L["ACCLOC_WEEK"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab4, 20);
	
	AccountantClassicFrameTab5:SetText(L["ACCLOC_PRVWEEK"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab5, 20);
	
	AccountantClassicFrameTab6:SetText(L["ACCLOC_MONTH"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab6, 20);
	
	AccountantClassicFrameTab7:SetText(L["ACCLOC_PRVMON"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab7, 20);

	AccountantClassicFrameTab8:SetText(L["ACCLOC_TOTAL"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab8, 20);

	AccountantClassicFrameTab9:SetText(L["ACCLOC_CHARS"]);
	PanelTemplates_TabResize(AccountantClassicFrameTab9, 25);
	
	PanelTemplates_SetNumTabs(AccountantClassicFrame, AC_TABS);
	PanelTemplates_SetTab(AccountantClassicFrame, AccountantClassicFrameTab1);
	PanelTemplates_UpdateTabs(AccountantClassicFrame);
end

local function AccountantClassic_PopulateCharacterList()
	local i = 1;
	local serverkey, servervalue, charkey, charvalue;

	if (#AC_SCROLL_LIST > 0) then
		AC_SCROLL_LIST = {};
	end
	for serverkey, servervalue in pairs(Accountant_ClassicSaveData) do
		for charkey, charvalue in pairs(Accountant_ClassicSaveData[serverkey]) do
			AC_SCROLL_LIST[i] = { serverkey, charkey };
			i = i + 1;
		end
	end
	AC_CURR_LINES = i - 1;

	-- Create and align any new entry buttons that we need
	for i = 1, AC_CURR_LINES do
		if (not _G["AccountantClassicCharacterEntry"..i]) then
			local f = CreateFrame("Frame", "AccountantClassicCharacterEntry"..i, AccountantClassicFrame, "AccountantClassicRowTemplate");
			if i == 1 then
				f:SetPoint("TOPLEFT", "AccountantClassicScrollBar", "TOPLEFT", 0, 0);
			else
				f:SetPoint("TOPLEFT", "AccountantClassicCharacterEntry"..(i - 1), "BOTTOMLEFT", 0, -1);
			end
		end
	end
end

local function AccountantClassicFrameCharacterDropDown_Setup()
	UIDropDownMenu_Initialize(AccountantClassicFrameCharacterDropDown, AccountantClassicFrameCharacterDropDown_Init);
	for i = 1, #AC_SCROLL_LIST do
		if (AccountantClassic_Server == AC_SCROLL_LIST[i][1] and AccountantClassic_Player == AC_SCROLL_LIST[i][2]) then
			AC_SELECTED_CHAR_NUM = i;
		end
	end
	UIDropDownMenu_SetSelectedValue(AccountantClassicFrameCharacterDropDown, AC_SELECTED_CHAR_NUM);
	UIDropDownMenu_SetWidth(AccountantClassicFrameCharacterDropDown, 200);
end

function AccountantClassic_OnLoad(self)
	-- Setup
	AccountantClassic_LoadData();
	AccountantClassic_SetLabels();

	-- Cash
	AccountantClassic_CurrentMoney = GetMoney();
	-- Check if there is any un-recorded money in or out
	if (AccountantClassic_LastSessionMoney ~= AccountantClassic_CurrentMoney) then
		AccountantClassic_Mode = "OTHER";
		AccountantClassic_LastMoney = AccountantClassic_LastSessionMoney;
		AccountantClassic_UpdateLog();
	end
	AccountantClassic_LastMoney = AccountantClassic_CurrentMoney;
	
	-- hooks
	AccountantClassic_RepairAllItems_old = RepairAllItems;
	RepairAllItems = AccountantClassic_RepairAllItems;
--	AccountantClassic_CursorHasItem_old = CursorHasItem;
--	CursorHasItem = AccountantClassic_CursorHasItem;

	-- tabs
	AccountantClassic_SettleTabText();

	AccountantClassic_PopulateCharacterList();
	AccountantClassicFrameCharacterDropDown_Setup();

	ACC_Print(L["ACCLOC_LOADED"]);
end

function AccountantClassic_LoadData()
	for key,value in pairs(AccountantClassic_Data) do
		for modekey,mode in pairs(AccountantClassic_LogModes) do
			AccountantClassic_Data[key][mode] = {In=0,Out=0};
		end
	end

	local cdate = date("%d/%m/%y");
	local cweek = "";
	local cmonth = date("%m");

	order = 1;
	for key, value in pairs(AccountantClassic_Data) do
		if (AccountantClassic_Profile["data"][key] == nil) then
			AccountantClassic_Profile["data"][key] = { };
		end
		if (AC_NewDB) then
			if (Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player]["data"][cdate][key] == nil) then
				Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player]["data"][cdate][key] = {
					In = 0;
					Out = 0;
				};
			end
		end
		for modekey,mode in pairs(AccountantClassic_LogModes) do
			if (AccountantClassic_Profile["data"][key][mode] == nil) then
				AccountantClassic_Profile["data"][key][mode] = {In=0, Out=0};
			end
			AccountantClassic_Data[key][mode].In  = AccountantClassic_Profile["data"][key][mode].In;
			AccountantClassic_Data[key][mode].Out = AccountantClassic_Profile["data"][key][mode].Out;
		end
		-- Here we reset session data
		AccountantClassic_Data[key]["Session"].In = 0;
		AccountantClassic_Data[key]["Session"].Out = 0;

--[[
		-- Old Version Conversion
		if (AccountantClassic_Profile["data"][key].TotalIn ~= nil) then
			AccountantClassic_Profile["data"][key]["Total"].In = AccountantClassic_Profile["data"][key].TotalIn;
			AccountantClassic_Data[key]["Total"].In = AccountantClassic_Profile["data"][key].TotalIn;
			AccountantClassic_Profile["data"][key].TotalIn = nil;
		end
		if (AccountantClassic_Profile["data"][key].TotalOut ~= nil) then
			AccountantClassic_Profile["data"][key]["Total"].Out = AccountantClassic_Profile["data"][key].TotalOut;
			AccountantClassic_Data[key]["Total"].Out = AccountantClassic_Profile["data"][key].TotalOut;
			AccountantClassic_Profile["data"][key].TotalOut = nil;
		end
		if (Accountant_SaveData[key] ~= nil) then
			Accountant_SaveData[key] = nil;
		end
		-- End OVC
]]
		AccountantClassic_Data[key].order = order;
		order = order + 1;
	end
	AccountantClassic_Profile["options"].version = AccountantClassic_Version;
	-- Here we retrieve the last session money before we set the option-value to the current one
	AccountantClassic_LastSessionMoney = AccountantClassic_Profile["options"].totalcash;
	AccountantClassic_Profile["options"].totalcash = GetMoney();

	-- Since we now (2016/12/17) supported to show specifc character or all characters' incoming / 
	-- outgoing data in each logmode, we have to deal with the date / week / month's rotating for all
	-- characters, not just the current one.
	local serverkey, servervalue, charkey, charvalue;
	for serverkey, servervalue in pairs(Accountant_ClassicSaveData) do
		for charkey, charvalue in pairs(Accountant_ClassicSaveData[serverkey]) do
			-- we need lastsessiondate, codes should not be necessary once every player's all characters have this option value being set
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"].lastsessiondate == nil) then
				Accountant_ClassicSaveData[serverkey][charkey]["options"].lastsessiondate = Accountant_ClassicSaveData[serverkey][charkey]["options"]["date"];
			end
			-- Check to see if the day has rolled over
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"]["date"] ~= cdate) then
				-- It's a new day! clear out the day tab
				Accountant_ClassicSaveData[serverkey][charkey]["options"]["prvday"] = Accountant_ClassicSaveData[serverkey][charkey]["options"]["date"];
				Accountant_ClassicSaveData[serverkey][charkey]["options"]["date"] = cdate;
				for mode, value in pairs(Accountant_ClassicSaveData[serverkey][charkey]["data"]) do
					if (not Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvDay"]) then
						Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvDay"] = { In = 0, Out = 0 };
					end
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvDay"].In = Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Day"].In;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvDay"].Out = Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Day"].Out;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Day"].In = 0;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Day"].Out = 0;
				end
				if (serverkey == AccountantClassic_Server and charkey == AccountantClassic_Player) then
					for mode, value in pairs(AccountantClassic_Data) do
						AccountantClassic_Data[mode]["PrvDay"].In = AccountantClassic_Data[mode]["Day"].In;
						AccountantClassic_Data[mode]["PrvDay"].Out = AccountantClassic_Data[mode]["Day"].Out;
						AccountantClassic_Data[mode]["Day"].In = 0;
						AccountantClassic_Data[mode]["Day"].Out = 0;
					end
				end
			end
			-- Check to see if the week has rolled over
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"]["dateweek"] ~= AccountantClassic_WeekStart()) then
				-- It's a new week! clear out the week tab
				Accountant_ClassicSaveData[serverkey][charkey]["options"]["prvdateweek"] = Accountant_ClassicSaveData[serverkey][charkey]["options"]["dateweek"];
				Accountant_ClassicSaveData[serverkey][charkey]["options"]["dateweek"] = AccountantClassic_WeekStart();
				for mode, value in pairs(Accountant_ClassicSaveData[serverkey][charkey]["data"]) do
					if (not Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvWeek"]) then
						Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvWeek"] = { In = 0, Out = 0 };
					end
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvWeek"].In = Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Week"].In;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvWeek"].Out = Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Week"].Out;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Week"].In = 0;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Week"].Out = 0;
				end
				if (serverkey == AccountantClassic_Server and charkey == AccountantClassic_Player) then
					AccountantClassic_Data[mode]["PrvWeek"].In = AccountantClassic_Data[mode]["Week"].In;
					AccountantClassic_Data[mode]["PrvWeek"].Out = AccountantClassic_Data[mode]["Week"].Out;
					AccountantClassic_Data[mode]["Week"].In = 0;
					AccountantClassic_Data[mode]["Week"].Out = 0;
				end
			end
			-- Check to see if the month has rolled over
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"]["month"] ~= cmonth) then
				-- It's a new month! clear out the month tab
				Accountant_ClassicSaveData[serverkey][charkey]["options"]["prvmonth"] = Accountant_ClassicSaveData[serverkey][charkey]["options"]["month"];
				Accountant_ClassicSaveData[serverkey][charkey]["options"]["month"] = cmonth;
				for mode, value in pairs(Accountant_ClassicSaveData[serverkey][charkey]["data"]) do
					if (not Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvMonth"]) then 
						Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvMonth"] = { In = 0, Out = 0};
					end
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvMonth"].In = Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Month"].In;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["PrvMonth"].Out = Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Month"].Out;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Month"].In = 0;
					Accountant_ClassicSaveData[serverkey][charkey]["data"][mode]["Month"].Out = 0;
				end
				if (serverkey == AccountantClassic_Server and charkey == AccountantClassic_Player) then
					AccountantClassic_Data[mode]["PrvMonth"].In = AccountantClassic_Data[mode]["Month"].In;
					AccountantClassic_Data[mode]["PrvMonth"].Out = AccountantClassic_Data[mode]["Month"].Out;
					AccountantClassic_Data[mode]["Month"].In = 0;
					AccountantClassic_Data[mode]["Month"].Out = 0;
				end
			end
		end
	end
	
	AccountantClassic_Profile["options"].lastsessiondate = cdate;
end

function Accountant_Slash(msg)
	if msg == nil or msg == "" then
		msg = "log";
	end
	local args = {n=0}
	local function helper(word) table.insert(args, word) end
	string.gsub(msg, "[_%w]+", helper);
	if args[1] == 'log'  then
		ShowUIPanel(AccountantClassicFrame);
	elseif args[1] == 'verbose' then
		if AccountantClassic_Verbose == nil then
			AccountantClassic_Verbose = 1;
			ACC_Print("Verbose Mode On");
		else
			AccountantClassic_Verbose = nil;
			ACC_Print("Verbose Mode Off");
		end
	elseif args[1] == 'week' then
		ACC_Print(AccountantClassic_WeekStart());
	else
		AccountantClassic_ShowUsage();
	end
end

function AccountantClassic_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	local oldmode = AccountantClassic_Mode;

	if (event == "ADDON_LOADED" and arg1 == "Accountant_Classic") then
		AccountantClassic_InitOptions();
	end

	if ( event == "UNIT_NAME_UPDATE" and arg1 == "player" ) or (event=="PLAYER_ENTERING_WORLD") then
		if (AccountantClassic_GotName) then
			return;
		end
		local playerName = UnitName("player");
		if ( playerName ~= UNKNOWNBEING and playerName ~= UNKNOWNOBJECT and playerName ~= nil ) then
			AccountantClassic_GotName = true;
			AccountantClassic_OnLoad();
			--AccountantClassicOptions_OnLoad();
			AccountantClassicMoneyInfoFrame_Init();

		end
		return;
	end

	if ( 
	event == "GARRISON_MISSION_FINISHED" or 
	event == "GARRISON_UPDATE" or
	event == "GARRISON_ARCHITECT_OPENED" or
	event == "GARRISON_MISSION_NPC_OPENED" or
	event == "GARRISON_SHIPYARD_NPC_OPENED"
	) then
		AccountantClassic_Mode = "GARRISON";
	elseif ( 
	event == "GARRISON_ARCHITECT_CLOSED" or
	event == "GARRISON_MISSION_NPC_CLOSED" or
	event == "GARRISON_SHIPYARD_NPC_CLOSED" or
	event == "BARBER_SHOP_APPEARANCE_APPLIED" or
	event == "BARBER_SHOP_CLOSE" or
	event == "TRANSMOGRIFY_CLOSE" or
	event == "VOID_STORAGE_CLOSE" or
	event == "MERCHANT_CLOSED" or
	event == "TRADE_CLOSE" or
	event == "TRAINER_CLOSED" or
	event == "AUCTION_HOUSE_CLOSED"
	) then
		AccountantClassic_Mode = "";
	elseif (
	event == "GUILDBANKFRAME_OPENED" or 
	event == "GUILDBANK_UPDATE_MONEY" or 
	event == "GUILDBANK_UPDATE_WITHDRAWMONEY"
	) then
		AccountantClassic_Mode = "GUILD";
	elseif event == "GUILDBANKFRAME_CLOSED" then
		AccountantClassic_Mode = "";
	elseif event == "LFG_COMPLETION_REWARD" then
		AccountantClassic_Mode = "LFG";
	elseif (event == "BARBER_SHOP_OPEN" or event == "BARBER_SHOP_SUCCESS") then
		AccountantClassic_Mode = "BARBER";
	elseif event == "TRANSMOGRIFY_OPEN" then
		AccountantClassic_Mode = "TRANSMO";
	elseif event == "VOID_STORAGE_OPEN" then
		AccountantClassic_Mode = "VOID";
	elseif event == "MERCHANT_SHOW" then
		AccountantClassic_Mode = "MERCH";
	elseif event == "MERCHANT_UPDATE" then
		if (InRepairMode() == true) then
			AccountantClassic_Mode = "REPAIRS";
		end
	elseif event == "TAXIMAP_OPENED" then
		AccountantClassic_Mode = "TAXI";
	elseif event == "TAXIMAP_CLOSED" then
		-- Commented out due to taximap closing before money transaction
		-- AccountantClassic_Mode = "";
	elseif event == "LOOT_OPENED" then
		AccountantClassic_Mode = "LOOT";
	elseif event == "LOOT_CLOSED" then
		-- Commented out due to loot window closing before money transaction
		-- AccountantClassic_Mode = "";
	elseif event == "TRADE_SHOW" then
		AccountantClassic_Mode = "TRADE";
	elseif event == "QUEST_COMPLETE" then
		AccountantClassic_Mode = "QUEST";
	elseif event == "QUEST_TURNED_IN" then
		AccountantClassic_Mode = "QUEST";
	elseif event == "QUEST_FINISHED" then
		-- Commented out due to quest window closing before money transaction
		-- AccountantClassic_Mode = "";	
	elseif event == "MAIL_INBOX_UPDATE" then
		if AccountantClassic_DetectAhMail() then
			AccountantClassic_Mode = "AH"
		else
			AccountantClassic_Mode = "MAIL"
		end
	elseif event == "CONFIRM_TALENT_WIPE" then
		AccountantClassic_Mode = "TRAIN";
	elseif event == "TRAINER_SHOW" then
		AccountantClassic_Mode = "TRAIN";
	elseif event == "AUCTION_HOUSE_SHOW" then
		AccountantClassic_Mode = "AH";
	elseif event == "PLAYER_MONEY" then
		AccountantClassic_UpdateLog();
	-- This event is supposed to be fired before PLAYER_MONEY.
	elseif event == "CHAT_MSG_MONEY" then
		AccountantClassic_OnShareMoney(arg1);
	end

	-- for combat lockdown
	if (event == "PLAYER_REGEN_DISABLED") then
		isInLockdown = true;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		isInLockdown = false;
	end
	
	if AccountantClassic_Verbose and AccountantClassic_Mode ~= oldmode then ACC_Print("Accountant mode changed to '"..AccountantClassic_Mode.."'"); end
	
	if (not Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].LDBDisplaySessionInfo) then
		Accountant_ClassicMiniMapLDB.text = AccountantClassic_GetFormattedValue(GetMoney());
	else
		Accountant_ClassicMiniMapLDB.text = AccountantClassic_ShowSessionNetMoney();
	end
end

-- codes by Tntdruid
function AccountantClassic_DetectAhMail()
	local numItems, totalItems = GetInboxNumItems();
	for x = 1, totalItems do    
		-- invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
		--    invoiceType : String - type of invoice ("buyer", "seller", or "seller_temp_invoice").
		local invoiceType = GetInboxInvoiceInfo(x);
		if (invoiceType == "seller") then
			return true;
		end
	end
end

function AccountantClassic_OnShareMoney(arg1)
	local gold, silver, copper, money, oldMode;

-- Parse the message for money gained.
	_, _, gold = string.find(arg1, "(%d+)" .. GOLD_AMOUNT)
	_, _, silver = string.find(arg1, "(%d+)" .. SILVER_AMOUNT)
	_, _, copper = string.find(arg1, "(%d+)" .. COPPER_AMOUNT)
	if (gold) then
		gold = tonumber(gold);
	else
		gold = 0;
	end
	if (silver) then
		silver = tonumber(silver);
	else
		silver = 0;
	end
	if (copper) then
		copper = tonumber(copper);
	else
		copper = 0;
	end

	money = copper + silver * 100 + gold * 10000

	oldMode = AccountantClassic_Mode;
	if (not AccountantClassic_LastMoney) then
		AccountantClassic_LastMoney = 0;
	end

-- This will force a money update with calculated amount.
	AccountantClassic_LastMoney = AccountantClassic_LastMoney - money;
	AccountantClassic_Mode = "LOOT";
	AccountantClassic_UpdateLog();
	AccountantClassic_Mode = oldMode;

-- This will suppress the incoming PLAYER_MONEY event.
	AccountantClassic_LastMoney = AccountantClassic_LastMoney + money;

end

function AccountantClassic_NiceCash(amount)
	local agold = 10000;
	local asilver = 100;
	local outstr = "";
	local gold = 0;
	local silver = 0;
	local cent = 0;

	if amount >= agold then
		gold = math.floor(amount / agold);
		outstr = "|cFFFFFF00" .. gold .. L["ACCLOC_GOLD"];
	end
	amount = amount - (gold * agold);
	if amount >= asilver then
		silver = math.floor(amount / asilver);
		if silver < 10 then
			silver = " "..silver;
		end
		outstr = outstr .. "|cFFDDDDDD" .. silver .. L["ACCLOC_SILVER"];
	end
	amount = amount - (silver * asilver);
	if amount > 0 then
		cent = amount;
		if cent < 10 then
			cent = " "..cent;
		end
		outstr = outstr .. "|cFFFF6600" .. cent .. L["ACCLOC_CENT"];
	end
	return outstr;
end

-- code adopted from SellTrash and MoneyFrame.lua
function AccountantClassic_GetFormattedValue(amount)
	local gold = floor(amount / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local goldDisplay = BreakUpLargeNumbers(gold);
	local silver = floor((amount - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(amount, COPPER_PER_SILVER);
	
	local TMP_GOLD_AMOUNT_TEXTURE = "%s\124TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0\124t";
	local TMP_SILVER_AMOUNT_TEXTURE = "%02d\124TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:2:0\124t";
	local TMP_COPPER_AMOUNT_TEXTURE = "%02d\124TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:2:0\124t";
	if (gold >0) then
		return format(TMP_GOLD_AMOUNT_TEXTURE.." "..TMP_SILVER_AMOUNT_TEXTURE.." "..TMP_COPPER_AMOUNT_TEXTURE, goldDisplay, 0, 0, silver, 0, 0, copper, 0, 0);
	elseif (silver >0) then 
		return format(SILVER_AMOUNT_TEXTURE.." "..TMP_COPPER_AMOUNT_TEXTURE, silver, 0, 0, copper, 0, 0);
	elseif (copper >0) then
		return format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
	else
		return "";
	end
end

function AccountantClassic_GetFormattedCurrency(currencyID)
	local name, amount, icon = GetCurrencyInfo(currencyID);
	
	if (amount >0) then
		local CURRENCY_TEXTURE = "%s\124T"..icon..":%d:%d:2:0\124t";
		return format(CURRENCY_TEXTURE.." ", BreakUpLargeNumbers(amount), 0, 0);
	else
		return "";
	end
end

function AccountantClassic_WeekStart()
	local oneday = 86400;
	local ct = time();
	local dt = date("*t",ct);
	local thisDay = dt["wday"];
	while thisDay ~= AccountantClassic_Profile["options"].weekstart do
		ct = ct - oneday;
		dt = date("*t",ct);
		thisDay = dt["wday"];
	end
	cdate = date(nil,ct);
	return string.sub(cdate,0,8);
end

function AccountantClassicScrollBar_Update()
	local lineplusoffset;
	FauxScrollFrame_Update(AccountantClassicScrollBar, AC_CURR_LINES, AC_CHAR_LINES, 19);
	for i = 1, AC_CHAR_LINES do
		lineplusoffset = i + FauxScrollFrame_GetOffset(AccountantClassicScrollBar);
		if (lineplusoffset <= AC_CURR_LINES) then
			local player_text, factionstr, faction_icon, classToken, class_color;
			local serverkey = AC_SCROLL_LIST[lineplusoffset][1];
			local charkey = AC_SCROLL_LIST[lineplusoffset][2];
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"].faction) then
				factionstr = Accountant_ClassicSaveData[serverkey][charkey]["options"].faction;
				faction_icon = "|TInterface\\PVPFrame\\PVP-Currency-"..factionstr..":0:0|t%s - %s";
				if (Accountant_ClassicSaveData[serverkey][charkey]["options"].class) then
					classToken = Accountant_ClassicSaveData[serverkey][charkey]["options"].class;
					class_color = "|c"..RAID_CLASS_COLORS[classToken]["colorStr"];
				end
				if(classToken) then 
					_G["AccountantClassicCharacterEntry"..i].Title:SetText(format(class_color..faction_icon.."|r", serverkey, charkey));
				else
					_G["AccountantClassicCharacterEntry"..i].Title:SetText(format(faction_icon, serverkey, charkey));
				end
			else
				_G["AccountantClassicCharacterEntry"..i].Title:SetText(charkey);
			end
			if Accountant_ClassicSaveData[serverkey][charkey]["options"]["totalcash"] ~= nil then
				_G["AccountantClassicCharacterEntry"..i].In:SetText("|cFFFFFFFF"..AccountantClassic_GetFormattedValue(Accountant_ClassicSaveData[serverkey][charkey]["options"]["totalcash"]));
				_G["AccountantClassicCharacterEntry"..i].Out:SetText(AccountantClassic_ParseDateStrings(Accountant_ClassicSaveData[serverkey][charkey]["options"]["lastsessiondate"], 2));
			else
				_G["AccountantClassicCharacterEntry"..i].In:SetText("Unknown");
			end
			_G["AccountantClassicCharacterEntry"..i]:Show();
		elseif (_G["AccountantClassicCharacterEntry"..i]) then
			_G["AccountantClassicCharacterEntry"..i]:Hide();
		end
	end
end

function AccountantClassic_OnShow(self)
	-- Check to see if the day has rolled over
	--tnt
	--cdate = date();
	local cdate = date ("%d/%m/%y");
	cdate = string.sub(cdate,0,8);
	local cmonth = date ("%m")
	

	if ( AccountantClassic_Profile["options"]["date"] ~= cdate ) then
		-- Its a new day! clear out the day tab
		for mode,value in pairs(AccountantClassic_Data) do
			AccountantClassic_Data[mode]["Day"].In = 0;
			AccountantClassic_Profile["data"][mode]["Day"].In = 0;
			AccountantClassic_Data[mode]["Day"].Out = 0;
			AccountantClassic_Profile["data"][mode]["Day"].Out = 0;
		end
	end
	AccountantClassic_Profile["options"]["date"] = cdate;

	-- Check to see if the week has rolled over
	if ( AccountantClassic_Profile["options"]["dateweek"] ~= AccountantClassic_WeekStart() ) then
		-- Its a new week! clear out the week tab
		for mode,value in pairs(AccountantClassic_Data) do
			AccountantClassic_Data[mode]["Week"].In = 0;
			AccountantClassic_Profile["data"][mode]["Week"].In = 0;
			AccountantClassic_Data[mode]["Week"].Out = 0;
			AccountantClassic_Profile["data"][mode]["Week"].Out = 0;
		end
	end
	AccountantClassic_Profile["options"]["dateweek"] = AccountantClassic_WeekStart();

	-- Check to see if the month has rolled over
	if ( AccountantClassic_Profile["options"]["month"] ~= cmonth ) then
		-- Its a new month! clear out the month tab
		for mode,value in pairs(AccountantClassic_Data) do
			AccountantClassic_Data[mode]["Month"].In = 0;
			AccountantClassic_Profile["data"][mode]["Month"].In = 0;
			AccountantClassic_Data[mode]["Month"].Out = 0;
			AccountantClassic_Profile["data"][mode]["Month"].Out = 0;
		end
	end
	AccountantClassic_Profile["options"]["month"] = cmonth;

	AccountantClassic_SetLabels();
	if ( AccountantClassic_CurrentTab ~= AC_TABS ) then
		-- for all the tabs except for character tab
		AccountantClassicScrollBar:Hide();
		for i = 1, AC_CURR_LINES do
			if (_G["AccountantClassicCharacterEntry"..i]) then
				_G["AccountantClassicCharacterEntry"..i]:Hide();
			end
		end
		if (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "Session")) then
			AccountantClassicFrameCharacterDropDown:Hide();
		else
			AccountantClassicFrameCharacterDropDown:Show();
		end

		local TotalIn = 0;
		local TotalOut = 0;
		local mode = AccountantClassic_LogModes[AccountantClassic_CurrentTab];
		local colIn, colOut;
		for key, value in pairs(AccountantClassic_Data) do
			colIn = _G["AccountantClassicFrameRow"..AccountantClassic_Data[key].InPos.."In"];
			colOut = _G["AccountantClassicFrameRow"..AccountantClassic_Data[key].InPos.."Out"];

			local mIn = 0;
			local mOut = 0;
			if (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "Session")) then
				mIn = AccountantClassic_Data[key][mode].In;
				mOut = AccountantClassic_Data[key][mode].Out;
			else
				if (AC_SELECTED_CHAR_NUM <= #AC_SCROLL_LIST) then
					local j = AC_SELECTED_CHAR_NUM;
					local serverkey = AC_SCROLL_LIST[j][1];
					local charkey = AC_SCROLL_LIST[j][2];
					
					if (Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode] and Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["In"]) then
						mIn = Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["In"];
					end
					if (Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode] and Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["Out"]) then
						mOut = Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["Out"];
					end
				elseif (AC_SELECTED_CHAR_NUM == #AC_SCROLL_LIST + 1) then
					local serverkey, servervalue, charkey, charvalue;
					for serverkey, servervalue in pairs(Accountant_ClassicSaveData) do
						for charkey, charvalue in pairs(Accountant_ClassicSaveData[serverkey]) do
							if (Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode] and Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["In"]) then
								mIn = mIn + Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["In"];
							end
							if (Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode] and Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["Out"]) then
								mOut = mOut + Accountant_ClassicSaveData[serverkey][charkey]["data"][key][mode]["Out"];
							end
						end
					end
				end
			end

			TotalIn = TotalIn + mIn;
			TotalOut = TotalOut + mOut;

			colIn:SetText(AccountantClassic_GetFormattedValue(mIn));
			colOut:SetText(AccountantClassic_GetFormattedValue(mOut));
		end
		AccountantClassicFrameTotalInValue:SetText("|cFFFFFFFF"..AccountantClassic_GetFormattedValue(TotalIn));
		AccountantClassicFrameTotalOutValue:SetText("|cFFFFFFFF"..AccountantClassic_GetFormattedValue(TotalOut));
		if (TotalOut > TotalIn) then
			diff = TotalOut - TotalIn;
			AccountantClassicFrameTotalFlow:SetText("|cFFFF3333"..L["ACCLOC_NETLOSS"]..":");
			AccountantClassicFrameTotalFlowValue:SetText("|cFFFF3333"..AccountantClassic_GetFormattedValue(diff));
		else
			if (TotalOut ~= TotalIn) then
				diff = TotalIn - TotalOut;
				AccountantClassicFrameTotalFlow:SetText("|cFF00FF00"..L["ACCLOC_NETPROF"]..":");
				AccountantClassicFrameTotalFlowValue:SetText("|cFF00FF00"..AccountantClassic_GetFormattedValue(diff));
			else
				AccountantClassicFrameTotalFlow:SetText(L["ACCLOC_NET"]..":");
				AccountantClassicFrameTotalFlowValue:SetText("");
			end
		end
		-- Set row 18 to be empty so that the total row from all characters will be clean out
		_G["AccountantClassicFrameRow18Title"]:SetText("");
		_G["AccountantClassicFrameRow18In"]:SetText("");
		

	else
		-- all characters' tab
		-- AccountantClassicFrame.ShowAll:Hide();
		AccountantClassicFrameCharacterDropDown:Hide();
		
		local alltotal = 0;
		local allin = 0;
		local allout = 0;
		local i = 1;
		local serverkey, servervalue, charkey, charvalue;

		i = 1;
		for serverkey, servervalue in pairs(Accountant_ClassicSaveData) do
			for charkey, charvalue in pairs(Accountant_ClassicSaveData[serverkey]) do
				if Accountant_ClassicSaveData[serverkey][charkey]["options"]["totalcash"] ~= nil then
					alltotal = alltotal + Accountant_ClassicSaveData[serverkey][charkey]["options"]["totalcash"];
				end

				for key, value in pairs(Accountant_ClassicSaveData[serverkey][charkey]["data"]) do
					allin = allin + Accountant_ClassicSaveData[serverkey][charkey]["data"][key]["Total"]["In"];
					allout = allout + Accountant_ClassicSaveData[serverkey][charkey]["data"][key]["Total"]["Out"];
				end
				i = i + 1;
			end
		end
		AccountantClassicScrollBar_Update();

		AccountantClassicFrameTotalInValue:SetText("|cFFFFFFFF"..AccountantClassic_GetFormattedValue(allin));
		AccountantClassicFrameTotalOutValue:SetText("|cFFFFFFFF"..AccountantClassic_GetFormattedValue(allout));
		if (allout > allin) then
			diff = allout - allin;
			AccountantClassicFrameTotalFlow:SetText("|cFFFF3333"..L["ACCLOC_NETLOSS"]..":");
			AccountantClassicFrameTotalFlowValue:SetText("|cFFFF3333"..AccountantClassic_GetFormattedValue(diff));
		else
			if allout ~= allin then
				diff = allin - allout;
				AccountantClassicFrameTotalFlow:SetText("|cFF00FF00"..L["ACCLOC_NETPROF"]..":");
				AccountantClassicFrameTotalFlowValue:SetText("|cFF00FF00"..AccountantClassic_GetFormattedValue(diff));
			else
				AccountantClassicFrameTotalFlow:SetText(L["ACCLOC_NET"]..":");
				AccountantClassicFrameTotalFlowValue:SetText("");
			end
		end
		_G["AccountantClassicFrameRow18Title"]:SetText(L["ACCLOC_SUM"]);
		_G["AccountantClassicFrameRow18In"]:SetText("|cFFFFFFFF"..AccountantClassic_GetFormattedValue(alltotal));
		
	end
	SetPortraitTexture(AccountantClassicFramePortrait, "player");

	-- Extra info
	if (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "Week")) then
		AccountantClassicFrameExtra:SetText(L["ACCLOC_WEEKSTART"]..":");
		AccountantClassicFrameExtraValue:SetText(AccountantClassic_ParseDateStrings(AccountantClassic_Profile["options"]["dateweek"], 1));
	elseif (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "PrvWeek")) then
		if (AccountantClassic_Profile["options"]["prvdateweek"]) then
			AccountantClassicFrameExtra:SetText(L["ACCLOC_WEEKSTART"]..":");
			AccountantClassicFrameExtraValue:SetText(AccountantClassic_ParseDateStrings(AccountantClassic_Profile["options"]["prvdateweek"], 1));
		else
			AccountantClassicFrameExtra:SetText("");
			AccountantClassicFrameExtraValue:SetText("");
		end
	elseif (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "Month")) then
		local m = tonumber(AccountantClassic_Profile["options"]["month"]);
		AccountantClassicFrameExtra:SetText("");
		AccountantClassicFrameExtraValue:SetText(months[m]);
	elseif (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "PrvMonth")) then
		if (AccountantClassic_Profile["options"]["prvmonth"]) then
			local m = tonumber(AccountantClassic_Profile["options"]["prvmonth"]);
			AccountantClassicFrameExtra:SetText("");
			AccountantClassicFrameExtraValue:SetText(months[m]);
		else
			AccountantClassicFrameExtra:SetText("");
			AccountantClassicFrameExtraValue:SetText("");
		end
	elseif (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "Day")) then
		AccountantClassicFrameExtra:SetText("");
		AccountantClassicFrameExtraValue:SetText(AccountantClassic_ParseDateStrings(cdate, 2));
	elseif (AccountantClassic_CurrentTab == TableIndex(AccountantClassic_LogModes, "PrvDay")) then
		if (AccountantClassic_Profile["options"]["prvday"]) then
			AccountantClassicFrameExtra:SetText("");
			AccountantClassicFrameExtraValue:SetText(AccountantClassic_ParseDateStrings(AccountantClassic_Profile["options"]["prvday"], 2));
		else
			AccountantClassicFrameExtra:SetText("");
			AccountantClassicFrameExtraValue:SetText("");
		end
	else
		AccountantClassicFrameExtra:SetText("");
		AccountantClassicFrameExtraValue:SetText("");
	end

	PanelTemplates_SetTab(AccountantClassicFrame, AccountantClassic_CurrentTab);
	
end

function AccountantClassicFrameCharacterDropDown_Init()
	local info = { };
	for i = 1, #AC_SCROLL_LIST do
		local serverkey = AC_SCROLL_LIST[i][1];
		local charkey = AC_SCROLL_LIST[i][2];
		info = { };
		if (Accountant_ClassicSaveData[serverkey][charkey]["options"].faction) then
			local factionstr = Accountant_ClassicSaveData[serverkey][charkey]["options"].faction;
			local faction_icon = "Interface\\PVPFrame\\PVP-Currency-"..factionstr;
			info.icon = faction_icon
		end
		if (Accountant_ClassicSaveData[serverkey][charkey]["options"].class) then
			local class = Accountant_ClassicSaveData[serverkey][charkey]["options"].class;
			info.colorCode = "|c"..RAID_CLASS_COLORS[class]["colorStr"];
		end
		info.text = serverkey.." - "..charkey;
		info.value = i;
		info.arg1 = serverkey;
		info.arg2 = charkey;
		info.func = AccountantClassicFrameCharacterDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
	
	-- Added All Chars to dropdown
	info = { };
	info.text = L["ACCLOC_CHARS"];
	info.value = #AC_SCROLL_LIST + 1;
	info.tooltipTitle = L["ACCLOC_SHOWALLTIP"];
	info.tooltipOnButton = true;
	info.func = AccountantClassicFrameCharacterDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end

function AccountantClassicFrameCharacterDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedID(AccountantClassicFrameCharacterDropDown, self:GetID());
	AC_SELECTED_CHAR_NUM = self.value;
	AccountantClassic_OnShow();
end

function AccountantClassic_OnHide()
	if MYADDONS_ACTIVE_OPTIONSFRAME == self then
		ShowUIPanel(myAddOnsFrame);
	end
end

function ACC_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function AccountantClassic_ShowUsage()
	ACC_Print("/accountant log\n");
end

function AccountantClassic_ResetData()
	local logmode = AccountantClassic_LogModes[AccountantClassic_CurrentTab];
	if logmode == "Total" then
		logmode = L["ACCLOC_TOTAL"];
	elseif logmode == "Session" then
		logmode = L["ACCLOC_SESS"];
	elseif logmode == "Day" then
		logmode = L["ACCLOC_DAY"];
	elseif logmode == "PrvDay" then
		logmode = L["ACCLOC_PRVDAY"];
	elseif logmode == "Week" then
		logmode = L["ACCLOC_WEEK"];
	elseif logmode == "PrvWeek" then
		logmode = L["ACCLOC_PRVWEEK"];
	elseif logmode == "Month" then
		logmode = L["ACCLOC_MONTH"];
	elseif logmode == "PrvMonth" then
		logmode = L["ACCLOC_PRVMON"];
	else

	end

	-- Confirm box
	LibDialog:Register("ACCOUNTANT_RESET", {
		text = format(L["ACCLOC_RESET_CONF"], logmode),
		buttons = {
			{
				text = OKAY,
				on_click = function() AccountantClassic_ResetConfirmed(); end,
			},
			{
				text = CANCEL,
				on_click = function(self, mouseButton, down) LibDialog:Dismiss("ACCOUNTANT_RESET"); end,
			},
		},
		show_while_dead = true,
		hide_on_escape = true,
		is_exclusive = true,
		hide_on_escape = true,
		show_during_cinematic = false,
		
	});
	LibDialog:Spawn("ACCOUNTANT_RESET");
	
end

function AccountantClassic_ResetConfirmed()
	local mode = AccountantClassic_LogModes[AccountantClassic_CurrentTab];
	for key,value in pairs(AccountantClassic_Data) do
		AccountantClassic_Data[key][mode].In = 0;
		AccountantClassic_Data[key][mode].Out = 0;
		AccountantClassic_Profile["data"][key][mode].In = 0;
		AccountantClassic_Profile["data"][key][mode].Out = 0;
	end
	if AccountantClassicFrame:IsVisible() then
		AccountantClassic_OnShow();
	end
end

function AccountantClassic_CharacterRemovalConfirmed(server, character)
	local faction_icon = "";
	local class_color = "";
	for ka, va in pairs(Accountant_ClassicSaveData) do
		if (ka == server) then
			for kb, vb in pairs(Accountant_ClassicSaveData[ka]) do
				if (kb == character) then
					if (Accountant_ClassicSaveData[ka][kb]["options"].faction) then
						local factionstr = Accountant_ClassicSaveData[ka][kb]["options"].faction;
						faction_icon = "|TInterface\\PVPFrame\\PVP-Currency-"..factionstr..":0:0|t";
					end
					if (Accountant_ClassicSaveData[ka][kb]["options"].class) then
						local classToken = Accountant_ClassicSaveData[ka][kb]["options"].class;
						class_color = "|c"..RAID_CLASS_COLORS[classToken]["colorStr"];
					end
					Accountant_ClassicSaveData[ka][kb] = nil;
					ACC_Print(format(L["ACCLOC_CHARREMOVEDONE"], faction_icon..class_color..server, character));
					AccountantClassic_PopulateCharacterList();
					if AccountantClassicFrame:IsVisible() then
						AccountantClassic_OnShow();
					end
					return;
				end
			end
		end
	end
end

function AccountantClassic_UpdateLog()
	local cdate = date("%d/%m/%y");
	
	AccountantClassic_CurrentMoney = GetMoney();
	AccountantClassic_Profile["options"].totalcash = AccountantClassic_CurrentMoney;
	diff = AccountantClassic_CurrentMoney - AccountantClassic_LastMoney;
	AccountantClassic_LastMoney = AccountantClassic_CurrentMoney;
	if (diff == 0 or diff == nil) then
		return;
	end

	local mode = AccountantClassic_Mode;
	if mode == "" then mode = "OTHER"; end
	if (diff >0) then
		for key,logmode in pairs(AccountantClassic_LogModes) do
			if (logmode == "PrvWeek" or logmode == "PrvMonth" or logmode == "PrvDay") then
				-- do nothing
			else
				AccountantClassic_Data[mode][logmode].In = AccountantClassic_Data[mode][logmode].In + diff
				AccountantClassic_Profile["data"][mode][logmode].In = AccountantClassic_Data[mode][logmode].In;
				if (AC_NewDB) then
					if (logmode == "Day") then
						Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player]["data"][cdate][mode].In = AccountantClassic_Data[mode][logmode].In;
					end
				end
			end
		end
		if AccountantClassic_Verbose then ACC_Print("Gained "..AccountantClassic_NiceCash(diff).." from "..mode); end
	elseif (diff < 0) then
		diff = diff * -1;
		for key,logmode in pairs(AccountantClassic_LogModes) do
			if (logmode == "PrvWeek" or logmode == "PrvMonth" or logmode == "PrvDay") then
				-- do nothing
			else
				AccountantClassic_Data[mode][logmode].Out = AccountantClassic_Data[mode][logmode].Out + diff
				AccountantClassic_Profile["data"][mode][logmode].Out = AccountantClassic_Data[mode][logmode].Out;
				if (AC_NewDB) then
					if (logmode == "Day") then
						Accountant_Classic_NewDB[AccountantClassic_Server][AccountantClassic_Player]["data"][cdate][mode].Out = AccountantClassic_Data[mode][logmode].Out;
					end
				end
			end
		end
		if AccountantClassic_Verbose then ACC_Print("Lost "..AccountantClassic_NiceCash(diff).." from "..mode); end
	end

	-- special case mode resets
	if AccountantClassic_Mode == "REPAIRS" then
		AccountantClassic_Mode = "MERCH";
	end

	if AccountantClassicFrame:IsVisible() then
		AccountantClassic_OnShow();
	end
end

function AccountantClassicTab_OnClick(self)
	PanelTemplates_SetTab(AccountantClassicFrame, self:GetID());
	AccountantClassic_CurrentTab = self:GetID();
	PlaySound("igCharacterInfoTab");
	AccountantClassic_OnShow();
end

-- hooks

function AccountantClassic_RepairAllItems(guildBankRepair)
	if (not guildBankRepair) then
		AccountantClassic_Mode = "REPAIRS";
	end
	AccountantClassic_RepairAllItems_old(guildBankRepair);
end

function AccountantClassic_CursorHasItem()
	if InRepairMode() then
		AccountantClassic_Mode = "REPAIRS";
	end
	local toret = AccountantClassic_CursorHasItem_old();
	return toret;
end

function AccountantClassic_BackpackTokenFrame_Update()
	local name, count, icon, currencyID;
	local tokenstr = "";
	for i=1, MAX_WATCHED_TOKENS do
		name, count, icon, currencyID = GetBackpackCurrencyInfo(i);
		-- Update watched tokens
		if ( name ) then
			tokenstr = tokenstr..AccountantClassic_GetFormattedCurrency(currencyID).." ";
		end
	end
	return tokenstr;
end

function AccountantClassicMoneyInfoFrame_Update()
	local frametxt = "|cFFFFFFFF"..AccountantClassic_GetFormattedValue(GetMoney());
	if (frametxt ~= AC_MNYSTR) then
		AccountantClassicMoneyInfoText:SetText(frametxt);
		--AccountantClassicMoneyInfoText:SetText(AccountantClassic_BackpackTokenFrame_Update());
		AC_MNYSTR = frametxt;
	end
end

function AccountantClassicMoneyInfoFrame_HandleMouseDown(self, buttonName)    
	-- Prevent activation when in combat
	if (isInLockdown) then
		return;
	end
	-- Handle left button clicks
	if (buttonName == "LeftButton") then
		AccountantClassicMoneyInfoFrame:StartMoving();
		GameTooltip:Hide();
	elseif (buttonName == "RightButton") then
		AccountantClassic_ButtonOnClick();
		GameTooltip_Hide();
	end
end

function AccountantClassicMoneyInfoFrame_HandleMouseUp(self, button)
	AccountantClassicMoneyInfoFrame:StopMovingOrSizing();
--[[	local x, y;

	_, _, _, x, y = AccountantClassicMoneyInfoFrame:GetPoint();
	AccountantClassic_Profile["options"].moneyinfoframe_x = x;
	AccountantClassic_Profile["options"].moneyinfoframe_y = y;
]]
end

function AccountantClassicMoneyInfoFrame_Init()
--	local offsetx = AccountantClassic_Profile["options"].moneyinfoframe_x;
--	local offsety = AccountantClassic_Profile["options"].moneyinfoframe_y;

	if(AccountantClassic_Profile["options"].showmoneyinfo == nil) then
		AccountantClassic_Profile["options"].showmoneyinfo = true;
	end
	if(AccountantClassic_Profile["options"].showmoneyinfo == true) then
		AccountantClassicMoneyInfoFrame:Show();
--[[		if (offsetx  and offsety ) then
			AccountantClassicMoneyInfoFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", offsetx, offsety);
		end
]]
	else
		AccountantClassicMoneyInfoFrame:Hide();
	end
end

function AccountantClassic_ShowSessionNetMoney()
	local amoney_str = "";

	local TotalIn = 0;
	local TotalOut = 0;
	local diff = 0;
	if (AccountantClassic_Data["REPAIRS"]["Session"]) then
		for key,value in pairs(AccountantClassic_Data) do
			TotalIn = TotalIn + AccountantClassic_Data[key]["Session"].In;
			TotalOut = TotalOut + AccountantClassic_Data[key]["Session"].Out;
		end
		if (TotalOut > TotalIn) then
			diff = TotalOut-TotalIn;
			amoney_str = amoney_str.."|cFFFF3333"..L["ACCLOC_NETLOSS"]..": ";
			amoney_str = amoney_str..AccountantClassic_GetFormattedValue(diff);
		else
			diff = TotalIn-TotalOut;
			if (diff == 0) then
				amoney_str = AccountantClassic_GetFormattedValue(GetMoney());
			else
				amoney_str = amoney_str.."|cFF00FF00"..L["ACCLOC_NETPROF"]..": ";
				amoney_str = amoney_str..AccountantClassic_GetFormattedValue(diff);
			end
		end
	else
		amoney_str = AccountantClassic_GetFormattedValue(GetMoney());
	end
	
	if (amoney_str) then
		return amoney_str;
	end
end

function AccountantClassic_ShowSessionToolTip()
	local amoney_str = "";

	local TotalIn = 0;
	local TotalOut = 0;
	for key,value in pairs(AccountantClassic_Data) do
		TotalIn = TotalIn + AccountantClassic_Data[key]["Session"].In;
		TotalOut = TotalOut + AccountantClassic_Data[key]["Session"].Out;
	end
	amoney_str = "|cFFFFFFFF"..L["ACCLOC_TOT_IN"]..": "..AccountantClassic_GetFormattedValue(TotalIn).."\n";
	amoney_str = amoney_str.."|cFFFFFFFF"..L["ACCLOC_TOT_OUT"]..": "..AccountantClassic_GetFormattedValue(TotalOut).."\n";
	if TotalOut > TotalIn then
		diff = TotalOut-TotalIn;
		amoney_str = amoney_str.."|cFFFF3333"..L["ACCLOC_NETLOSS"]..": ";
		amoney_str = amoney_str..AccountantClassic_GetFormattedValue(diff);
	else
		if TotalOut ~= TotalIn then
			diff = TotalIn-TotalOut;
			amoney_str = amoney_str.."|cFF00FF00"..L["ACCLOC_NETPROF"]..": ";
			amoney_str = amoney_str..AccountantClassic_GetFormattedValue(diff);
		else
			-- do nothing
		end
	end
	
	if (amoney_str) then
		return amoney_str;
	end
end

function AccountantClassicMoneyInfoFrame_OnEnter(self)
	if (isInLockdown) then
		return;
	end

	if (not GameTooltip:IsShown()) then
		local amoney_str = AccountantClassic_ShowSessionToolTip();

		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -10, 0);
		GameTooltip:SetBackdropColor(0, 0, 0, 0.5);
		GameTooltip:SetText("|cFFFFFFFF"..L["ACCLOC_TITLE"].." - "..L["ACCLOC_SESS"], 1, 1, 1, nil, 1);
		GameTooltip:AddLine(amoney_str, 1, 1, 1, 1);
		local tokenstr = AccountantClassic_BackpackTokenFrame_Update();
		if (tokenstr) then
			GameTooltip:AddLine(tokenstr, 1, 1, 1, 1);
		end
		if (Accountant_ClassicSaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showintrotip == true) then
			GameTooltip:AddLine("("..L["ACCLOC_TIP2"]..")", 0.8, 0.8, 0.8, 1);
		end
		GameTooltip:Show();
	else
		GameTooltip:Hide();
	end
end

function AccountantClassicMoneyInfoFrame_OnLeave(self)
	GameTooltip_Hide();
end

function AccountantClassic_ParseDateStrings(s, typ)
	local mm, dd, yy;
	local sdate = s;
	
	if (typ == 1) then -- mm/dd/yy, currently used in dateweek (WeekStart)
		mm = string.sub(sdate, 1, 2);
		dd = string.sub(sdate, 4, 5);
	else
		dd = string.sub(sdate, 1, 2);
		mm = string.sub(sdate, 4, 5);
	end
	yy = string.sub(sdate, 7, 8);

--[[ /////////////////////////
	[1] = "mm/dd/yy";
	[2] = "dd/mm/yy";
	[3] = "yy/mm/dd";
]]
	if (AccountantClassic_Profile["options"].dateformat == 1) then
		sdate = mm.."/"..dd.."/"..yy;
	elseif (AccountantClassic_Profile["options"].dateformat == 2) then
		sdate = dd.."/"..mm.."/"..yy;
	else
		sdate = yy.."/"..mm.."/"..dd;
	end
	
	return sdate;
end

