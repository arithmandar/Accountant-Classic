--[[
$Id$
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("Accountant_Classic");
local L = LibStub("AceLocale-3.0"):GetLocale("Accountant_Classic");
local LibDialog = LibStub("LibDialog-1.0");

ACCOUNTANT_OPTIONS_TITLE = ACCLOC_OPTS;

function AccountantClassicOptions_Toggle()
	if(InterfaceOptionsFrame:IsVisible()) then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory(L["ACCLOC_TITLE"]);
		-- Yes we have to call this twice
		InterfaceOptionsFrame_OpenToCategory(L["ACCLOC_TITLE"]);
	end
end

function AccountantClassicOptions_OnLoad(self)
	UIPanelWindows['AccountantClassicOptionsFrame'] = {area = 'center', pushable = 0};
	
	self.name = L["ACCLOC_TITLE"];
	InterfaceOptions_AddCategory(self);
	if (LibStub:GetLibrary("LibAboutPanel", true)) then
		LibStub("LibAboutPanel").new(L["ACCLOC_TITLE"], "Accountant_Classic");
	end
end

function AccountantClassicOptions_OnShow()
	AccountantClassicOptionsFrameToggleButton:SetChecked(AccountantClassic_Profile["options"].showbutton);
	AccountantClassicOptionsFrameToggleMoneyDisplay:SetChecked(AccountantClassic_Profile["options"].showmoneyinfo);
	AccountantClassicOptionsFrameToggleDisplayInstroTips:SetChecked(AccountantClassic_Profile["options"].showintrotip);
	AccountantClassicOptionsFrameToggleMoneyOnMiniMap:SetChecked(AccountantClassic_Profile["options"].showmoneyonbutton);
	AccountantClassicOptionsFrameToggleSessionOnMiniMap:SetChecked(AccountantClassic_Profile["options"].showsessiononbutton);
	AccountantClassicOptionsFrameToggleMoneyDisplayOnLDB:SetChecked(AccountantClassic_Profile["options"].LDBDisplaySessionInfo);
	--AccountantSliderButtonPos:SetValue(AccountantClassic_Profile["options"].buttonpos);
	UIDropDownMenu_Initialize(AccountantClassicOptionsFrameWeek, AccountantClassicOptionsFrameWeek_Init);
	UIDropDownMenu_SetSelectedID(AccountantClassicOptionsFrameWeek, AccountantClassic_Profile["options"].weekstart);
	UIDropDownMenu_Initialize(AccountantClassicOptionsFrameCharacterDropDown, AccountantClassicOptionsCharacterDropDown_Init);
	UIDropDownMenu_Initialize(AccountantClassicOptionsFrameDateDropDown, AccountantClassicOptionsDateDropDown_Init);
	UIDropDownMenu_SetSelectedValue(AccountantClassicOptionsFrameDateDropDown, AccountantClassic_Profile["options"].dateformat);
end

function AccountantClassicOptions_OnHide(self)
	if(MYADDONS_ACTIVE_OPTIONSFRAME == self) then
		ShowUIPanel(myAddOnsFrame);
	end
end

function AccountantClassicOptionsFrameWeek_Init()
	local info;
	Accountant_DayList = {WEEKDAY_SUNDAY, WEEKDAY_MONDAY, WEEKDAY_TUESDAY, WEEKDAY_WEDNESDAY, WEEKDAY_THURSDAY, WEEKDAY_FRIDAY, WEEKDAY_SATURDAY};
	for i = 1, getn(Accountant_DayList), 1 do
		info = { };
		info.text = Accountant_DayList[i];
		info.func = AccountantClassicOptionsFrameWeek_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function AccountantClassicOptionsFrameWeek_OnClick(self)
	UIDropDownMenu_SetSelectedID(AccountantClassicOptionsFrameWeek, self:GetID());
	AccountantClassic_Profile["options"].weekstart = self:GetID();
end

function AccountantClassicMoneyInfoFrame_Toggle()
	if(AccountantClassicMoneyInfoFrame:IsVisible()) then
		AccountantClassicMoneyInfoFrame:Hide();
		AccountantClassic_Profile["options"].showmoneyinfo = false;
	else
		AccountantClassicMoneyInfoFrame:Show();
		AccountantClassic_Profile["options"].showmoneyinfo = true;
	end
end

function AccountantClassicOptionsIntroTip_Toggle()
	if (AccountantClassic_Profile["options"].showintrotip == true) then
		AccountantClassic_Profile["options"].showintrotip = false;
	else
		AccountantClassic_Profile["options"].showintrotip = true;
	end
end

function AccountantClassicOptionsMoneyOnMinimap_Toggle()
	if (AccountantClassic_Profile["options"].showmoneyonbutton == true) then
		AccountantClassic_Profile["options"].showmoneyonbutton = false;
	else
		AccountantClassic_Profile["options"].showmoneyonbutton = true;
	end
end

function AccountantClassicOptionsSessionOnMinimap_Toggle()
	if (AccountantClassic_Profile["options"].showsessiononbutton == true) then
		AccountantClassic_Profile["options"].showsessiononbutton = false;
	else
		AccountantClassic_Profile["options"].showsessiononbutton = true;
	end
end

function AccountantClassicLDBDisplay_Toggle()
	if (AccountantClassic_Profile["options"].LDBDisplaySessionInfo == true) then
		AccountantClassic_Profile["options"].LDBDisplaySessionInfo = false;
	else
		AccountantClassic_Profile["options"].LDBDisplaySessionInfo = true;
	end
end

function AccountantClassicMoneyInfoFrame_ResetPosition()
	AccountantClassicMoneyInfoFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 10, -80);
	AccountantClassic_Profile["options"].moneyinfoframe_x = 10;
	AccountantClassic_Profile["options"].moneyinfoframe_y = -80;
end

function AccountantClassicOptionsCharacterDropDown_Init()
	local info;
	local serverkey, server_value, charkey, char_value;
	for serverkey, server_value in pairs(Accountant_ClassicSaveData) do
		for charkey, char_value in pairs(Accountant_ClassicSaveData[serverkey]) do
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
			-- info.value = charkey;
			info.arg1 = serverkey;
			info.arg2 = charkey;
			info.func = AccountantClassicOptionsCharacterDropDown_OnClick;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function AccountantClassicOptionsCharacterDropDown_OnClick(self)
	local selected_srv  = self.arg1;
	local selected_char  = self.arg2;
	local faction_icon = "";
	local class_color = "";
	UIDropDownMenu_SetSelectedID(AccountantClassicFrameCharacterDropDown, self:GetID());

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
		text = L["ACCLOC_CHARREMOVETEXT"].."\n|r"..faction_icon..class_color..self.value,
		buttons = {
			{
				text = OKAY,
				on_click = function() AccountantClassic_CharacterRemovalConfirmed(selected_srv, selected_char); end,
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

function AccountantClassicOptionsDateDropDown_Init()
	local options = {
		"mm/dd/yy",
		"dd/mm/yy",
		"yy/mm/dd",
	};
	local info;
	for i = 1, getn(options), 1 do
		info = { };
		info.text = options[i];
		info.value = i;
		info.arg1 = i;
		info.func = AccountantClassicOptionsDateDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function AccountantClassicOptionsDateDropDown_OnClick(self, arg1)
	UIDropDownMenu_SetSelectedValue(AccountantClassicOptionsFrameDateDropDown, arg1);
	AccountantClassic_Profile["options"].dateformat = arg1;
end


