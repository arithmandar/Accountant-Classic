--[[
$Id$
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("Accountant_Classic");
local L = LibStub("AceLocale-3.0"):GetLocale("Accountant_Classic");
local LibDialog = LibStub("LibDialog-1.0");

local ACC_WEEKDAYS = { WEEKDAY_SUNDAY, WEEKDAY_MONDAY, WEEKDAY_TUESDAY, WEEKDAY_WEDNESDAY, WEEKDAY_THURSDAY, WEEKDAY_FRIDAY, WEEKDAY_SATURDAY };
--local ACC_WEEKSTART = ACC_WEEKDAYS[1];

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
	AccountantClassicOptionsFrameToggleBreakupNumbers:SetChecked(AccountantClassic_Profile["options"].breakupnumbers);
	AccountantClassicOptionsFrameToggleButton:SetChecked(AccountantClassic_Profile["options"].showbutton);
	AccountantClassicOptionsFrameToggleMoneyOnMiniMap:SetChecked(AccountantClassic_Profile["options"].showmoneyonbutton);
	AccountantClassicOptionsFrameToggleSessionOnMiniMap:SetChecked(AccountantClassic_Profile["options"].showsessiononbutton);
	AccountantClassicOptionsFrameToggleMoneyDisplay:SetChecked(AccountantClassic_Profile["options"].showmoneyinfo);
	AccountantClassicOptionsFrameToggleDisplayInstroTips:SetChecked(AccountantClassic_Profile["options"].showintrotip);
	AccountantClassicOptionsFrameToggleMoneyDisplayOnLDB:SetChecked(AccountantClassic_Profile["options"].LDBDisplaySessionInfo);
	AccountantClassicOptionsFrameToggleCrossServer:SetChecked(AccountantClassic_Profile["options"].cross_server);
	AccountantClassicOptionsFrameToggleTrackZone:SetChecked(AccountantClassic_Profile["options"].trackzone);
	AccountantClassicOptionsFrameToggleTrackSubZone:SetChecked(AccountantClassic_Profile["options"].tracksubzone);
	--AccountantSliderButtonPos:SetValue(AccountantClassic_Profile["options"].buttonpos);
	Lib_UIDropDownMenu_Initialize(AccountantClassicOptionsFrameWeek, AccountantClassicOptionsFrameWeek_Init);
	Lib_UIDropDownMenu_SetSelectedID(AccountantClassicOptionsFrameWeek, AccountantClassic_Profile["options"].weekstart);
	Lib_UIDropDownMenu_Initialize(AccountantClassicOptionsFrameCharacterDropDown, AccountantClassicOptionsCharacterDropDown_Init);
	Lib_UIDropDownMenu_Initialize(AccountantClassicOptionsFrameDateDropDown, AccountantClassicOptionsDateDropDown_Init);
	Lib_UIDropDownMenu_SetSelectedValue(AccountantClassicOptionsFrameDateDropDown, AccountantClassic_Profile["options"].dateformat);
	AccountantClassicOptionsFrameSliderFrameScale:SetValue(AccountantClassic_Profile["options"].scale);
	AccountantClassicOptionsFrameSliderFrameAlpha:SetValue(AccountantClassic_Profile["options"].alpha);
	AccountantClassicOptionsFrameSliderInfoScale:SetValue(AccountantClassic_Profile["options"].infoscale);
	AccountantClassicOptionsFrameSliderInfoAlpha:SetValue(AccountantClassic_Profile["options"].infoalpha);
end

function AccountantClassicOptions_OnHide(self)
	if(MYADDONS_ACTIVE_OPTIONSFRAME == self) then
		ShowUIPanel(myAddOnsFrame);
	end
end

function AccountantClassicOptionsFrameWeek_Init()
	for i = 1, #ACC_WEEKDAYS do
		local info = Lib_UIDropDownMenu_CreateInfo();
		info.text = ACC_WEEKDAYS[i];
		info.func = AccountantClassicOptionsFrameWeek_OnClick;
		info.arg1 = i;
		Lib_UIDropDownMenu_AddButton(info, 1);
	end
end

function AccountantClassicOptionsFrameWeek_OnClick(self)
	Lib_UIDropDownMenu_SetSelectedID(AccountantClassicOptionsFrameWeek, self:GetID());
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

function AccountantClassic_BreakupNumbersToggle()
	AccountantClassic_Profile["options"].breakupnumbers = not AccountantClassic_Profile["options"].breakupnumbers;
	if ( AccountantClassicFrame:IsVisible() ) then
		AccountantClassic_OnShow();
	end
end

function AccountantClassicOptionsIntroTip_Toggle()
	AccountantClassic_Profile["options"].showintrotip = not AccountantClassic_Profile["options"].showintrotip;
end

function AccountantClassicOptionsMoneyOnMinimap_Toggle()
	AccountantClassic_Profile["options"].showmoneyonbutton = not AccountantClassic_Profile["options"].showmoneyonbutton;
end

function AccountantClassicOptionsSessionOnMinimap_Toggle()
	AccountantClassic_Profile["options"].showsessiononbutton = not AccountantClassic_Profile["options"].showsessiononbutton;
end

function AccountantClassicLDBDisplay_Toggle()
	AccountantClassic_Profile["options"].LDBDisplaySessionInfo = not AccountantClassic_Profile["options"].LDBDisplaySessionInfo;
end

function AccountantClassicOptionsCrossServer_Toggle()
	AccountantClassic_Profile["options"].cross_server = not AccountantClassic_Profile["options"].cross_server;
	
	AccountantClassic_PopulateCharacterList();

	if ( AccountantClassicFrame:IsVisible() ) then
		AccountantClassic_OnShow();
	end
end

function AccountantClassicOptionsTrackZone_Toggle()
	AccountantClassic_Profile["options"].trackzone = not AccountantClassic_Profile["options"].trackzone;
	if (AccountantClassic_Profile["options"].trackzone == false) then
		AccountantClassicOptionsFrameToggleTrackSubZone:Disable();
	else
		AccountantClassicOptionsFrameToggleTrackSubZone:Enable();
	end
end

function AccountantClassicOptionsTrackSubZone_Toggle()
	AccountantClassic_Profile["options"].tracksubzone = not AccountantClassic_Profile["options"].tracksubzone;
end

function AccountantClassicMoneyInfoFrame_ResetPosition()
	AccountantClassicMoneyInfoFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 10, -80);
	AccountantClassic_Profile["options"].moneyinfoframe_x = 10;
	AccountantClassic_Profile["options"].moneyinfoframe_y = -80;
end

function AccountantClassicOptionsCharacterDropDown_Init()
	-- local info;
	local serverkey, server_value, charkey, char_value;
	for serverkey, server_value in pairs(Accountant_ClassicSaveData) do
		for charkey, char_value in pairs(Accountant_ClassicSaveData[serverkey]) do
			local info = Lib_UIDropDownMenu_CreateInfo();
			if (Accountant_ClassicSaveData[serverkey][charkey]["options"].faction) then
				local factionstr = Accountant_ClassicSaveData[serverkey][charkey]["options"].faction;
				local faction_icon = "Interface\\PVPFrame\\PVP-Currency-"..factionstr;
				info.icon = faction_icon;
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
			Lib_UIDropDownMenu_AddButton(info);
		end
	end
end

function AccountantClassicOptionsCharacterDropDown_OnClick(self)
	local selected_srv  = self.arg1;
	local selected_char  = self.arg2;
	local faction_icon = "";
	local class_color = "";
	Lib_UIDropDownMenu_SetSelectedID(AccountantClassicFrameCharacterDropDown, self:GetID());

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
	-- local info;
	for i = 1, getn(options), 1 do
		local info = Lib_UIDropDownMenu_CreateInfo();
		info.text = options[i];
		info.value = i;
		info.arg1 = i;
		info.func = AccountantClassicOptionsDateDropDown_OnClick;
		Lib_UIDropDownMenu_AddButton(info);
	end
end

function AccountantClassicOptionsDateDropDown_OnClick(self, arg1)
	Lib_UIDropDownMenu_SetSelectedValue(AccountantClassicOptionsFrameDateDropDown, arg1);
	AccountantClassic_Profile["options"].dateformat = arg1;
end

function AccountantClassicOptions_SetupSlider(self, text, mymin, mymax, step)
	self:SetMinMaxValues(mymin, mymax);
	self:SetValueStep(step);
end

local function round(num, idp)
   local mult = 10 ^ (idp or 0);
   return math.floor(num * mult + 0.5) / mult;
end

local function AccountantClassicOptions_UpdateSlider(self, text)
	_G[self:GetName().."Text"]:SetText("|cffffd200"..text.." ("..round(self:GetValue(), 3)..")");
end

function AccountantClassicOptions_OnMouseWheel(self, delta)
	if (delta > 0) then
		self:SetValue(self:GetValue() + self:GetValueStep())
	else
		self:SetValue(self:GetValue() - self:GetValueStep())
	end
end

function AccountantClassicOptions_SliderFrameScaleOnValueChanged(self)
	AccountantClassicOptions_UpdateSlider(self, ACCLOC_FRAMESCALE);
	AccountantClassic_Profile["options"].scale = self:GetValue();
	AccountantClassicFrame:SetScale(AccountantClassic_Profile["options"].scale); 
end

function AccountantClassicOptions_SliderFrameAlphaOnValueChanged(self)
	AccountantClassicOptions_UpdateSlider(self, ACCLOC_FRAMEALPHA);
	AccountantClassic_Profile["options"].alpha = self:GetValue();
	AccountantClassicFrame:SetAlpha(AccountantClassic_Profile["options"].alpha); 
end

function AccountantClassicOptions_SliderInfoScaleOnValueChanged(self)
	AccountantClassicOptions_UpdateSlider(self, ACCLOC_INFOSCALE);
	AccountantClassic_Profile["options"].infoscale = self:GetValue();
	AccountantClassicMoneyInfoFrame:SetScale(AccountantClassic_Profile["options"].infoscale); 
end

function AccountantClassicOptions_SliderInfoAlphaOnValueChanged(self)
	AccountantClassicOptions_UpdateSlider(self, ACCLOC_INFOALPHA);
	AccountantClassic_Profile["options"].infoalpha = self:GetValue();
	AccountantClassicMoneyInfoFrame:SetAlpha(AccountantClassic_Profile["options"].infoalpha); 
end
