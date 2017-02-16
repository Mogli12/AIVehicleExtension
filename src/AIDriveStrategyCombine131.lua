AIDriveStrategyCombine131 = {};
local AIDriveStrategyCombine131_mt = Class(AIDriveStrategyCombine131, AIDriveStrategy);

function AIDriveStrategyCombine131:new(customMt)
    if customMt == nil then
        customMt = AIDriveStrategyCombine131_mt;
    end;

    local self = AIDriveStrategy:new(customMt);

    self.combines = {};

    return self;
end

function AIDriveStrategyCombine131:delete()
    AIDriveStrategyCombine131:superClass().delete(self);

end

function AIDriveStrategyCombine131:setAIVehicle(vehicle)
    AIDriveStrategyCombine131:superClass().setAIVehicle(self, vehicle);

    if SpecializationUtil.hasSpecialization(Combine, self.vehicle.specializations) then
        table.insert(self.combines, self.vehicle);
    end
    for _,implement in pairs(self.vehicle.aiImplementList) do
        if SpecializationUtil.hasSpecialization(Combine, implement.object.specializations) then
            table.insert(self.combines, implement.object);
        end
    end
end

function AIDriveStrategyCombine131:update(dt)

end

function AIDriveStrategyCombine131:getDriveData(dt, vX,vY,vZ)

    --# check for turn
    local isTurning = false;
    for _,strategy in pairs(self.vehicle.driveStrategies) do
        if strategy.activeTurnStrategy ~= nil then
            isTurning = true;
            break;
        end
    end

    local allowedToDrive = true;
    local waitForStraw = false;

    for _,combine in pairs(self.combines) do
    
        if not combine:getIsThreshingAllowed() then
            self.vehicle:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR);
            return nil, nil, nil, nil, nil;
        end
    
        local fillType = combine:getUnitLastValidFillType(combine.overloading.fillUnitIndex);
        local fillLevel = combine:getUnitFillLevel(combine.overloading.fillUnitIndex);
        local capacity = combine:getUnitCapacity(combine.overloading.fillUnitIndex);

        local validTrailer;
        for trailer,value in pairs(combine.overloading.trailersInRange) do
            if value > 0 then
                if trailer:allowFillType(fillType) then
                    if trailer:getFillLevel(fillType) < trailer:getCapacity(fillType) then
                        validTrailer = trailer;
                        break;
                    end
                end
            end
        end


        if capacity == 0 then
            if combine.pipeTargetState ~= 2 then
                combine:setPipeState(2);
            end
            if isTurning then
                allowedToDrive = true;
            else
                allowedToDrive = validTrailer ~= nil and ( combine:getIsOverloadingAllowed() or (self.lastValidInputFruitType == FruitUtil.FRUITTYPE_UNKNOWN) );
            end
        else
            local pipeState = combine.pipeTargetState; --1;

            if fillLevel > (0.8*capacity) then
                if self.vehicle.beaconLightsActive == false then
                    self.vehicle:setBeaconLightsVisibility(true, false);
                end
            else
                if self.vehicle.beaconLightsActive == true then
                    self.vehicle:setBeaconLightsVisibility(false, false);
                end
            end
            
            if fillLevel == capacity then
                pipeState = 2;
                self.wasCompletelyFull = true;
                if self.notificationFullGrainTankShown ~= true then
                    g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, string.format(g_i18n:getText(AIVehicle.REASON_TEXT_MAPPING[AIVehicle.STOP_REASON_GRAINTANK_IS_FULL]), self.vehicle.currentHelper.name) )
                    self.notificationFullGrainTankShown = true;
                end
            else
                self.notificationFullGrainTankShown = false;
            end

            if validTrailer and fillLevel > 0 then
                pipeState = 2;
            else
                if fillLevel < capacity then
                    self.wasCompletelyFull = false;
                end
            end
            
            if validTrailer == nil then
                pipeState = 1;
            end

            if combine.pipeTargetState ~= pipeState then
                combine:setPipeState(pipeState);
            end
            
            allowedToDrive = fillLevel < capacity;
            
            if pipeState == 2 and self.wasCompletelyFull then
                allowedToDrive = false;
            end

            if isTurning and validTrailer ~= nil then
                if combine.trailerFound ~= 0 then
                    allowedToDrive = fillLevel == 0;
                end
            end
        end

        if combine.isStrawEnabled then
            if combine.strawPSenabled then
                waitForStraw = true;
            end
        end
    end

    --if (not allowedToDrive and not isTurning) or (isTurning and waitForStraw) then
    if not allowedToDrive or (isTurning and waitForStraw) then
        return 0, 1, true, 0, math.huge;
    else
        return nil, nil, nil, nil, nil;
    end

end

function AIDriveStrategyCombine131:updateDriving(dt)
end

