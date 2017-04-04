-- AIVehicleUtil
-- Description
-- 
-- 	Util class for various ai vehicle functions
-- 
-- Functions
-- 
-- driveToPoint
-- Description
-- 
-- 	Drive vehicle to given point
-- 
-- Definition
-- 
-- 	driveToPoint(table self, float dt, float acceleration, boolean allowedToDrive, boolean moveForwards, float tX, float tY, float maxSpeed, boolean doNotSteer)
-- 
-- Arguments
-- table	self	object of vehicle to move
-- float	dt	time since last call in ms
-- float	acceleration	acceleration
-- boolean	allowedToDrive	allowed to drive
-- boolean	moveForwards	move forwards
-- float	tX	local space x position
-- float	tY	local space y position
-- float	maxSpeed	speed limit
-- boolean	doNotSteer	do not steer
-- Code
function AIVehicleUtil.driveToPoint(self, dt, acceleration, allowedToDrive, moveForwards, tX, tZ, maxSpeed, doNotSteer)

    if self.firstTimeRun then

        if allowedToDrive then

            local tX_2 = tX * 0.5;
            local tZ_2 = tZ * 0.5;

            local d1X, d1Z = tZ_2, -tX_2;
            if tX > 0 then
                d1X, d1Z = -tZ_2, tX_2;
            end

            local hit,_,f2 = Utils.getLineLineIntersection2D(tX_2,tZ_2, d1X,d1Z, 0,0, tX, 0);

            if doNotSteer == nil or not doNotSteer then
                local rotTime = 0;
                local radius = 0;
                if hit and math.abs(f2) < 100000 then
                    radius = tX * f2;
                    rotTime = self.wheelSteeringDuration * ( math.atan(1/radius) / math.atan(1/self.maxTurningRadius) );
                end

                local targetRotTime = 0;
                if rotTime >= 0 then
                    targetRotTime = math.min(rotTime, self.maxRotTime)
                else
                    targetRotTime = math.max(rotTime, self.minRotTime)
                end

                if targetRotTime > self.rotatedTime then
                    self.rotatedTime = math.min(self.rotatedTime + dt*self.aiSteeringSpeed, targetRotTime);
                else
                    self.rotatedTime = math.max(self.rotatedTime - dt*self.aiSteeringSpeed, targetRotTime);
                end

                -- adjust maxSpeed
                local steerDiff = targetRotTime - self.rotatedTime;
                local fac = math.abs(steerDiff) / math.max(self.maxRotTime, -self.minRotTime);
                maxSpeed = maxSpeed * math.max( 0.01, 1.0 - math.pow(fac,0.25));
            end;
        end

        self.motor:setSpeedLimit(maxSpeed);
        if self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE then
            self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_ACTIVE);
        end

        if not allowedToDrive then
            acceleration = 0;
        end
        if not moveForwards then
            acceleration = -acceleration;
        end

        if not g_currentMission.missionInfo.stopAndGoBraking then
            if acceleration ~= self.nextMovingDirection then
                if not self.hasStopped then
                    if math.abs(self.lastSpeedAcceleration) < 0.0001 and math.abs(self.lastSpeedReal) < 0.0001 and math.abs(self.lastMovedDistance) < 0.001 then
                        acceleration = 0;
                    end
                end
            end
        end

        WheelsUtil.updateWheelsPhysics(self, dt, self.lastSpeedReal, acceleration, not allowedToDrive, self.requiredDriveMode);

    end

