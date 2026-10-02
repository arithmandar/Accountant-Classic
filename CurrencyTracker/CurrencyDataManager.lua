-- CurrencyDataManager.lua
-- Handles all currency data operations and storage
-- Provides generic tracking logic that works with any currency ID

-- Create the DataManager module
CurrencyTracker = CurrencyTracker or {}
CurrencyTracker.DataManager = {}

local DataManager = CurrencyTracker.DataManager

-- Module state
local isInitialized = false

-- Import constants module reference
local Constants = nil

-- Core interface implementation
function DataManager:Initialize()
    if isInitialized then
        return true
    end

    -- Get reference to Constants module
    Constants = CurrencyTracker.Constants
    if Constants and Constants.RefreshData then
        Constants:RefreshData()
    end

    -- Initialize storage if available
    if CurrencyTracker.Storage then
        CurrencyTracker.Storage:Initialize()
    end

    isInitialized = true
    return true
end

-- Generic currency tracking function that works with any currency ID
function DataManager:TrackCurrencyChange(currencyID, amount, source, zone)
    if not currencyID or not amount or amount == 0 then
        return false
    end

    -- Validate currency ID
    if not self:IsCurrencySupported(currencyID) then
        if CurrencyTracker.LogDebug then
            CurrencyTracker:LogDebug("Currency ID %d not supported", currencyID)
        end
        return false
    end

    -- Default source if not provided
    source = source or "Unknown"

    -- Determine if this is income or outgoing
    local isIncome = amount > 0
    local absAmount = math.abs(amount)

    -- Store the transaction
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:RecordCurrencyTransaction(
            currencyID,
            absAmount,
            isIncome,
            source,
            zone
        )
    end

    return true
end

-- Get currency data for different time periods (Session, Day, Week, etc.)
function DataManager:GetCurrencyData(currencyID, timeframe)
    if not currencyID then
        return nil
    end

    timeframe = timeframe or "Session"

    -- Retrieve data from storage
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:GetCurrencyData(currencyID, timeframe)
    end

    -- Return empty data structure if storage not available
    return {
        income = 0,
        outgoing = 0,
        net = 0,
        transactions = {}
    }
end

-- Get list of currencies that have data
function DataManager:GetAvailableCurrencies()
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:GetAvailableCurrencies()
    end

    return {}
end

-- Get list of supported currencies from LibCurrencyInfo and Constants
function DataManager:GetSupportedCurrencies()
    local lib = LibStub and LibStub("LibCurrencyInfo", true)
    local merged = {}

    -- Pull curated currencies from LibCurrencyInfo
    if lib and lib.data and lib.data.Currencies then
        for id, cdata in pairs(lib.data.Currencies) do
            if not cdata.hide then
                local catName = (lib.GetCurrencyCategoryNameByCategoryID and lib:GetCurrencyCategoryNameByCategoryID(cdata.category)) or "Other"
                merged[id] = {
                    id = id,
                    categoryID = cdata.category,
                    category = catName,
                    isTracked = true,
                }
            end
        end
    end

    -- Merge with seeded/fallback currencies from Constants
    local seeded = (Constants and Constants.SupportedCurrencies) or {}
    for id, cur in pairs(seeded) do
        if not merged[id] then
            merged[id] = cur
        end
    end

    -- Merge dynamically discovered currencies from Storage
    if CurrencyTracker.Storage and CurrencyTracker.Storage.GetDiscoveredCurrencies then
        local discovered = CurrencyTracker.Storage:GetDiscoveredCurrencies() or {}
        for id, meta in pairs(discovered) do
            if type(id) == "number" and meta then
                if not merged[id] then
                    merged[id] = {
                        id = id,
                        name = meta.name or ("Currency "..tostring(id)),
                        icon = meta.icon,
                        isTracked = (meta.tracked ~= false),
                        category = meta.category or "Discovered",
                    }
                else
                    if meta.tracked ~= nil then
                        merged[id].isTracked = meta.tracked
                    end
                end
            end
        end
    end

    return merged
