-----------------------------------------------------------------------
-- Description: Creates the reusable row templates used by the Accountant Classic UI.
-- This file is used to build the data rows and their text columns for the main frame.
-----------------------------------------------------------------------

local _, private = ...

-- True when a FontString cannot display its whole text within its width
local function isTextTruncated(fontString)
	if fontString.IsTruncated then
		return fontString:IsTruncated()
	end
	if fontString.GetUnboundedStringWidth then
		return fontString:GetUnboundedStringWidth() > fontString:GetWidth() + 0.5
	end
	-- Unable to detect on this client: always offer the tooltip
	return true
end

local function column_OnEnter(self)
	if self.fullText then
		-- Character rows: show the full "realm - character" text if it is cut off
		if isTextTruncated(self.Text) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(self.fullText, nil, nil, nil, nil, true)
			GameTooltip:Show()
		end
		return
	end
	AccountantClassic_LogTypeOnShow(self)
end

local function createRowColumn(parent, key, width, offset, font, justify)
	local button = CreateFrame("Button", parent:GetName()..key, parent)
	button:SetSize(width, 19)
	button:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, 0)
	button.Text = button:CreateFontString(parent:GetName()..key.."_Text", "OVERLAY", font)
	button.Text:SetSize(width, 19)
	button.Text:SetPoint("TOPLEFT", button, "TOPLEFT")
	button.Text:SetJustifyH(justify)
	if button.Text.SetNonSpaceWrap then
		button.Text:SetNonSpaceWrap(true)
	end
	button:SetScript("OnEnter", column_OnEnter)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return button
end

function AccountantClassic_InitializeRow(row)
	row:SetSize(600, 19)
	row.Title = createRowColumn(row, "Title", 280, 3, "GameFontNormal", "LEFT")
	row.In = createRowColumn(row, "In", 160, 273, "NumberFontNormal", "RIGHT")
	row.Out = createRowColumn(row, "Out", 160, 434, "NumberFontNormal", "RIGHT")
	return row
end

function AccountantClassic_CreateRow(parent, name)
	return AccountantClassic_InitializeRow(CreateFrame("Frame", name, parent))
end
