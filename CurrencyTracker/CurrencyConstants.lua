--[[
    CurrencyConstants.lua
    
    Defines supported currencies, their metadata, and version comparison utilities
    for the Accountant Classic Currency Tracker module.
]]

local addonName, addonTable = ...

-- Create the CurrencyConstants namespace
local CurrencyConstants = {}

-- Version comparison utilities
CurrencyConstants.VersionUtils = {
    -- Convert version string (e.g., "11.0.0") to comparable number (e.g., 110000)
    ParseVersion = function(versionString)
        if not versionString or type(versionString) ~= "string" then
            return 0
        end
        
        local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
        if not major or not minor or not patch then
            return 0
        end
        
        return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
    end,
    
    -- Compare two version numbers (returns -1, 0, or 1)
    CompareVersions = function(version1, version2)
        local v1 = type(version1) == "string" and CurrencyConstants.VersionUtils.ParseVersion(version1) or version1
        local v2 = type(version2) == "string" and CurrencyConstants.VersionUtils.ParseVersion(version2) or version2
        
        if v1 < v2 then
            return -1
        elseif v1 > v2 then
            return 1
        else
            return 0
        end
    end,
    
    -- Get current WoW version as comparable number
    GetCurrentWoWVersion = function()
        local version = GetBuildInfo()
        if version then
            return CurrencyConstants.VersionUtils.ParseVersion(version)
        end
        return 0
    end,
    
    -- Check if current client supports a minimum version
    IsVersionSupported = function(minVersion)
        local currentVersion = CurrencyConstants.VersionUtils.GetCurrentWoWVersion()
        local requiredVersion = type(minVersion) == "string" and CurrencyConstants.VersionUtils.ParseVersion(minVersion) or minVersion
        return currentVersion >= requiredVersion
    end
}

-- Utility functions for currency management backed by LibCurrencyInfo
local function GetLibCurrencyInfo()
    return LibStub and LibStub("LibCurrencyInfo", true) or nil
end

CurrencyConstants.Utils = {
    -- Acquire LibCurrencyInfo instance
    GetLib = GetLibCurrencyInfo,

    -- Check if a currency is supported / curated
    IsCurrencySupported = function(currencyID)
        if not currencyID or type(currencyID) ~= "number" then
            return false
        end
        local lib = GetLibCurrencyInfo()
        if lib and lib.data and lib.data.Currencies then
            local cdata = lib.data.Currencies[currencyID]
            if cdata ~= nil then
                return not cdata.hide
            end
        end
        -- Fallback: check Blizzard API
        if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
            local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, currencyID)
            return ok and type(info) == "table" and info.name ~= nil and info.name ~= ""
        end
        return false
    end,

    -- Get currency info by ID combining LibCurrencyInfo and Blizzard API
    GetCurrencyInfo = function(currencyID, locale)
        if not currencyID then
            return nil
        end
        local lib = GetLibCurrencyInfo()
        if lib then
            local info = lib:GetCurrencyInfo(currencyID, locale)
            if info then
                return {
                    id = currencyID,
                    name = info.name,
                    icon = info.iconFileID,
                    categoryID = info.categoryID,
                    category = info.categoryName or "",
                    description = info.description or "",
                    quantity = info.quantity or 0,
                    maxQuantity = info.maxQuantity or 0,
                    maxWeeklyQuantity = info.maxWeeklyQuantity or 0,
                    quantityEarnedThisWeek = info.quantityEarnedThisWeek or 0,
                    discovered = info.discovered,
                    quality = info.quality,
                    isTracked = true,
                }
            end
        end

        -- Fallback to C_CurrencyInfo if library did not resolve
        if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
            local ok, ci = pcall(C_CurrencyInfo.GetCurrencyInfo, currencyID)
            if ok and type(ci) == "table" and ci.name then
                return {
                    id = currencyID,
                    name = ci.name,
                    icon = ci.iconFileID,
                    quantity = ci.quantity or 0,
                    maxQuantity = ci.maxQuantity or 0,
                    maxWeeklyQuantity = ci.maxWeeklyQuantity or 0,
                    quantityEarnedThisWeek = ci.quantityEarnedThisWeek or 0,
                    discovered = ci.discovered,
                    quality = ci.quality,
                    categoryID = nil,
                    category = "Other",
                    description = "",
                    isTracked = true,
                }
            end
        end

        return nil
    end,

    -- Get all curated currency IDs for the current client from LibCurrencyInfo
    GetCuratedCurrencies = function()
        local list = {}
        local lib = GetLibCurrencyInfo()
        if lib and lib.data and lib.data.Currencies then
            for cid, cdata in pairs(lib.data.Currencies) do
                if not cdata.hide then
                    table.insert(list, cid)
                end
            end
            table.sort(list)
        end
        return list
    end,

    -- Get all currencies for current client version
    GetCurrenciesForCurrentVersion = function()
        local currencies = {}
        local lib = GetLibCurrencyInfo()
        if lib and lib.data and lib.data.Currencies then
            for cid, cdata in pairs(lib.data.Currencies) do
                if not cdata.hide then
                    local info = CurrencyConstants.Utils.GetCurrencyInfo(cid)
                    if info then
                        currencies[cid] = info
                    end
                end
            end
        end
        return currencies
    end,

    -- Get tracked currencies (curated set)
    GetTrackedCurrencies = function()
        return CurrencyConstants.Utils.GetCurrenciesForCurrentVersion()
    end,
}

