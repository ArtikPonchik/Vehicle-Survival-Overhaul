local CHECK_INTERVAL = 30
local MAX_CONDITION = 100
local MAX_DISTANCE = 15

local tickCounter = 0

local function canProcessVehicle(vehicle, localPlayer)
    if not isClient() then
        return true
    end

    local driver = vehicle:getDriver()

    if driver then
        return driver:isLocalPlayer()
    end

    if localPlayer then
        return localPlayer:DistTo(vehicle) <= MAX_DISTANCE
    end

    return false
end

local function processGlobalArmor(vehicle, md)
    if not md.isGlobalReinforced then
        return
    end

    if not md.globalReinforceHits or md.globalReinforceHits <= 0 then
        return
    end

    local damaged = false

    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)

        if part and part:getCondition() < MAX_CONDITION then
            part:setCondition(MAX_CONDITION)
            vehicle:transmitPartCondition(part)
            damaged = true
        end
    end

    if not damaged then
        return
    end

    md.globalReinforceHits = md.globalReinforceHits - 1

    if md.globalReinforceHits <= 0 then
        md.isGlobalReinforced = false
        md.globalReinforceHits = 0

        local driver = vehicle:getDriver()
        if driver and driver:isLocalPlayer() then
            driver:Say("Глобальное укрепление машины полностью разрушено!")
        end
    end

    vehicle:transmitModData()
end

local function processHoodArmor(vehicle, md)
    if not md.frontArmorHits or md.frontArmorHits <= 0 then
        return
    end

    local hood = vehicle:getPartById("EngineDoor")

    if not hood then
        return
    end

    if not hood:getInventoryItem() then
        md.frontArmorTier = 0
        md.frontArmorHits = 0
        md.originalHoodCond = nil

        vehicle:transmitModData()
        return
    end

    if hood:getCondition() >= MAX_CONDITION then
        return
    end

    hood:setCondition(MAX_CONDITION)
    vehicle:transmitPartCondition(hood)

    md.frontArmorHits = md.frontArmorHits - 1

    if md.frontArmorHits <= 0 then
        md.frontArmorTier = 0
        md.frontArmorHits = 0

        hood:setCondition(md.originalHoodCond or 0)
        vehicle:transmitPartCondition(hood)

        md.originalHoodCond = nil

        local driver = vehicle:getDriver()

        if driver and driver:isLocalPlayer() then
            driver:Say(getText("UI_HoodArmor_Broken"))
            driver:getEmitter():playSound("SmashWindow")
        end
    end

    vehicle:transmitModData()
end

Events.OnTick.Add(function()

    tickCounter = tickCounter + 1

    if tickCounter < CHECK_INTERVAL then
        return
    end

    tickCounter = 0

    local cell = getCell()
    if not cell then
        return
    end

    local vehicles = cell:getVehicles()
    if not vehicles then
        return
    end

    local localPlayer = getPlayer()

    for i = 0, vehicles:size() - 1 do

        local vehicle = vehicles:get(i)

        if vehicle then

            local md = vehicle:getModData()

            if canProcessVehicle(vehicle, localPlayer) then
                processGlobalArmor(vehicle, md)
                processHoodArmor(vehicle, md)
            end

        end
    end
end)