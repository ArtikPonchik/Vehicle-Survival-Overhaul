require "TimedActions/ISBaseTimedAction"

BatteryJumpAction = ISBaseTimedAction:derive("BatteryJumpAction")

function BatteryJumpAction:isValid()
    return self.vehicle:isInArea(self.part:getArea(), self.character)
end

function BatteryJumpAction:update()
    self.character:faceThisObject(self.vehicle)
end

function BatteryJumpAction:start()
    self:setActionAnim("Repair")
    self.character:getEmitter():playSound("GeneratorAddFuel")
end

function BatteryJumpAction:stop()
    ISBaseTimedAction.stop(self)
end

function BatteryJumpAction:perform()
    local carBat = self.part:getInventoryItem()
    
    
    local carCharge = carBat:getUsedDelta()
    local invCharge = self.invBat:getUsedDelta()
    
    if carCharge < 1.0 and invCharge > 0 then
        
        local needed = 1.0 - carCharge
        
        
        local transfer = math.min(needed, invCharge)
        
        
        carBat:setUsedDelta(carCharge + transfer)
        self.invBat:setUsedDelta(invCharge - transfer)
        
        
        self.vehicle:transmitPartItem(self.part)
        
        self.character:Say(getText("UI_ChargeSuccess"))
    else
        self.character:Say(getText("UI_ChargeFail"))
    end

    ISBaseTimedAction.perform(self)
end

function BatteryJumpAction:new(character, vehicle, part, invBat)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.part = part
    o.invBat = invBat
    o.maxTime = 150
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end