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
  v2.4 - current version:
     Updated by: Arith, Tntdruid
]]

Accountant_Version = GetAddOnMetadata("Accountant", "Version");
Accountant_Data = nil;
Accountant_SaveData = nil;
Accountant_Disabled = false;
Accountant_Mode = "";
Accountant_CurrentMoney = 0;
Accountant_LastMoney = 0;
Accountant_Verbose = nil;
Accountant_GotName = false;
Accountant_CurrentTab = 1;
Accountant_LogModes = {"Session", "Day", "Week", "Month", "Total"};
Accountant_Player = "";
Accountant_Server = "";
local Accountant_RepairAllItems_old;
local Accountant_CursorHasItem_old;

function Accountant_RegisterEvents(self)
	
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_ARCHITECT_OPENED");
	self:RegisterEvent("GARRISON_ARCHITECT_CLOSED");
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	self:RegisterEvent("GARRISON_MISSION_NPC_CLOSED");
	self:RegisterEvent("GARRISON_UPDATE");
	
	self:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED");
	self:RegisterEvent("BARBER_SHOP_OPEN");
	self:RegisterEvent("BARBER_SHOP_SUCCESS");
	self:RegisterEvent("BARBER_SHOP_CLOSE");
	
	self:RegisterEvent("CONFIRM_TALENT_WIPE");
	
	self:RegisterEvent("LFG_COMPLETION_REWARD");
	
	self:RegisterEvent("VOID_STORAGE_OPEN");
	self:RegisterEvent("VOID_STORAGE_CLOSE");
	
	self:RegisterEvent("TRANSMOGRIFY_OPEN");
	self:RegisterEvent("TRANSMOGRIFY_CLOSE");
	
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:RegisterEvent("MERCHANT_UPDATE");

	self:RegisterEvent("QUEST_COMPLETE");
	self:RegisterEvent("QUEST_FINISHED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_CLOSED");

	self:RegisterEvent("TAXIMAP_OPENED");
	self:RegisterEvent("TAXIMAP_CLOSED");

	self:RegisterEvent("TRADE_SHOW");
	self:RegisterEvent("TRADE_CLOSE");

	self:RegisterEvent("MAIL_INBOX_UPDATE");
	self:RegisterEvent("MAIL_SHOW");
	self:RegisterEvent("MAIL_CLOSED");

	self:RegisterEvent("TRAINER_SHOW");
	self:RegisterEvent("TRAINER_CLOSED");

	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");

	self:RegisterEvent("CHAT_MSG_MONEY");

	self:RegisterEvent("PLAYER_MONEY");

	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function Accountant_SetLabels(self)
	-- if current tab is All Chars tab
	if Accountant_CurrentTab == 6 then
		AccountantFrameSource:SetText(ACCLOC_CHAR);
		AccountantFrameIn:SetText(ACCLOC_MONEY);
		AccountantFrameOut:SetText(ACCLOC_UPDATED);
		AccountantFrameTotalIn:SetText(ACCLOC_SUM..":");
		AccountantFrameTotalOut:SetText("");
		AccountantFrameTotalFlow:SetText("");
		AccountantFrameTotalInValue:SetText("");
		AccountantFrameTotalOutValue:SetText("");
		AccountantFrameTotalFlowValue:SetText("");
		for i = 1, 18, 1 do
			_G["AccountantFrameRow"..i.."Title"]:SetText("");
			_G["AccountantFrameRow"..i.."Title"]:SetPoint("TOPLEFT", 3, -2);
			_G["AccountantFrameRow"..i.."In"]:SetText("");
			_G["AccountantFrameRow"..i.."Out"]:SetText("");
		end
		AccountantFrameResetButton:Hide();
		return;
	else
		AccountantFrameResetButton:Show();

		AccountantFrameSource:SetText(ACCLOC_SOURCE);
		AccountantFrameIn:SetText(ACCLOC_IN);
		AccountantFrameOut:SetText(ACCLOC_OUT);
		AccountantFrameTotalIn:SetText(ACCLOC_TOT_IN..":");
		AccountantFrameTotalOut:SetText(ACCLOC_TOT_OUT..":");
		AccountantFrameTotalFlow:SetText(ACCLOC_NET..":");

		-- Row Labels (auto generate)
		InPos = 1
		for key,value in pairs(Accountant_Data) do
			Accountant_Data[key].InPos = InPos;
			_G["AccountantFrameRow"..InPos.."Title"]:SetText(Accountant_Data[key].Title);
			_G["AccountantFrameRow"..InPos.."Title"]:SetPoint("TOPLEFT", 3, -2);
			InPos = InPos + 1;
		end

		-- Set the header
		local name = AccountantFrame:GetName();
		local header = _G[name.."TitleText"];
		if ( header ) then
			header:SetText(ACCLOC_TITLE);
		end
	end
