local function isValidPrefix(pinyin)
  for validPinyin, _ in pairs(PinyinNext.Dict.PinyinToCharacters) do
    if string.find(validPinyin, pinyin, 1, true) == 1 then
      return true
    end
  end
  return false
end

---@param start number
---@param pinyin string
---@param result string[]
---@param solutions string[]
---@param possible boolean[]
local function getAllSolutions(start, pinyin, result, solutions, possible)
  local len = PinyinNext.Utils.Utf8Len(pinyin)
  if start > len then
    local last = result[#result]
    if string.find(last, ",") then
      table.remove(result)
      for _, piece in ipairs({ string.split(",", last) }) do
        table.insert(solutions, table.concat(result, " ") .. " " .. piece)
      end
    else
      table.insert(solutions, table.concat(result, " "))
    end
    return
  end
  for i = start, len do
    local piece = PinyinNext.Utils.Utf8Sub(pinyin, start, i - start + 1)
    local match = false
    if possible[i + 1] then
      if i == len and isValidPrefix(piece) then
        table.insert(result, piece)
        match = true
      elseif PinyinNext.Dict.PinyinToCharacters[piece] and possible[i + 1] then
        table.insert(result, piece)
        match = true
      end
    end

    if match then
      local count = #solutions
      getAllSolutions(i + 1, pinyin, result, solutions, possible)
      if count == #solutions then
        possible[i + 1] = false
      end
      table.remove(result)
    end
  end
end

---@param pinyin string
---@return string[]
function PinyinNext:BreakPinyinCharacters(pinyin)
  ---@type string[], string[], boolean[]
  local result, solutions, possible = {}, {}, {}
  local len = self.Utils.Utf8Len(pinyin)
  for i = 1, len + 1 do
    possible[i] = true
  end
  getAllSolutions(1, pinyin, result, solutions, possible)
  -- DevTool:AddData(solutions)

  return solutions
end

function PinyinNext:GetCharacterPinyinList(text)
  local result = {};
  for i = 1, self.Utils.Utf8Len(text) do
    local char = self.Utils.Utf8Sub(text, i, 1)
    local pinyins = self.Dict.CharacterToPinyins[char] or { char }
    table.insert(result, pinyins)
  end
  return result
end

function PinyinNext:GetSentencePinyin(text)
  local pinyins = self:GetCharacterPinyinList(text)
  local firstPinyin = {}
  for i, v in ipairs(pinyins) do
    table.insert(firstPinyin, v[1])
  end
  return table.concat(firstPinyin)
end

---@param characterPinyins string[]
---@param keywordPinyin string
---@return boolean
function PinyinNext:IsCharacterPinyinMatch(characterPinyins, keywordPinyin)
  return tContains(characterPinyins, keywordPinyin)
end

---@param characterPinyins string[]
---@param keywordPinyin string
---@return boolean
function PinyinNext:IsCharacterPinyinMatchPrefix(characterPinyins, keywordPinyin)
  for _, pinyin in ipairs(characterPinyins) do
    if string.find(pinyin, keywordPinyin, 1, true) == 1 then
      return true
    end
  end
  return false
end

function PinyinNext:Match(text, keyword)
  local textPinyins = self:GetCharacterPinyinList(text)
  local textLength = #textPinyins
  local keywordBreak = self:BreakPinyinCharacters(keyword)
  for _, solution in ipairs(keywordBreak) do
    local keywordCharacterPinyins = { string.split(" ", solution) }
    for i = 1, textLength do
      if textLength - i + 1 < #keywordCharacterPinyins then
        break
      end

      local match = true
      for j = 1, #keywordCharacterPinyins do
        local textCharacterPinyins = textPinyins[i + j - 1]
        local keywordCharacterPinyin = keywordCharacterPinyins[j]
        if j == #keywordCharacterPinyins then
          if not self:IsCharacterPinyinMatchPrefix(textCharacterPinyins, keywordCharacterPinyin) then
            match = false
            break
          end
        else
          if not self:IsCharacterPinyinMatch(textCharacterPinyins, keywordCharacterPinyin) then
            match = false
            break
          end
        end
      end
      if match then
        return true
      end
    end
  end

  local keywordLen = self.Utils.Utf8Len(keyword)
  for i = 1, textLength do
    if textLength - i + 1 < keywordLen then
      break
    end
    local match = true
    for j = 1, keywordLen do
      local textCharacter = self.Utils.Utf8Sub(text, i + j - 1, 1)
      local textCharacterPinyins = textPinyins[i + j - 1]
      local keywordCharacter = self.Utils.Utf8Sub(keyword, j, 1)
      if textCharacter ~= keywordCharacter
          and not self:IsCharacterPinyinMatchPrefix(textCharacterPinyins, keywordCharacter) then
        match = false
        break
      end
    end
    if match then
      return true
    end
  end

  return false
end
