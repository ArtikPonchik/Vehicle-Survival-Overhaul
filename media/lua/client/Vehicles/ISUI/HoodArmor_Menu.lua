require "ISUI/ISToolTip"
require "TimedActions/ISPathFindAction"

local function onUpgradeHood(playerObj, vehicle, part, tier, hits)
    if vehicle and part then
        ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
        ISTimedActionQueue.add(HoodArmorAction:new(playerObj, vehicle, part, tier, hits))
    end
end

local function onPryTrunk(playerObj, vehicle, part)
    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
    ISTimedActionQueue.add(TrunkPryAction:new(playerObj, vehicle, part))
end

local function onDeepScrap(playerObj, vehicle)
    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, "Engine"))
    ISTimedActionQueue.add(DeepScrapAction:new(playerObj, vehicle))
end

local function onReinforceVehicle(playerObj, vehicle)
    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, "Engine"))
    ISTimedActionQueue.add(ReinforceAction:new(playerObj, vehicle))
end

local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(player)
    local vehicle = nil
    
    for _, obj in ipairs(worldobjects) do
        if instanceof(obj, "IsoVehicle") then vehicle = obj break end
    end

    if not vehicle then
        local sq
        for _, obj in ipairs(worldobjects) do
            sq = obj:getSquare()
            break
        end
        if sq then vehicle = sq:getVehicleContainer() end
    end

    if not vehicle then
        vehicle = playerObj:getNearVehicle()
    end

    if not vehicle then return end

    local inv = playerObj:getInventory()
    local md = vehicle:getModData()

    
    local trunk = vehicle:getPartById("TrunkDoor") or vehicle:getPartById("DoorRear")
    if trunk and trunk:getDoor() and trunk:getDoor():isLocked() then
        if inv:containsTypeRecurse("Crowbar") then
            context:addOption(getText("UI_PryTrunk"), playerObj, onPryTrunk, vehicle, trunk)
        end
    end

    
    local hood = vehicle:getPartById("EngineDoor")
    if hood and hood:getInventoryItem() then
        if not md.frontArmorTier or md.frontArmorTier < 3 then
            local upgradeOption = context:addOption(getText("UI_HoodArmor_Upgrade"), nil, nil)
            local subMenu = context:getNew(context)
            context:addSubMenu(upgradeOption, subMenu)

            
            if not md.frontArmorTier or md.frontArmorTier < 1 then
                local hasHammer = inv:containsTypeRecurse("Hammer") or inv:containsTypeRecurse("ClubHammer")
                local hasPlanks = inv:getItemCountRecurse("Base.Plank") >= 2
                local hasNails = inv:getItemCountRecurse("Base.Nails") >= 4
                local opt1 = subMenu:addOption(getText("UI_HoodArmor_Planks"), playerObj, onUpgradeHood, vehicle, hood, 1, 20)
                local tool1 = ISToolTip:new(); tool1:initialise(); tool1:setVisible(false);
                tool1.description = (hasHammer and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Hammer") .. " <br> " ..
                                    (hasPlanks and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Planks2") .. " <br> " ..
                                    (hasNails and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Nails4")
                opt1.toolTip = tool1
                if not (hasHammer and hasPlanks and hasNails) then opt1.notAvailable = true end
            end

            
            if not md.frontArmorTier or md.frontArmorTier < 2 then
                local hasTorch = inv:getUsesTypeRecurse("Base.BlowTorch") >= 1
                local hasMask = inv:containsTypeRecurse("WeldingMask")
                local hasSheet = inv:getItemCountRecurse("Base.SheetMetal") >= 1
                local hasSkill = playerObj:getPerkLevel(Perks.MetalWelding) >= 1
                local opt2 = subMenu:addOption(getText("UI_HoodArmor_Sheet1"), playerObj, onUpgradeHood, vehicle, hood, 2, 30)
                local tool2 = ISToolTip:new(); tool2:initialise(); tool2:setVisible(false);
                tool2.description = (hasTorch and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Blowtorch") .. " <br> " ..
                                    (hasMask and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Mask") .. " <br> " ..
                                    (hasSheet and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Sheet1_Item") .. " <br> " ..
                                    (hasSkill and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Skill1")
                opt2.toolTip = tool2
                if not (hasTorch and hasMask and hasSheet and hasSkill) then opt2.notAvailable = true end
            end

            
            if not md.frontArmorTier or md.frontArmorTier < 3 then
                local hasTorch = inv:getUsesTypeRecurse("Base.BlowTorch") >= 2
                local hasMask = inv:containsTypeRecurse("WeldingMask")
                local hasSheets = inv:getItemCountRecurse("Base.SheetMetal") >= 2
                local hasSkill = playerObj:getPerkLevel(Perks.MetalWelding) >= 2
                local opt3 = subMenu:addOption(getText("UI_HoodArmor_Sheet2"), playerObj, onUpgradeHood, vehicle, hood, 3, 50)
                local tool3 = ISToolTip:new(); tool3:initialise(); tool3:setVisible(false);
                tool3.description = (hasTorch and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Blowtorch") .. " <br> " ..
                                    (hasMask and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Mask") .. " <br> " ..
                                    (hasSheets and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Sheet2_Item") .. " <br> " ..
                                    (hasSkill and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Skill2")
                opt3.toolTip = tool3
                if not (hasTorch and hasMask and hasSheets and hasSkill) then opt3.notAvailable = true end
            end
        end
    end

    
    local hasTorchScrap = inv:getUsesTypeRecurse("Base.BlowTorch") >= 8
    local hasMaskScrap = inv:containsTypeRecurse("WeldingMask")
    
    local hasReadBook = playerObj:getAlreadyReadBook():contains("Base.WeldingMag1") or playerObj:getPerkLevel(Perks.MetalWelding) >= 1

    local scrapOption = context:addOption(getText("UI_DeepScrap"), playerObj, onDeepScrap, vehicle)
    local toolScrap = ISToolTip:new(); toolScrap:initialise(); toolScrap:setVisible(false);
    toolScrap.description = getText("UI_DeepScrap_Req") .. 
                            (hasTorchScrap and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Blowtorch") .. " (8) <br> " ..
                            (hasMaskScrap and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Mask") .. " <br> " ..
                            (hasReadBook and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_DeepScrap_Book")
    scrapOption.toolTip = toolScrap
    if not (hasTorchScrap and hasMaskScrap and hasReadBook) then scrapOption.notAvailable = true end

    
    if not md.isGlobalReinforced then
        local hasParts = inv:getItemCountRecurse("Base.SpecialEnginePart") >= 5
        local hasSkillReinforce = playerObj:getPerkLevel(Perks.MetalWelding) >= 3
        local hasTorchReinforce = inv:getUsesTypeRecurse("Base.BlowTorch") >= 4
        local hasMaskReinforce = inv:containsTypeRecurse("WeldingMask")

        local reinforceOption = context:addOption(getText("UI_ReinforceVeh"), playerObj, onReinforceVehicle, vehicle)
        local toolRein = ISToolTip:new(); toolRein:initialise(); toolRein:setVisible(false);
        toolRein.description = getText("UI_ReinforceVeh_Req") .. 
                               (hasParts and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_ReinforceVeh_Parts") .. " <br> " ..
                               (hasSkillReinforce and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_ReinforceVeh_Skill") .. " <br> " ..
                               (hasTorchReinforce and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Blowtorch") .. " (4) <br> " ..
                               (hasMaskReinforce and " <RGB:0,1,0> " or " <RGB:1,0,0> ") .. getText("UI_HoodArmor_Mask")
        reinforceOption.toolTip = toolRein
        if not (hasParts and hasSkillReinforce and hasTorchReinforce and hasMaskReinforce) then reinforceOption.notAvailable = true end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)