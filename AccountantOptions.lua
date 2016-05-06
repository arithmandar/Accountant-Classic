--[[
$Id$
]]
ACCOUNTANT_OPTIONS_TITLE = ACCLOC_OPTS;

function AccountantOptions_Toggle()
--[[
	if(AccountantOptionsFrame:IsVisible()) then
		AccountantOptionsFrame:Hide();
	else
		AccountantOptionsFrame:Show();
	end
]]
	if(InterfaceOptionsFrame:IsVisible()) then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory("Accountant Classic");
		InterfaceOptionsFrame_OpenToCategory("Accountant Classic");
	end
end

function AccountantOptions_OnLoad(panel)
	UIPanelWindows['AccountantOptionsFrame'] = {area = 'center', pushable = 0};
	
--	panel = _G["AccountantOptionsFrame"];
	panel.name = ACCLOC_TITLE;
	InterfaceOptions_AddCategory(panel);
	if (LibStub:GetLibrary("LibAboutPanel", true)) then
		-- lib.new(parent, addonname);
		LibStub("LibAboutPanel").new(ACCLOC_TITLE, "Accountant_Classic");
	end
end


function AccountantOptions_OnShow()
	--AccountantOptionsFrameToggleButtonText:SetText(ACCLOC_MINIBUT);
	--AccountantOptionsFrameToggleMoneyDisplayText:SetText(ACCLOC_ONSCRMONEY);
	--AccountantSliderButtonPosText:SetText(ACCLOC_BUTPOS);
	--AccountantOptionsFrameWeekLabel:SetText(ACCLOC_STARTWEEK);

	AccountantOptionsFrameToggleButton:SetChecked(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showbutton);
	AccountantOptionsFrameToggleMoneyDisplay:SetChecked(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showmoneyinfo);
	--AccountantSliderButtonPos:SetValue(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].buttonpos);
	UIDropDownMenu_Initialize(AccountantOptionsFrameWeek, AccountantOptionsFrameWeek_Init);
	UIDropDownMenu_SetSelectedID(AccountantOptionsFrameWeek, Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].weekstart);
end

function AccountantOptions_OnHide(self)
	if(MYADDONS_ACTIVE_OPTIONSFRAME == self) then
		ShowUIPanel(myAddOnsFrame);
	end
end

function AccountantOptionsFrameWeek_Init()
	local info;
	Accountant_DayList = {WEEKDAY_SUNDAY, WEEKDAY_MONDAY, WEEKDAY_TUESDAY, WEEKDAY_WEDNESDAY, WEEKDAY_THURSDAY, WEEKDAY_FRIDAY, WEEKDAY_SATURDAY};
	for i = 1, getn(Accountant_DayList), 1 do
		info = { };
		info.text = Accountant_DayList[i];
		info.func = AccountantOptionsFrameWeek_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function AccountantOptionsFrameWeek_OnClick(self)
	UIDropDownMenu_SetSelectedID(AccountantOptionsFrameWeek, self:GetID());
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].weekstart = self:GetID();
end

function AccountantMoneyInfoFrame_Toggle()
	if(AccountantMoneyInfoFrame:IsVisible()) then
		AccountantMoneyInfoFrame:Hide();
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showmoneyinfo = false;
	else
		AccountantMoneyInfoFrame:Show();
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showmoneyinfo = true;
	end
end