end
-- 	driveInDirection(table self, float dt, float steeringAngleLimit, float acceleration, float slowAcceleration, float slowAngleLimit, boolean allowedToDrive, boolean moveForwards, float lx, float lz, float maxSpeed, float slowDownFactor)
-- 
-- Arguments
-- table	self	object of vehicle
-- float	dt	time since last call in ms
-- float	steeringAngleLimit	limit for steering angle
-- float	acceleration	acceleration
-- float	slowAcceleration	slow acceleration
-- float	slowAngleLimit	limit of slow angle
-- boolean	allowedToDrive	allow to drive
-- boolean	moveForwards	move forwards
-- float	lx	x direction
-- float	lz	z direction
-- float	maxSpeed	max speed
-- float	slowDownFactor	slow down factor
function AIVehicleUtil.driveInDirection(self, dt, steeringAngleLimit, acceleration, slowAcceleration, slowAngleLimit, allowedToDrive, moveForwards, lx, lz, maxSpeed, slowDownFactor)

    local angle = 0;
    if lx ~= nil and lz ~= nil then
        local dot = lz;
        angle = math.deg(math.acos(dot));
        if angle < 0 then
            angle = angle+180;
        end

        local turnLeft = lx > 0.00001;
        if not moveForwards then
            turnLeft = not turnLeft;
        end

        local targetRotTime = 0;

        if turnLeft then
            --rotate to the left
            targetRotTime = self.maxRotTime*math.min(angle/steeringAngleLimit, 1);
        else
            --rotate to the right
            targetRotTime = self.minRotTime*math.min(angle/steeringAngleLimit, 1);
        end

        if targetRotTime > self.rotatedTime then
            self.rotatedTime = math.min(self.rotatedTime + dt*self.aiSteeringSpeed, targetRotTime);
        else
            self.rotatedTime = math.max(self.rotatedTime - dt*self.aiSteeringSpeed, targetRotTime);
        end
    end


    if self.firstTimeRun then
        local acc = acceleration;
        if maxSpeed ~= nil and maxSpeed ~= 0 then
            if math.abs(angle) >= slowAngleLimit then
                maxSpeed = maxSpeed * slowDownFactor;
            end
            self.motor:setSpeedLimit(maxSpeed);

            if self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE then
                self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_ACTIVE);
            end
        else
            if math.abs(angle) >= slowAngleLimit then
                acc = slowAcceleration;
            end
        end
        if not allowedToDrive then
            acc = 0;
        end
        if not moveForwards then
            acc = -acc;
        end
        WheelsUtil.updateWheelsPhysics(self, dt, self.lastSpeedReal, acc, not allowedToDrive, self.requiredDriveMode);
    end
end
-- Arguments
-- integer	refNode	id of ref node
-- float	x	world x
-- float	y	world y
-- float	z	world z
-- Return Values
-- float	lx	x direction
-- float	lz	z direction
-- Code
function AIVehicleUtil.getDriveDirection(refNode, x, y, z)
    local lx, _, lz = worldToLocal(refNode, x, y, z);

    local length = Utils.vector2Length(lx, lz);
    if length > 0.00001 then
        length = 1/length;
        lx = lx*length;
        lz = lz*length;
    end
    return lx, lz;
end
-- Arguments
-- integer	refNode	id of ref node
-- float	x	world x 1
-- float	y	world y 1
-- float	z	world z 1
-- float	x2	world x 2
-- float	y2	world y 2
-- float	z2	world z 2
-- Return Values
-- float	lx	average x direction
-- float	lz	average z direction
-- Code
function AIVehicleUtil.getAverageDriveDirection(refNode, x, y, z, x2, y2, z2)
    local lx, _, lz = worldToLocal(refNode, (x+x2)*0.5, (y+y2)*0.5, (z+z2)*0.5);

    local length = Utils.vector2Length(lx, lz);
    if length > 0.00001 then
        lx = lx/length;
        lz = lz/length;
    end
    return lx, lz, length;
end
-- Arguments
-- table	vehicle	vehicle to check
-- Return Values
-- boolean	isAttached	is attached
-- Code
function AIVehicleUtil.getIsTrailerOrTrailerLowAttached(vehicle)
    for _,implement in pairs(vehicle.attachedImplements) do
        if implement.object ~= nil then
            local jointDesc = implement.object.attacherVehicle.attacherJoints[implement.jointDescIndex];
            if jointDesc.jointType == AttacherJoints.JOINTTYPE_TRAILER or jointDesc.jointType == AttacherJoints.JOINTTYPE_TRAILERLOW then
                return true;
            end
            if AIVehicleUtil.getIsTrailerOrTrailerLowAttached(implement.object) then
                return true;
            end
        end
    end
    return false;
end
-- Arguments
-- table	vehicle	vehicle to check
-- Return Values
-- integer	aiToolReverserDirectionNode	reverser direction node of ai tool
-- Code
function AIVehicleUtil.getAIToolReverserDirectionNode(vehicle)
    for _,implement in pairs(vehicle.attachedImplements) do
        if implement.object ~= nil then
            if AIVehicleUtil.getAIToolReverserDirectionNode(implement.object) ~= nil then
                if implement.object.aiToolReverserDirectionNode ~= nil then
                    return nil;
                end
            end
            if implement.object.aiToolReverserDirectionNode ~= nil then
                return implement.object.aiToolReverserDirectionNode;
            end
        end
    end
