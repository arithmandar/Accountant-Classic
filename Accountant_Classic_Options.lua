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
	UIPanelWindows['AccountantOptionsFrame'] = {area = 'center', pushable = 0};
	
	self.name = L["ACCLOC_TITLE"];
	InterfaceOptions_AddCategory(self);
	if (LibStub:GetLibrary("LibAboutPanel", true)) then
		LibStub("LibAboutPanel").new(L["ACCLOC_TITLE"], "Accountant_Classic");
	end
end

function AccountantClassicOptions_OnShow()
	AccountantOptionsFrameToggleButton:SetChecked(AccountantClassic_Profile["options"].showbutton);
	AccountantOptionsFrameToggleMoneyDisplay:SetChecked(AccountantClassic_Profile["options"].showmoneyinfo);
	AccountantOptionsFrameToggleDisplayInstroTips:SetChecked(AccountantClassic_Profile["options"].showintrotip);
	AccountantOptionsFrameToggleMoneyOnMiniMap:SetChecked(AccountantClassic_Profile["options"].showmoneyonbutton);
	AccountantOptionsFrameToggleSessionOnMiniMap:SetChecked(AccountantClassic_Profile["options"].showsessiononbutton);
	--AccountantSliderButtonPos:SetValue(AccountantClassic_Profile["options"].buttonpos);
	UIDropDownMenu_Initialize(AccountantOptionsFrameWeek, AccountantClassicOptionsFrameWeek_Init);
	UIDropDownMenu_SetSelectedID(AccountantOptionsFrameWeek, AccountantClassic_Profile["options"].weekstart);
	UIDropDownMenu_Initialize(AccountantOptionsFrameCharacterDropDown, AccountantClassicOptionsCharacterDropDown_Init);
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
	UIDropDownMenu_SetSelectedID(AccountantOptionsFrameWeek, self:GetID());
	AccountantClassic_Profile["options"].weekstart = self:GetID();
end

function AccountantClassicMoneyInfoFrame_Toggle()
	if(AccountantMoneyInfoFrame:IsVisible()) then
		AccountantMoneyInfoFrame:Hide();
		AccountantClassic_Profile["options"].showmoneyinfo = false;
	else
		AccountantMoneyInfoFrame:Show();
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

function AccountantMoneyInfoFrame_ResetPosition()
	AccountantMoneyInfoFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 90, 0);
	AccountantClassic_Profile["options"].moneyinfoframe_x = 90;
	AccountantClassic_Profile["options"].moneyinfoframe_y = 0;
end

function AccountantClassicOptionsCharacterDropDown_Init()
	local info;
	local server_key, server_value, char_key, char_value;
	for server_key, server_value in pairs(Accountant_SaveData) do
		for char_key, char_value in pairs(Accountant_SaveData[server_key]) do
			info = { };
			info.text = server_key.." - "..char_key;
			info.value = char_key;
			info.arg1 = server_key;
			info.func = AccountantClassicOptionsCharacterDropDown_OnClick;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function AccountantClassicOptionsCharacterDropDown_OnClick(self, arg1)
	local selected_char = self.value;
	local selected_srv  = arg1;
	UIDropDownMenu_SetSelectedID(AccountantFrameCharacterDropDown, self:GetID());
	
	-- Confirm box
	LibDialog:Register("ACCLOC_CHARREMOVE", {
		text = L["ACCLOC_CHARREMOVETEXT"].."\n|cFFFFFF00"..selected_srv.." - "..selected_char.."|r",
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
