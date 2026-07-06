require "TimedActions/ISBaseTimedAction"

DeepScrapAction = ISBaseTimedAction:derive("DeepScrapAction")

function DeepScrapAction:isValid()
    return self.vehicle:getSquare() ~= nil
end

function DeepScrapAction:update()
    self.character:faceThisObject(self.vehicle)
end

function DeepScrapAction:start()
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

function DeepScrapAction:stop()
    stopSound(self)
    ISBaseTimedAction.stop(self)
end

function DeepScrapAction:perform()
    stopSound(self)
    
    local inv = self.character:getInventory()
    local torch = inv:getItemFromType("BlowTorch")
    if torch then
        for i=1, 8 do torch:Use() end
    end

    self.character:getXp():AddXP(Perks.MetalWelding, 150)

    local sq = self.character:getSquare()
    
    
    local itemType = "Base.SpecialEnginePart"
    if getScriptManager():getItem(itemType) then
        sq:AddWorldInventoryItem(itemType, 0.5, 0.5, 0.0)
        sq:AddWorldInventoryItem(itemType, 0.5, 0.5, 0.0)
    else
        sq:AddWorldInventoryItem("Base.EngineParts", 0.5, 0.5, 0.0)
        sq:AddWorldInventoryItem("Base.EngineParts", 0.5, 0.5, 0.0)
    end

    sq:AddWorldInventoryItem("Base.SheetMetal", 0.5, 0.5, 0.0)
    sq:AddWorldInventoryItem("Base.ScrapMetal", 0.5, 0.5, 0.0)
    sq:AddWorldInventoryItem("Base.MetalParts", 0.5, 0.5, 0.0)

    self.vehicle:permanentlyRemove()
    self.character:Say(getText("UI_DeepScrap_Success"))

    ISBaseTimedAction.perform(self)
end

function DeepScrapAction:new(character, vehicle)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.maxTime = 3600 
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end