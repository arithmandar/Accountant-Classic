---@meta _
-- ----------------------------------------------------------------------------
-- Accountant-Classic Annotations for Lua Language Server
--
-- Annotations for lua-language-server and Ketho's WoW API extension for
-- VS Code (https://github.com/Ketho/vscode-wow-api). This file is NOT loaded
-- by the game (it is not listed in the TOC) and is excluded from packaging.
--
-- All shared types are declared here. The source files only keep a one line
-- `---@class X` on the local where the object is created (so that methods
-- defined there are attached to the class) plus @param / @return on functions.
-- ----------------------------------------------------------------------------

------------------------------------------------------------------------
-- Addon namespace (the private table passed to every file as `...`)
------------------------------------------------------------------------

---@class ACNamespace
---@field addon_name string Folder name of the addon ("Accountant_Classic")
---@field Client ACClient Which game client flavour is running
---@field constants ACConstants Static tables shared by all files
---@field GetClassColorPrefix fun(classToken: string?): string Returns "|cAARRGGBB" for a class token, or "" when unknown
---@field History ACHistory Long-lived history ledger (Core/History.lua)

---@class ACClient
---@field projectID integer WOW_PROJECT_ID of the running client
---@field isRetail boolean Mainline client (WOW_PROJECT_MAINLINE)
---@field isClassicEra boolean Classic Era / Season of Discovery / Hardcore
---@field isTBCClassic boolean Burning Crusade Classic / Anniversary
---@field isCataclysmClassic boolean Cataclysm Classic
---@field isMistsClassic boolean Mists of Pandaria Classic
---@field isForever boolean WoW: Forever (codename Camelot)
---@field isProgressionClassic boolean Cataclysm or Mists Classic
---@field isAnyClassic boolean Classic Era, TBC or a progression Classic client
---@field isKnownProject boolean Retail, any Classic or Forever

------------------------------------------------------------------------
-- Log types, periods and amounts
------------------------------------------------------------------------

---Income / expense category. Each one is a row in the main window.
---@alias ACLogType
---| "TRANSMO"   # Transmogrification
---| "GARRISON"  # Garrison / order hall / covenant mission tables
---| "LFG"       # Dungeon finder rewards
---| "BARBER"    # Barber shop
---| "GUILD"     # Guild bank deposits / withdrawals
---| "BANK"      # Bank tabs / bag slots and Warband bank gold
---| "LOOT"      # Looted money
---| "MERCH"     # Merchants (buying / selling)
---| "QUEST"     # Quest rewards
---| "TRADE"     # Player trades
---| "MAIL"      # Mailbox (including auction house mail)
---| "AH"        # Auction house deposits / payouts
---| "TRAIN"     # Class / profession trainers
---| "TAXI"      # Flight masters
---| "REPAIRS"   # Repairs
---| "OTHER"     # Anything else

---Log type currently in effect; "" means no specific source (logged as OTHER).
---@alias ACActiveLogType ACLogType|""

---Reporting period. "Prv*" keys hold the previous period, rolled over by shiftLogs().
---@alias ACLogMode
---| "Session"
---| "Day"
---| "PrvDay"
---| "Week"
---| "PrvWeek"
---| "Month"
---| "PrvMonth"
---| "Year"
---| "PrvYear"
---| "Total"

---@alias ACCashFlow "In"|"Out"

---Copper earned and spent in one period.
---@class ACAmounts
---@field In integer Copper earned
---@field Out integer Copper spent

---Runtime row data for one log type (private.constants.onlineData / AC_DATA).
---@class ACLogTypeData
---@field Title string Localized row title
---@field InPos integer? Row index in the main window, set by setLabels()
---@field order integer? Position in constants.logtypes, set by loadData()
---@field Session ACAmounts?
---@field Day ACAmounts?
---@field PrvDay ACAmounts?
---@field Week ACAmounts?
---@field PrvWeek ACAmounts?
---@field Month ACAmounts?
---@field PrvMonth ACAmounts?
---@field Year ACAmounts?
---@field PrvYear ACAmounts?
---@field Total ACAmounts?

---Saved amounts for one log type, keyed by period.
---@alias ACLogTypeHistory table<ACLogMode, ACAmounts>

---Selected character in the dropdown / All Chars list: { server, character }.
---@class ACCharacterRef
---@field [1] string Server key
---@field [2] string Character key

---Period rollover rule: { option key, previous option key, mode, previous mode }.
---@class ACPeriodRule
---@field [1] "date"|"dateweek"|"month"|"curryear"
---@field [2] "prvday"|"prvdateweek"|"prvmonth"|"prvyear"
---@field [3] ACLogMode
---@field [4] ACLogMode

------------------------------------------------------------------------
-- Constants (Core/Constants.lua)
------------------------------------------------------------------------

---@class ACConstants
---@field addon_name string Same as ACNamespace.addon_name
---@field defaults { profile: ACProfile } AceDB defaults
---@field logmodes ACLogMode[] Period shown by each tab, indexed by tab number
---@field months string[] Localized month names (MONTH_JANUARY ...)
---@field currTab integer Tab selected when the window first opens
---@field tabText string[] Localized tab captions
---@field tabTooltipText string[] Localized tab tooltips
---@field logtypes ACLogType[] Row order of the main window (also AC_LOGTYPE_ORDER)
---@field onlineData table<ACLogType, ACLogTypeData> Row titles for the current client
---@field eventLogTypes table<string, ACActiveLogType> Event name to the log type it switches to
---@field events string[] Events registered by the main frame
---@field ldbDisplayTypes ACLogMode[] LDB / minimap text period, indexed by profile.ldbDisplayType
---@field dateformats string[] Date formats offered in the options, indexed by profile.dateformat
---@field maxCharLines integer Rows in the character list (All Chars tab)
---@field maxTooltipLines integer Maximum zone lines in a row tooltip
---@field iconTexture string Addon icon file path

------------------------------------------------------------------------
-- Saved variables (see ## SavedVariables in the .toc)
------------------------------------------------------------------------

---LibDBIcon settings; LibDBIcon treats a missing `lock` as unlocked.
---@class ACMinimapDB : LibDBIcon.button.DB
---@field lock boolean?
---@field show boolean? Legacy flag kept in the defaults

---AceDB profile (Accountant_ClassicDB).
---@class ACProfile
---@field minimap ACMinimapDB LibDBIcon position / visibility
---@field showbutton boolean Show the minimap button
---@field showmoneyinfo boolean Show the floating money frame
---@field showmoneyonbutton boolean Show net money on the minimap / LDB button
---@field showintrotip boolean Show the intro text in the minimap tooltip
---@field showsessiononbutton boolean Show session income / expense in the minimap tooltip
---@field cross_server boolean Show characters of every realm
---@field show_allFactions boolean Show characters of both factions
---@field trackzone boolean Record which zone money changed in
---@field tracksubzone boolean Include the sub-zone when tracking zones
---@field breakupnumbers boolean Use thousand separators for gold
---@field ldbDisplayType integer Index into constants.ldbDisplayTypes
---@field dateformat integer Index into constants.dateformats
---@field weekstart integer First day of the week (1 = Sunday)
---@field AcFramePoint table? Saved anchor of the main window
---@field MnyFramePoint table? Saved anchor of the money frame
---@field scale number Main window scale
---@field alpha number Main window alpha
---@field infoscale number Money frame scale
---@field infoalpha number Money frame alpha
---@field faction string? Faction of the character that created the profile
---@field class string? Class token of the character that created the profile
---@field rememberSelectedCharacter boolean Reopen with the last selected character
---@field selectedCharacterKey string? Last selected character, "server\tcharacter" or "*" for All Chars
---@field selectedCharacter integer? Legacy index-based selection, cleared on save
---@field profileCopied boolean Default for the "per-character options copied" flag
---@field oprofileCopied boolean? Set once the legacy per-character options were copied into the profile

---@class ACDatabase : AceDBObject-3.0
---@field profile ACProfile

---Per-character options stored in Accountant_ClassicSaveData.
---@class ACCharacterOptions
---@field version string? Addon version that last wrote the record
---@field date string Current day ("dd/mm/yy")
---@field lastsessiondate string Day of the last session ("dd/mm/yy")
---@field weekdate string Legacy week field, "" for new records
---@field weekstart integer
---@field month string Current month ("%m")
---@field curryear string Current year ("%Y")
---@field totalcash integer Copper on the character at last update
---@field faction string? "Alliance", "Horde" or "Neutral"
---@field class string? Class token, e.g. "MAGE"
---@field prvday string? Previous day, set when the day rolls over
---@field dateweek string? Start of the current week ("mm/dd/yy", see addon:WeekStart())
---@field prvdateweek string? Previous week, set when the week rolls over
---@field prvmonth string? Previous month
---@field prvyear string? Previous year
---@field showbutton boolean? Legacy per-character option (copied into the profile)
---@field showmoneyinfo boolean? Legacy per-character option
---@field showintrotip boolean? Legacy per-character option
---@field showmoneyonbutton boolean? Legacy per-character option
---@field showsessiononbutton boolean? Legacy per-character option
---@field breakupnumbers boolean? Legacy per-character option
---@field cross_server boolean? Legacy per-character option
---@field show_allFactions boolean? Legacy per-character option
---@field trackzone boolean? Legacy per-character option
---@field tracksubzone boolean? Legacy per-character option
---@field dateformat integer? Legacy per-character option
---@field scale number? Legacy per-character option
---@field alpha number? Legacy per-character option
---@field infoscale number? Legacy per-character option
---@field infoalpha number? Legacy per-character option
---@field buttonpos number? Legacy minimap button angle

---@class ACCharacterData
---@field options ACCharacterOptions
---@field data table<ACLogType, ACLogTypeHistory>

---Server name, then character name (Forever: "Name-Server" for characters with a second name).
---@alias ACSaveData table<string, table<string, ACCharacterData>>

---Zone breakdown for one character: period, then log type, then zone text.
---@class ACZoneCharacterData
---@field data table<ACLogMode, table<ACLogType, table<string, ACAmounts>>>

---@alias ACZoneDB table<string, table<string, ACZoneCharacterData>>

---Money history of every character, by server and character name.
---@type ACSaveData
Accountant_ClassicSaveData = {}

---Optional zone breakdown of the money history.
---@type ACZoneDB
Accountant_ClassicZoneDB = {}

------------------------------------------------------------------------
-- History ledger (Core/History.lua)
------------------------------------------------------------------------

---Totals of one category on one day (or summed over a range by GetTotals).
---@class ACHistoryBucket
---@field i integer Copper in
---@field o integer Copper out
---@field ni integer Number of money-in records
---@field no integer Number of money-out records
---@field mi integer Largest single money-in
---@field mo integer Largest single money-out

---Income / expense and online time of one hour. Transfers are not included.
---@class ACHistoryHour
---@field i integer Copper in
---@field o integer Copper out
---@field m integer Online minutes
---@field a integer? AFK minutes (subset of m)

---One day of one character: category buckets plus `h` (hours 0-23), `bal`,
---`z[uiMapID][category]` and `s[uiMapID][subZone][category]` (ACHistoryLocationBucket).
---@alias ACHistoryDay table<string, ACHistoryBucket|table<integer, ACHistoryHour>|integer>

---@class ACHistoryChar
---@field server string
---@field name string Same as the classic character key
---@field guid string? Player GUID, used to tell a re-created character from the old one
---@field since integer YYYYMMDD of the first tracked day
---@field deleted integer? Time the classic data was removed while the history was kept
---@field archivedFrom string? Original key when the name was reused by another character
---@field faction string?
---@field class string?
---@field money integer? Last known balance
---@field moneyAt integer? Time of that balance
---@field days table<integer, ACHistoryDay> By YYYYMMDD

---Recent money change for drill-down. Consecutive LOOT and MERCH income records are merged.
---@class ACHistoryRecent
---@field t integer Time
---@field c string charKey ("Server|Name")
---@field k string Category
---@field a integer Signed copper amount
---@field n integer? Number of merged records
---@field z integer? uiMapID
---@field s string? English sub-zone key (LibBabble-SubZone)
---@field sr string? Raw sub-zone text when no key was found
---@field sl string? Locale of sr
---@field u integer? 1 when found at login (change outside the tracked sessions); no location

---Money of one category in one location on one day. Transfers are not included.
---@class ACHistoryLocationBucket
---@field i integer Copper in
---@field o integer Copper out
---@field ni integer Number of money-in records
---@field no integer Number of money-out records

---Location totals returned by History:GetLocationTotals.
---@class ACHistoryLocationTotal: ACHistoryLocationBucket
---@field categories table<string, ACHistoryLocationBucket>
---@field subZones table<string, ACHistoryLocationTotal>? By English sub-zone key, or "#<locale>:<raw text>"

---@class ACHistoryDB
---@field schema integer
---@field created integer
---@field settings { recentMax: integer, recentDays: integer }
---@field chars table<string, ACHistoryChar> By charKey
---@field warband { money: integer, moneyAt: integer, days: table<integer, integer> }?
---@field recent ACHistoryRecent[]

---Filter for the query functions. "All" or nil means no filter.
---@class ACHistoryScope
---@field char string? charKey
---@field server string?
---@field faction string?
---@field excludeDeleted boolean?

---@class ACHistorySummary
---@field income integer
---@field expense integer
---@field net integer
---@field transferIn integer
---@field transferOut integer
---@field since integer? Earliest tracked day in scope

---@class ACHistoryDailyPoint
---@field day integer YYYYMMDD (first day of the period for AggregateBy)
---@field income integer
---@field expense integer
---@field net integer
---@field transferIn integer
---@field transferOut integer
---@field minutes integer
---@field afk integer
---@field noData boolean Before tracking began

---History ledger saved variable.
---@type ACHistoryDB
Accountant_ClassicHistory = {}

---Raw AceDB storage behind addon.db.
---@type table
Accountant_ClassicDB = {}

------------------------------------------------------------------------
-- Addon object and modules
------------------------------------------------------------------------

---@class ACAddon : AceAddon, AceConsole-3.0, AceHook-3.0
---@field db ACDatabase
---@field constants ACConstants
---@field Name string Folder name
---@field LocName string Localized title
---@field Notes string? TOC notes
---@field Version string? TOC version
---@field UpdateDate string? TOC X-Date
---@field Author string? TOC author
---@field icon string Addon icon file path, used by the LDB object
---@field optionsFrames table<string, integer> Settings category IDs from AceConfigDialog:AddToBlizOptions, by key
---@field optionsFrameRefs table<string, Frame> Options panels from AceConfigDialog:AddToBlizOptions, by key
_G.Accountant_Classic = {}

---Floating money frame module (Core/MoneyFrame.lua).
---@class ACMoneyFrameModule : AceModule, AceEvent-3.0
---@field frame ACMoneyInfoFrame?

------------------------------------------------------------------------
-- Frames created by name (Core/UI.lua, Core/Templates.lua, Core/Tabs.lua)
------------------------------------------------------------------------

---One cell of a log row. Hovering shows the full text when it is truncated, or
---the zone breakdown for In / Out cells.
---@class ACRowColumn : Button
---@field Text FontString
---@field fullText string? Untruncated text shown in the tooltip
---@field logType ACLogType? Row log type, used for the zone tooltip
---@field cashflow ACCashFlow? "In" or "Out", used for the zone tooltip

---A row of the main window, also reused for the character list.
---@class ACRow : Frame
---@field Title ACRowColumn
---@field In ACRowColumn
---@field Out ACRowColumn

---Bottom tab of the main window.
---@class ACTab : Button, AccountantClassicTabButtonMixin
---@field Text FontString
---@field Left Texture?
---@field Middle Texture?
---@field Right Texture?
---@field LeftActive Texture?
---@field MiddleActive Texture?
---@field RightActive Texture?
---@field LeftHighlight Texture?
---@field MiddleHighlight Texture?
---@field RightHighlight Texture?

---Mixin applied to each bottom tab.
---@class AccountantClassicTabButtonMixin : Button
AccountantClassicTabButtonMixin = {}

---Sortable column header of the character list.
---@class ACHeaderButton : Button
---@field highlightTexture Texture?

---Dropdown created with LibUIDropDownMenu.
---@class ACDropDown : Frame
---@field Label FontString?

---@class ACMainFrame : Frame
---@field Portrait Texture
---@field TitleText FontString
---@field Source FontString
---@field In FontString
---@field Out FontString
---@field TotalIn FontString
---@field TotalInValue FontString
---@field TotalOut FontString
---@field TotalOutValue FontString
---@field TotalFlow FontString
---@field TotalFlowValue FontString
---@field Extra FontString
---@field ExtraValue FontString
---@field HeaderSource ACHeaderButton?
---@field HeaderIn ACHeaderButton?
---@field HeaderOut ACHeaderButton?
---@field ServerDropDown ACDropDown?
---@field FactionDropDown ACDropDown?
---@field CharacterDropDown ACDropDown?
---@field numTabs integer
---@field tabPadding number? Retail tab sizing (PanelTemplates_TabResize)
---@field minTabWidth number?
---@field maxTabWidth number?
---@field selectedTab integer?
---@field _accountantInitialized boolean?

---@class ACMoneyInfoFrame : Frame
---@field Text FontString

---@type ACMainFrame
AccountantClassicFrame = nil

---@type ScrollFrame
AccountantClassicScrollBar = nil

---@type Button
AccountantClassicFrameResetButton = nil

---@type ACTab
AccountantClassicFrameTab1 = nil

---@type ACDropDown
AccountantClassicFrameServerDropDown = nil

---@type ACDropDown
AccountantClassicFrameFactionDropDown = nil

---@type ACDropDown
AccountantClassicFrameCharacterDropDown = nil

---@type ACMoneyInfoFrame
AccountantClassicMoneyInfoFrame = nil

------------------------------------------------------------------------
-- LibUIDropDownMenu-4.0 (no annotations ship with the library)
------------------------------------------------------------------------

---Entry passed to UIDropDownMenu_AddButton.
---@class ACDropDownInfo
---@field text string?
---@field value any
---@field arg1 any
---@field arg2 any
---@field func fun(self: ACDropDownButton, arg1: any, arg2: any, checked: boolean?)?
---@field checked boolean|fun(self: ACDropDownButton): boolean?
---@field icon string|integer?
---@field colorCode string? "|cAARRGGBB" prefix for the text
---@field tooltipTitle string?
---@field tooltipText string?
---@field tooltipOnButton boolean?
---@field notCheckable boolean?
---@field isTitle boolean?
---@field disabled boolean?

---Menu button handed to an ACDropDownInfo.func callback.
---@class ACDropDownButton : Button
---@field value any
---@field arg1 any
---@field arg2 any
---@field checked boolean?

---@class ACLibUIDropDownMenu
local LibUIDropDownMenu = {}

---@param name string? Global frame name
---@param parent Frame?
---@return ACDropDown
function LibUIDropDownMenu:Create_UIDropDownMenu(name, parent) end

---@param frame Frame
---@param initFunction fun(frame: Frame, level: integer?, menuList: any?)
---@param displayMode string?
---@param level integer?
---@param menuList any?
function LibUIDropDownMenu:UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList) end

---@return ACDropDownInfo
function LibUIDropDownMenu:UIDropDownMenu_CreateInfo() end

---@param info ACDropDownInfo
---@param level integer?
function LibUIDropDownMenu:UIDropDownMenu_AddButton(info, level) end

---@param frame Frame
---@param value any
---@param useValue boolean?
function LibUIDropDownMenu:UIDropDownMenu_SetSelectedValue(frame, value, useValue) end

---@param frame Frame
---@param width number
---@param padding number?
function LibUIDropDownMenu:UIDropDownMenu_SetWidth(frame, width, padding) end

---@param frame Frame
---@param text string?
function LibUIDropDownMenu:UIDropDownMenu_SetText(frame, text) end

---@param frame Frame
---@param justifyH "LEFT"|"CENTER"|"RIGHT"
function LibUIDropDownMenu:UIDropDownMenu_JustifyText(frame, justifyH) end

---@param frame Frame
function LibUIDropDownMenu:UIDropDownMenu_EnableDropDown(frame) end

---@param frame Frame
function LibUIDropDownMenu:UIDropDownMenu_DisableDropDown(frame) end

---@param level integer?
function LibUIDropDownMenu:CloseDropDownMenus(level) end

------------------------------------------------------------------------
-- Globals from other clients / addons that the WoW API extension does not know
------------------------------------------------------------------------

---WoW: Forever project ID; only defined on the Forever client.
---@type integer?
WOW_PROJECT_CAMELOT = nil

---Legacy Interface Options panel (pre-Dragonflight clients without the Settings API).
---@type Frame?
InterfaceOptionsFrame = nil

---Legacy Interface Options API (pre-Dragonflight clients without the Settings API).
---@param panel string|Frame Category name or panel frame
function InterfaceOptionsFrame_OpenToCategory(panel) end

---Titan Panel: refreshes a plugin button. Only present when Titan Panel is loaded.
---@type fun(id: string)?
TitanPanelButton_UpdateButton = nil
