local ADDON = "WoWAscensionRework_CA"
local frame
local state = { mode = "Abilities", class = "Warrior", tab = nil, search = "", classButtons = {}, specButtons = {}, entryButtons = {} }
local CLASS_ORDER = {"Warrior","Paladin","Hunter","Rogue","Priest","DeathKnight","Shaman","Mage","Warlock","Druid"}
local CLASS_LABEL = {DeathKnight="Death Knight"}
local CLASS_ICON = {
  Warrior="Interface\\Icons\\ClassIcon_Warrior", Paladin="Interface\\Icons\\ClassIcon_Paladin", Hunter="Interface\\Icons\\ClassIcon_Hunter",
  Rogue="Interface\\Icons\\ClassIcon_Rogue", Priest="Interface\\Icons\\ClassIcon_Priest", DeathKnight="Interface\\Icons\\ClassIcon_DeathKnight",
  Shaman="Interface\\Icons\\ClassIcon_Shaman", Mage="Interface\\Icons\\ClassIcon_Mage", Warlock="Interface\\Icons\\ClassIcon_Warlock", Druid="Interface\\Icons\\ClassIcon_Druid"
}
local QUALITY = { Normal={1,1,1}, Uncommon={0.12,1,0}, Rare={0,0.44,0.87}, Epic={0.64,0.21,0.93}, Legendary={1,0.50,0} }

local function safeCall(t, name, ...)
  if type(t)=="table" and type(t[name])=="function" then
    local ok,a,b,c,d = pcall(t[name], ...)
    if ok then return a,b,c,d end
  end
end
local function api() return _G.C_CharacterAdvancement end
local function normalize(s) return string.lower(tostring(s or "")) end
local function entryCost(e)
  if e.Type == "Talent" or e.Type == "TalentAbility" then return e.TECost or 1, "TE" end
  return e.AECost or 0, "AE"
end
local function iconPath(e)
  if e.Icon and e.Icon ~= "" then return "Interface\\Icons\\"..e.Icon end
  local sid=e.Spells and e.Spells[1]
  if sid and GetSpellTexture then local tex=GetSpellTexture(sid); if tex then return tex end end
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end
local function tooltip(button)
  local e=button.entry; if not e then return end
  GameTooltip:SetOwner(button,"ANCHOR_RIGHT")
  local sid=e.Spells and e.Spells[1]
  if sid and GameTooltip.SetHyperlink then pcall(GameTooltip.SetHyperlink,GameTooltip,"spell:"..sid) end
  if not GameTooltip:IsShown() then GameTooltip:SetText(e.Name or ("Entry "..e.ID),1,1,1) end
  local cost,kind=entryCost(e)
  GameTooltip:AddLine((kind=="AE" and "Ability Essence: " or "Talent Essence: ")..tostring(cost),1,0.82,0,true)
  if e.RequiredLevel then GameTooltip:AddLine("Required level: "..e.RequiredLevel,0.8,0.8,0.8,true) end
  if e.RequiredTEInvestment then GameTooltip:AddLine("Required TE investment: "..e.RequiredTEInvestment,0.8,0.8,0.8,true) end
  if e.RequiredAEInvestment then GameTooltip:AddLine("Required AE investment: "..e.RequiredAEInvestment,0.8,0.8,0.8,true) end
  GameTooltip:Show()
end
local function isKnown(e)
  local ca=api()
  if ca then
    local known=safeCall(ca,"IsKnown",e.ID); if known~=nil then return known end
    local rank=safeCall(ca,"GetKnownRankByEntryID",e.ID); if type(rank)=="number" then return rank>0 end
    if e.Spells and e.Spells[1] and IsSpellKnown then return IsSpellKnown(e.Spells[1]) end
  end
  return false
end
local function learnEntry(e)
  local ca=api()
  if _G.CharacterAdvancementUtil and CharacterAdvancementUtil.ConfirmOrLearnID then CharacterAdvancementUtil.ConfirmOrLearnID(e.ID); return end
  if ca then
    local can=safeCall(ca,"CanAddByEntryID",e.ID)
    if can~=false and type(ca.AddByEntryID)=="function" then ca.AddByEntryID(e.ID); return end
    can=safeCall(ca,"CanLearnID",e.ID)
    if can~=false and type(ca.LearnID)=="function" then ca.LearnID(e.ID); return end
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[CA]|r Learning API is not available yet for entry "..e.ID)
end
local function unlearnEntry(e)
  local ca=api()
  if _G.CharacterAdvancementUtil and CharacterAdvancementUtil.ConfirmOrUnlearnID then CharacterAdvancementUtil.ConfirmOrUnlearnID(e.ID); return end
  if ca then
    local can=safeCall(ca,"CanRemoveByEntryID",e.ID)
    if can~=false and type(ca.RemoveByEntryID)=="function" then ca.RemoveByEntryID(e.ID); return end
    if type(ca.UnlearnID)=="function" then ca.UnlearnID(e.ID); return end
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[CA]|r Unlearning API is not available yet for entry "..e.ID)
end
local function onEntryClick(self, button)
  if button=="RightButton" or IsShiftKeyDown() then unlearnEntry(self.entry) else learnEntry(self.entry) end
