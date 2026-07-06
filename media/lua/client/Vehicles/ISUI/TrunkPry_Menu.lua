require "TimedActions/ISBaseTimedAction"

TrunkPryAction = ISBaseTimedAction:derive("TrunkPryAction")

function TrunkPryAction:isValid()
    return self.vehicle:isInArea(self.part:getArea(), self.character)
end

function TrunkPryAction:update()
    self.character:faceThisObject(self.vehicle)
end

function TrunkPryAction:start()
    self:setActionAnim("SmashWindow")
    self:setOverrideHandModels(self.character:getPrimaryHandItem(), nil)
    self.character:getEmitter():playSound("Crowbar")
end

function TrunkPryAction:stop()
    ISBaseTimedAction.stop(self)
end

function TrunkPryAction:perform()
    local carType = self.vehicle:getScript():getMechanicType()
    
    local chance = 90
    if carType == 2 then chance = 60 end
    if carType == 3 then chance = 30 end

    if ZombRand(100) < chance then
        self.part:getDoor():setLocked(false)
        self.vehicle:transmitPartDoor(self.part)
        self.character:Say(getText("UI_PrySuccess"))
        self.character:getEmitter():playSound("UnlockDoor")
    else
        self.character:Say(getText("UI_PryFail"))
        self.character:getEmitter():playSound("BreakLock")
        
        if carType == 3 and ZombRand(100) < 50 then
            self.vehicle:triggerAlarm()
        end
    end

    ISBaseTimedAction.perform(self)
end

function TrunkPryAction:new(character, vehicle, part)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.part = part
    o.maxTime = 200
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end