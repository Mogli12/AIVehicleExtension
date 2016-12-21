
-- AIVehicle
-- Description
-- 
--	 Specialization for AI vehicles
-- 
-- Functions
-- 
--	 prerequisitesPresent
--	 load
--	 postLoad
--	 delete
--	 getSaveAttributesAndNodes
--	 readStream
--	 writeStream
--	 update
--	 updateTick
--	 draw
--	 onEnter
--	 onLeave
--	 onAttachImplement
--	 onDetachImplement
--	 canStartAIVehicle
--	 startAIVehicle
--	 stopAIVehicle
--	 onStartAiVehicle
--	 onStopAiVehicle
--	 getAdditionalAIPrice
--	 getVehicleData
--	 setDriveStrategies
--	 getDeactivateOnLeave
--	 getXMLStatsAttributes
--	 aiRotateRight
--	 aiRotateLeft
--	 consoleCommandToggleDebugRenderingAI

-- prerequisitesPresent
-- Description
-- 
--	 Checks if all prerequisite specializations are loaded
-- 
-- Definition
-- 
--	 prerequisitesPresent(table specializations)
-- 
-- Arguments
-- table	specializations	specializations
-- Return Values
-- boolean	hasPrerequisite	true if all prerequisite specializations are loaded
-- Code
function AIVehicle.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Steerable, specializations);
end
-- load
-- Description
-- 
--	 Called on loading
-- 
-- Definition
-- 
--	 load(table savegame)
-- 
-- Arguments
-- table	savegame	savegame
-- Code
function AIVehicle:load(savegame)
	self.onStartAiVehicle = SpecializationUtil.callSpecializationsFunction("onStartAiVehicle");
	self.onStopAiVehicle = SpecializationUtil.callSpecializationsFunction("onStopAiVehicle");
	self.getAdditionalAIPrice = SpecializationUtil.callSpecializationsFunction("getAdditionalAIPrice");
	self.getDeactivateOnLeave = Utils.overwrittenFunction(self.getDeactivateOnLeave, AIVehicle.getDeactivateOnLeave);
	self.canStartAIVehicle = AIVehicle.canStartAIVehicle;
	self.startAIVehicle = AIVehicle.startAIVehicle;
	self.stopAIVehicle = AIVehicle.stopAIVehicle;
	self.getVehicleData = AIVehicle.getVehicleData;
	self.setDriveStrategies = AIVehicle.setDriveStrategies;
	self.aiVehicleDirectionNode = self.steeringCenterNode;  -- defined and created by ackermann steering
	if self.aiVehicleDirectionNode == nil then
		print("Warning: AIVehicle can't be loaded for "..tostring(self.configFileName)..", because the setup for Ackermann Steering is missing!");
	end
	self.aiIsStarted = false;
	self.isAllowedToDrive = true;
	self.aiImplementList = {};
	self.aiToolsDirtyFlag = true;
	self.driveStrategies = {};
	self.trafficCollisionIgnoreList = {};
	self.didNotMoveTimeout = Utils.getNoNil( getXMLFloat(self.xmlFile, "vehicle.ai.didNotMoveTimeout#value"), 5000);
	if getXMLBool(self.xmlFile, "vehicle.ai.didNotMoveTimeout#deactivated") then
		self.didNotMoveTimeout = math.huge;
	end;
	self.didNotMoveTimer = self.didNotMoveTimeout;
	--
	local aiLightState = Utils.getNoNil( getXMLInt(self.xmlFile, "vehicle.ai.lightState#index"), 3);
	if self.lightStates ~= nil and #self.lightStates > 0 then
		if self.lightStates[aiLightState] == nil then
			aiLightState = 1;
		end
		self.aiLightsTypesMask = 0
		for _, lightType in pairs(self.lightStates[aiLightState]) do
			self.aiLightsTypesMask = bitOR(self.aiLightsTypesMask, 2^lightType);
		end
	end
	-- used for visual debuging
	self.debugTexts = {};
	self.debugLines = {};
	self.debugPoints = {};
	self.pricePerMS = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.ai.pricePerHour"), 2000)/60/60/1000;
	self.isConveyorBelt = hasXMLProperty(self.xmlFile, "vehicle.ai.conveyorBelt");
	if self.isConveyorBelt then
		self.aiConveyorBelt = {};
		self.aiConveyorBelt.minAngle = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.ai.conveyorBelt#minAngle"), 5);
		self.aiConveyorBelt.maxAngle = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.ai.conveyorBelt#maxAngle"), 45);
		self.aiConveyorBelt.stepSize = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.ai.conveyorBelt#stepSize"), 5);
		self.aiConveyorBelt.currentAngle = self.aiConveyorBelt.minAngle;
		self.aiConveyorBelt.speed = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.ai.conveyorBelt#speed"), 1);
		self.aiConveyorBelt.centerWheelIndex = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.ai.conveyorBelt#centerWheelIndex"), 1);
		self.aiConveyorBelt.backWheelIndex = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.ai.conveyorBelt#backWheelIndex"), 2);
	end;
	self.isHired = false;
	self.isHirableBlocked = false;