end
-- Arguments
-- table	implement	implement to check
-- Return Values
-- float	maxTurnRadius	max turn radius
-- Code
function AIVehicleUtil.getMaxToolRadius(implement)

    local radius = 0;

    if implement.object.aiTurningRadiusLimitation ~= nil then
        if implement.object.aiTurningRadiusLimitation.radius ~= nil then
            return implement.object.aiTurningRadiusLimitation.radius;
        end
    end

    if implement.object.aiTurningRadiusLimitation ~= nil and implement.object.aiTurningRadiusLimitation.rotationJoint ~= nil then

        local refNode = implement.object.aiTurningRadiusLimitation.rotationJoint;
        -- If the refNode is any attacher joint, we always use the currently used attacher joint
        for _, inputAttacherJoint in pairs(implement.object.inputAttacherJoints) do
            if refNode == inputAttacherJoint.node then
                refNode = implement.object.attacherJoint.node;
                break;
            end
        end

        local rx,_,rz = localToLocal(refNode, implement.object.components[1].node, 0,0,0);

        for _,wheelIndex in pairs(implement.object.aiTurningRadiusLimitation.wheelIndices) do

            -- use first component as cosy?!
            local wheel = implement.object.wheels[wheelIndex+1];
            local nx,_,nz = localToLocal(wheel.repr, implement.object.components[1].node, 0,0,0);

            local x,z = nx-rx, nz-rz;
            local cx,cz = 0,0;

            -- get max rotation
            local rotMax;
            if refNode == implement.object.attacherJoint.node then
                local jointDesc = implement.object.attacherVehicle.attacherJoints[implement.jointDescIndex];
                rotMax = math.max(jointDesc.upperRotLimit[2], jointDesc.lowerRotLimit[2]) * implement.object.attacherJoint.lowerRotLimitScale[2];
            else
                for _,compJoint in pairs(implement.object.componentJoints) do
                    if refNode == compJoint.jointNode then
                        rotMax = compJoint.rotLimit[2];
                        if implement.object.aiVehicleDirectionNode ~= nil then
                            cx,_,cz = localToLocal(implement.object.aiVehicleDirectionNode, refNode, 0,0,0);
                        end
                        break;
                    end
                end
            end

            -- calc turning radius
            local x1 = x*math.cos(rotMax) - z*math.sin(rotMax);
            local z1 = x*math.sin(rotMax) + z*math.cos(rotMax);

            local dx = -z1;
            local dz = x1;
            if wheel.steeringAxleScale ~= 0 and wheel.steeringAxleRotMax ~= 0 then
                local tmpx, tmpz = dx, dz;
                dx = tmpx*math.cos(wheel.steeringAxleRotMax) - tmpz*math.sin(wheel.steeringAxleRotMax);
                dz = tmpx*math.sin(wheel.steeringAxleRotMax) + tmpz*math.cos(wheel.steeringAxleRotMax);
            end

            local hit,f1,f2 = Utils.getLineLineIntersection2D(cx,cz, 1,0, x1,z1, dx,dz);
            if hit then
                radius = math.max(radius, math.abs(f1));
            end

        end

    end

    return radius;
end
-- Arguments
-- table	rootAttacherVehicle	root attacher vehicle
-- table	vehicle	vehicle
-- Code

function AIVehicleUtil.updateInvertLeftRightMarkers(rootAttacherVehicle, vehicle)
    if vehicle.aiLeftMarker ~= nil and vehicle.aiRightMarker ~= nil then
        local lX, _, _ = localToLocal(vehicle.aiLeftMarker, rootAttacherVehicle.aiVehicleDirectionNode, 0,0,0);
        local rX, _, _ = localToLocal(vehicle.aiRightMarker, rootAttacherVehicle.aiVehicleDirectionNode, 0,0,0);
        if rX > lX then
            vehicle.aiLeftMarker, vehicle.aiRightMarker = vehicle.aiRightMarker, vehicle.aiLeftMarker;
        end
    end
