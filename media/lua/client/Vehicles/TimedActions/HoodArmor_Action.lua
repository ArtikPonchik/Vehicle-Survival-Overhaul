require "TimedActions/ISBaseTimedAction"

HoodArmorAction = ISBaseTimedAction:derive("HoodArmorAction")

function HoodArmorAction:isValid()
    return self.vehicle:isInArea(self.part:getArea(), self.character)
end

function HoodArmorAction:update()
    self.character:faceThisObject(self.vehicle)
end

function HoodArmorAction:start()
    if self.tier == 1 then
        self:setActionAnim("BuildLow")
        self.character:getEmitter():playSound("WoodblockTap")
    else
        self:setActionAnim("BlowTorch")
        self:setOverrideHandModels(self.character:getPrimaryHandItem(), nil)
        self.sound = self.character:getEmitter():playSound("BlowTorch")
    end
end

function HoodArmorAction:stop()

    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end

    ISBaseTimedAction.stop(self)
end

function HoodArmorAction:perform()
    local inv = self.character:getInventory()

    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end

    if self.tier == 1 then
        for i = 1, 2 do
            inv:RemoveOneOf("Base.Plank")
        end
        for i = 1, 4 do
            inv:RemoveOneOf("Base.Nails")
        end

    elseif self.tier == 2 then
        inv:RemoveOneOf("Base.SheetMetal")

        local torch = inv:getItemFromType("BlowTorch")
        if torch then
            torch:Use()
        end

    elseif self.tier == 3 then
        for i = 1, 2 do
            inv:RemoveOneOf("Base.SheetMetal")
        end

        local torch = inv:getItemFromType("BlowTorch")
        if torch then
            torch:Use()
            torch:Use()
        end
    end

    local md = self.vehicle:getModData()
    md.frontArmorTier = self.tier
    md.frontArmorHits = self.hits

    if not md.originalHoodCond then
        md.originalHoodCond = self.part:getCondition()
    end

    self.part:setCondition(100)

    self.vehicle:transmitPartCondition(self.part)
    self.vehicle:transmitModData()

    self.character:Say(getText("UI_HoodArmor_Success", tostring(self.tier)))

    ISBaseTimedAction.perform(self)
end

function HoodArmorAction:new(character, vehicle, part, tier, hits)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.part = part
    o.tier = tier
    o.hits = hits
    o.maxTime = 150 + (tier * 50)
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end