end
-- postLoad
-- Description
-- 
-- 	Called after loading
-- 
-- Definition
-- 
-- 	postLoad(table savegame)
-- 
-- Arguments
-- table	savegame	savegame
-- Code
function AIVehicle:postLoad(savegame)
	if self.isConveyorBelt then
		if savegame ~= nil and not savegame.resetVehicles then
			self.aiConveyorBelt.currentAngle = Utils.getNoNil(getXMLFloat(savegame.xmlFile, savegame.key.."#currentAngle"), self.aiConveyorBelt.minAngle);
		end
	end;
end
-- delete
-- Description
-- 
-- 	Called on deleting
-- 
-- Definition
-- 
-- 	delete()
-- 
-- Code
function AIVehicle:delete()
	if self.aiIsStarted then
		self:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR);
	end
end
-- getSaveAttributesAndNodes
-- Description
-- 
-- 	Returns attributes and nodes to save
-- 
-- Definition
-- 
-- 	getSaveAttributesAndNodes(table nodeIdent)
-- 
-- Arguments
-- table	nodeIdent	node ident
-- Return Values
-- string	attributes	attributes
-- string	nodes	nodes
-- Code
function AIVehicle:getSaveAttributesAndNodes(nodeIdent)
	local attributes = "";
	local nodes = "";
	if self.isConveyorBelt then
		attributes = 'currentAngle="'..self.aiConveyorBelt.currentAngle..'"';
	end;
	return attributes, nodes;
end;
-- readStream
-- Description
-- 
-- 	Called on client side on join
-- 
-- Definition
-- 
-- 	readStream(integer streamId, integer connection)
-- 
-- Arguments
-- integer	streamId	streamId
-- integer	connection	connection
-- Code
function AIVehicle:readStream(streamId, connection)
	local isHired = streamReadBool(streamId);
	if isHired then
		local helperIndex = streamReadUInt8(streamId)
		self:startAIVehicle(helperIndex, true)
	end
end
-- writeStream
-- Description
-- 
-- 	Called on server side on join
-- 
-- Definition
-- 
-- 	writeStream(integer streamId, integer connection)
-- 
-- Arguments
-- integer	streamId	streamId
-- integer	connection	connection
-- Code
function AIVehicle:writeStream(streamId, connection)
	if streamWriteBool(streamId, self.isHired) then
		streamWriteUInt8(streamId, self.currentHelper.index)
	end
