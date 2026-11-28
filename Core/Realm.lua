-- Accountant Classic realm keys.
--
-- Every saved table is keyed by realm first:
--   Accountant_ClassicSaveData[realm][character]
--   Accountant_ClassicZoneDB[realm][character]
--   Accountant_ClassicHistory.chars["realm|character"]
--
-- WoW Forever has no realm list: players pick a ruleset (Normal, PvP, Roleplay,
-- Roleplay PvP, later Hardcore) and full names ("First-Surname") are unique per region
-- across all rulesets. Forever 1.60.1 also hides the realm from add-ons: GetRealmName()
-- returns "" and GetRealmID() 0 (Blizzard add-on notes "Forever 1.60.1 Live Update 2",
-- November 2026). Older versions therefore saved Forever characters under
--   * the real realm name, e.g. "CAMWOW TW4 Realm 1 PvE" (before the hotfix),
--   * "" (v2.30.03 and older after the hotfix),
--   * "Forever <region> <ruleset>", e.g. "Forever KR PvE" (v2.30.04 - v2.30.07).
--
-- Since v2.30.08 the realm key on Forever is the ruleset plus the region:
-- "<ruleset> (<region>)", e.g. "PvE (US)", "RP-PvP (EU)" or "PvE (Asia)". The ruleset
-- is named like AceDB-3.0 does when RegionalUniqueNamesEnabled() is true ("PvE", "PvP",
-- "RP", "RP-PvP", "Hardcore"). Battle.net Asia is stored as "Asia": KR and TW share one
-- region and TW clients report "KR" as well. Keeping the region in the key means that
-- characters of the same name from two regions never share a record.
--
-- Realm.MigrateToRuleset() merges the records under the older keys into the ruleset
-- keys. The current character is migrated on login; other characters at the same time
-- when the old key names their ruleset, otherwise on their own next login.
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
---@class ACNamespace
local private = select(2, ...)

local _G = getfenv(0)
local pairs, ipairs, next, type, pcall = _G.pairs, _G.ipairs, _G.next, _G.type, _G.pcall
local string = _G.string
local strmatch, strfind, strlower, strupper, strsub, gmatch = string.match, string.find, string.lower, string.upper, string.sub, string.gmatch
local tsort = table.sort

---@class ACRealm
local Realm = {}
private.Realm = Realm

-- Realm key written by v2.30.03 and older while Forever hides the realm.
local HIDDEN = ""
Realm.HIDDEN_KEY = HIDDEN
-- Prefix of the realm keys written by v2.30.04 - v2.30.07, e.g. "Forever KR PvE".
local LEGACY_PREFIX = "Forever "
-- Prefix of the Forever realm names the client gave before the hotfix.
local REALM_PREFIX = "CAMWOW "

-- Rulesets and regions of the realm keys used on Forever since v2.30.08.
local RULESETS = { PvE = true, PvP = true, RP = true, ["RP-PvP"] = true, Hardcore = true }
local ASIA = "Asia"
local KEY_REGIONS = { US = true, EU = true, CN = true, [ASIA] = true }

-- GetCurrentRegion() ids, same table as AceDB-3.0.
local REGIONS = { "US", "KR", "EU", "TW", "CN" }
local REGION_SET = {}
for _, r in ipairs(REGIONS) do REGION_SET[r] = true end
-- Battle.net Asia (KR and TW) shares portal "KR" / GetCurrentRegion() == 2,
-- while TW Forever realm names contain "TW" (e.g. "CAMWOW TW4 Realm 1 PvE").
local ASIA_REGIONS = { KR = true, TW = true }
-- Region tokens of realm names that belong to another Battle.net region (Oceania and
-- Latin America realms are in the US region).
local REGION_ALIASES = { OC = "US", LA = "US", BR = "US" }

local issecretvalue = _G.issecretvalue

---@param value any
---@return string? text The value when it is a plain, non-empty string
local function usableString(value)
	if value == nil then return nil end
	if issecretvalue and issecretvalue(value) then return nil end
	if type(value) ~= "string" or value == "" then return nil end
	return value