end

function Accountant_OnLoad(self)

	Accountant_Player = UnitName("player");
	Accountant_Server = GetRealmName();
	Accountant_Faction = UnitFactionGroup("player");

	-- Setup
	Accountant_LoadData();
	Accountant_SetLabels();

	-- Current Cash
	Accountant_CurrentMoney = GetMoney();
	Accountant_LastMoney = Accountant_CurrentMoney;

	-- Slash Commands
	SlashCmdList["ACCOUNTANT"] = Accountant_Slash;
	SLASH_ACCOUNTANT1 = "/accountant";
	SLASH_ACCOUNTANT2 = "/acc";

	-- Add myAddOns support
	if myAddOnsList then
		myAddOnsList.Accountant = {name = "Accountant", description = "Tracks your incomings / outgoings", version = Accountant_Version, frame = "AccountantFrame", optionsframe = "AccountantFrame"};
	end

	-- Confirm box
	StaticPopupDialogs["ACCOUNTANT_RESET"] = {
		text = TEXT("meh"),
		button1 = TEXT(OKAY),
		button2 = TEXT(CANCEL),
		OnAccept = function()
			Accountant_ResetConfirmed();
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		interruptCinematic = 1
	};

	-- hooks
	Accountant_RepairAllItems_old = RepairAllItems;
	RepairAllItems = Accountant_RepairAllItems;
--	Accountant_CursorHasItem_old = CursorHasItem;
--	CursorHasItem = Accountant_CursorHasItem;

	-- tabs
	AccountantFrameTab1:SetText(ACCLOC_SESS);
	PanelTemplates_TabResize(AccountantFrameTab1, 10);
	AccountantFrameTab2:SetText(ACCLOC_DAY);
	PanelTemplates_TabResize(AccountantFrameTab2, 10);
	AccountantFrameTab3:SetText(ACCLOC_WEEK);
	PanelTemplates_TabResize(AccountantFrameTab3, 10);
	AccountantFrameTab4:SetText(ACCLOC_MONTH);
	PanelTemplates_TabResize(AccountantFrameTab4, 10);
	AccountantFrameTab5:SetText(ACCLOC_TOTAL);
	PanelTemplates_TabResize(AccountantFrameTab5, 10);
	AccountantFrameTab6:SetText(ACCLOC_CHARS);
	PanelTemplates_TabResize(AccountantFrameTab6, 10);
	PanelTemplates_SetNumTabs(AccountantFrame, 6);
	PanelTemplates_SetTab(AccountantFrame, AccountantFrameTab1);
	PanelTemplates_UpdateTabs(AccountantFrame);

	ACC_Print(ACCLOC_TITLE.." "..ACCLOC_LOADED);

	--Make an LDB object
	LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Accountant_Classic", {
		type = "launcher",
		text = ACCLOC_TITLE,
		OnClick = function(_, msg)
			if msg == "LeftButton" then
				AccountantButton_OnClick();
			elseif msg == "RightButton" then
				AccountantOptions_Toggle();
			end
		end,
		icon = "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantButton-Up",
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("|cffffffff"..ACCLOC_TITLE)
			tooltip:AddLine(ACCLOC_TIP)
		end,
	});

	if ( TitanPanelButton_UpdateButton ) then
		TitanPanelButton_UpdateButton("Accountant_Classic");
	end
end