end
-- update
-- Description
-- 
-- 	Called on update
-- 
-- Definition
-- 
-- 	update(float dt)
-- 
-- Arguments
-- float	dt	time since last call in ms
-- Code
function AIVehicle:update(dt)
	local activeForInput = not g_gui:getIsGuiVisible() and not g_currentMission.isPlayerFrozen and self.isEntered;
	if activeForInput and AIVehicle.aiDebugRendering then
		if #self.debugTexts > 0 then
			for i,text in pairs(self.debugTexts) do
				renderText(0.7, 0.92-(0.02*i), 0.02, text);
			end
		end
		if #self.debugLines > 0 then
			for _,l in pairs(self.debugLines) do
				drawDebugLine(l.s[1],l.s[2],l.s[3], l.c[1],l.c[2],l.c[3], l.e[1],l.e[2],l.e[3], l.c[1],l.c[2],l.c[3]);
			end
		end
	end
	if activeForInput then
		if InputBinding.hasEvent(InputBinding.TOGGLE_AI) and not g_currentMission.inGameMessage:getIsVisible() then
			if g_currentMission:getHasPermission("hireAI") then
				if self.aiIsStarted then
					self:stopAIVehicle(AIVehicle.STOP_REASON_USER);
				else
					if self:canStartAIVehicle() then
						self:startAIVehicle(nil, false);
					end
				end
			end
		end
		if self.isConveyorBelt then
			if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA3) and not self.aiIsStarted  then
				self.aiConveyorBelt.currentAngle = self.aiConveyorBelt.currentAngle + self.aiConveyorBelt.stepSize
				if self.aiConveyorBelt.currentAngle > self.aiConveyorBelt.maxAngle then
					self.aiConveyorBelt.currentAngle = self.aiConveyorBelt.minAngle;
				end
			end
		end;
	end
	if self:getIsActive() then
		if self.aiToolsDirtyFlag == true then
			self.aiToolsDirtyFlag = false;
			self:getVehicleData();
		end
	end
	--# only run on server side?
	if not self.isServer then
		return;
	end
	if self.aiIsStarted then
		if self.driveStrategies ~= nil and #self.driveStrategies > 0 then
			for i=1,#self.driveStrategies do
				local driveStrategy = self.driveStrategies[i];
				driveStrategy:update(dt);
			end
		end
	end
	if self.isHired then
		self.forceIsActive = true;
		self.stopMotorOnLeave = false;
		self.steeringEnabled = false;
		-- check light and turn on dependent on daytime
		if self.aiLightsTypesMask ~= nil then
			local dayMinutes = g_currentMission.environment.dayTime/(1000*60);
			local needLights = (dayMinutes > (19*60) or dayMinutes < (6*60));
			if needLights then
				if self.lightsTypesMask ~= self.aiLightsTypesMask then
					self:setLightsTypesMask(self.aiLightsTypesMask);
				end
			else
				if self.lightsTypesMask ~= 0 then
					self:setLightsTypesMask(0);
				end
			end
		end
	end;
end
-- updateTick
-- Description
-- 
-- 	Called on update tick
-- 
-- Definition
-- 
-- 	updateTick(float dt)
-- 
-- Arguments
-- float	dt	time since last call in ms
-- Code
function AIVehicle:updateTick(dt)
	--# only run on server side?
	if not self.isServer then
		return;
	end
	if self.isHired and self.isServer and not self.isHirableBlocked then
		local difficultyMultiplier = g_currentMission.missionInfo.buyPriceMultiplier;
		g_currentMission:addSharedMoney(-dt*difficultyMultiplier*self.pricePerMS, "wagePayment");
		g_currentMission:addMoneyChange(-dt*difficultyMultiplier*self.pricePerMS, FSBaseMission.MONEY_TYPE_AI)
	end;
	self.debugTexts = {};
	self.debugLines = {};
	if self.aiIsStarted then
		if self.driveStrategies ~= nil and #self.driveStrategies > 0 then
			local vX,vY,vZ = getWorldTranslation(self.aiVehicleDirectionNode);
			local tX, tZ, moveForwards, maxSpeed, distanceToStop;
			for i=1,#self.driveStrategies do
				local driveStrategy = self.driveStrategies[i];
				tX, tZ, moveForwards, maxSpeed, distanceToStop = driveStrategy:getDriveData(dt, vX,vY,vZ)
				if tX ~= nil or not self.aiIsStarted then
					break;
				end
			end
			if tX == nil then
				if self.aiIsStarted then -- check if AI is till active, because it might have been kicked by a strategy
					self:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR);
				end
				return;
			end
			local lx, lz = AIVehicleUtil.getDriveDirection(self.aiVehicleDirectionNode, tX, vY, tZ);
			if not moveForwards then
				lx, lz = -lx, -lz;
			end
			local acceleration = 1.0;
			local minimumSpeed = 5;
			local lookAheadDistance = 5;
			local distSpeed = math.max(minimumSpeed, maxSpeed * math.min(1, distanceToStop/lookAheadDistance));
			local speedLimit, doCheckSpeedLimit = self:getSpeedLimit();
			maxSpeed = math.min(maxSpeed, distSpeed, speedLimit);
			maxSpeed = math.min(maxSpeed, self.cruiseControl.speed);
			self.isAllowedToDrive = maxSpeed ~= 0;
			local pX,pY,pZ = worldToLocal(self.aiVehicleDirectionNode, tX,vY,tZ);
			if not moveForwards and self.articulatedAxis ~= nil then
				if self.articulatedAxis.aiRevereserNode ~= nil then
					pX,pY,pZ = worldToLocal(self.articulatedAxis.aiRevereserNode, tX,vY,tZ);
				end
			end
			local doNotSteer = nil;
			if self.isConveyorBelt then
				doNotSteer = true;
			end;
			AIVehicleUtil.driveToPoint(self, dt, acceleration, self.isAllowedToDrive, moveForwards, pX, pZ, maxSpeed, doNotSteer);
			-- worst case check: did not move but should have moved
			if self.isAllowedToDrive and self:getLastSpeed() < 0.5 then
				self.didNotMoveTimer = self.didNotMoveTimer - dt;
			else
				self.didNotMoveTimer = self.didNotMoveTimeout;
			end
			if self.didNotMoveTimer < 0 then
				self:stopAIVehicle(AIVehicle.STOP_REASON_BLOCKED_BY_OBJECT);
			end
		end
	end
