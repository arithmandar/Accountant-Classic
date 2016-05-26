--[[
$Id$
]]
--[[
local LibStub = _G.LibStub

local addon = LibStub("AceAddon-3.0"):GetAddon("Accountant_Classic")
--local options = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db);

-- Minimap button with LibDBIcon-1.0
local Accountant_ClassicMiniMapLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Accountant_Classic", {
	type = "launcher",
	text = ACCLOC_TITLE,
	icon = "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantButton-Up",
	OnClick = function(self, button)
		if button == "LeftButton" then
			AccountantClassic_ButtonOnClick();
		elseif button == "RightButton" then
			AccountantClassicOptions_Toggle();
		end
	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		local title = "|cffffffff"..ACCLOC_TITLE;
		if (Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showmoneyonbutton) then
			title = title.." - "..AccountantClassic_GetFormattedValue(GetMoney());
		end
		tooltip:AddLine(title);
		if (Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showsessiononbutton == true) then
			tooltip:AddLine(AccountantClassic_ShowSessionToolTip());
		end
		if (Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showintrotip == true) then
			tooltip:AddLine(ACCLOC_TIP);
		end
	end,
})
if ( TitanPanelButton_UpdateButton ) then
	TitanPanelButton_UpdateButton("Accountant_Classic");
end
]]
--local button = LibStub("LibDBIcon-1.0")

--[[
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Accountant_ClassicDB", {
		profile = {
			minimap = {
				hide = false,
				minimapPos = 153,
			},
		},
	})
	button:Register("Accountant_Classic", Accountant_ClassicMiniMapLDB, self.db.profile.minimap);
	self:RegisterChatCommand("accountantbutton", AccountantClassic_ButtonToggle)
	self:RegisterChatCommand("accountant", Accountant_Slash)
end
]]
--[[
function addon:Toggle()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	if self.db.profile.minimap.hide then
		button:Hide("Accountant_Classic")
		Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton = false;
	else
		button:Show("Accountant_Classic")
		Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton = true;
	end
	AccountantOptionsFrameToggleButton:SetChecked(Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton);
end
]]
--[[
function AccountantClassic_ButtonToggle()
--	addon:Toggle()
	

	addon.db.profile.minimap.hide = not addon.db.profile.minimap.hide
	if addon.db.profile.minimap.hide then
		button:Hide("Accountant_Classic")
		Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton = false;
	else
		button:Show("Accountant_Classic")
		Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton = true;
	end
	AccountantOptionsFrameToggleButton:SetChecked(Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton);
end

function AccountantClassic_ButtonOnClick()
	if AccountantFrame:IsVisible() then
		HideUIPanel(AccountantFrame);
	else
		ShowUIPanel(AccountantFrame);
	end
end


function AccountantButton_Init()
	if(Accountant_SaveData[AccountantClassic_Server][AccountantClassic_Player]["options"].showbutton) then
		button:Show("Accountant_Classic")
	else
		button:Hide("Accountant_Classic")
	end
end
]]
--[[
function AccountantButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(ACCLOC_TITLE);
	GameTooltipTextLeft1:SetTextColor(1, 1, 1);
	GameTooltip:AddLine(ACCLOC_TIP);
	GameTooltip:Show();
end

function AccountantClassic_ButtonToggle()
	if(AccountantButtonFrame:IsVisible()) then
		AccountantButtonFrame:Hide();
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showbutton = false;
	else
		AccountantButtonFrame:Show();
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showbutton = true;
	end
end

function AccountantButton_UpdatePosition()
	AccountantButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		55 - (75 * cos(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].buttonpos)),
		(75 * sin(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].buttonpos)) - 55
	);
end
]]