function Accountant_LoadData()
	Accountant_Data = {};
	Accountant_Data["TRAIN"] = 	{Title = ACCLOC_TRAIN};
	Accountant_Data["TAXI"] = 	{Title = ACCLOC_TAXI};
	Accountant_Data["TRADE"] = 	{Title = ACCLOC_TRADE};
	Accountant_Data["AH"] = 	{Title = AUCTIONS};
	Accountant_Data["MERCH"] = 	{Title = ACCLOC_MERCH};
	Accountant_Data["REPAIRS"] = 	{Title = ACCLOC_REPAIR};
	Accountant_Data["MAIL"] = 	{Title = ACCLOC_MAIL};
	Accountant_Data["QUEST"] = 	{Title = ACCLOC_QUEST};
	Accountant_Data["LOOT"] = 	{Title = LOOT};
	Accountant_Data["OTHER"] = 	{Title = ACCLOC_OTHER};
	Accountant_Data["VOID"] =  	{Title = VOID_STORAGE};
	Accountant_Data["TRANSMO"] =	{Title = TRANSMOGRIFY};
	Accountant_Data["GARRISON"] =	{Title = GARRISON_LOCATION_TOOLTIP};
	Accountant_Data["LFG"] =	{Title = ACCLOC_LFG};
	Accountant_Data["BARBER"] =	{Title = BARBERSHOP};

	for key,value in pairs(Accountant_Data) do
		for modekey,mode in pairs(Accountant_LogModes) do
			Accountant_Data[key][mode] = {In=0,Out=0};
		end
	end

	if(Accountant_SaveData == nil) then
		Accountant_SaveData = {};
	end
	if (Accountant_SaveData[Accountant_Server] == nil) then
		Accountant_SaveData[Accountant_Server] = {};
	end
	if (Accountant_SaveData[Accountant_Server][Accountant_Player] == nil ) then
		--cdate = date();
		--tnt
		cdate = date ("%d/%m/%y");
		cdate = string.sub(cdate,0,8);
		cweek = "";
		cmonth = date("%m");
		Accountant_SaveData[Accountant_Server][Accountant_Player] = {
			options = {
				showbutton = true, 
				showmoneyinfo = true, 
				buttonpos = 0, 
				version = Accountant_Version, 
				date = cdate, 
				weekdate = cweek, 
				month = cmonth,
				weekstart = 1, 
				totalcash = 0
			},
			data={}
		};
		ACC_Print(ACCLOC_NEWPROFILE.." "..Accountant_Player);
	else
		ACC_Print(ACCLOC_LOADPROFILE.." "..Accountant_Player);
	end

	order = 1;
	for key,value in pairs(Accountant_Data) do
		if Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key] == nil then
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key] = {}
		end
		for modekey,mode in pairs(Accountant_LogModes) do
			if Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][mode] == nil then
				Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][mode] = {In=0,Out=0};
			end
			Accountant_Data[key][mode].In  = Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][mode].In;
			Accountant_Data[key][mode].Out = Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][mode].Out;
		end
		Accountant_Data[key]["Session"].In = 0;
		Accountant_Data[key]["Session"].Out = 0;

		-- Old Version Conversion
		if Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalIn ~= nil then
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key]["Total"].In = Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalIn;
			Accountant_Data[key]["Total"].In = Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalIn;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalIn = nil;
		end
		if Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalOut ~= nil then
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key]["Total"].Out = Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalOut;
			Accountant_Data[key]["Total"].Out = Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalOut;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key].TotalOut = nil;
		end
		if Accountant_SaveData[key] ~= nil then
			Accountant_SaveData[key] = nil;
		end
		-- End OVC
		Accountant_Data[key].order = order;
		order = order + 1;
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].version = Accountant_Version;
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].totalcash = GetMoney();

	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["weekstart"] == nil then
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["weekstart"] = 3;
	end
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] == nil then
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] = Accountant_WeekStart();
	end
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] == nil then
		--tnt
		--cdate = date();
		cdate = date ("%d/%m/%y")
		cdate = string.sub(cdate,0,8);
		
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] = cdate;
	end
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["month"] == nil then
		cmonth = date ("%m")
		Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["month"] = cmonth;
	end

	--Duplicate below from OnShow as the day and week data seems need to be initialize here, when the addon is loaded for a fresh day/week.
	-- Check to see if the day has rolled over
	--tnt
	--cdate = date();
	cdate = date ("%d/%m/%y")
	cdate = string.sub(cdate,0,8);
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] ~= cdate then
		-- Its a new day! clear out the day tab
		for mode,value in pairs(Accountant_Data) do
			Accountant_Data[mode]["Day"].In = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Day"].In = 0;
			Accountant_Data[mode]["Day"].Out = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Day"].Out = 0;
		end
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] = cdate;

	-- Check to see if the week has rolled over
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] ~= Accountant_WeekStart() then
		-- Its a new week! clear out the week tab
		for mode,value in pairs(Accountant_Data) do
			Accountant_Data[mode]["Week"].In = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Week"].In = 0;
			Accountant_Data[mode]["Week"].Out = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Week"].Out = 0;
		end
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] = Accountant_WeekStart();

	-- Check to see if the month has rolled over
	cmonth = date ("%m")
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["month"] ~= cmonth then
		-- Its a new month! clear out the month tab
		for mode,value in pairs(Accountant_Data) do
			Accountant_Data[mode]["Month"].In = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Month"].In = 0;
			Accountant_Data[mode]["Month"].Out = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Month"].Out = 0;
		end
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["month"] = cmonth;