end
-- draw
-- Description
-- 
-- 	Called on draw
-- 
-- Definition
-- 
-- 	draw()
-- 
-- Code
function AIVehicle:draw()
	if g_currentMission:getHasPermission("hireAI") then
		if self.aiIsStarted then
			g_currentMission:addHelpButtonText(g_i18n:getText("action_dismissEmployee"), InputBinding.TOGGLE_AI, nil, GS_PRIO_HIGH);
		else
			if self:canStartAIVehicle() then
				g_currentMission:addHelpButtonText(g_i18n:getText("action_hireEmployee"), InputBinding.TOGGLE_AI, nil, GS_PRIO_HIGH);
			end
		end
	end
	if self.isConveyorBelt then
		if self:getIsActiveForInput(true) and not self.aiIsStarted then
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("action_conveyorBeltChangeAngle"), string.format("%.0f", self.aiConveyorBelt.currentAngle)), InputBinding.IMPLEMENT_EXTRA3, nil, GS_PRIO_NORMAL);
		end
	end;
	--
	if not self.isServer then
		return;
	end
	if self.aiIsStarted then
		if self.driveStrategies ~= nil and #self.driveStrategies > 0 then
			for i=1,#self.driveStrategies do
				local driveStrategy = self.driveStrategies[i];
				if driveStrategy.draw ~= nil then
					driveStrategy:draw();
				end
			end
		end
	end
end
-- onEnter
-- Description
-- 
-- 	Called on enter vehicle
-- 
-- Definition
-- 
-- 	onEnter(boolean isControlling)
-- 
-- Arguments
-- boolean	isControlling	is player controlling the vehicle
-- Code
function AIVehicle:onEnter(isControlling)
	if self.mapAIHotspot ~= nil then
		self.mapAIHotspot.enabled = false;
	end
end
-- onLeave
-- Description
-- 
-- 	Called on leaving the vehicle
-- 
-- Definition
-- 
-- 	onLeave()
-- 
-- Code
function AIVehicle:onLeave()
	if self.mapAIHotspot ~= nil then
		self.mapAIHotspot.enabled = true;
	end
	if self.isHired and self.vehicleCharacter ~= nil then
		self.vehicleCharacter:setCharacterVisibility(true);
	end
end
-- onAttachImplement
-- Description
-- 
-- 	Called on attaching a implement
-- 
-- Definition
-- 
-- 	onAttachImplement(table implement)
-- 
-- Arguments
-- table	implement	implement to attach
-- Code
function AIVehicle:onAttachImplement(implement)
	self.aiToolsDirtyFlag = true;
end
-- onDetachImplement
-- Description
-- 
-- 	Called on detaching a implement
-- 
-- Definition
-- 
-- 	onDetachImplement(integer implementIndex)
-- 
-- Arguments
-- integer	implementIndex	index of implement to detach
-- Code
function AIVehicle:onDetachImplement(implementIndex)
	self.aiToolsDirtyFlag = true;
