-- AIVehicleUtil
-- Description
-- 
-- 	Util class for various ai vehicle functions
-- 
-- Functions
-- 
-- 	driveToPoint
-- 	driveInDirection
-- 	getDriveDirection
-- 	getAverageDriveDirection
-- 	getIsTrailerOrTrailerLowAttached
-- 	getAIToolReverserDirectionNode
-- 	getMaxToolRadius
-- 	updateInvertLeftRightMarkers
-- 	invertsMarkerOnTurn
-- 	getValidityOfTurnDirections
-- 	getImplementList
-- 	checkImplementListForValidGround
-- 	getAIAreaOfVehicle
-- 	getAIArea

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
			local hit,f1,f2 = Utils.getLineLineIntersection2D(tX_2,tZ_2, d1X,d1Z, 0,0, tX, 0);
			if doNotSteer == nil or not doNotSteer then
				local rotTime = 0;
				local radius = 0;
				if hit and math.abs(f2) < 100000 then
					radius = tX * f2;
					rotTime = 1/self.wheelSteeringDuration * math.atan(1/radius) / math.atan(1/self.maxTurningRadius);
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
				maxSpeed = maxSpeed * math.max( 0.01, 1.0 - math.pow(fac, 0.25));
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
-- driveInDirection
-- Description
-- 
-- 	Drive in given direction
-- 
-- Definition
-- 
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
-- Code
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
-- getDriveDirection
-- Description
-- 
-- 	Returns drive direction
-- 
-- Definition
-- 
-- 	getDriveDirection(integer refNode, float x, float y, float z)
-- 
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
-- getAverageDriveDirection
-- Description
-- 
-- 	Returns average drive direction between 2 given vectors
-- 
-- Definition
-- 
-- 	getAverageDriveDirection(integer refNode, float x, float y, float z, float x2, float y2, float z2)
-- 
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
-- getIsTrailerOrTrailerLowAttached
-- Description
-- 
-- 	Returns if trailer or trailer low is attached
-- 
-- Definition
-- 
-- 	getIsTrailerOrTrailerLowAttached(table vehicle)
-- 
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
-- getAIToolReverserDirectionNode
-- Description
-- 
-- 	Returns reverser direction node of attached ai tool
-- 
-- Definition
-- 
-- 	getAIToolReverserDirectionNode(table vehicle)
-- 
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
-- getMaxToolRadius
-- Description
-- 
-- 	Returns max tool turn radius
-- 
-- Definition
-- 
-- 	getMaxToolRadius(table implement)
-- 
-- Arguments
-- table	implement	implement to check
-- Return Values
-- float	maxTurnRadius	max turn radius
-- Code
function AIVehicleUtil.getMaxToolRadius(implement)
--print(" ------> AIVehicleUtil.getMaxToolRadius("..tostring(implement.object.configFileName));
	local radius = 0;
	if implement.object.aiTurningRadiusLimiation ~= nil then
		if implement.object.aiTurningRadiusLimiation.radius ~= nil then
			return implement.object.aiTurningRadiusLimiation.radius;
		end
	end
	if implement.object.aiTurningRadiusLimiation ~= nil and implement.object.aiTurningRadiusLimiation.rotationJoint ~= nil then
		local refNode = implement.object.aiTurningRadiusLimiation.rotationJoint;
		local rx,ry,rz = localToLocal(refNode, implement.object.components[1].node, 0,0,0);
		for _,wheelIndex in pairs(implement.object.aiTurningRadiusLimiation.wheelIndices) do
			-- use first component as cosy?!
			local wheel = implement.object.wheels[wheelIndex+1];
			local nx,ny,nz = localToLocal(wheel.repr, implement.object.components[1].node, 0,0,0);
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
-- updateInvertLeftRightMarkers
-- Description
-- 
-- 	Update invertation of ai left and right markers on vehicle
-- 
-- Definition
-- 
-- 	updateInvertLeftRightMarkers(table rootAttacherVehicle, table vehicle)
-- 
-- Arguments
-- table	rootAttacherVehicle	root attacher vehicle
-- table	vehicle	vehicle
-- Code
function AIVehicleUtil.updateInvertLeftRightMarkers(rootAttacherVehicle, vehicle)
	if vehicle.aiLeftMarker ~= nil and vehicle.aiRightMarker ~= nil then
		local lX, lY, lZ = localToLocal(vehicle.aiLeftMarker, rootAttacherVehicle.aiVehicleDirectionNode, 0,0,0);
		local rX, rY, rZ = localToLocal(vehicle.aiRightMarker, rootAttacherVehicle.aiVehicleDirectionNode, 0,0,0);
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
-- Definition
-- 
-- 	getValidityOfTurnDirections(table vehicle, float checkFrontDistance)
-- 
-- Arguments
-- table	vehicle	vehicle to check
-- float	checkFrontDistance	distance to check in front of vehicle
-- Return Values
-- float	leftAreaPercentage	left area percentage
-- float	rightAreaPercentage	right area percentage
-- Code
function AIVehicleUtil.getValidityOfTurnDirections(vehicle, checkFrontDistance)
	-- let's check the area at/around the marker which is farest behind of vehicle
	local leftAreaPercentage = 0;
	local rightAreaPercentage = 0;
	local minZ = 0;
	for i,implement in pairs(vehicle.aiImplementList) do
		local x,y,z = localToLocal(implement.object.aiLeftMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
		minZ = math.min(minZ, z);
		local x,y,z = localToLocal(implement.object.aiRightMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
		minZ = math.min(minZ, z);
	end
	local maxAreaWidth = 0;
	local minAreaWidth = math.huge;
	for i,implement in pairs(vehicle.aiImplementList) do
		local lx, ly, lz = localToLocal(implement.object.aiLeftMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
		local rx, ry, rz = localToLocal(implement.object.aiRightMarker, vehicle.aiVehicleDirectionNode, 0,0,0)
		local areaWidth = Utils.vector2Length(lx-rx, lz-rz);
		minAreaWidth = math.min(minAreaWidth, areaWidth);
		maxAreaWidth = math.max(maxAreaWidth, areaWidth);
	end
	local areaWidth = maxAreaWidth;
	local areaLength = maxAreaWidth + math.max(0, checkFrontDistance);
	areaLength = math.max(2*areaLength, areaWidth);
	local dx, dz = vehicle.aiDriveDirection[1], vehicle.aiDriveDirection[2];
	local sx, sz = -dz, dx;
	for i,implement in pairs(vehicle.aiImplementList) do
		local lx, ly, lz = localToLocal(implement.object.aiLeftMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
		local rx, ry, rz = localToLocal(implement.object.aiRightMarker, vehicle.aiVehicleDirectionNode, 0,0,0);
		lz = minZ;
		rz = minZ;
		lx, ly, lz = localToWorld(vehicle.aiVehicleDirectionNode, lx,ly,lz + checkFrontDistance); -- +2);
		rx, ry, rz = localToWorld(vehicle.aiVehicleDirectionNode, rx,ry,rz + checkFrontDistance); -- +2);
		local lSX = lx;
		local lSZ = lz;
		local lWX = lSX - sx * areaWidth;
		local lWZ = lSZ - sz * areaWidth;
		local lHX = lSX - dx * areaLength;
		local lHZ = lSZ - dz * areaLength;
		local rSX = rx;
		local rSZ = rz;
		local rWX = rSX + sx * areaWidth;
		local rWZ = rSZ + sz * areaWidth;
		local rHX = rSX - dx * areaLength;
		local rHZ = rSZ - dz * areaLength;
		local lArea, lTotal = AIVehicleUtil.getAIAreaOfVehicle(implement.object, lSX,lSZ, lWX,lWZ, lHX,lHZ);
		local rArea, rTotal = AIVehicleUtil.getAIAreaOfVehicle(implement.object, rSX,rSZ, rWX,rWZ, rHX,rHZ);
		leftAreaPercentage = math.max(leftAreaPercentage, ( lArea / lTotal ));
		rightAreaPercentage = math.max(rightAreaPercentage, ( rArea / rTotal ));
		-- just visual debuging
		if AIVehicle.aiDebugRendering then
			local lSY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lSX,0,lSZ)+2;
			local lWY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lWX,0,lWZ)+2;
			local lHY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lHX,0,lHZ)+2;
			local rSY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rSX,0,rSZ)+2;
			local rWY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rWX,0,rWZ)+2;
			local rHY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rHX,0,rHZ)+2;
			table.insert(vehicle.debugLines, { s={lSX,lSY,lSZ}, e={lWX,lWY,lWZ}, c={1,0,0} });
			table.insert(vehicle.debugLines, { s={lSX,lSY,lSZ}, e={lHX,lHY,lHZ}, c={1,0,0} });
			table.insert(vehicle.debugLines, { s={rSX,rSY,rSZ}, e={rWX,rWY,rWZ}, c={0,1,0} });
			table.insert(vehicle.debugLines, { s={rSX,rSY,rSZ}, e={rHX,rHY,rHZ}, c={0,1,0} });
		end
	end
	return leftAreaPercentage, rightAreaPercentage;