end

function Accountant_Slash(msg)
	if msg == nil or msg == "" then
		msg = "log";
	end
	local args = {n=0}
	local function helper(word) table.insert(args, word) end
	string.gsub(msg, "[_%w]+", helper);
	if args[1] == 'log'  then
		ShowUIPanel(AccountantFrame);
	elseif args[1] == 'verbose' then
		if Accountant_Verbose == nil then
			Accountant_Verbose = 1;
			ACC_Print("Verbose Mode On");
		else
			Accountant_Verbose = nil;
			ACC_Print("Verbose Mode Off");
		end
	elseif args[1] == 'week' then
		ACC_Print(Accountant_WeekStart());
	else
		Accountant_ShowUsage();
	end
end

function Accountant_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	local oldmode = Accountant_Mode;
	if ( event == "UNIT_NAME_UPDATE" and arg1 == "player" ) or (event=="PLAYER_ENTERING_WORLD") then
		if (Accountant_GotName) then
			return;
		end
		local playerName = UnitName("player");
		if ( playerName ~= UNKNOWNBEING and playerName ~= UNKNOWNOBJECT and playerName ~= nil ) then
			Accountant_GotName = true;
			Accountant_OnLoad();
			--AccountantOptions_OnLoad();
			AccountantButton_Init();
			AccountantButton_UpdatePosition();
			AccountantMoneyInfoFrame_Init();
		end
		return;
	end

	
	if event == "GARRISON_MISSION_FINISHED" then
		Accountant_Mode = "GARRISON";
	elseif event == "GARRISON_UPDATE" then
		Accountant_Mode = "GARRISON";
	elseif event == "GARRISON_ARCHITECT_OPENED" then
		Accountant_Mode = "GARRISON";
	elseif event == "GARRISON_ARCHITECT_CLOSED" then
		Accountant_Mode = "";
	elseif event == " GARRISON_MISSION_NPC_OPENED" then
		Accountant_Mode = "GARRISON";
	elseif event == " GARRISON_MISSION_NPC_CLOSED" then
		Accountant_Mode = "";
	elseif event == "BARBER_SHOP_APPEARANCE_APPLIED" then
		Accountant_Mode = "";
	elseif event == "LFG_COMPLETION_REWARD" then
		Accountant_Mode = "LFG";
	elseif Accountant_Mode == "BARBER_SHOP_OPEN" then
		Accountant_Mode = "";
	elseif Accountant_Mode == "BARBER_SHOP_SUCCESS" then
		Accountant_Mode = "BARBER";
	elseif Accountant_Mode == "BARBER_SHOP_CLOSE" then
		Accountant_Mode = "";
	elseif event == "TRANSMOGRIFY_OPEN" then
		Accountant_Mode = "TRANSMO";
	elseif event == "TRANSMOGRIFY_CLOSE" then
		Accountant_Mode = "";
	elseif event == "VOID_STORAGE_OPEN" then
		Accountant_Mode = "VOID";
	elseif event == "VOID_STORAGE_CLOSE" then
		Accountant_Mode = "";
	elseif event == "MERCHANT_SHOW" then
		Accountant_Mode = "MERCH";
	elseif event == "MERCHANT_CLOSED" then
		Accountant_Mode = "";
	elseif event == "MERCHANT_UPDATE" then
		if (InRepairMode() == true) then
			Accountant_Mode = "REPAIRS";
		end
	elseif event == "TAXIMAP_OPENED" then
		Accountant_Mode = "TAXI";
	elseif event == "TAXIMAP_CLOSED" then
		-- Commented out due to taximap closing before money transaction
		-- Accountant_Mode = "";
	elseif event == "LOOT_OPENED" then
		Accountant_Mode = "LOOT";
	elseif event == "LOOT_CLOSED" then
		-- Commented out due to loot window closing before money transaction
		-- Accountant_Mode = "";
	elseif event == "TRADE_SHOW" then
		Accountant_Mode = "TRADE";
	elseif event == "TRADE_CLOSE" then
		Accountant_Mode = "";
	elseif event == "QUEST_COMPLETE" then
		Accountant_Mode = "QUEST";
	elseif event == "QUEST_TURNED_IN" then
		Accountant_Mode = "QUEST";
	elseif event == "QUEST_FINISHED" then
		-- Commented out due to quest window closing before money transaction
		-- Accountant_Mode = "";	
	elseif event == "MAIL_INBOX_UPDATE" then
		if Accountant_DetectAhMail() then
			Accountant_Mode = "AH"
		else
			Accountant_Mode = "MAIL"
		end
	elseif event == "CONFIRM_TALENT_WIPE" then
		Accountant_Mode = "TRAIN";
	elseif event == "TRAINER_SHOW" then
		Accountant_Mode = "TRAIN";
	elseif event == "TRAINER_CLOSED" then
		Accountant_Mode = "";
	elseif event == "AUCTION_HOUSE_SHOW" then
		Accountant_Mode = "AH";
	elseif event == "AUCTION_HOUSE_CLOSED" then
		Accountant_Mode = "";
	elseif event == "PLAYER_MONEY" then
		Accountant_UpdateLog();
