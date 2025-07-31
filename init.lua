PinyinNext = {}

PinyinNext.debug = false
function PinyinNext:Printf(msg, ...)
  if PinyinNext.debug then
    print(string.format(
      "%s: %s",
      RAID_CLASS_COLORS.EVOKER:WrapTextInColorCode("PinyinNext"),
      string.format(msg, ...)
    ))
  end
end