end

---@param value any
---@return boolean
local function isTrue(value)
	if issecretvalue and issecretvalue(value) then return false end
	return value == true
end

-----------------------------------------------------------------------
-- Client information
-----------------------------------------------------------------------
---@return string? realm Realm name from the client, nil when it is hidden (Forever)
function Realm.GetClientRealm()
	local GetRealmName = _G.GetRealmName
	if not GetRealmName then return nil end
	local ok, name = pcall(GetRealmName)
	return ok and usableString(name) or nil
end

---@return string? region "US", "KR", "EU", "TW" or "CN"
function Realm.GetRegion()
	local GetCurrentRegion, GetCurrentRegionName = _G.GetCurrentRegion, _G.GetCurrentRegionName
	if GetCurrentRegion then
		local ok, id = pcall(GetCurrentRegion)
		if ok and not (issecretvalue and issecretvalue(id)) and REGIONS[id] then
			return REGIONS[id]
		end
	end
	if GetCurrentRegionName then
		local ok, name = pcall(GetCurrentRegionName)
		name = ok and usableString(name)
		if name then return strupper(name) end
	end
	return nil
end

---Ruleset of the current character, named like AceDB-3.0 does on Forever.
---@return "Hardcore"|"RP-PvP"|"RP"|"PvP"|"PvE"|nil
function Realm.GetRuleset()
	local C_GameRules, Enum = _G.C_GameRules, _G.Enum
	if not (C_GameRules and C_GameRules.IsGameRuleActive and Enum and Enum.GameRule) then return nil end
	local rules = Enum.GameRule
	local function active(rule)
		if rule == nil then return false end
		local ok, value = pcall(C_GameRules.IsGameRuleActive, rule)
		return ok and isTrue(value)
	end
	if active(rules.HardcoreRuleset) then return "Hardcore" end
	local rp, pvp = active(rules.RPRuleset), active(rules.PvPRuleset)
	if rp and pvp then return "RP-PvP" end
	if rp then return "RP" end
	if pvp then return "PvP" end
	return "PvE"
end

-----------------------------------------------------------------------
-- Realm keys
-----------------------------------------------------------------------
---Reads the region and ruleset out of a Forever realm name or an older realm key, e.g.
---"CAMWOW TW4 Realm 1 PvE" -> "TW", "PvE"; "CAMWOW US2 Realm 9 RP PvP" -> "US", "RP-PvP";
---"Forever US RP" -> "US", "RP".
---@param name string
---@return string? region
---@return string? ruleset
function Realm.ParseRealm(name)
	if type(name) ~= "string" then return nil, nil end
	local region
	for token in gmatch(name, "%S+") do
		local r = strmatch(token, "^(%u%u)%d*$")
		r = r and (REGION_ALIASES[r] or r)
		if r and REGION_SET[r] then
			region = r
			break
		end
	end
	local lower = strlower(name)
	local rp = strfind(lower, "%f[%a]rp%f[%A]") or strfind(lower, "role%s*play")
	local pvp = strfind(lower, "pvp", 1, true)
	local ruleset
	if strfind(lower, "hardcore", 1, true) then
		ruleset = "Hardcore"
	elseif rp and pvp then
		ruleset = "RP-PvP"
	elseif rp then
		ruleset = "RP"
	elseif pvp then
		ruleset = "PvP"
	elseif strfind(lower, "pve", 1, true) or strfind(lower, "normal", 1, true) then
		ruleset = "PvE"
	end
	return region, ruleset
end

---@param name string
---@return boolean
local function isBetaRealm(name)
	return strfind(strlower(name), "beta", 1, true) ~= nil
end

---Region as used in the realm key: KR and TW become "Asia".
---@param region string?
---@return string?
local function keyRegion(region)
	if region == nil then return nil end
	if ASIA_REGIONS[region] or region == ASIA then return ASIA end
	return region
end
Realm.KeyRegion = keyRegion