end

-- Get currencies filtered by expansion
function DataManager:GetCurrenciesByExpansion(expansion)
    if Constants and Constants.Utils and Constants.Utils.GetCurrenciesByExpansion then
        return Constants.Utils.GetCurrenciesByExpansion(expansion)
    end

    -- Fallback implementation
    local supported = self:GetSupportedCurrencies()
    local filtered = {}

    for id, currency in pairs(supported) do
        if currency.expansion == expansion then
            filtered[id] = currency
        end
    end

    return filtered
end

-- Get currencies filtered by patch version
function DataManager:GetCurrenciesByPatch(patch)
    if Constants and Constants.Utils and Constants.Utils.GetCurrenciesByPatch then
        return Constants.Utils.GetCurrenciesByPatch(patch)
    end

    -- Fallback implementation
    local supported = self:GetSupportedCurrencies()
    local filtered = {}

    for id, currency in pairs(supported) do
        if currency.patch == patch then
            filtered[id] = currency
        end
    end

    return filtered
end

-- Get currencies available for current WoW version
function DataManager:GetCurrenciesForCurrentVersion()
    if Constants and Constants.Utils and Constants.Utils.GetCurrenciesForCurrentVersion then
        return Constants.Utils.GetCurrenciesForCurrentVersion()
    end

    -- Fallback implementation
    local currentVersion = self:GetCurrentWoWVersion()
    local supported = self:GetSupportedCurrencies()
    local available = {}

    for id, currency in pairs(supported) do
        if currency.minVersion and self:ComparePatchVersions(currentVersion, currency.minVersion) >= 0 then
            available[id] = currency
        end
    end

    return available
end

-- Check if a currency is supported
function DataManager:IsCurrencySupported(currencyID)
    -- Always treat seeded currencies as supported when available
    if Constants and Constants.Utils and Constants.Utils.IsCurrencySupported then
        if Constants.Utils.IsCurrencySupported(currencyID) then
            return true
        end
        -- Fall through to discovered currencies merge so newly discovered IDs
        -- are recognized immediately even when Constants are present.
    end

    -- Include dynamically discovered currencies
    local supported = self:GetSupportedCurrencies()
    return supported[currencyID] ~= nil
end

-- Get current WoW version
function DataManager:GetCurrentWoWVersion()
    if Constants and Constants.VersionUtils and Constants.VersionUtils.GetCurrentWoWVersion then
        return Constants.VersionUtils.GetCurrentWoWVersion()
    end

    -- Fallback implementation using WoW API
    local version = GetBuildInfo()
    if version then
        local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
        if major and minor and patch then
            return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
        end
    end

    -- Default to a recent version if detection fails
    return 110000 -- 11.0.0
end

-- Compare patch versions (returns -1, 0, or 1)
function DataManager:ComparePatchVersions(version1, version2)
    if Constants and Constants.VersionUtils and Constants.VersionUtils.CompareVersions then
        return Constants.VersionUtils.CompareVersions(version1, version2)
    end

    -- Fallback implementation
    local v1 = type(version1) == "string" and self:ParseVersionString(version1) or version1
    local v2 = type(version2) == "string" and self:ParseVersionString(version2) or version2

    if v1 == v2 then
        return 0
    elseif v1 < v2 then
        return -1
    else
        return 1
    end
end

-- Helper function to parse version strings
function DataManager:ParseVersionString(versionString)
    if not versionString or type(versionString) ~= "string" then
        return 0
    end

    local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
    if not major or not minor or not patch then
        return 0
    end

    return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
end