-- UI Constants
CurrencyConstants.UI = {
    GOLD_TAB_INDEX = 1,
    CURRENCY_TAB_INDEX = 2,
}

-- Default currency settings
CurrencyConstants.Defaults = {
    PRIMARY_CURRENCY = 1166, -- Default fallback ID (e.g. Timewarped Badge)
    TRACKING_ENABLED = true,
    MAX_HISTORY_DAYS = 365,
    UPDATE_THROTTLE_MS = 100,
}

-- Dynamic list of currencies mirrored from LibCurrencyInfo
CurrencyConstants.CurrencyWhitelist = {}
CurrencyConstants.SupportedCurrencies = {}

function CurrencyConstants:RefreshData()
    local lib = GetLibCurrencyInfo()
    local curated = CurrencyConstants.Utils.GetCuratedCurrencies()

    -- Populate CurrencyWhitelist array
    for k in pairs(self.CurrencyWhitelist) do
        self.CurrencyWhitelist[k] = nil
    end
    for i, cid in ipairs(curated) do
        self.CurrencyWhitelist[i] = cid
    end

    -- Populate SupportedCurrencies table
    for k in pairs(self.SupportedCurrencies) do
        self.SupportedCurrencies[k] = nil
    end
    if lib and lib.data and lib.data.Currencies then
        for cid, cdata in pairs(lib.data.Currencies) do
            if not cdata.hide then
                self.SupportedCurrencies[cid] = {
                    id = cid,
                    categoryID = cdata.category,
                    isTracked = true,
                }
            end
        end
    end
    -- Fallback seed if library has no currencies for current flavor (e.g. vanilla Era)
    if not next(self.SupportedCurrencies) then
        self.SupportedCurrencies[CurrencyConstants.Defaults.PRIMARY_CURRENCY] = {
            id = CurrencyConstants.Defaults.PRIMARY_CURRENCY,
            name = "Timewarped Badge",
            isTracked = true,
        }
    end

    return self.SupportedCurrencies
end

-- Populate initial caches
CurrencyConstants:RefreshData()

-- Export the module to CurrencyTracker namespace
CurrencyTracker = CurrencyTracker or {}
CurrencyTracker.Constants = CurrencyConstants

-- Source code tokens map
-- Numeric codes from CURRENCY_DISPLAY_UPDATE mapped to stable tokens.
-- Keys should be absolute values; direction is represented by sign at usage site.
CurrencyTracker.SourceCodeTokens = CurrencyTracker.SourceCodeTokens or {
    -- Official names mirrored from Enum.CurrencySource
    [0]  = "ConvertOldItem",
    [1]  = "ConvertOldPvPCurrency",
    [2]  = "ItemRefund",
    [3]  = "QuestReward",
    [4]  = "Cheat",
    [5]  = "Vendor",
    [6]  = "PvPKillCredit",
    [7]  = "PvPMetaCredit",
    [8]  = "PvPScriptedAward",
    [9]  = "Loot",
    [10] = "UpdatingVersion",
    [11] = "LFGReward",
    [12] = "Trade",
    [13] = "Spell",
    [14] = "ItemDeletion",
    [15] = "RatedBattleground",
    [16] = "RandomBattleground",
    [17] = "Arena",
    [18] = "ExceededMaxQty",
    [19] = "PvPCompletionBonus",
    [20] = "Script",
    [21] = "GuildBankWithdrawal",
    [22] = "Pushloot",
    [23] = "GarrisonBuilding",
    [24] = "PvPDrop",
    [25] = "GarrisonFollowerActivation",
    [26] = "GarrisonBuildingRefund",
    [27] = "GarrisonMissionReward",
    [28] = "GarrisonResourceOverTime",
    [29] = "QuestRewardIgnoreCapsDeprecated",
    [30] = "GarrisonTalent",
    [31] = "GarrisonWorldQuestBonus",
    [32] = "PvPHonorReward",
    [33] = "BonusRoll",
    [34] = "AzeriteRespec",
    [35] = "WorldQuestReward",
    [36] = "WorldQuestRewardIgnoreCapsDeprecated",
    [37] = "FactionConversion",
    [38] = "DailyQuestReward",
    [39] = "DailyQuestWarModeReward",
    [40] = "WeeklyQuestReward",
    [41] = "WeeklyQuestWarModeReward",
    [42] = "AccountCopy",
    [43] = "WeeklyRewardChest",
    [44] = "GarrisonTalentTreeReset",
    [45] = "DailyReset",
    [46] = "AddConduitToCollection",
    [47] = "Barbershop",
    [48] = "ConvertItemsToCurrencyValue",
    [49] = "PvPTeamContribution",
    [50] = "Transmogrify",
    [51] = "AuctionDeposit",
    [52] = "PlayerTrait",
    [53] = "PhBuffer_53",
    [54] = "PhBuffer_54",
    [55] = "RenownRepGain",
    [56] = "CraftingOrder",
    [57] = "CatalystBalancing",
    [58] = "CatalystCraft",
    [59] = "ProfessionInitialAward",
    [60] = "PlayerTraitRefund",
    [61] = "AccountHwmUpdate",
    [62] = "ConvertItemsToCurrencyAndReputation",
    [63] = "PhBuffer_63",
    [64] = "SpellSkipLinkedCurrency",
    [65] = "AccountTransfer",
}

