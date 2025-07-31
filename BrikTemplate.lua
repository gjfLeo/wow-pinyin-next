local _, BrikTemplate = ...

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
  if event == "ADDON_LOADED" then
    local addOnName = ...

    if addOnName == "BrikTemplate" then
      print("Loaded!")
    end
  end
end)

SLASH_BRIKTEMPLATE1 = "/briktemplate"
SLASH_BRIKTEMPLATE2 = "/bt"

function SlashCmdList.BRIKTEMPLATE()
  print("Slash command works")
end