end
-- canStartAIVehicle
-- Description
-- 
-- 	Returns true if ai can start
-- 
-- Definition
-- 
-- 	canStartAIVehicle()
-- 
-- Return Values
-- boolean	canStart	can start ai
-- Code
function AIVehicle:canStartAIVehicle()
	-- check if reverse driving is available and used, we do not allow the AI to work when reverse driving is enabled
	if self.isReverseDriving ~= nil then
		if self.isReverseDriving or self.isChangingDirection then
			return false;
		end
	end
	if self.aiVehicleDirectionNode == nil then
		return false;
	end
	if g_currentMission.disableAIVehicle then
		return false;
	end
	if AIVehicle.numHirablesHired >= g_currentMission.maxNumHirables then
		return false;
	end
	if not self.isMotorStarted then
		return false;
	end
	if self.isConveyorBelt then
		return true;
	end;
	if self.aiImplementList ~= nil and #self.aiImplementList > 0 then
		return true;
	else
		return false;
	end
end
-- startAIVehicle
-- Description
-- 
-- 	Starts ai vehicle
-- 
-- Definition
-- 
-- 	startAIVehicle(integer helperIndex, boolean noEventSend)
-- 
-- Arguments
-- integer	helperIndex	index of hired helper
-- boolean	noEventSend	no event send
-- Code
function AIVehicle:startAIVehicle(helperIndex, noEventSend)
	if helperIndex ~= nil then
		self.currentHelper = HelperUtil.helperIndexToDesc[helperIndex]
	else
		self.currentHelper = HelperUtil.getRandomHelper()
	end
	HelperUtil.useHelper(self.currentHelper)
	g_currentMission.missionStats:updateStats("workersHired", 1);
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(AIVehicleSetStartedEvent:new(self, nil, true, self.currentHelper), nil, nil, self);
		else
			g_client:getServerConnection():sendEvent(AIVehicleSetStartedEvent:new(self, nil, true, self.currentHelper));
		end
	end
	self:onStartAiVehicle();
end
-- stopAIVehicle
-- Description
-- 
-- 	Stops ai vehicle
-- 
-- Definition
-- 
-- 	stopAIVehicle(integer reason, boolean noEventSend)
-- 
-- Arguments
-- integer	reason	reason
-- boolean	noEventSend	no event send
-- Code
function AIVehicle:stopAIVehicle(reason, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(AIVehicleSetStartedEvent:new(self, reason, false), nil, nil, self);
		else
			g_client:getServerConnection():sendEvent(AIVehicleSetStartedEvent:new(self, reason, false));
		end
	end
	if reason ~= nil and reason ~= AIVehicle.STOP_REASON_USER then
		local notificationType = FSBaseMission.INGAME_NOTIFICATION_CRITICAL
		if reason == AIVehicle.STOP_REASON_REGULAR then
			notificationType = FSBaseMission.INGAME_NOTIFICATION_OK
		end
		g_currentMission:addIngameNotification(notificationType, string.format(g_i18n:getText(AIVehicle.REASON_TEXT_MAPPING[reason]), self.currentHelper.name))
	end
	HelperUtil.releaseHelper(self.currentHelper)
	g_currentMission.missionStats:updateStats("workersHired", -1);
	self:onStopAiVehicle();
end
-- onStartAiVehicle
-- Description
-- 
-- 	Called on start ai vehicle
-- 
-- Definition
-- 
-- 	onStartAiVehicle()
-- 
-- Code
function AIVehicle:onStartAiVehicle()
	if not self.aiIsStarted then
		if not self.isHired then
			AIVehicle.numHirablesHired = AIVehicle.numHirablesHired + 1;
		end;
		self.isHired = true;
		self.isHirableBlocked = false;
		self.forceIsActive = true;
		self.stopMotorOnLeave = false;
		self.steeringEnabled = false;
		self.disableCharacterOnLeave = false;
		if self.vehicleCharacter ~= nil then
		   self.vehicleCharacter:delete();
		   self.vehicleCharacter:loadCharacter(self.currentHelper.xmlFilename, getUserRandomizedMpColor(self.currentHelper.name))
		   if self.isEntered then
				self.vehicleCharacter:setCharacterVisibility(false)
		   end
		end
		local hotspotX, _, hotspotZ = getWorldTranslation(self.rootNode);
		local _, textSize = getNormalizedScreenValues(0, 6);
		local _, textOffsetY = getNormalizedScreenValues(0, 11.5);
		local width, height = getNormalizedScreenValues(15,15)
		self.mapAIHotspot = g_currentMission.ingameMap:createMapHotspot("helper", self.currentHelper.name, nil, getNormalizedUVs({776, 520, 240, 240}), {0.052, 0.1248, 0.672, 1}, hotspotX, hotspotZ, width, height, false, false, true, self.components[1].node, true, MapHotspot.CATEGORY_AI, textSize, textOffsetY, {1, 1, 1, 1}, nil, getNormalizedUVs({776, 520, 240, 240}), Overlay.ALIGN_VERTICAL_MIDDLE, 0.7)
		self.aiIsStarted = true;
		if self.isServer then
			self:getVehicleData();
			self:setDriveStrategies();
		end
		self:aiTurnOn();
		for _,implement in pairs(self.aiImplementList) do
			implement.object:aiTurnOn();
		end
	end
end
-- onStopAiVehicle
-- Description
-- 
-- 	Called on stop ai vehicle
-- 
-- Definition
-- 
-- 	onStopAiVehicle()
-- 
-- Code
function AIVehicle:onStopAiVehicle()
	if self.aiIsStarted then
		if self.isHired then
			AIVehicle.numHirablesHired = math.max(AIVehicle.numHirablesHired - 1, 0);
		end;
		self.isHired = false;
		self.forceIsActive = false;
		self.stopMotorOnLeave = true;
		self.steeringEnabled = true;
		self.disableCharacterOnLeave = true;
		if self.vehicleCharacter ~= nil then
		   self.vehicleCharacter:delete();
		end
		if self.isEntered or self.isControlled then
			if self.vehicleCharacter ~= nil then
				self.vehicleCharacter:loadCharacter(PlayerUtil.playerIndexToDesc[self.playerIndex].xmlFilename, self.playerColorIndex)
				self.vehicleCharacter:setCharacterVisibility(not self.isEntered)
			end
		end;
		self.currentHelper = nil
		if self.mapAIHotspot ~= nil then
			g_currentMission.ingameMap:deleteMapHotspot(self.mapAIHotspot);
			self.mapAIHotspot = nil;
		end
		self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_OFF, true);
		if self.isServer then
			WheelsUtil.updateWheelsPhysics(self, 0, self.lastSpeedReal, 0, true, self.requiredDriveMode);
		end
		if not g_currentMission.missionInfo.automaticMotorStartEnabled and not self.isEntered then
			self:stopMotor(true);
		end
		if self.isServer then
			if self.driveStrategies ~= nil and #self.driveStrategies > 0 then
				for i=#self.driveStrategies,1,-1 do
					self.driveStrategies[i]:delete();
					table.remove(self.driveStrategies, i);
				end
				self.driveStrategies = {};
			end
		end
		self:aiTurnOff();
		for _,implement in pairs(self.aiImplementList) do
			if implement.object ~= nil then
				implement.object:aiTurnOff();
			end;
		end
		self.aiIsStarted = false;
	end
