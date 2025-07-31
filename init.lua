PinyinNext = {}

PinyinNext.debug = false
--@debug@
  PinyinNext.debug = true
--@end-debug@

function PinyinNext:Printf(msg, ...)
  if PinyinNext.debug then
    print(string.format(
      "[%s] %s",
      RAID_CLASS_COLORS.EVOKER:WrapTextInColorCode("PinyinNext"),
      string.format(msg, ...)
    ))
  end
end

PinyinNext.Hooked = {}