end
local function makeEntryButton(parent,i)
  local b=CreateFrame("Button",ADDON.."Entry"..i,parent)
  b:SetSize(186,46); b:RegisterForClicks("LeftButtonUp","RightButtonUp")
  b.bg=b:CreateTexture(nil,"BACKGROUND"); b.bg:SetAllPoints(); b.bg:SetTexture("Interface\\Buttons\\WHITE8X8"); b.bg:SetVertexColor(0.06,0.06,0.06,0.80)
  b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetSize(36,36); b.icon:SetPoint("LEFT",5,0)
  b.border=b:CreateTexture(nil,"OVERLAY"); b.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border"); b.border:SetBlendMode("ADD"); b.border:SetSize(58,58); b.border:SetPoint("CENTER",b.icon,"CENTER",0,0)
  b.name=b:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); b.name:SetPoint("TOPLEFT",b.icon,"TOPRIGHT",7,-2); b.name:SetPoint("RIGHT",-6,0); b.name:SetJustifyH("LEFT")
  b.meta=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); b.meta:SetPoint("BOTTOMLEFT",b.icon,"BOTTOMRIGHT",7,2); b.meta:SetJustifyH("LEFT")
  b.rank=b:CreateFontString(nil,"OVERLAY","NumberFontNormalSmall"); b.rank:SetPoint("BOTTOMRIGHT",b.icon,"BOTTOMRIGHT",0,0)
  b:SetScript("OnEnter",tooltip); b:SetScript("OnLeave",function() GameTooltip:Hide() end); b:SetScript("OnClick",onEntryClick)
  return b
end
local function makeClassButton(parent,i,class)
  local b=CreateFrame("Button",ADDON.."Class"..i,parent); b:SetSize(112,48); b.class=class
  b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetSize(34,34); b.icon:SetPoint("LEFT",5,0); b.icon:SetTexture(CLASS_ICON[class])
  b.text=b:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); b.text:SetPoint("LEFT",b.icon,"RIGHT",5,0); b.text:SetText(CLASS_LABEL[class] or class)
  b.sel=b:CreateTexture(nil,"BACKGROUND"); b.sel:SetAllPoints(); b.sel:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2"); b.sel:SetBlendMode("ADD"); b.sel:Hide()
  b:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
  b:SetScript("OnClick",function(self) state.class=self.class; state.tab=nil; WoWAscensionReworkCA_Refresh() end)
  return b
end
local function allRows()
  local ca=api()
  local t=safeCall(ca,"GetAllEntries")
  if type(t)=="table" and #t>0 then return t end
  return WoWAscensionReworkCAData or {}