-- This event is supposed to be fired before PLAYER_MONEY.
	elseif event == "CHAT_MSG_MONEY" then
		Accountant_OnShareMoney(arg1);
	end
	if Accountant_Verbose and Accountant_Mode ~= oldmode then ACC_Print("Accountant mode changed to '"..Accountant_Mode.."'"); end
end

function Accountant_DetectAhMail()
    local numItems, totalItems = GetInboxNumItems()
    for x = 1, totalItems do    
        local invoiceType = GetInboxInvoiceInfo(x)
        if invoiceType == "seller" then
            return true
        end
    end
end

function Accountant_OnShareMoney(arg1)
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

	oldMode = Accountant_Mode;
	if (not Accountant_LastMoney) then
		Accountant_LastMoney = 0;
	end

-- This will force a money update with calculated amount.
	Accountant_LastMoney = Accountant_LastMoney - money;
	Accountant_Mode = "LOOT";
	Accountant_UpdateLog();
	Accountant_Mode = oldMode;

-- This will suppress the incoming PLAYER_MONEY event.
	Accountant_LastMoney = Accountant_LastMoney + money;

end


function Accountant_NiceCash(amount)
	local agold = 10000;
	local asilver = 100;
	local outstr = "";
	local gold = 0;
	local silver = 0;
	local cent = 0;

	if amount >= agold then
		gold = math.floor(amount / agold);
		outstr = "|cFFFFFF00" .. gold .. ACCLOC_GOLD;
	end
	amount = amount - (gold * agold);
	if amount >= asilver then
		silver = math.floor(amount / asilver);
		if silver < 10 then
			silver = " "..silver;
		end
		outstr = outstr .. "|cFFDDDDDD" .. silver .. ACCLOC_SILVER;
	end
	amount = amount - (silver * asilver);
	if amount > 0 then
		cent = amount;
		if cent < 10 then
			cent = " "..cent;
		end
		outstr = outstr .. "|cFFFF6600" .. cent .. ACCLOC_CENT;
	end
	return outstr;
end