end
-- getAdditionalAIPrice
-- Description
-- 
-- 	Returns additional ai price
-- 
-- Definition
-- 
-- 	getAdditionalAIPrice()
-- 
-- Return Values
-- float	price	additional price
-- Code
function AIVehicle:getAdditionalAIPrice()
	return 0;
end
-- getVehicleData
-- Description
-- 
-- 	Fills aiImplementList with vehicles to use by ai
-- 
-- Definition
-- 
-- 	getVehicleData()
-- 
-- Code
function AIVehicle:getVehicleData()
	self.aiImplementList = {};
	if self.aiLeftMarker ~= nil and self.aiRightMarker ~= nil and self.aiBackMarker ~= nil then
		table.insert(self.aiImplementList, {object=self});
	end
	AIVehicleUtil.getImplementList(self, self.aiImplementList);
	--# check type and relative position of implement
	if self.aiImplementList ~= nil then
		for i,implement in pairs(self.aiImplementList) do
			if implement.object.attacherVehicle ~= nil then
				local jointDesc = implement.object.attacherVehicle.attacherJoints[implement.jointDescIndex];
				if jointDesc.rotationNode ~= nil then
					implement.isTool = true;
				else
					implement.isTool = false;
				end
			else
				implement.isTool = true;
			end
		end
	end
