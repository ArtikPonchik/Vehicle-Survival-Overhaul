local original_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside

function ISVehicleMenu.showRadialMenuOutside(playerObj)
    
    original_showRadialMenuOutside(playerObj)
    
    local vehicle = playerObj:getNearVehicle()
    if not vehicle then return end
    
    
    local hoodPart = vehicle:getPartById("EngineDoor")
    if not hoodPart or not vehicle:isInArea(hoodPart:getArea(), playerObj) then return end

    local inv = playerObj:getInventory()
    
    local invBat = inv:getItemFromType("CarBattery1") or inv:getItemFromType("CarBattery2") or inv:getItemFromType("CarBattery3")
    
    
    local carBatPart = vehicle:getPartById("Battery")
    
    
    if invBat and carBatPart and carBatPart:getInventoryItem() then
        local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
        
        
        menu:addSlice(getText("UI_ChargeBattery"), getTexture("Item_JumpStart"), function()
            ISTimedActionQueue.add(BatteryJumpAction:new(playerObj, vehicle, carBatPart, invBat))
        end)
    end
end