end
-- invertsMarkerOnTurn
-- Description
-- 
-- 	Returns if ai markers should be turned on turn
-- 
-- Definition
-- 
-- 	invertsMarkerOnTurn(table vehicle, boolean turnLeft)
-- 
-- Arguments
-- table	vehicle	vehicle
-- boolean	turnLeft	turn left
-- Return Values
-- 		
-- getValidityOfTurnDirections
-- Description
-- 
-- 	Checks fruits on left and right side of vehicle to decide the turn direction
-- 
-- Arguments
-- table	vehicle	vehicle to check
-- float	checkFrontDistance	distance to check in front of vehicle
-- Return Values
-- float	leftAreaPercentage	left area percentage
-- float	rightAreaPercentage	right area percentage
-- Code
function AIVehicleUtil.getValidityOfTurnDirections(vehicle, checkFrontDistance, turnData)
    -- let's check the area at/around the marker which is farest behind of vehicle

    checkFrontDistance = 5;

    local leftAreaPercentage = 0;
    local rightAreaPercentage = 0;

    local minZ = math.huge;
    local maxZ = -math.huge;
    for _,implement in pairs(vehicle.aiImplementList) do
        local _,_,zl = localToLocal(implement.object.aiLeftMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
        local _,_,zr = localToLocal(implement.object.aiRightMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
        local _,_,zb = localToLocal(implement.object.aiBackMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
        minZ = math.min(minZ, zl, zr, zb);
        maxZ = math.max(maxZ, zl, zr, zb);
    end

    local sideDistance;
    if turnData == nil then
        local minAreaWidth = math.huge;
        for _,implement in pairs(vehicle.aiImplementList) do
            local lx, _, _ = localToLocal(implement.object.aiLeftMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
            local rx, _, _ = localToLocal(implement.object.aiRightMarker, vehicle.aiVehicleDirectionNode, 0,0,0)
            minAreaWidth = math.min(minAreaWidth, math.abs(lx-rx));
        end
        sideDistance = minAreaWidth;
    else
        sideDistance = math.abs(turnData.sideOffsetRight - turnData.sideOffsetLeft);
    end
    --checkFrontDistance = math.max(checkFrontDistance, maxAreaWidth);

    local dx, dz = vehicle.aiDriveDirection[1], vehicle.aiDriveDirection[2];
    local sx, sz = -dz, dx;

    for _,implement in pairs(vehicle.aiImplementList) do
        local lx, ly, lz = localToLocal(implement.object.aiLeftMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
        local rx, ry, rz = localToLocal(implement.object.aiRightMarker, vehicle.aiVehicleDirectionNode, 0,0,0);

        local width = math.abs(lx-rx);
        local length = checkFrontDistance + (maxZ - minZ) + math.max(sideDistance*1.3 + 2, checkFrontDistance); -- 1.3~tan(53) allows detecting back along a field side with angle 53 (and 2m extra compensates for some variances, or higher angles with small tools)

        lx, ly, lz = localToWorld(vehicle.aiVehicleDirectionNode, lx,ly,maxZ + checkFrontDistance);
        rx, ry, rz = localToWorld(vehicle.aiVehicleDirectionNode, rx,ry,maxZ + checkFrontDistance);


        local lSX = lx;
        local lSZ = lz;
        local lWX = lSX - sx * width;
        local lWZ = lSZ - sz * width;
        local lHX = lSX - dx * length;
        local lHZ = lSZ - dz * length;

        local rSX = rx;
        local rSZ = rz;
        local rWX = rSX + sx * width;
        local rWZ = rSZ + sz * width;
        local rHX = rSX - dx * length;
        local rHZ = rSZ - dz * length;

        local lArea, lTotal = AIVehicleUtil.getAIAreaOfVehicle(implement.object, lSX,lSZ, lWX,lWZ, lHX,lHZ, false);
        local rArea, rTotal = AIVehicleUtil.getAIAreaOfVehicle(implement.object, rSX,rSZ, rWX,rWZ, rHX,rHZ, false);

        --leftAreaPercentage = math.max(leftAreaPercentage, (lArea / lTotal));
        --rightAreaPercentage = math.max(rightAreaPercentage, (rArea / rTotal));
        if lTotal > 0 then
            leftAreaPercentage = leftAreaPercentage + (lArea / lTotal);
        end
        if rTotal > 0 then
            rightAreaPercentage = rightAreaPercentage + (rArea / rTotal);
        end

        -- just visual debuging
        if AIVehicle.aiDebugRendering then
            local lSY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lSX,0,lSZ)+2;
            local lWY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lWX,0,lWZ)+2;
            local lHY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lHX,0,lHZ)+2;
            local rSY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rSX,0,rSZ)+2;
            local rWY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rWX,0,rWZ)+2;
            local rHY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rHX,0,rHZ)+2;
            table.insert(vehicle.debugLines, { s={lSX,lSY,lSZ}, e={lWX,lWY,lWZ}, c={0.5, 0.5, 0.5} });
            table.insert(vehicle.debugLines, { s={lSX,lSY,lSZ}, e={lHX,lHY,lHZ}, c={0.5, 0.5, 0.5} });
            table.insert(vehicle.debugLines, { s={rSX,rSY,rSZ}, e={rWX,rWY,rWZ}, c={0.5, 0.5, 0.5} });
            table.insert(vehicle.debugLines, { s={rSX,rSY,rSZ}, e={rHX,rHY,rHZ}, c={0.5, 0.5, 0.5} });
        end
    end

    leftAreaPercentage = leftAreaPercentage / table.getn(vehicle.aiImplementList);
    rightAreaPercentage = rightAreaPercentage / table.getn(vehicle.aiImplementList);
    --print(" ==> left/rightAreaPercentage = "..tostring(leftAreaPercentage).." / "..tostring(rightAreaPercentage));

    return leftAreaPercentage, rightAreaPercentage;