-- code adopted from SellTrash and MoneyFrame.lua
function Accountant_GetFormattedValue(amount)
	local gold = floor(amount / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local goldDisplay = BreakUpLargeNumbers(gold);
	local silver = floor((amount - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(amount, COPPER_PER_SILVER);
	
	local TMP_GOLD_AMOUNT_TEXTURE = "%s\124TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0\124t";
	if (gold >0) then
		return format(TMP_GOLD_AMOUNT_TEXTURE.." "..SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, goldDisplay, 0, 0, silver, 0, 0, copper, 0, 0);
	elseif (silver >0) then 
		return format(SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, silver, 0, 0, copper, 0, 0);
	elseif (copper >0) then
		return format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
	else
		return "";
	end
end

function Accountant_WeekStart()
	oneday = 86400;
	ct = time();
	dt = date("*t",ct);
	thisDay = dt["wday"];
	while thisDay ~= Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].weekstart do
		ct = ct - oneday;
		dt = date("*t",ct);
		thisDay = dt["wday"];
	end
	cdate = date(nil,ct);
	return string.sub(cdate,0,8);
end

function Accountant_OnShow()
	-- Check to see if the day has rolled over
	--tnt
	--cdate = date();
	cdate = date ("%d/%m/%y")
	
	cdate = string.sub(cdate,0,8);
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] ~= cdate then
		-- Its a new day! clear out the day tab
		for mode,value in pairs(Accountant_Data) do
			Accountant_Data[mode]["Day"].In = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Day"].In = 0;
			Accountant_Data[mode]["Day"].Out = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Day"].Out = 0;
		end
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["date"] = cdate;
	-- Check to see if the week has rolled over
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] ~= Accountant_WeekStart() then
		-- Its a new week! clear out the week tab
		for mode,value in pairs(Accountant_Data) do
			Accountant_Data[mode]["Week"].In = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Week"].In = 0;
			Accountant_Data[mode]["Week"].Out = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Week"].Out = 0;
		end
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"] = Accountant_WeekStart();

	-- Check to see if the month has rolled over
	cmonth = date ("%m")
	if Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["month"] ~= cmonth then
		-- Its a new month! clear out the month tab
		for mode,value in pairs(Accountant_Data) do
			Accountant_Data[mode]["Month"].In = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Month"].In = 0;
			Accountant_Data[mode]["Month"].Out = 0;
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode]["Month"].Out = 0;
		end
	end
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["month"] = cmonth;

	Accountant_SetLabels();
	if Accountant_CurrentTab ~= 6 then
		-- for all the tabs except for character tab
		TotalIn = 0;
		TotalOut = 0;
		mode = Accountant_LogModes[Accountant_CurrentTab];
		for key,value in pairs(Accountant_Data) do
			row = _G["AccountantFrameRow"..Accountant_Data[key].InPos.."In"];
			local mIn = Accountant_Data[key][mode].In;
			--row:SetText(Accountant_NiceCash(mIn));
			row:SetText(Accountant_GetFormattedValue(mIn));
			TotalIn = TotalIn + mIn;
			row = _G["AccountantFrameRow"..Accountant_Data[key].InPos.."Out"];
			local mOut = Accountant_Data[key][mode].Out;
			TotalOut = TotalOut + mOut;
			--row:SetText(Accountant_NiceCash(mOut));
			row:SetText(Accountant_GetFormattedValue(mOut));
		end

		--AccountantFrameTotalInValue:SetText(Accountant_NiceCash(TotalIn));
		--AccountantFrameTotalOutValue:SetText(Accountant_NiceCash(TotalOut));
		AccountantFrameTotalInValue:SetText("|cFFFFFFFF"..Accountant_GetFormattedValue(TotalIn));
		AccountantFrameTotalOutValue:SetText("|cFFFFFFFF"..Accountant_GetFormattedValue(TotalOut));
		if TotalOut > TotalIn then
			diff = TotalOut-TotalIn;
			AccountantFrameTotalFlow:SetText("|cFFFF3333"..ACCLOC_NETLOSS..":");
			--AccountantFrameTotalFlowValue:SetText(Accountant_NiceCash(diff));
			AccountantFrameTotalFlowValue:SetText("|cFFFF3333"..Accountant_GetFormattedValue(diff));
		else
			if TotalOut ~= TotalIn then
				diff = TotalIn-TotalOut;
				AccountantFrameTotalFlow:SetText("|cFF00FF00"..ACCLOC_NETPROF..":");
				--AccountantFrameTotalFlowValue:SetText(Accountant_NiceCash(diff));
				AccountantFrameTotalFlowValue:SetText("|cFF00FF00"..Accountant_GetFormattedValue(diff));
			else
				AccountantFrameTotalFlow:SetText(ACCLOC_NET..":");
				AccountantFrameTotalFlowValue:SetText("");
			end
		end
	else
		-- character totals
		local alltotal = 0;
		local i=1;
		for char,charvalue in pairs(Accountant_SaveData[Accountant_Server]) do
			_G["AccountantFrameRow"..i.."Title"]:SetText(char);
