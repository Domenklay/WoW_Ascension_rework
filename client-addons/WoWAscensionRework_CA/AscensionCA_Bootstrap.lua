local function Size(f,w,h) f:SetWidth(w); f:SetHeight(h) end
local function Panel(parent,w,h,r,g,b,a)
  local f=CreateFrame("Frame",nil,parent)
  Size(f,w,h)
  f:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=16,insets={left=4,right=4,top=4,bottom=4}})
  f:SetBackdropColor(r or 0.05,g or 0.05,b or 0.05,a or 0.92)
  return f
end

local f=CreateFrame("Frame","WoWAscensionReworkCAFrame",UIParent)
Size(f,1165,758)
f:SetPoint("CENTER",UIParent,"CENTER",0,0)
f:SetFrameStrata("DIALOG")
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart",function() f:StartMoving() end)
f:SetScript("OnDragStop",function() f:StopMovingOrSizing() end)
f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}})
f:SetBackdropColor(0.12,0.09,0.06,0.98)
f:Hide()

local title=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOP",f,"TOP",0,-16)
title:SetText("Character Advancement")

local subtitle=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
subtitle:SetPoint("TOP",title,"BOTTOM",0,-3)
subtitle:SetText("Forever.Ascension - recovered UI test")

local close=CreateFrame("Button",nil,f,"UIPanelCloseButton")
close:SetPoint("TOPRIGHT",f,"TOPRIGHT",-5,-5)
close:SetScript("OnClick",function() f:Hide() end)

f.Left=Panel(f,132,650,0.04,0.04,0.04,0.92)
f.Left:SetPoint("TOPLEFT",f,"TOPLEFT",14,-82)

f.Center=Panel(f,800,585,0.03,0.03,0.03,0.88)
f.Center:SetPoint("TOPLEFT",f,"TOPLEFT",150,-128)

f.Right=Panel(f,196,650,0.04,0.04,0.04,0.92)
f.Right:SetPoint("TOPRIGHT",f,"TOPRIGHT",-14,-82)
local rightTitle=f.Right:CreateFontString(nil,"OVERLAY","GameFontNormal")
rightTitle:SetPoint("TOP",f.Right,"TOP",0,-10)
rightTitle:SetText("Build Summary")
local rightText=f.Right:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
rightText:SetPoint("TOPLEFT",f.Right,"TOPLEFT",12,-36)
rightText:SetPoint("RIGHT",f.Right,"RIGHT",-12,0)
rightText:SetJustifyH("LEFT")
rightText:SetJustifyV("TOP")
rightText:SetText("Select a class and specialization.\n\nLeft click: learn\nRight click / Shift+click: unlearn\n\nThis first build verifies the UI and client API connection.")

f.Search=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
Size(f.Search,300,24)
f.Search:SetPoint("TOPLEFT",f,"TOPLEFT",154,-92)
f.Search:SetAutoFocus(false)
f.Search:SetScript("OnEnterPressed",function(self) self:ClearFocus(); WoWAscensionReworkCA_Search(self:GetText()) end)
f.Search:SetScript("OnTextChanged",function(self) WoWAscensionReworkCA_Search(self:GetText()) end)
local searchLabel=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
searchLabel:SetPoint("BOTTOMLEFT",f.Search,"TOPLEFT",3,2)
searchLabel:SetText("Search")

local function Tab(text,x,fn)
  local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
  Size(b,118,26)
  b:SetPoint("TOPLEFT",f,"TOPLEFT",x,-90)
  b:SetText(text)
  b:SetScript("OnClick",fn)
  return b
end
f.AbilitiesTab=Tab("Abilities",474,function() WoWAscensionReworkCA_SetMode("Abilities") end)
f.TalentsTab=Tab("Talents",596,function() WoWAscensionReworkCA_SetMode("Talents") end)
f.MasteryTab=Tab("Mastery",718,function() WoWAscensionReworkCA_SetMode("Mastery") end)

f.Reset=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
Size(f.Reset,160,24)
f.Reset:SetPoint("BOTTOM",f,"BOTTOM",0,18)
f.Reset:SetText("Reset Build")
f.Reset:SetScript("OnClick",WoWAscensionReworkCA_Reset)

f.Save=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
Size(f.Save,160,28)
f.Save:SetPoint("BOTTOM",f.Reset,"TOP",0,4)
f.Save:SetText("Save Changes")
f.Save:SetScript("OnClick",WoWAscensionReworkCA_Save)

f.Essence=CreateFrame("Frame",nil,f)
Size(f.Essence,355,28)
f.Essence:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",154,15)
f.Essence.AE=f.Essence:CreateFontString(nil,"OVERLAY","GameFontNormal")
f.Essence.TE=f.Essence:CreateFontString(nil,"OVERLAY","GameFontNormal")

f.Rarity=CreateFrame("Frame",nil,f)
Size(f.Rarity,355,28)
f.Rarity:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-18,15)
f.Rarity.Text=f.Rarity:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
f.Rarity.Text:SetPoint("RIGHT",f.Rarity,"RIGHT",0,0)

WoWAscensionReworkCA_OnLoad(f)
f:SetScript("OnShow",function(self) WoWAscensionReworkCA_OnShow(self) end)
SLASH_WOWASCENSIONREWORKCA3="/fa"
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Forever.Ascension CA Test 1.0.1|r loaded. Commands: /wca /ca2 /fa")
