require "TimedActions/ISBaseTimedAction"

ReinforceAction = ISBaseTimedAction:derive("ReinforceAction")

function ReinforceAction:isValid()
    return self.vehicle:getSquare() ~= nil
end

function ReinforceAction:update()
    self.character:faceThisObject(self.vehicle)
end

function ReinforceAction:start()
    local torch = self.character:getInventory():getFirstTypeRecurse("Base.BlowTorch")
    
    self:setOverrideHandModels(torch, nil)
    self:setActionAnim("BlowTorch")
    self.sound = self.character:getEmitter():playSound("BlowTorch")
end

local function stopSound(self)
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:getEmitter():stopSound(self.sound)
    end
end

function ReinforceAction:stop()
    stopSound(self)
    ISBaseTimedAction.stop(self)
end

function ReinforceAction:perform()
    stopSound(self)
    
    local inv = self.character:getInventory()
    local itemType = "Base.SpecialEnginePart"
    
    if getScriptManager():getItem(itemType) and inv:containsTypeRecurse(itemType) then
        for i=1, 5 do inv:RemoveOneOf(itemType) end
    else
        for i=1, 5 do inv:RemoveOneOf("Base.EngineParts") end
    end

    local md = self.vehicle:getModData()
    md.isGlobalReinforced = true
    md.globalReinforceHits = 150

    for i=0, self.vehicle:getPartCount()-1 do
        local part = self.vehicle:getPartByIndex(i)
        part:setCondition(100)
        self.vehicle:transmitPartCondition(part)
    end

    md.lastGlobalVehicleCond = 100
    self.vehicle:transmitModData()
    self.character:Say(getText("UI_ReinforceVeh_Success"))

    ISBaseTimedAction.perform(self)
end

function ReinforceAction:new(character, vehicle)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.maxTime = 3600 
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end