--			_G["AccountantFrameRow"..i.."Title"]:SetPoint("TOPLEFT", 20, -2);
			if Accountant_SaveData[Accountant_Server][char]["options"]["totalcash"] ~= nil then
				--_G["AccountantFrameRow"..i.."In"]:SetText(Accountant_NiceCash(Accountant_SaveData[Accountant_Server][char]["options"]["totalcash"]));
				_G["AccountantFrameRow"..i.."In"]:SetText("|cFFFFFFFF"..Accountant_GetFormattedValue(Accountant_SaveData[Accountant_Server][char]["options"]["totalcash"]));
				alltotal = alltotal + Accountant_SaveData[Accountant_Server][char]["options"]["totalcash"];
				_G["AccountantFrameRow"..i.."Out"]:SetText(Accountant_SaveData[Accountant_Server][char]["options"]["date"]);
			else
				_G["AccountantFrameRow"..i.."In"]:SetText("Unknown");
			end
			i=i+1;
		end
		--AccountantFrameTotalInValue:SetText(Accountant_NiceCash(alltotal));
		AccountantFrameTotalInValue:SetText("|cFFFFFFFF"..Accountant_GetFormattedValue(alltotal));

	end
	SetPortraitTexture(AccountantFramePortrait, "player");

	if Accountant_CurrentTab == 3 then
		AccountantFrameExtra:SetText(ACCLOC_WEEKSTART..":");
		AccountantFrameExtraValue:SetText(Accountant_SaveData[Accountant_Server][Accountant_Player]["options"]["dateweek"]);
	else
		AccountantFrameExtra:SetText("");
		AccountantFrameExtraValue:SetText("");
	end

	PanelTemplates_SetTab(AccountantFrame, Accountant_CurrentTab);

end


function Accountant_OnHide()
	if MYADDONS_ACTIVE_OPTIONSFRAME == self then
		ShowUIPanel(myAddOnsFrame);
	end
end

function ACC_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function Accountant_ShowUsage()
	ACC_Print("/accountant log\n");
end

function Accountant_ResetData()
	local type = Accountant_LogModes[Accountant_CurrentTab];
	if type == "Total" then
		type = ACCLOC_TOTAL;
	elseif type == "Session" then
		type = ACCLOC_SESS;
	elseif type == "Day" then
		type = ACCLOC_DAY;
	elseif type == "Week" then
		type = ACCLOC_WEEK;
	elseif type == "Month" then
		type = ACCLOC_MONTH;
	else

	end

	StaticPopupDialogs["ACCOUNTANT_RESET"].text = ACCLOC_RESET_CONF.."\""..type.."\"?";
	local dialog = StaticPopup_Show("ACCOUNTANT_RESET","weeee");
end

function Accountant_ResetConfirmed()
	local type = Accountant_LogModes[Accountant_CurrentTab];
	for key,value in pairs(Accountant_Data) do
		Accountant_Data[key][type].In = 0;
		Accountant_Data[key][type].Out = 0;
		Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][type].In = 0;
		Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][key][type].Out = 0;
	end
	if AccountantFrame:IsVisible() then
		Accountant_OnShow();
	end
end

function Accountant_UpdateLog()
	Accountant_CurrentMoney = GetMoney();
	Accountant_SaveData[Accountant_Server][Accountant_Player]["options"].totalcash = Accountant_CurrentMoney;
	diff = Accountant_CurrentMoney - Accountant_LastMoney;
	Accountant_LastMoney = Accountant_CurrentMoney;
	if diff == 0 or diff == nil then
		return;
	end

	local mode = Accountant_Mode;
	if mode == "" then mode = "OTHER"; end
	if diff >0 then
		for key,logmode in pairs(Accountant_LogModes) do
			Accountant_Data[mode][logmode].In = Accountant_Data[mode][logmode].In + diff
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode][logmode].In = Accountant_Data[mode][logmode].In;
		end
		if Accountant_Verbose then ACC_Print("Gained "..Accountant_NiceCash(diff).." from "..mode); end
	elseif diff < 0 then
		diff = diff * -1;
		for key,logmode in pairs(Accountant_LogModes) do
			Accountant_Data[mode][logmode].Out = Accountant_Data[mode][logmode].Out + diff
			Accountant_SaveData[Accountant_Server][Accountant_Player]["data"][mode][logmode].Out = Accountant_Data[mode][logmode].Out;
		end
		if Accountant_Verbose then ACC_Print("Lost "..Accountant_NiceCash(diff).." from "..mode); end
	end

	-- special case mode resets
	if Accountant_Mode == "REPAIRS" then
		Accountant_Mode = "MERCH";
	end


	if AccountantFrame:IsVisible() then
		Accountant_OnShow();
	end