end

-- Arguments
-- table	vehicle	vehicle
-- table	implementList	list to fill in vehicles
-- Code
function AIVehicleUtil.getImplementList(vehicle, implementList)
    local validAttacherUsed = false
    if vehicle.attachedImplements ~= nil then
        for _,implement in pairs(vehicle.attachedImplements) do
            if implement.object ~= nil then
                AIVehicleUtil.getImplementList(implement.object, implementList);
                if implement.object.aiLeftMarker ~= nil and implement.object.aiRightMarker ~= nil and implement.object.aiBackMarker ~= nil then
                    -- check if tool is attached with correct attacherJoint
                    if table.getn(implement.object.inputAttacherJoints) > 1 then

                        local usedJointType;
                        local hasCutterOrImplementJoint = false
                        for j,inputAttacherJoint in pairs (implement.object.inputAttacherJoints) do
                            local joinType = inputAttacherJoint.jointType;
                            if implement.object.inputAttacherJointDescIndex == j then
                                usedJointType = jointType;
                            end
                            if jointType == AttacherJoints.JOINTTYPE_CUTTER or jointType == AttacherJoints.JOINTTYPE_CUTTERHARVESTER or jointType == AttacherJoints.JOINTTYPE_IMPLEMENT then
                                hasCutterOrImplementJoint = true;
                            end
                        end
                        -- If the tool has cutter or implement attacher joint, it needs to be attached to this attacher joint (e.g. a cutter with a trailer attacher)
                        if not hasCutterOrImplementJoint or (usedJointType == AttacherJoints.JOINTTYPE_CUTTER or usedJointType == AttacherJoints.JOINTTYPE_CUTTERHARVESTER or usedJointType == AttacherJoints.JOINTTYPE_IMPLEMENT) then
                            table.insert(implementList, implement);
                        end
                    else
                        table.insert(implementList, implement);
                    end
                end
            end
        end
    end
end



