end
local function tabsForClass(class)
  local seen,out={},{}
  for _,e in ipairs(allRows()) do if e.Class==class and e.Tab and e.Tab~="None" and not seen[e.Tab] then seen[e.Tab]=true; out[#out+1]=e.Tab end end
  table.sort(out); return out
end
local function rowsForView()
  local out={}; local q=normalize(state.search)
  for _,e in ipairs(allRows()) do
    local typeOK = (state.mode=="Abilities" and (e.Type=="Ability" or e.Type=="TalentAbility")) or (state.mode=="Talents" and e.Type=="Talent") or (state.mode=="Mastery" and (e.Type=="Trait" or e.Type=="Mastery"))
    if typeOK and e.Class==state.class and (not state.tab or e.Tab==state.tab) then
      if q=="" or string.find(normalize(e.Name),q,1,true) or string.find(normalize(e.Tab),q,1,true) then out[#out+1]=e end
    end
  end
  table.sort(out,function(a,b)
    if state.mode=="Talents" then
      local ar,br=a.RequiredTEInvestment or 0,b.RequiredTEInvestment or 0; if ar~=br then return ar<br end
      local ac,bc=a.Column or 9,b.Column or 9; if ac~=bc then return ac<bc end
    end
    local al,bl=a.RequiredLevel or 0,b.RequiredLevel or 0; if al~=bl then return al<bl end
    return (a.Name or "")<(b.Name or "")
  end)
  return out
end
local function refreshClassButtons()
  for _,b in ipairs(state.classButtons) do if b.class==state.class then b.sel:Show() else b.sel:Hide() end end
end
local function refreshSpecs()
  for _,b in ipairs(state.specButtons) do b:Hide() end
  local tabs=tabsForClass(state.class); if not state.tab then state.tab=tabs[1] end
  for i,tab in ipairs(tabs) do
    local b=state.specButtons[i]
    if not b then b=CreateFrame("Button",ADDON.."Spec"..i,frame,"UIPanelButtonTemplate"); b:SetSize(118,24); state.specButtons[i]=b end
    b.tab=tab; b:SetText(tab); b:ClearAllPoints(); b:SetPoint("TOPLEFT",frame,"TOPLEFT",154+(i-1)*122,-64); b:SetScript("OnClick",function(self) state.tab=self.tab; WoWAscensionReworkCA_RefreshEntries() end); b:Show()
  end
end
function WoWAscensionReworkCA_RefreshEntries()
  local rows=rowsForView(); local parent=frame.Center
  local maxVisible=48
  for i=1,maxVisible do
    local b=state.entryButtons[i]; if not b then b=makeEntryButton(parent,i); state.entryButtons[i]=b end
    local e=rows[i]
    if e then
      b.entry=e; b.icon:SetTexture(iconPath(e)); b.name:SetText(e.Name or ("Entry "..e.ID))
      local cost,kind=entryCost(e); b.meta:SetText((e.Tab or "").."  -  "..cost.." "..kind..(e.RequiredLevel and ("  -  L"..e.RequiredLevel) or ""))
      local c=QUALITY[e.Quality] or QUALITY.Normal; b.border:SetVertexColor(c[1],c[2],c[3]); b.border:SetAlpha(isKnown(e) and 1 or 0.35)
      b.rank:SetText(isKnown(e) and "+" or "")
      local col,row
      if state.mode=="Talents" then col=(e.Column and math.max(1,math.min(4,e.Column))) or (((i-1)%4)+1); row=math.floor((i-1)/4)+1 else col=((i-1)%4)+1; row=math.floor((i-1)/4)+1 end
      b:ClearAllPoints(); b:SetPoint("TOPLEFT",parent,"TOPLEFT",8+(col-1)*195,-10-(row-1)*49); b:Show()
    else b.entry=nil; b:Hide() end
  end
  frame.Rarity.Text:SetText(string.format("%s - %s - %d shown", state.class, state.tab or "All", math.min(#rows,maxVisible)))
end
local function refreshCurrencies()
  local ca=api(); local ae=safeCall(ca,"GetPendingRemainingAE") or safeCall(ca,"GetLearnedAE") or "?"; local te=safeCall(ca,"GetPendingRemainingTE") or safeCall(ca,"GetLearnedTE") or "?"
  frame.Essence.AE:ClearAllPoints(); frame.Essence.AE:SetPoint("LEFT",0,0); frame.Essence.AE:SetText("Ability Essence: |cffffffff"..tostring(ae).."|r")
  frame.Essence.TE:ClearAllPoints(); frame.Essence.TE:SetPoint("LEFT",frame.Essence.AE,"RIGHT",28,0); frame.Essence.TE:SetText("Talent Essence: |cffffffff"..tostring(te).."|r")
end
function WoWAscensionReworkCA_Refresh()
  refreshClassButtons(); refreshSpecs(); WoWAscensionReworkCA_RefreshEntries(); refreshCurrencies()
  if state.mode=="Abilities" then frame.AbilitiesTab:Disable() else frame.AbilitiesTab:Enable() end
  if state.mode=="Talents" then frame.TalentsTab:Disable() else frame.TalentsTab:Enable() end
  if state.mode=="Mastery" then frame.MasteryTab:Disable() else frame.MasteryTab:Enable() end
end
function WoWAscensionReworkCA_SetMode(mode) state.mode=mode; WoWAscensionReworkCA_Refresh() end
function WoWAscensionReworkCA_Search(text) state.search=text or ""; WoWAscensionReworkCA_RefreshEntries() end
function WoWAscensionReworkCA_Save()
  local ca=api(); if ca and type(ca.ApplyPendingBuild)=="function" then ca.ApplyPendingBuild(); return end
  if ca and type(ca.Apply)=="function" then ca.Apply(); return end
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[CA]|r Pending-build save API is not available yet.")
end
function WoWAscensionReworkCA_Reset()
  if _G.CharacterAdvancementUtil and CharacterAdvancementUtil.ConfirmClearBuild then CharacterAdvancementUtil.ConfirmClearBuild(); return end
  local ca=api(); if ca and type(ca.ClearPendingBuild)=="function" then ca.ClearPendingBuild(); return end
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[CA]|r Reset API is not available yet.")
end
function WoWAscensionReworkCA_OnLoad(self)
  frame=self; self:RegisterEvent("PLAYER_ENTERING_WORLD"); self:RegisterEvent("PLAYER_LEVEL_UP")
  pcall(self.RegisterEvent,self,"CHARACTER_ADVANCEMENT_PENDING_BUILD_UPDATED"); pcall(self.RegisterEvent,self,"CHARACTER_ADVANCEMENT_LEARN_RESULT")
  for i,class in ipairs(CLASS_ORDER) do local b=makeClassButton(self.Left,i,class); b:SetPoint("TOPLEFT",self.Left,"TOPLEFT",7,-8-(i-1)*51); state.classButtons[i]=b end
  self:SetScript("OnEvent",function() if self:IsShown() then WoWAscensionReworkCA_Refresh() end end)
  SLASH_WOWASCENSIONREWORKCA1="/wca"; SLASH_WOWASCENSIONREWORKCA2="/ca2"; SlashCmdList.WOWASCENSIONREWORKCA=function() if self:IsShown() then self:Hide() else self:Show() end end
end
function WoWAscensionReworkCA_OnShow(self) WoWAscensionReworkCA_Refresh() end
