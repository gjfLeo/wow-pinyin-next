local frame = CreateFrame("Frame")
EventRegistry:RegisterCallback("PinyinNext.GetPyTableCompleted", function()
  PinyinNext:Printf("词库加载完毕")
  PinyinNext:Hook()
end, frame)

-- frame:RegisterEvent("ADDON_LOADED")
-- frame:SetScript("OnEvent", function(self, event, ...)
--   if event == "ADDON_LOADED" and ... == "PinyinNext" then
--     -- PinyinNext:Hook()
--   end
-- end)

function PinyinNext:Hook()
  if C_AddOns.IsAddOnLoaded("MountsJournal") then
    self:HookMountsJournal()
    self:Printf("MountsJournal功能已加载")
  end

  if C_AddOns.IsAddOnLoaded("Rematch") then
    self:HookRematch()
    self:Printf("Rematch功能已加载")
  end

  if C_AddOns.IsAddOnLoaded("Routes") then
    self:HookRoutes()
    self:Printf("Routes功能已加载")
  end
end

function PinyinNext:HookMountsJournal()
  local mounts = _G["MountsJournal"]
  local journal = _G["MountsJournalFrame"]
  local util = _G["MountsJournalUtil"]

  local original = journal.updateMountsList

  journal.updateMountsList = function(journalSelf)
    local filters, list, newMounts, tags = mounts.filters, journalSelf.list, {}, journalSelf.tags
    local sources, factions, pet, expansions = filters.sources, filters.factions, filters.pet, filters.expansions
    local text = util.cleanText(journalSelf.searchBox:GetText())
    local numMounts = 0

    if filters.onlyNew then
      return original(journalSelf)
    end

    journalSelf.dataProvider = CreateDataProvider()

    for i = 1, #journalSelf.mountIDs do
      local mountID = journalSelf.mountIDs[i]
      local name, spellID, _, _, isUsable, sourceType, _, _, mountFaction, shouldHideOnChar, isCollected = journalSelf:getMountInfo(mountID)
      local expansion, familyID, rarity, _, _, sourceText, isSelfMount, mountType = journalSelf:getMountInfoExtra(mountID)
      local petID = journalSelf.petForMount[spellID]
      local isMountHidden = journalSelf:isMountHidden(spellID)

      -- FAMILY
      if journalSelf:getFilterFamily(familyID)
          -- HIDDEN FOR CHARACTER
          and (not shouldHideOnChar or filters.hideOnChar)
          and (not (filters.hideOnChar and filters.onlyHideOnChar) or shouldHideOnChar)
          -- HIDDEN BY PLAYER
          and (not isMountHidden or filters.hiddenByPlayer)
          and (not (filters.hiddenByPlayer and filters.onlyHiddenByPlayer) or isMountHidden)
          -- COLLECTED
          and (isCollected and filters.collected or not isCollected and filters.notCollected)
          -- UNUSABLE
          and (isUsable or not isCollected or filters.unusable)
          -- EXPANSIONS
          and expansions[expansion]
          -- ONLY NEW
          -- and (not filters.onlyNew or newMounts[mountID])
          -- SOURCES
          and sources[sourceType]
          -- SEARCH
          and (#text == 0
            or name:lower():find(text, 1, true)
            or self:Match(name, text)
            or sourceText:lower():find(text, 1, true)
            or tags:find(spellID, text)
            or journalSelf:getCustomSearchFilter(text, mountID, spellID, mountType))
          -- TYPE
          and journalSelf:getFilterType(mountType)
          -- FACTION
          and factions[(mountFaction or 2) + 1]
          -- SELECTED
          and journalSelf:getFilterSelected(spellID)
          -- PET
          and pet[petID and (type(petID) == "number" and petID or 3) or 4]
          -- SPECIFIC
          and journalSelf:getFilterSpecific(spellID, isSelfMount, mountType, mountID)
          -- MOUNTS RARITY
          and journalSelf:getFilterRarity(rarity or 100)
          -- MOUNTS WEIGHT
          and journalSelf:getFilterWeight(spellID)
          -- TAGS
          and tags:getFilterMount(spellID) then
        numMounts = numMounts + 1
        journalSelf.dataProvider:Insert({ mountID = mountID })
      end
    end

    journalSelf:updateScrollMountList()
    journalSelf:setShownCountMounts(numMounts)
  end
end

function PinyinNext:HookRematch()
  local Rematch = _G["Rematch"]
  Rematch.utils.match = function(_, pattern, ...)
    if type("pattern") == "string" then
      for i = 1, select("#", ...) do
        local candidate = select(i, ...)
        if type(candidate) == "string" then
          if candidate:match(pattern) then
            return true
          end
          if PinyinNext.Utils.Utf8Len(candidate) <= 15 then
            local patternParsed = string.gsub(pattern, "%[(%w)%w%]", function(c) return c end)
            if PinyinNext:Match(candidate, patternParsed) then
              return true
            end
          end
        end
      end
    end
    return false
  end
end

function PinyinNext:HookRoutes()
  local Routes = _G["Routes"]

  local sortedZoneNames = {}
  local zoneNameToPinyin = {}
  local zonePinyinOrder = {}
  for zoneName in pairs(Routes.LZName) do
    table.insert(sortedZoneNames, zoneName)
    zoneNameToPinyin[zoneName] = PinyinNext:GetSentencePinyin(zoneName)
  end
  table.sort(sortedZoneNames, function(a, b)
    return zoneNameToPinyin[a] < zoneNameToPinyin[b]
  end)
  for i, zoneName in ipairs(sortedZoneNames) do
    zonePinyinOrder[zoneName] = i
  end

  Routes.options.args.add_group.args.zone_choice.sorting = sortedZoneNames
  Routes.options.args.taboo_group.args.zone_choice.sorting = sortedZoneNames
  for _, v in pairs(Routes.options.args.routes_group.args) do
    v.order = zonePinyinOrder[v.name]
  end
end