---Ruleset realm key, e.g. "PvE (US)" or "PvE (Asia)"; just "PvE" when the region is
---unknown.
---@param ruleset string
---@param region string? "US", "KR", "TW", "EU", "CN" or "Asia"
---@return string
function Realm.RulesetKey(ruleset, region)
	region = keyRegion(region)
	if region then return ruleset.." ("..region..")" end
	return ruleset
end

---Splits a ruleset realm key.
---@param server string
---@return string? ruleset nil when server is not a ruleset key
---@return string? region Region part of "<ruleset> (<region>)"
function Realm.ParseRulesetKey(server)
	if type(server) ~= "string" then return nil end
	if RULESETS[server] then return server, nil end
	local ruleset, region = strmatch(server, "^(%S+) %((%a+)%)$")
	if ruleset and RULESETS[ruleset] then return ruleset, region end
	return nil
end

---True for a realm key of the current format, "<ruleset> (<region>)".
---@param server string
---@return boolean
local function isCurrentKey(server)
	local ruleset, region = Realm.ParseRulesetKey(server)
	return ruleset ~= nil and region ~= nil and KEY_REGIONS[region] == true
end
Realm.IsCurrentKey = isCurrentKey

---True for the realm keys of older versions that are merged into the current keys:
---"", "CAMWOW TW4 Realm 1 PvE", "Forever KR PvE", and the keys without (or with a
---non-merged) region, "PvE" or "PvE (KR)", written by test builds of this change.
---Beta realms are left alone: they held separate copies of the characters.
---@param server string
---@return boolean
function Realm.IsLegacyKey(server)
	if server == HIDDEN then return true end
	if type(server) ~= "string" or isCurrentKey(server) or isBetaRealm(server) then
		return false
	end
	if Realm.ParseRulesetKey(server) then return true end
	return strsub(server, 1, #LEGACY_PREFIX) == LEGACY_PREFIX
		or strsub(server, 1, #REALM_PREFIX) == REALM_PREFIX
end

---Region and ruleset of a record under an older key.
---@param server string
---@param record ACCharacterData?
---@return string? region
---@return string? ruleset
local function legacyInfo(server, record)
	local ruleset, region = Realm.ParseRulesetKey(server)
	if not ruleset then
		region, ruleset = Realm.ParseRealm(server)
	end
	if not region then
		local options = type(record) == "table" and record.options
		region = type(options) == "table" and options.region or nil
	end
	return keyRegion(region), ruleset
end

---Compares two player GUIDs ("Player-<realmID>-<characterID>").
---@param a string?
---@param b string?
---@return boolean? same true = same character, false = another character, nil = unknown
function Realm.CompareGUID(a, b)
	if type(a) ~= "string" or type(b) ~= "string" then return nil end
	if issecretvalue and (issecretvalue(a) or issecretvalue(b)) then return nil end
	if a == b then return true end
	local ra, ca = strmatch(a, "^Player%-(%d+)%-(%x+)$")
	local rb, cb = strmatch(b, "^Player%-(%d+)%-(%x+)$")
	if not ra or not rb then return false end
	-- Same character id: the realm part changed (hidden / obfuscated realm).
	if ca == cb then return true end
	-- Both parts changed: the realm id is no longer readable, so this proves nothing.
	if ra ~= rb then return nil end
	return false
end

---"dd/mm/yy" -> "yymmdd" so that string comparison sorts chronologically.
---@param s string?
---@return string
local function sortableDate(s)
	if type(s) ~= "string" or #s < 8 then return "" end
	return strsub(s, 7, 8)..strsub(s, 4, 5)..strsub(s, 1, 2)
end
Realm.SortableDate = sortableDate

---@param historyChars table<string, ACHistoryChar>?
---@param server string
---@param name string
---@return string? guid
local function historyGUID(historyChars, server, name)
	local node = historyChars and historyChars[server.."|"..name]
	return node and node.guid
end

---True on clients where character names are unique per region (WoW Forever).
---@param isForever boolean?
---@return boolean
function Realm.UsesRulesetKeys(isForever)
	if isForever then return true end
	local RegionalUniqueNamesEnabled = _G.RegionalUniqueNamesEnabled
	if not RegionalUniqueNamesEnabled then return false end
	local ok, enabled = pcall(RegionalUniqueNamesEnabled)
	return ok and isTrue(enabled)
end

---Realm key of the current character.
---@param name string Classic character key
---@param isForever boolean
---@return string server
function Realm.Resolve(name, isForever)
	if Realm.UsesRulesetKeys(isForever) then
		local ruleset = Realm.GetRuleset()
		if ruleset then
			return Realm.RulesetKey(ruleset, Realm.GetRegion())
		end
	end
	local realm = Realm.GetClientRealm()
	if realm then return realm end
	-- Not expected; keep the old behaviour.
	return HIDDEN
end

---Text shown for a realm key.
---@param server string
---@param unknownText string Text for the hidden realm key
---@return string
function Realm.DisplayName(server, unknownText)
	if server == HIDDEN then return unknownText end
	return server
end

-----------------------------------------------------------------------
-- Migration of the older realm keys
-----------------------------------------------------------------------
local SESSION_MODE = "Session"

---@param t table?
---@return boolean
local function isEmpty(t)
	return type(t) ~= "table" or next(t) == nil
end

---Adds every In / Out of one amount table into another.
---@param src ACAmounts
---@param dst ACAmounts
local function addAmounts(src, dst)
	dst.In = (dst.In or 0) + (src.In or 0)
	dst.Out = (dst.Out or 0) + (src.Out or 0)
end

---@param src table<string, ACAmounts> Zone -> amounts
---@param dst table<string, ACAmounts>
local function addZoneAmounts(src, dst)
	for zone, amounts in pairs(src) do
		local d = dst[zone]
		if type(d) ~= "table" then
			d = { In = 0, Out = 0 }
			dst[zone] = d
		end
		addAmounts(amounts, d)
	end
end

---Merges one classic character record (and its zone record) into another. Both records
---must already be rolled over to the current periods.
---@param src ACCharacterData Record under an older realm key
---@param dst ACCharacterData Record under the ruleset key, receives the result
---@param zsrc table? Zone record of src ({ data = ... })
---@param zdst table? Zone record of dst
---@param periods ACPeriodRule[]
---@return table? zone The zone record to keep for dst
function Realm.MergeCharacterData(src, dst, zsrc, zdst, periods)
	local so, dopt = src.options or {}, dst.options
	if not dopt then
		dopt = {}
		dst.options = dopt
	end
	dst.data = dst.data or {}
	local srcNewer = sortableDate(so.lastsessiondate) >= sortableDate(dopt.lastsessiondate)

	-- Previous periods: the same previous period is added up; otherwise the newer
	-- record's previous period wins.
	---@type table<string, "sum"|"take"|"keep">
	local prvAction = {}
	local isPrevious = {}
	for _, period in ipairs(periods) do
		local prvKey, prvMode = period[2], period[4]
		isPrevious[prvMode] = true
		if so[prvKey] == nil then
			prvAction[prvMode] = "keep"
		elseif dopt[prvKey] == nil or so[prvKey] == dopt[prvKey] then
			prvAction[prvMode] = (dopt[prvKey] == nil) and "take" or "sum"
		else
			prvAction[prvMode] = srcNewer and "take" or "keep"
		end
		if prvAction[prvMode] == "take" then
			dopt[prvKey] = so[prvKey]
			-- The older previous period is replaced, also for log types src never had.
			for _, dmodes in pairs(dst.data) do
				if type(dmodes) == "table" and type(dmodes[prvMode]) == "table" then
					dmodes[prvMode].In, dmodes[prvMode].Out = 0, 0
				end
			end
		end
	end

	for logtype, modes in pairs(src.data or {}) do
		local dmodes = dst.data[logtype]
		if type(dmodes) ~= "table" then
			dmodes = {}
			dst.data[logtype] = dmodes
		end
		for mode, amounts in pairs(modes) do
			if type(amounts) == "table" and mode ~= SESSION_MODE then
				local d = dmodes[mode]
				if type(d) ~= "table" then
					d = { In = 0, Out = 0 }
					dmodes[mode] = d
				end
				local action = isPrevious[mode] and prvAction[mode] or "sum"
				if action == "sum" then
					addAmounts(amounts, d)
				elseif action == "take" then
					d.In, d.Out = amounts.In or 0, amounts.Out or 0
				end
			end
		end
	end

	-- Options: the newer record has the current balance and last session.
	if srcNewer then
		if so.totalcash ~= nil then dopt.totalcash = so.totalcash end
		if so.lastsessiondate ~= nil then dopt.lastsessiondate = so.lastsessiondate end
	end
	for k, v in pairs(so) do
		if dopt[k] == nil then dopt[k] = v end
	end

	-- Zone record
	if not zsrc or isEmpty(zsrc.data) then return zdst end
	if not zdst or isEmpty(zdst.data) then return zsrc end
	for mode, byType in pairs(zsrc.data) do
		if mode ~= SESSION_MODE and type(byType) == "table" then
			local action = isPrevious[mode] and prvAction[mode] or "sum"
			if action == "take" then
				zdst.data[mode] = byType
			elseif action == "sum" then
				local dByType = zdst.data[mode]
				if type(dByType) ~= "table" then
					dByType = {}
					zdst.data[mode] = dByType
				end
				for logtype, zones in pairs(byType) do
					if type(zones) == "table" then
						local dZones = dByType[logtype]
						if type(dZones) ~= "table" then
							dZones = {}
							dByType[logtype] = dZones
						end
						addZoneAmounts(zones, dZones)
					end
				end
			end
		end
	end
	return zdst
end

---Moves (or merges) one character from an older realm key into a ruleset key.
---@param ctx ACRealmMigrateContext
---@param from string
---@param name string
---@param target string
---@return boolean merged True when an existing record was merged, false when moved
local function moveCharacter(ctx, from, name, target)
	local saveData, zoneDB = ctx.saveData, ctx.zoneDB
	local fromChars = saveData[from]
	local src = fromChars and fromChars[name]
	local zFrom = zoneDB and zoneDB[from]
	local zsrc = zFrom and zFrom[name]
	local merged = false

	saveData[target] = saveData[target] or {}
	local dst = saveData[target][name]
	if zoneDB then zoneDB[target] = zoneDB[target] or {} end
	local zdst = zoneDB and zoneDB[target][name]

	if src then
		if dst then
			-- Bring both records to the current periods before adding them up.
			ctx.roll(from, name, src)
			ctx.roll(target, name, dst)
			local zone = Realm.MergeCharacterData(src, dst, zsrc, zdst, ctx.periods)
			if zoneDB then zoneDB[target][name] = zone end
			merged = true
		else
			saveData[target][name] = src
			if zoneDB and zsrc then zoneDB[target][name] = zsrc end
		end
		fromChars[name] = nil
	elseif zoneDB and zsrc and not zdst then
		zoneDB[target][name] = zsrc
	end
	if zFrom then zFrom[name] = nil end
	if zoneDB and isEmpty(zoneDB[target]) then zoneDB[target] = nil end
	-- The region is part of the key now; drop the field written by test builds.
	local moved = saveData[target][name]
	if type(moved) == "table" and type(moved.options) == "table" then moved.options.region = nil end
	if isEmpty(saveData[target]) then saveData[target] = nil end

	if ctx.history and ctx.history.MoveChar then
		local ok, historyMerged = pcall(ctx.history.MoveChar, ctx.history, from, name, target)
		merged = merged or (ok and historyMerged == "merged")
	end
	return merged
end

---Every (older key, character) pair found in the classic, zone and history tables.
---@param ctx ACRealmMigrateContext
---@return { server: string, name: string }[]
local function collectLegacy(ctx)
	local seen, list = {}, {}
	local function add(server, name)
		if type(server) ~= "string" or type(name) ~= "string" then return end
		if not Realm.IsLegacyKey(server) then return end
		local key = server.."|"..name
		if seen[key] then return end
		seen[key] = true
		list[#list + 1] = { server = server, name = name }
	end
	for server, chars in pairs(ctx.saveData) do
		if type(chars) == "table" then
			for name in pairs(chars) do add(server, name) end
		end
	end
	for server, chars in pairs(ctx.zoneDB or {}) do
		if type(chars) == "table" then
			for name in pairs(chars) do add(server, name) end
		end
	end
	for _, node in pairs(ctx.historyChars or {}) do
		if type(node) == "table" and not node.archivedFrom then
			add(node.server, node.name)
		end
	end
	tsort(list, function(a, b)
		if a.name ~= b.name then return a.name < b.name end
		return a.server < b.server
	end)
	return list
end

---Ruleset key already holding a character of this name, when there is exactly one.
---@param ctx ACRealmMigrateContext
---@param from string
---@param name string
---@return string? server
local function uniqueRulesetRecord(ctx, from, name)
	local found
	local guid = historyGUID(ctx.historyChars, from, name)
	for server, chars in pairs(ctx.saveData) do
		if isCurrentKey(server) and type(chars) == "table" and chars[name] then
			if found then return nil end
			if Realm.CompareGUID(historyGUID(ctx.historyChars, server, name), guid) == false then
				return nil
			end
			found = server
		end
	end
	return found
end

---True when any table still has a record under an older realm key.
---@param ctx ACRealmMigrateContext
---@return boolean
function Realm.NeedsMigration(ctx)
	return collectLegacy(ctx)[1] ~= nil
end

---Merges the records under the older Forever realm keys ("", "CAMWOW ... PvE",
---"Forever KR PvE", "PvE", ...) into the current keys ("PvE (Asia)", "RP (US)", ...).
---@param ctx ACRealmMigrateContext
---@return ACRealmMigrateResult
function Realm.MigrateToRuleset(ctx)
	local result = { merged = 0, moved = 0, pending = {}, renamed = {} }
	if type(ctx.saveData) ~= "table" or not isCurrentKey(ctx.server) then return result end
	local currentRuleset, currentRegion = Realm.ParseRulesetKey(ctx.server)

	local function migrate(entry, target)
		if moveCharacter(ctx, entry.server, entry.name, target) then
			result.merged = result.merged + 1
		else
			result.moved = result.moved + 1
		end
		result.renamed[entry.server.."\t"..entry.name] = target.."\t"..entry.name
	end

	local waiting = {}
	for _, entry in ipairs(collectLegacy(ctx)) do
		local chars = ctx.saveData[entry.server]
		local region, ruleset = legacyInfo(entry.server, type(chars) == "table" and chars[entry.name] or nil)
		local target
		if entry.name == ctx.player and (region == nil or region == currentRegion)
			and (ruleset == nil or ruleset == currentRuleset) then
			target = ctx.server
		elseif ruleset and region then
			target = Realm.RulesetKey(ruleset, region)
		end
		if target then
			migrate(entry, target)
		else
			waiting[#waiting + 1] = entry
		end
	end

	-- Records without a ruleset or region (e.g. saved under ""): the single record of the
	-- same name under a current key, if any; otherwise they wait for the character's own
	-- login.
	local pendingNames = {}
	for _, entry in ipairs(waiting) do
		local target = uniqueRulesetRecord(ctx, entry.server, entry.name)
		if target then
			migrate(entry, target)
		elseif not pendingNames[entry.name] then
			pendingNames[entry.name] = true
			result.pending[#result.pending + 1] = entry.name
		end
	end

	for server, chars in pairs(ctx.saveData) do
		if Realm.IsLegacyKey(server) and isEmpty(chars) then ctx.saveData[server] = nil end
	end
	for server, chars in pairs(ctx.zoneDB or {}) do
		if Realm.IsLegacyKey(server) and isEmpty(chars) then ctx.zoneDB[server] = nil end
	end
	return result
end