-- 
-- Arguments
-- table	vehicle	vehicle to check
-- float	lookAheadDist	look a head distance
-- float	lookAheadSize	look a head size
-- getAIAreaOfVehicle
-- Description
-- 
-- 	Returns amount of fruit to work for ai vehicle is in given area
-- 
-- Definition
-- 
-- 	getAIAreaOfVehicle(table vehicle, float startWorldX, float startWorldZ, float widthWorldX, float widthWorldZ, float heightWorldX, float heightWorldZ)
-- 
-- Arguments
-- table	vehicle	vehicle
-- float	startWorldX	start world x
-- float	startWorldZ	start world z
-- float	widthWorldX	width world x
-- float	widthWorldZ	width world z
-- float	heightWorldX	height world x
-- float	heightWorldZ	height world z
-- Return Values
-- float	area	area found
-- float	totalArea	total area checked
-- Code
function AIVehicleUtil.getAIAreaOfVehicle(vehicle, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, ignoreProhibitedValues)
    local terrainDetailRequiredValueRanges  = vehicle.terrainDetailRequiredValueRanges;
    local terrainDetailProhibitValueRanges  = vehicle.terrainDetailProhibitValueRanges;
    local requiredFruitType                 = vehicle.aiRequiredFruitType;
    local requiredMinGrowthState            = vehicle.aiRequiredMinGrowthState;
    local requiredMaxGrowthState            = vehicle.aiRequiredMaxGrowthState;
    local requiredFruitType2                = vehicle.aiRequiredFruitType2;
    local requiredMinGrowthState2           = vehicle.aiRequiredMinGrowthState2;
    local requiredMaxGrowthState2           = vehicle.aiRequiredMaxGrowthState2;
    local prohibitedFruitType               = vehicle.aiProhibitedFruitType;
    local prohibitedMinGrowthState          = vehicle.aiProhibitedMinGrowthState;
    local prohibitedMaxGrowthState          = vehicle.aiProhibitedMaxGrowthState;
    local useWindrowed                      = vehicle.aiUseWindrowFruitType;
    local useDensityHeightMap               = vehicle.aiUseDensityHeightMap;
    if ignoreProhibitedValues then
        terrainDetailProhibitValueRanges = {};
        prohibitedFruitType = FruitUtil.FRUITTYPE_UNKNOWN;
        prohibitedMinGrowthState = nil;
        prohibitedMaxGrowthState = nil;
    end

    if not useDensityHeightMap then
        if vehicle.fruitTypes == nil then       -- no cutter
            local area, totalArea = AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, requiredMinGrowthState, requiredMaxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed, requiredFruitType2, requiredMinGrowthState2, requiredMaxGrowthState2);
            return area, totalArea;
        else
            -- cutter
            local area, totalArea = 0, 0;

            local fruitTypesToUse = vehicle.fruitTypes;
            if vehicle.currentInputFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
                fruitTypesToUse = {};
                fruitTypesToUse[vehicle.currentInputFruitType] = true;
            end
            for index,_ in pairs(fruitTypesToUse) do

                local desc = FruitUtil.fruitIndexToDesc[index];
                local isAllowed = true;

                if vehicle.getCombine ~= nil then
                    local combine = vehicle:getCombine();
                    if combine ~= nil then
                        if vehicle.fillTypeConverters ~= nil and vehicle.fillTypeConverters[index] ~= nil then
                            isAllowed = combine:allowFillType(vehicle.fillTypeConverters[index].fillTypeTarget, false);
                        else
                            isAllowed = combine:allowFillType(FruitUtil.fruitTypeToFillType[index], false);
                        end
                    end
                end

                if isAllowed then
                    requiredFruitType = index;
                    local minGrowthState, maxGrowthState, minGrowthState2, maxGrowthState2;
                    if vehicle.fruitPreparer ~= nil and vehicle.fruitPreparer.fruitType ~= nil then
                        minGrowthState = Utils.getNoNil(requiredMinGrowthState, desc.minPreparingGrowthState);
                        maxGrowthState = Utils.getNoNil(requiredMaxGrowthState, desc.maxPreparingGrowthState);

                        requiredFruitType2 = requiredFruitType
                        minGrowthState2 = Utils.getNoNil(requiredMinGrowthState2, desc.minHarvestingGrowthState);
                        maxGrowthState2 = Utils.getNoNil(requiredMaxGrowthState2, desc.maxHarvestingGrowthState);
                        if vehicle.allowsForageGrowhtState then
                            minGrowthState2 = math.min(minGrowthState2, desc.minForageGrowthState);
                        end
                    else
                        minGrowthState = Utils.getNoNil(requiredMinGrowthState, desc.minHarvestingGrowthState);
                        maxGrowthState = Utils.getNoNil(requiredMaxGrowthState, desc.maxHarvestingGrowthState);
                        if vehicle.allowsForageGrowhtState then
                            minGrowthState = math.min(minGrowthState, desc.minForageGrowthState);
                        end
                    end
                    area, totalArea = AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, minGrowthState, maxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed, requiredFruitType2, minGrowthState2, maxGrowthState2);
                end

                if area > 0 then
                    break;
                end
            end
            return area, totalArea;
        end
    else
        -- first check if we are on a field
        local detailId = g_currentMission.terrainDetailId;
        local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);

        setDensityCompareParams(detailId, "greater", 0);
        local _,area,_ = getDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels);
        setDensityCompareParams(detailId, "greater", -1);
        if area == 0 then
            return 0, 0;
        end

        if requiredFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
            local fillType;
            if useWindrowed then
                fillType = FruitUtil.fruitTypeToWindrowFillType[requiredFruitType];
            else
                fillType = FruitUtil.fruitTypeToFillType[requiredFruitType];
            end
            local _, area, totalArea = TipUtil.getFillLevelAtArea(fillType, startWorldX,startWorldZ, widthWorldX,widthWorldZ, heightWorldX,heightWorldZ);
            return area, totalArea;
        else
            if useWindrowed then
                for _,desc in pairs(FruitUtil.fruitTypes) do
                    if desc.hasWindrow then
                        local fillType = FruitUtil.fruitTypeToWindrowFillType[desc.index];
                        local fillLevel, area, totalArea = TipUtil.getFillLevelAtArea(fillType, startWorldX,startWorldZ, widthWorldX,widthWorldZ, heightWorldX,heightWorldZ);
                        if fillLevel > 0 then
                            return area, totalArea;
                        end
                    end
                end
            end
        end
    end
    return 0, 0;
