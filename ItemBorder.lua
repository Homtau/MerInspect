-------------------------------------
-- 物品邊框 Author: M (FIXED)
-------------------------------------

local LibEvent = LibStub:GetLibrary("LibEvent.7000")

-------------------------------------------------
-- 安全获取品质颜色（核心修复）
-------------------------------------------------
local function SafeGetQualityColor(quality)
    if type(quality) == "table" then
        quality = quality.quality or quality.itemQuality or quality.Quality
    end

    if type(quality) ~= "number" then
        quality = 0
    end

    local ok, r, g, b = pcall(C_Item.GetItemQualityColor, quality)
    if ok then
        return r, g, b
    end

    return 0.62, 0.62, 0.62
end

-------------------------------------------------
-- 直角邊框 @trigger SET_ITEM_ANGULARBORDER
-------------------------------------------------
local function SetItemAngularBorder(self, quality, itemIDOrLink)
    if not self then return end

    if not self.angularFrame then
        local anchor = self.Icon or self.icon or self.IconBorder or self
        local w, h = anchor:GetSize()

        if w == 0 or h == 0 then
            w, h = self:GetSize()
        end

        self.angularFrame = CreateFrame("Frame", nil, self)
        self.angularFrame:SetFrameLevel(5)
        self.angularFrame:SetSize(w, h)
        self.angularFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        self.angularFrame:Hide()

        self.angularFrame.mask = CreateFrame("Frame", nil, self.angularFrame, "BackdropTemplate")
        self.angularFrame.mask:SetSize(w - 2, h - 2)
        self.angularFrame.mask:SetPoint("CENTER")
        self.angularFrame.mask:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeSize = 2
        })
        self.angularFrame.mask:SetBackdropBorderColor(0, 0, 0)

        self.angularFrame.border = CreateFrame("Frame", nil, self.angularFrame, "BackdropTemplate")
        self.angularFrame.border:SetSize(w, h)
        self.angularFrame.border:SetPoint("CENTER")
        self.angularFrame.border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1
        })
    end

    if MerInspectDB and MerInspectDB.ShowItemBorder then
        LibEvent:trigger("SET_ITEM_ANGULARBORDER", self.angularFrame, quality, itemIDOrLink)
    else
        self.angularFrame:Hide()
    end
end

-------------------------------------------------
-- hook item quality
-------------------------------------------------
hooksecurefunc("SetItemButtonQuality", SetItemAngularBorder)

-------------------------------------------------
-- Inspect UI hook
-------------------------------------------------
LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if addonName == "Blizzard_InspectUI" then
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(self)
            local textureName = GetInventoryItemTexture(InspectFrame.unit, self:GetID())
            if not textureName then
                SetItemAngularBorder(self, nil)
            end
        end)
    end
end)

-------------------------------------------------
-- apply border
-------------------------------------------------
LibEvent:attachTrigger("SET_ITEM_ANGULARBORDER", function(self, frame, quality, itemIDOrLink)
    if not frame then return end

    -- ===== FIX: unwrap quality =====
    if type(quality) == "table" then
        quality = quality.quality or quality.itemQuality or quality.rarity
    end

    if type(quality) ~= "number" then
        quality = 0
    end

    local r, g, b = C_Item.GetItemQualityColor(quality)

    if quality <= 1 then
        r = r - 0.3
        g = g - 0.3
        b = b - 0.3
    end

    frame.border:SetBackdropBorderColor(r, g, b)
    frame:Show()
end)