-- Get currency information by ID
function DataManager:GetCurrencyInfo(currencyID, locale)
    if not currencyID then return nil end

    local lib = LibStub and LibStub("LibCurrencyInfo", true)
    if lib then
        local info = lib:GetCurrencyInfo(currencyID, locale)
        if info then
            return {
                id = currencyID,
                name = info.name,
                icon = info.iconFileID,
                categoryID = info.categoryID,
                category = info.categoryName or "Other",
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

    -- Try Constants first to get metadata
    local info
    if Constants and Constants.Utils and Constants.Utils.GetCurrencyInfo then
        info = Constants.Utils.GetCurrencyInfo(currencyID, locale)
    end

    -- If not found, try merged discovered set
    if not info then
        local supported = self:GetSupportedCurrencies()
        info = supported[currencyID]
    end

    -- If still nil, fallback shell
    if not info then
        info = {
            id = currencyID,
            name = "Currency " .. tostring(currencyID),
            minVersion = 0,
            isTracked = true,
            category = "Discovered",
        }
    end

    -- Prefer localized name/icon from live client API
    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local ok, ci = pcall(C_CurrencyInfo.GetCurrencyInfo, currencyID)
        if ok and type(ci) == "table" then
            info.name = ci.name or info.name
            info.icon = ci.iconFileID or info.icon
            info.quantity = ci.quantity or info.quantity
            info.maxQuantity = ci.maxQuantity or info.maxQuantity
        end
    end

    return info
end

-- Get currencies grouped by category from LibCurrencyInfo
function DataManager:GetCurrenciesGroupedByCategory(locale)
    local lib = LibStub and LibStub("LibCurrencyInfo", true)
    local grouped = {}
    if lib and lib.data and lib.data.CurrencyCategories then
        for catID, catData in pairs(lib.data.CurrencyCategories) do
            if not catData.hide then
                local catName = (lib.GetCurrencyCategoryNameByCategoryID and lib:GetCurrencyCategoryNameByCategoryID(catID, locale)) or ("Category " .. tostring(catID))
                local cids = (lib.GetCurrencyByCategoryID and lib:GetCurrencyByCategoryID(catID)) or {}
                local list = {}
                for _, cid in ipairs(cids) do
                    local cinfo = self:GetCurrencyInfo(cid, locale)
                    if cinfo then
                        table.insert(list, cinfo)
                    end
                end
                if #list > 0 then
                    grouped[catID] = {
                        id = catID,
                        name = catName,
                        currencies = list,
                    }
                end
            end
        end
    end
    return grouped
end

-- Backward compatibility stub
function DataManager:GetCurrenciesGroupedByExpansion()
    return self:GetCurrenciesGroupedByCategory()
end

-- Get tracked currencies (enabled by default)
function DataManager:GetTrackedCurrencies()
    if Constants and Constants.Utils and Constants.Utils.GetTrackedCurrencies then
        return Constants.Utils.GetTrackedCurrencies()
    end

    -- Fallback implementation
    local trackedCurrencies = {}
    local supported = self:GetSupportedCurrencies()

    for id, currency in pairs(supported) do
        if currency.isTracked then
            trackedCurrencies[id] = currency
        end
    end

    return trackedCurrencies
end

-- Validate currency data integrity
function DataManager:ValidateData()
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:ValidateData()
    end
    return true
end

-- Get storage statistics
function DataManager:GetStorageStats()
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:GetStorageStats()
    end

    return {
        currenciesTracked = 0,
        totalTransactions = 0,
        lastUpdate = 0
    }
end

-- Reset all currency data
function DataManager:ResetAllData()
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:ResetAllData()
    end
    return false
end

-- Check if tracking is enabled
function DataManager:IsTrackingEnabled()
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:IsTrackingEnabled()
    end
    return false
end

-- Set tracking enabled/disabled
function DataManager:SetTrackingEnabled(enabled)
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:SetTrackingEnabled(enabled)
    end
    return false
end

-- Save currency selection preference
function DataManager:SaveCurrencySelection(currencyID)
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:SaveCurrencySelection(currencyID)
    end
    return false
end

-- Load currency selection preference
function DataManager:LoadCurrencySelection()
    if CurrencyTracker.Storage then
        return CurrencyTracker.Storage:LoadCurrencySelection()
    end
    return 1166 -- Default to Timewarped Badge
end