-- Destroy reason tokens map (loss side)
-- Official names mirrored from Enum.CurrencyDestroyReason (WoW 11.0.2+)
-- Keys are absolute enum values; direction is represented by sign at usage site (negative for loss)
CurrencyTracker.DestroyReasonTokens = CurrencyTracker.DestroyReasonTokens or {
    [0]  = "Cheat",
    [1]  = "Spell",
    [2]  = "VersionUpdate",
    [3]  = "QuestTurnin",
    [4]  = "Vendor",
    [5]  = "Trade",
    [6]  = "Capped",
    [7]  = "Garrison",
    [8]  = "DroppedToCorpse",
    [9]  = "BonusRoll",
    [10] = "FactionConversion",
    [11] = "FulfillCraftingOrder",
    [12] = "Script",
    [13] = "ConcentrationCast",
    [14] = "AccountTransfer",
}

--- Resolve and format source token/label for child transactions
-- @param source number|string The raw source code or string token
-- @return string Localized display label
function CurrencyTracker:FormatSourceLabel(source)
    local label = tostring(source)
    local L = LibStub and LibStub("AceLocale-3.0", true) and LibStub("AceLocale-3.0"):GetLocale("Accountant_Classic", true) or nil
    local num = tonumber(source)
    if num ~= nil then
        local token
        if num >= 0 then
            token = self.SourceCodeTokens and self.SourceCodeTokens[num]
        else
            local absCode = -num
            token = self.DestroyReasonTokens and self.DestroyReasonTokens[absCode]
        end
        if token then
            label = (L and L[token]) or token
        else
            label = "S:" .. tostring(num)
        end
    elseif type(source) == "string" then
        if L and L[source] then
            label = L[source]
        end
    end
    return label
end

--- Check whether a currency ID passes the whitelist filter
-- @param currencyID number The currency ID to check
-- @return boolean True if allowed, false if filtered out
function CurrencyTracker:IsCurrencyAllowed(currencyID)
    if not currencyID then return false end
    currencyID = tonumber(currencyID)
    if not currencyID then return false end

    -- Read whitelist toggle (default ON)
    local whitelistEnabled = true
    if EnsureSavedVariablesStructure and GetCurrentServerAndCharacter then
        local server, character = GetCurrentServerAndCharacter()
        local sv = _G.Accountant_ClassicSaveData
        if sv and sv[server] and sv[server][character] then
            local charData = sv[server][character]
            local opt = charData.currencyOptions and charData.currencyOptions.whitelistFilter
            if opt ~= nil then whitelistEnabled = opt and true or false end
        end
    end

    if not whitelistEnabled then
        return true
    end

    if self.Constants and self.Constants.SupportedCurrencies and next(self.Constants.SupportedCurrencies) then
        return self.Constants.SupportedCurrencies[currencyID] ~= nil
    end

    local wl = self.Constants and self.Constants.CurrencyWhitelist
    if wl and #wl > 0 then
        for _, id in ipairs(wl) do
            if id == currencyID then return true end
        end
        return false
    end

    return true
end

-- Also export to addon table and global if available
if addonTable then
    addonTable.CurrencyConstants = CurrencyConstants
else
    _G.CurrencyConstants = CurrencyConstants
end

return CurrencyConstants