end

function AccountantTab_OnClick(self)
	PanelTemplates_SetTab(AccountantFrame, self:GetID());
	Accountant_CurrentTab = self:GetID();
	PlaySound("igCharacterInfoTab");
	Accountant_OnShow();
end

-- hooks

function Accountant_RepairAllItems(guildBankRepair)
	if (not guildBankRepair) then
		Accountant_Mode = "REPAIRS";
	end
	Accountant_RepairAllItems_old(guildBankRepair);
end

function Accountant_CursorHasItem()
	if InRepairMode() then
		Accountant_Mode = "REPAIRS";
	end
	local toret = Accountant_CursorHasItem_old();
	return toret;
end

function AccountantMoneyInfoFrame_Update()
	--AccountantMoneyInfoText:SetText(Accountant_NiceCash(GetMoney()));
	AccountantMoneyInfoText:SetText("|cFFFFFFFF"..Accountant_GetFormattedValue(GetMoney()));
end

function AccountantMoneyInfoFrame_HandleMouseDown(self, buttonName)    
	-- Prevent activation when in combat
	if (InCombatLockdown() == 1) then
		return;
	end
	-- Handle left button clicks
	if (buttonName == "LeftButton") then
		AccountantMoneyInfoFrame:StartMoving();
	elseif (buttonName == "RightButton") then
		AccountantButton_OnClick();
		GameTooltip_Hide();
	end
end

function AccountantMoneyInfoFrame_HandleMouseUp(self, button)
	AccountantMoneyInfoFrame:StopMovingOrSizing();
end

function AccountantMoneyInfoFrame_Init()
	if(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showmoneyinfo == nil) then
		Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showmoneyinfo = true;
	end
	if(Accountant_SaveData[GetRealmName()][UnitName("player")]["options"].showmoneyinfo == true) then
		AccountantMoneyInfoFrame:Show();
	else
		AccountantMoneyInfoFrame:Hide();
	end
end

function AccountantMoneyInfoFrame_OnEnter(self)
	if (not GameTooltip:IsShown()) then
		local amoney_str = "";

		local TotalIn = 0;
		local TotalOut = 0;
		for key,value in pairs(Accountant_Data) do
			TotalIn = TotalIn + Accountant_Data[key]["Session"].In;
			TotalOut = TotalOut + Accountant_Data[key]["Session"].Out;
		end
		amoney_str = "|cFFFFFFFF"..ACCLOC_TOT_IN..": "..Accountant_GetFormattedValue(TotalIn).."\n";
		amoney_str = amoney_str.."|cFFFFFFFF"..ACCLOC_TOT_OUT..": "..Accountant_GetFormattedValue(TotalOut).."\n";
		if TotalOut > TotalIn then
			diff = TotalOut-TotalIn;
			amoney_str = amoney_str.."|cFFFF3333"..ACCLOC_NETLOSS..": ";
			amoney_str = amoney_str..Accountant_GetFormattedValue(diff);
		else
			if TotalOut ~= TotalIn then
				diff = TotalIn-TotalOut;
				amoney_str = amoney_str.."|cFF00FF00"..ACCLOC_NETPROF..": ";
				amoney_str = amoney_str..Accountant_GetFormattedValue(diff);
			else

			end
		end

		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -10, 0);
		GameTooltip:SetBackdropColor(0, 0, 0, 0.5);
		GameTooltip:SetText("|cFFFFFFFF"..ACCLOC_TITLE.." - "..ACCLOC_SESS, 1, 1, 1, nil, 1);
		GameTooltip:AddLine(amoney_str, 1, 1, 1, 1);
		GameTooltip:AddLine("("..ACCLOC_TIP2..")", 0.8, 0.8, 0.8, 1);
		GameTooltip:Show();
	else
		GameTooltip:Hide();
	end
end

function AccountantMoneyInfoFrame_OnLeave(self)
	GameTooltip_Hide();
end
