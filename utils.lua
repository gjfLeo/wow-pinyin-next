PinyinNext.Utils = {}

--获取单个字符长度
local function GetCharSize(char)
  if not char then
    return 0
  elseif char > 240 then
    return 4
  elseif char > 225 then
    return 3
  elseif char > 192 then
    return 2
  else
    return 1
  end
end

--获取中文字符长度
function PinyinNext.Utils.Utf8Len(str)
  local len = 0
  local currentIndex = 1
  while currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + GetCharSize(char)
    len = len + 1
  end
  return len
end

--截取中文字符串
function PinyinNext.Utils.Utf8Sub(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
    local char = string.byte(str, startIndex)
    startIndex = startIndex + GetCharSize(char)
    startChar = startChar - 1
  end

  if numChars == nil then
    return string.sub(str, startIndex)
  end

  local currentIndex = startIndex

  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + GetCharSize(char)
    numChars = numChars - 1
  end

  return string.sub(str, startIndex, currentIndex - 1)
end