end
-- setDriveStrategies
-- Description
-- 
-- 	Set drive strategies depending on the vehicle
-- 
-- Definition
-- 
-- 	setDriveStrategies()
-- 
-- Code
function AIVehicle:setDriveStrategies()
	if self.aiImplementList ~= nil and #self.aiImplementList > 0 then
		if self.driveStrategies ~= nil and #self.driveStrategies > 0 then
			for i=#self.driveStrategies,1,-1 do
				self.driveStrategies[i]:delete();
				table.remove(self.driveStrategies, i);
			end
			self.driveStrategies = {};
		end
		local foundCombine = false;
		for i,implement in pairs(self.aiImplementList) do
			if SpecializationUtil.hasSpecialization(Combine, implement.object.specializations) then
				foundCombine = true;
				break;
			end
		end
		foundCombine = foundCombine or SpecializationUtil.hasSpecialization(Combine, self.specializations);
		if foundCombine then
			local driveStrategyCombine = AIDriveStrategyCombine:new();
			driveStrategyCombine:setAIVehicle(self);
			table.insert(self.driveStrategies, driveStrategyCombine);
		end
		local driveStrategyCollision = AIDriveStrategyCollision:new();
		local driveStrategyStraight = AIDriveStrategyStraight:new();
		driveStrategyCollision:setAIVehicle(self);
		driveStrategyStraight:setAIVehicle(self);
		table.insert(self.driveStrategies, driveStrategyCollision);
		table.insert(self.driveStrategies, driveStrategyStraight);
	end
	if self.isConveyorBelt then
		if self.driveStrategies ~= nil and #self.driveStrategies > 0 then
			for i=#self.driveStrategies,1,-1 do
				self.driveStrategies[i]:delete();
				table.remove(self.driveStrategies, i);
			end
			self.driveStrategies = {};
		end
		local aiDriveStrategyConveyor = AIDriveStrategyConveyor:new();
		aiDriveStrategyConveyor:setAIVehicle(self);
		table.insert(self.driveStrategies, aiDriveStrategyConveyor);
	end;
end
-- getDeactivateOnLeave
-- Description
-- 
-- 	Get deactivate on leaving
-- 
-- Definition
-- 
-- 	getDeactivateOnLeave()
-- 
-- Return Values
-- boolean	deactivateOnLeave	deactivate on leaving
-- Code
function AIVehicle:getDeactivateOnLeave(superFunc)
	local deactivate = true
	if superFunc ~= nil then
		deactivate = deactivate and superFunc(self)
	end
	return deactivate and not self.isHired
end;
-- getXMLStatsAttributes
-- Description
-- 
-- 	Returns string with states for game stats xml file
-- 
-- Definition
-- 
-- 	getXMLStatsAttributes()
-- 
-- Return Values
-- string	attributes	stats attributes
-- Code
function AIVehicle:getXMLStatsAttributes()
	if self.isHired then
		return 'isHired="true"';
	end
	return nil;
end
-- aiRotateRight
-- Description
-- 
-- 	Turns ai to the right
-- 
-- Definition
-- 
-- 	aiRotateRight(boolean force)
-- 
-- Arguments
-- boolean	force	force rotation
-- Code
function AIVehicle.aiRotateRight(self, force)
	if self.isServer then
		g_server:broadcastEvent(AIVehicleRotateRightEvent:new(self), nil, nil, self);
	end
	if self.onAiRotateRight ~= nil then
		self:onAiRotateRight(force);
	end
	for _,implement in pairs(self.aiImplementList) do
		if implement.object ~= nil then
			implement.object:onAiRotateRight(force);
		end
	end
end
-- aiRotateLeft
-- Description
-- 
-- 	Turns ai to the left
-- 
-- Definition
-- 
-- 	aiRotateLeft(boolean force)
-- 
-- Arguments
-- boolean	force	force rotation
-- Code
function AIVehicle.aiRotateLeft(self, force)
	if self.isServer then
		g_server:broadcastEvent(AIVehicleRotateLeftEvent:new(self), nil, nil, self);
	end
	if self.onAiRotateLeft ~= nil then
		self:onAiRotateLeft(force);
	end
	for _,implement in pairs(self.aiImplementList) do
		if implement.object ~= nil then
			implement.object:onAiRotateLeft(force);
		end
	end
end
-- consoleCommandToggleDebugRenderingAI
-- Description
-- 
-- 	Activates ai debug rendering
-- 
-- Definition
-- 
-- 	consoleCommandToggleDebugRenderingAI()
-- 
-- Code
function AIVehicle.consoleCommandToggleDebugRenderingAI(unusedSelf)
	AIVehicle.aiDebugRendering = not AIVehicle.aiDebugRendering;
end