end
-- Arguments
-- float	startWorldX	start world x
-- float	startWorldZ	start world z
-- float	widthWorldX	width world x
-- float	widthWorldZ	width world z
-- float	heightWorldX	height world x
-- float	heightWorldZ	height world z
-- table	terraindetailrequiredvalueranges	terrain detail required value ranges
-- table	terraindetailprohibitvalueranges	terrain detail prohibit value ranges
-- integer	requiredfruittype	required fruit type
-- integer	requiredmingrowthstate	required min growth state
-- integer	requiredmaxgrowthstate	required max growth state
-- integer	prohibitedfruittype	prohibited fruit type
-- integer	prohibitedmingrowthstate	prohibited min growth state
-- integer	prohibitedmaxgrowthstate	prohibited max growth state
-- boolean	usewindrowed	use windrow
-- Return Values
-- float	area	area found
-- float	totalArea	total area checked
-- Code
function AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, requiredMinGrowthState, requiredMaxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed, requiredFruitType2, requiredMinGrowthState2, requiredMaxGrowthState2)

    local query = g_currentMission.fieldCropsQuery;

    if requiredFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
        local ids = g_currentMission.fruits[requiredFruitType];
        if ids ~= nil and ids.id ~= 0 then
            local id = ids.id;
            if useWindrowed then
                return 0, 1;
            end

            query:addRequiredCropType(ids.id, requiredMinGrowthState+1, requiredMaxGrowthState+1, 0, g_currentMission.numFruitStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels);
        end
    end
    if requiredFruitType2 ~= FruitUtil.FRUITTYPE_UNKNOWN and requiredFruitType2 ~= nil then
        local ids = g_currentMission.fruits[requiredFruitType2];
        if ids ~= nil and ids.id ~= 0 then
            local id = ids.id;
            if useWindrowed then
                return 0, 1;
            end

            query:addRequiredCropType(ids.id, requiredMinGrowthState2+1, requiredMaxGrowthState2+1, 0, g_currentMission.numFruitStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels);
        end
    end
    if prohibitedFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
        local ids = g_currentMission.fruits[prohibitedFruitType];
        if ids ~= nil and ids.id ~= 0 then
            query:addProhibitedCropType(ids.id, prohibitedMinGrowthState+1, prohibitedMaxGrowthState+1, 0, g_currentMission.numFruitStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels);
        end
    end

    for _,valueRange in pairs(terrainDetailRequiredValueRanges) do
        query:addRequiredGroundValue(valueRange[1], valueRange[2], valueRange[3], valueRange[4]);
    end
    for _,valueRange in pairs(terrainDetailProhibitValueRanges) do
        query:addProhibitedGroundValue(valueRange[1], valueRange[2], valueRange[3], valueRange[4]);
    end
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    return query:getParallelogram(x,z, widthX,widthZ, heightX,heightZ, true);
end