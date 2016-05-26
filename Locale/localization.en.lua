-- $Id$ 

local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("Accountant_Classic", "enUS", true, is_silent);

if not L then return end

-- Header
L["ACCLOC_TITLE"]		= "Accountant Classic";
L["ACCLOC_DESC"]		= "A basic tool to track your monetary incomings and outgoings within WoW.";
L["ACCLOC_TIP"]			= "Left-Click to open Accountant Classic.\nRight-Click for Accountant Classic options.\nLeft-click and drag to move this button.";
L["ACCLOC_TIP2"]		= "Left-click and drag to move this button.\nRight-Click to open Accountant Classic.";
L["ACCLOC_TOT_IN"]		= "Total Incomings";
L["ACCLOC_TOT_OUT"]		= "Total Outgoings";
L["ACCLOC_NET"]			= "Net Profit / Loss";
L["ACCLOC_NETLOSS"]		= "Net Loss";
L["ACCLOC_NETPROF"]		= "Net Profit";
L["ACCLOC_SOURCE"]		= "Source";
L["ACCLOC_IN"]			= "Incomings";
L["ACCLOC_OUT"]			= "Outgoings";
L["ACCLOC_WEEKSTART"]		= "Week Start";
L["ACCLOC_SUM"]			= "Sum Total";
L["ACCLOC_CHAR"]		= "Character";
L["ACCLOC_MONEY"]		= "Money";
L["ACCLOC_UPDATED"]		= "Updated";

-- Section Labels
L["ACCLOC_QUEST"]		= "Quest Rewards";
L["ACCLOC_MERCH"]		= "Merchants";
L["ACCLOC_TRADE"]		= "Trade Window";
L["ACCLOC_MAIL"]		= "Mail";
L["ACCLOC_TRAIN"]		= "Training Costs";
L["ACCLOC_TAXI"]		= "Taxi Fares";
L["ACCLOC_OTHER"]		= "Unknown";
L["ACCLOC_REPAIR"]		= "Repair Costs";
L["ACCLOC_LFG"]			= "LFD, LFR and Scen.";

-- Buttons
L["ACCLOC_RESET"]		= "Reset";
L["ACCLOC_OPTBUT"]		= "Options";
L["ACCLOC_EXIT"]		= "Exit";

-- Tabs
L["ACCLOC_SESS"]		= "Session";
L["ACCLOC_DAY"]			= "Day";
L["ACCLOC_WEEK"]		= "Week";
L["ACCLOC_MONTH"]		= "Month";
L["ACCLOC_TOTAL"]		= "Total";
L["ACCLOC_CHARS"]		= "All Chars";

-- Options
L["ACCLOC_OPTS"]		= "Accountant Classic Options";
L["ACCLOC_MINIBUT"]		= "Show minimap button";
L["ACCLOC_MINIBUTMONEY"]	= "Show money on minimap button's tooltip";
L["ACCLOC_MINIBUTSESSINF"]	= "Show session info on minimap button's tooltip";
L["ACCLOC_ONSCRMONEY"]		= "Show money on screen";
L["ACCLOC_RSTPOSITION"]		= "Reset position";
L["ACCLOC_RSTMNYFRM_TIP"]	= "Reset money frame's position";
L["ACCLOC_BUTPOS"]		= "Minimap Button Position";
L["ACCLOC_STARTWEEK"]		= "Start of Week";
L["ACCLOC_DONE"]		= "Done";
L["ACCLOC_INTROTIPS"]		= "Display Instruction Tips";
L["ACCLOC_INTROTIPS_TIP"]	= "Toggle whether to display minimap button or floating money frame's operation tips.";

-- Misc
L["ACCLOC_RESET_CONF"]		= "Are you sure you want to reset the ";
L["ACCLOC_NEWPROFILE"]		= "New Accountant Classic profile created for ";
L["ACCLOC_LOADPROFILE"]		= "Loaded Accountant Classic Profile for ";
L["ACCLOC_LOADED"]		= "Loaded";
L["ACCLOC_GOLD"]		= "g ";
L["ACCLOC_SILVER"]		= "s ";
L["ACCLOC_CENT"]		= "c";
L["ACCLOC_ABOUT"]		= "About";

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT"]	= "Accountant Classic";
L["BINDING_NAME_ACCOUNTANTTOG"]	= "Toggle Accountant Classic";