end
-- getImplementList
-- Description
-- 
-- 	Returns a list with ai implements attached to given vehicle
-- 
-- Definition
-- 
-- 	getImplementList(table vehicle, table implementList)
-- 
-- Arguments
-- table	vehicle	vehicle
-- table	implementList	list to fill in vehicles
-- Code
function AIVehicleUtil.getImplementList(vehicle, implementList)
	if vehicle.attachedImplements ~= nil then
		for i,implement in pairs(vehicle.attachedImplements) do
			if implement.object ~= nil then
				AIVehicleUtil.getImplementList(implement.object, implementList);
				if implement.object.aiLeftMarker ~= nil and implement.object.aiRightMarker ~= nil and implement.object.aiBackMarker ~= nil then
					-- check if tool is attached with correct attacherJoint
					if table.getn(implement.object.inputAttacherJoints) > 1 then
						if not validAttacherUsed then
							for j,inputAttacherJoint in pairs (implement.object.inputAttacherJoints) do
								if inputAttacherJoint.jointType == AttacherJoints.jointTypeNameToInt["cutter"] or
									inputAttacherJoint.jointType == AttacherJoints.jointTypeNameToInt["cutterHarvester"] or
									inputAttacherJoint.jointType == AttacherJoints.jointTypeNameToInt["implement"]
								then
									if implement.object.inputAttacherJointDescIndex == j then
										validAttacherUsed = true;
										break;
									end
								end
							end
						end
						if validAttacherUsed then
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
-- checkImplementListForValidGround
-- Description
-- 
-- 	Returns if valid ground to work on is found for ai vehicle
-- 
-- Definition
-- 
-- 	checkImplementListForValidGround(table vehicle, float lookAheadDist, float lookAheadSize)
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
function AIVehicleUtil.getAIAreaOfVehicle(vehicle, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
	local terrainDetailRequiredValueRanges  = vehicle.terrainDetailRequiredValueRanges;
	local terrainDetailProhibitValueRanges  = vehicle.terrainDetailProhibitValueRanges;
	local requiredFruitType				 = vehicle.aiRequiredFruitType;
	local requiredMinGrowthState			= vehicle.aiRequiredMinGrowthState;
	local requiredMaxGrowthState			= vehicle.aiRequiredMaxGrowthState;
	local prohibitedFruitType			   = vehicle.aiProhibitedFruitType;
	local prohibitedMinGrowthState		  = vehicle.aiProhibitedMinGrowthState;
	local prohibitedMaxGrowthState		  = vehicle.aiProhibitedMaxGrowthState;
	local useWindrowed					  = vehicle.aiUseWindrowFruitType;
	local useDensityHeightMap			   = vehicle.aiUseDensityHeightMap;
	if not useDensityHeightMap then
		if vehicle.fruitTypes == nil then	   -- no cutter
			local area, totalArea = AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, requiredMinGrowthState, requiredMaxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed);
			return area, totalArea;
		else
			-- cutter
			local area, totalArea = 0, 0;
			if requiredFruitType ~= nil and requiredFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
				local desc = FruitUtil.fruitIndexToDesc[requiredFruitType];
				local minGrowthState = Utils.getNoNil(Utils.getNoNil(requiredMinGrowthState, desc.minForageGrowthState), desc.minHarvestingGrowthState);
				local maxGrowthState = Utils.getNoNil(Utils.getNoNil(requiredMaxGrowthState, desc.maxForageGrowthState), desc.maxHarvestingGrowthState);
				area, totalArea = AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, minGrowthState, maxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed);
			end
			if area == 0 then
				for index,state in pairs(vehicle.fruitTypes) do
					local desc = FruitUtil.fruitIndexToDesc[index];
					local isAllowed = true;
					if vehicle.getCombine ~= nil and vehicle.fillTypeConverters ~= nil and vehicle.fillTypeConverters[index] ~= nil then
						local combine = vehicle:getCombine();
						if combine ~= nil then
							isAllowed = combine:allowFillType(vehicle.fillTypeConverters[index].fillTypeTarget, false);
						end
					end
					if isAllowed then
						requiredFruitType = index;
						local minGrowthState = Utils.getNoNil(Utils.getNoNil(requiredMinGrowthState, desc.minForageGrowthState), desc.minHarvestingGrowthState);
						local maxGrowthState = Utils.getNoNil(Utils.getNoNil(requiredMaxGrowthState, desc.maxForageGrowthState), desc.maxHarvestingGrowthState);
						area, totalArea = AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, minGrowthState, maxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed);
					end
					if area > 0 then
						break;
					end
				end
			end
			return area, totalArea;
		end
	else
		-- first check if we are on a field
		local detailId = g_currentMission.terrainDetailId;
		local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
		setDensityCompareParams(detailId, "greater", 0);
		local _,area,totalArea = getDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels);
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
			local fillLevel, area, totalArea = TipUtil.getFillLevelAtArea(fillType, startWorldX,startWorldZ, widthWorldX,widthWorldZ, heightWorldX,heightWorldZ);
			return area, totalArea;
		else
			if useWindrowed then
				for fruitTypeName,desc in pairs(FruitUtil.fruitTypes) do
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
-- getAIArea
-- Description
-- 
-- 	Returns amount of fruit to work is in given area
-- 
-- Definition
-- 
-- 	getAIArea(float startWorldX, float startWorldZ, float widthWorldX, float widthWorldZ, float heightWorldX, float heightWorldZ, table terraindetailrequiredvalueranges, table terraindetailprohibitvalueranges, integer requiredfruittype, integer requiredmingrowthstate, integer requiredmaxgrowthstate, integer prohibitedfruittype, integer prohibitedmingrowthstate, integer prohibitedmaxgrowthstate, boolean usewindrowed)
-- 
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
function AIVehicleUtil.getAIArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, requiredMinGrowthState, requiredMaxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed)
	local area = 0;
	local totalArea = 0;
	local detailId = g_currentMission.terrainDetailId;
	local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
	if table.getn(terrainDetailRequiredValueRanges) > 0 then
		for _,terrainDetailRequiredValueRange in pairs(terrainDetailRequiredValueRanges) do
			setDensityCompareParams(detailId, "between", terrainDetailRequiredValueRange[1], terrainDetailRequiredValueRange[2]);
			local _,requiredArea,totalRequiredArea = getDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, terrainDetailRequiredValueRange[3], terrainDetailRequiredValueRange[4]);
			area = math.max(area, requiredArea);
			totalArea = math.max(totalArea, totalRequiredArea);
			setDensityCompareParams(detailId, "greater", -1);
		end
	end
	if requiredFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
		local ids = g_currentMission.fruits[requiredFruitType];
		if ids ~= nil and ids.id ~= 0 then
			local id = ids.id;
			if useWindrowed then
				return 0, 1;
			end
			setDensityCompareParams(id, "between", requiredMinGrowthState+1, requiredMaxGrowthState+1);
			-- valid only on terrain layer
			local _,requiredArea,totalRequiredArea = getDensityMaskedParallelogram(id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitStateChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels);
			setDensityCompareParams(id, "greater", -1);
			if requiredArea == 0 then
				area = 0;
				totalArea = 1;
			else
				area = math.max(area, requiredArea);
				totalArea = math.max(totalArea, totalRequiredArea);
			end
		end
	end
	if area > 0 then
		if prohibitedFruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
			local ids = g_currentMission.fruits[prohibitedFruitType];
			if ids ~= nil and ids.id ~= 0 then
				setDensityMaskParams(detailId, "between", prohibitedMinGrowthState+1, prohibitedMaxGrowthState+1); -- only fruit outside the given range is allowed
				local _,prohibitedArea,totalProhibitArea = getDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, ids.id, 0, g_currentMission.numFruitStateChannels);
				setDensityMaskParams(detailId, "greater", 0);
				area = area - prohibitedArea;
			end
		end
		if table.getn(terrainDetailProhibitValueRanges) > 0 then
			for _,terrainDetailProhibitValueRange in pairs(terrainDetailProhibitValueRanges) do
				setDensityMaskParams(detailId, "between", terrainDetailProhibitValueRange[1], terrainDetailProhibitValueRange[2]);
				local _,prohibitArea,_ = getDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitStateChannels, detailId, terrainDetailProhibitValueRange[3], terrainDetailProhibitValueRange[4]);
				setDensityMaskParams(detailId, "greater", -1);
				area = area - prohibitArea;
			end
		end
	end
	area = math.max(0, area);
	totalArea = math.max(1, totalArea);
	return area, totalArea;
end
