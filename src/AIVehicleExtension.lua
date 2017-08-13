--
-- AIVehicleExtension
-- Extended AIVehicle
--
-- @author	mogli aka biedens
-- @version 1.1.0.4
-- @date		23.03.2014
--
--	code source: AIVehicle.lua by Giants Software		
 
AIVehicleExtension = {}
local AtDirectory = g_currentModDirectory

------------------------------------------------------------------------
-- INCLUDES
------------------------------------------------------------------------
source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
_G[g_currentModName..".mogliBase"].newClass( "AIVehicleExtension", "acParameters" )
------------------------------------------------------------------------
source(Utils.getFilename("mogliHud.lua", g_currentModDirectory))
_G[g_currentModName..".mogliHud"].newClass( "AIVEHud", "atHud" )
------------------------------------------------------------------------
source(Utils.getFilename("AIVEEvents.lua", g_currentModDirectory))
------------------------------------------------------------------------
source(Utils.getFilename("FieldBitmap.lua", g_currentModDirectory))
source(Utils.getFilename("FrontPacker.lua", g_currentModDirectory))
source(Utils.getFilename("AutoSteeringEngine.lua", g_currentModDirectory))
source(Utils.getFilename("AIDriveStrategyMogli.lua", g_currentModDirectory))
source(Utils.getFilename("AIDriveStrategyCombine131.lua", g_currentModDirectory))
source(Utils.getFilename("AIDriveStrategyCollisionOtherAI.lua", g_currentModDirectory))
------------------------------------------------------------------------

------------------------------------------------------------------------
-- statEvent
------------------------------------------------------------------------
AIVehicleExtension.acDevFeatures = (AIVEGlobals.devFeatures > 0)
function AIVehicleExtension:statEvent( name, dt )
	if AIVEGlobals.showStat > 0 then
		if self.acStat == nil then self.acStat = {} end
		if self.acStat[name] == nil then self.acStat[name] = { t=0, n=0 } end
		self.acStat[name].t = self.acStat[name].t + dt
		self.acStat[name].n = self.acStat[name].n + 1
	end
end
------------------------------------------------------------------------
-- debugPrint
------------------------------------------------------------------------
function AIVehicleExtension:debugPrint( ... )
	if AIVEGlobals.devFeatures > 0 then
		print( ... )
	end
	if self ~= nil and AIVEGlobals.showInfo > 0 and self.atMogliInitDone then
		self.atHud.InfoText = tostring( ... )
	end	
end

function AIVehicleExtension:aiveAddDebugText( s )
	AIVehicleExtension.debugPrint( s )
end

AIVehicleExtension.saveAttributesMapping = { 
		enabled         = { xml = "acDefaultOn",	 tp = "B", default = true,  always = true },
		upNDown				  = { xml = "acUTurn",			 tp = "B", default = false, always = true },
		rightAreaActive = { xml = "acAreaRight",	 tp = "B", default = false, always = true },
		headland				= { xml = "acHeadland",		 tp = "B", default = false },
		collision			  = { xml = "acCollision",	 tp = "B", default = false },
		inverted				= { xml = "acInverted",		 tp = "B", default = false },
		frontPacker		  = { xml = "acFrontPacker", tp = "B", default = false },
		isHired				  = { xml = "acIsHired",		 tp = "B", default = false },
		bigHeadland		  = { xml = "acBigHeadland", tp = "B", default = true },
		turnModeIndex	  = { xml = "acTurnMode",		 tp = "I", default = 1 },
		turnModeIndexC	= { xml = "acTurnModeC",	 tp = "I", default = 1 },
		widthOffset		  = { xml = "acWidthOffset", tp = "F", default = 0 },
		turnOffset			= { xml = "acTurnOffset",	 tp = "F", default = 0 },
		angleFactor		  = { xml = "acAngleFactorN",tp = "F", default = 0.5 },
		noSteering			= { xml = "acNoSteering",	 tp = "B", default = false },
		useAIFieldFct		= { xml = "acUseAIField",	 tp = "B", default = false },
		waitForPipe			= { xml = "acWaitForPipe", tp = "B", default = true } }																															
AIVehicleExtension.turnStageNoNext = { -4, -3, -2, -1, 0, 21, 22, 23, 198, 199 } --{ 0 }
AIVehicleExtension.turnStageEnd	= { 
	--{ 4, -1 },
		{ 14, -1 },
	--{ 23, 25 },
		{ 25, 27 },
		{ 27, -2 },
		{ 28, -2 },
		{ 29, -2 },
		{ 33, 36 },
		{ 34, 36 },
		{ 36, 38 },
		{ 38, -1 },
		{ 41, 43 },
		{ 43, 45 },
		{ 45, 49 },
		{ 46, 49 },
		{ 47, 49 },
		{ 49, -2 },
		{ 53, 56 },
		{ 54, 56 },
		{ 59, -2 },
		{ 60, -2 },
		{ 75, 79 },
		{ 76, 79 },
		{ 77, 79 },
		{ 78, 79 },
		{ 79, -2 },
		{ 83, 85 },
		{ 86, -2 },
		{ 89, -1 },
		{ 99, -1 },
		{103, -1 },
		{108, -1 },
		{114, -2 },
		{119, -2 },
		{124, -1 }}

------------------------------------------------------------------------
-- prerequisitesPresent
------------------------------------------------------------------------
function AIVehicleExtension.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Hirable, specializations) 
		 and SpecializationUtil.hasSpecialization(AIVehicle, specializations)
end

------------------------------------------------------------------------
-- load
------------------------------------------------------------------------
function AIVehicleExtension:load(saveGame)

	-- for courseplay	
	self.acIsCPStopped				= false
	self.acTurnStage					= 0
	self.acPause							= false	
	self.acParameters				  = AIVehicleExtension.getParameterDefaults( )
	self.acAxisSide					  = 0
	self.acDebugPrint			  	= AIVehicleExtension.debugPrint
	self.aiveAddDebugText     = AIVehicleExtension.aiveAddDebugText
	self.acShowTrace					= true
	self.waitForTurnTime      = 0
	self.turnTimer            = 0
	self.aiRescueTimer        = 0
	
	self.acDeltaTimeoutWait	  = math.max(Utils.getNoNil( self.waitForTurnTimeout, 1600 ), 1000 ) 
	self.acDeltaTimeoutRun		= math.max(Utils.getNoNil( self.turnTimeout, 800 ), 500 )
	self.acDeltaTimeoutStop	  = math.max(Utils.getNoNil( self.turnStage1Timeout , 20000), 10000)
	self.acDeltaTimeoutStart	= math.max(Utils.getNoNil( self.turnTimeoutLong	 , 6000 ), 4000 )
	self.acDeltaTimeoutNoTurn = 2 * self.acDeltaTimeoutWait --math.max(Utils.getNoNil( self.waitForTurnTimeout , 2000 ), 1000 )
	self.acRecalculateDt			= 0
	self.acTurnStageSent			= 0
	self.acWaitTimer					= 0
	self.acTurnOutsideTimer   = 0
	self.acSteeringSpeed      = self.aiSteeringSpeed
	self.aiveCanStartArtAxis  = false
	
	self.acAutoRotateBackSpeedBackup = self.autoRotateBackSpeed	
	
	local tempNode = self.aiVehicleDirectionNode
	if self.aiVehicleDirectionNode == nil then
		tempNode = self.components[1].node
	end
	if			self.articulatedAxis ~= nil 
			and self.articulatedAxis.componentJoint ~= nil
			and self.articulatedAxis.anchorActor ~= nil
			and self.articulatedAxis.componentJoint.jointNode ~= nil then				
		tempNode = getParent( self.articulatedAxis.componentJoint.jointNode )
	end
	
	self.acRefNode = createTransformGroup( "acNewRefNode" )
	link( tempNode, self.acRefNode )

	if AIVEGlobals.otherAIColli > 0 then
		self.acI3D = getChild(Utils.loadSharedI3DFile("AutoCombine.i3d", AtDirectory),"AutoCombine")	
	--self.acBackTrafficCollisionTrigger   = getChild(self.acI3D,"backCollisionTrigger")
		self.acOtherCombineCollisionTriggerL = getChild(self.acI3D,"otherCombColliTriggerL")
		self.acOtherCombineCollisionTriggerR = getChild(self.acI3D,"otherCombColliTriggerR")
		link(self.acRefNode,self.acI3D)
		
		self.acCollidingVehicles = nil
		self.onOtherAICollisionTrigger = AIVehicleExtension.onOtherAICollisionTrigger
	end
	
	self.acChopperWithCourseplay = false 
end

------------------------------------------------------------------------
-- printCallstack
------------------------------------------------------------------------
function AIVehicleExtension.printCallstack()
	AIVEHud.printCallstack()
end

------------------------------------------------------------------------
-- initMogliHud
------------------------------------------------------------------------
function AIVehicleExtension:initMogliHud()
	if self.atMogliInitDone then
		return
	end
	
	local mogliRows = 1
	local mogliCols = 7
	--(												directory,	 hudName, hudBackground, onTextID, offTextID, showHudKey, x,y, nx, ny, w, h, cbOnClick )
	AIVEHud.init( self, AtDirectory, "AIVEHud", 0.4, "AIVE_TEXTHELPPANELON", "AIVE_TEXTHELPPANELOFF", InputBinding.AIVE_HELPPANEL, 0.5-0.015*mogliCols, 0.0108, mogliCols, mogliRows, AIVehicleExtension.sendParameters )--, nil, nil, 0.8 )
	AIVEHud.setTitle( self, "AIVE_VERSION" )

	AIVEHud.addButton(self, "dds/ai_combine.dds",     "dds/auto_combine.dds",  AIVehicleExtension.onEnable,      AIVehicleExtension.evalEnable,     1,1, "AIVE_STOP", "AIVE_START" )
	AIVEHud.addButton(self, "dds/active_right.dds",   "dds/active_left.dds",   AIVehicleExtension.setAreaLeft,   AIVehicleExtension.evalAreaLeft,   2,1, "AIVE_ACTIVESIDERIGHT", "AIVE_ACTIVESIDELEFT" )
	AIVEHud.addButton(self, "dds/no_uturn2.dds",      "dds/uturn.dds",         AIVehicleExtension.setUTurn,      AIVehicleExtension.evalUTurn,      3,1, "AIVE_UTURN_OFF", "AIVE_UTURN_ON") 
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.setTurnMode,   nil,                               4,1, nil, nil, AIVehicleExtension.getTurnModeText, AIVehicleExtension.getTurnModeImage )
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.onSteerPause,  nil,                               5,1, "AIVE_PAUSE_OFF", "AIVE_PAUSE_ON", AIVehicleExtension.getSteerPauseText, AIVehicleExtension.getSteerPauseImage )
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.onRaiseNext,   nil,                               6,1, "AIVE_STEER_ON", "AIVE_STEER_OFF", AIVehicleExtension.getRaiseNextText, AIVehicleExtension.getRaiseNextImage )
	AIVEHud.addButton(self, "dds/setings.dds",        nil,                     AIVehicleExtension.onAIVEScreen,  nil,                               7,1, "AIVE_SETTINGS", "AIVE_SETTINGS" )


--AIVEHud.addButton(self, "dds/auto_steer_off.dds", "dds/auto_steer_on.dds", AIVehicleExtension.onAutoSteer,   AIVehicleExtension.evalAutoSteer,  5,1, "AIVE_STEER_ON", "AIVE_STEER_OFF" )
--AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.onRaisePause,  nil,                               6,1, "AIVE_PAUSE_OFF", "AIVE_PAUSE_ON", AIVehicleExtension.getRaisePauseText, AIVehicleExtension.getRaisePauseImage )
--AIVEHud.addButton(self, "dds/next.dds",           "dds/no_next.dds",       AIVehicleExtension.nextTurnStage, AIVehicleExtension.evalTurnStage,  7,1, "AIVE_NEXTTURNSTAGE", nil )
	
	if type( self.atHud ) == "table" then
		self.atMogliInitDone = true
	else
		print("ERROR: Initialization of AIVehicleExtension HUD failed")
	end
end

------------------------------------------------------------------------
-- draw
------------------------------------------------------------------------
function AIVehicleExtension:draw()

	if self.atMogliInitDone then
		local alwaysDrawTitle = false
		if self.aiveIsStarted or self.acTurnStage >= 198 then
			alwaysDrawTitle = true
		end
		AIVEHud.draw(self,true,alwaysDrawTitle)
	end

	if     self.acLAltPressed then
		if self.isServer then
			if AIVehicleExtension.evalAutoSteer(self) then
				g_currentMission:addHelpButtonText(AIVEHud.getText("AIVE_STEER_ON"), InputBinding.AIVE_STEER)
			elseif self.acTurnStage >= 198 then
				g_currentMission:addHelpButtonText(AIVEHud.getText("AIVE_STEER_OFF"),InputBinding.AIVE_STEER)
			end	
		end	
	else
		g_currentMission:addHelpButtonText(AIVEHud.getText("AIVE_SETTINGS"), InputBinding.AIVE_START_AIVE)		
	end	
	
	if self.acPause then
		g_currentMission:addHelpButtonText(AIVEHud.getText("AIVE_CONTINUE"), InputBinding.TOGGLE_CRUISE_CONTROL)
	end
	
end

------------------------------------------------------------------------
-- onLeave
------------------------------------------------------------------------
function AIVehicleExtension:onLeave()
	if self.atMogliInitDone then
		AIVEHud.onLeave(self)
	end
end

------------------------------------------------------------------------
-- onEnter
------------------------------------------------------------------------
function AIVehicleExtension:onEnter()
	if self.atMogliInitDone then
		AIVEHud.onEnter(self)
	end
end

------------------------------------------------------------------------
-- mouseEvent
------------------------------------------------------------------------
function AIVehicleExtension:mouseEvent(posX, posY, isDown, isUp, button)
	if self.isEntered and self.isClient and self.atMogliInitDone then
		AIVEHud.mouseEvent(self, posX, posY, isDown, isUp, button)	
	end
end

------------------------------------------------------------------------
-- delete
------------------------------------------------------------------------
function AIVehicleExtension:preDelete()
	if AIVEGlobals.otherAIColli > 0 then
	--removeTrigger( self.acBackTrafficCollisionTrigger   )
		removeTrigger( self.acOtherCombineCollisionTriggerL )
		removeTrigger( self.acOtherCombineCollisionTriggerR )
	end
	
	if self.atMogliInitDone then
		AIVEHud.delete(self)
	end
	AutoSteeringEngine.deleteChain(self)

	if self.atShiftedMarker ~= nil then
		for _,marker in pairs( {"aiCurrentLeftMarker", "aiCurrentRightMarker", "aiCurrentBackMarker"} ) do
			AutoSteeringEngine.deleteNode( self.atShiftedMarker[marker] )
		end
		self.atShiftedMarker = nil
	end
end

------------------------------------------------------------------------
-- delete
------------------------------------------------------------------------
function AIVehicleExtension:delete()
end

------------------------------------------------------------------------
-- mouse event callbacks
------------------------------------------------------------------------
function AIVehicleExtension:onAIVEScreen()
	if g_gui:getIsGuiVisible() then
		return 
	end
	if self.atMogliInitDone == nil or not self.atMogliInitDone then
		AIVehicleExtension.initMogliHud(self)
	end
	g_AIVEScreen:setVehicle( self )
	g_gui:showGui( "AIVEScreen" )
end

function AIVehicleExtension:onRaiseNext()
	if self.aiIsStarted then
		if self.aiveIsStarted then 
			AIVehicleExtension.setNextTurnStage(self)
		end
	else
		local moveDown = not self.acImplementsMoveDown
		self.acImplementsMoveDown = nil
		AIVehicleExtension.setAIImplementsMoveDown(self, moveDown,true)
		if self.acParameters ~= nil and not moveDown and self.acParameters.upNDown then
			self.acParameters.leftAreaActive	= not self.acParameters.leftAreaActive 
			self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive
			AIVehicleExtension.sendParameters( self )
		end
	end
end

function AIVehicleExtension:getRaiseNextText()
	if self.aiIsStarted then
		if not self.aiveIsStarted then 
			return ""
		else
			for _,ts in pairs( AIVehicleExtension.turnStageNoNext ) do
				if self.acTurnStage == ts then
					return ""
				end
			end
			return AIVEHud.getText( "AIVE_NEXTTURNSTAGE" )
		end
	else
		if self.acImplementsMoveDown then
			return AIVEHud.getText( "AIVE_STEER_RAISE" )
		else
			return AIVEHud.getText( "AIVE_STEER_LOWER" )
		end
	end
end

function AIVehicleExtension:getRaiseNextImage()
	if self.aiIsStarted then
		if not self.aiveIsStarted then 
			return "empty.dds"
		else
			for _,ts in pairs( AIVehicleExtension.turnStageNoNext ) do
				if self.acTurnStage == ts then
					return "dds/no_next.dds"
				end
			end
			return "dds/next.dds"
		end
	else
		if self.acImplementsMoveDown then
			return "dds/raise_impl.dds"
		else
			return "dds/lower_impl.dds"
		end
	end
end

function AIVehicleExtension:onRaisePause()
	if self.aiIsStarted then
		if self.aiveIsStarted then 
			self.acPause = not self.acPause
		end
	else
		local moveDown = not self.acImplementsMoveDown
		self.acImplementsMoveDown = nil
		AIVehicleExtension.setAIImplementsMoveDown(self, moveDown,true)
		if self.acParameters ~= nil and not moveDown and self.acParameters.upNDown then
			self.acParameters.leftAreaActive	= not self.acParameters.leftAreaActive 
			self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive
			AIVehicleExtension.sendParameters( self )
		end
	end
end

function AIVehicleExtension:getRaisePauseText()
	if self.aiIsStarted then
		if not self.aiveIsStarted then 
			return ""
		elseif self.acPause then
			return AIVEHud.getText( "AIVE_PAUSE_OFF" )
		else
			return AIVEHud.getText( "AIVE_PAUSE_ON" )
		end
	else
		if self.acImplementsMoveDown then
			return AIVEHud.getText( "AIVE_STEER_RAISE" )
		else
			return AIVEHud.getText( "AIVE_STEER_LOWER" )
		end
	end
end

function AIVehicleExtension:getRaisePauseImage()
	if self.aiIsStarted then
		if not self.aiveIsStarted then 
			return "empty.dds"
		elseif self.acPause then
			return "dds/pause.dds"
		else
			return "dds/no_pause.dds"
		end
	else
		if self.acImplementsMoveDown then
			return "dds/raise_impl.dds"
		else
			return "dds/lower_impl.dds"
		end
	end
end

function AIVehicleExtension:onSteerPause()
	if self.aiIsStarted then
		if self.aiveIsStarted then 
			self.acPause = not self.acPause
		end
	elseif self.isServer then
		if self.acTurnStage >= 198 then
			AIVehicleExtension.setStatus( self, 0 )
			self.acTurnStage = 0
			self.stopMotorOnLeave = true
			self.deactivateOnLeave = true
		else
			AIVehicleExtension.initMogliHud(self)
			AutoSteeringEngine.invalidateField( self, self.acParameters.useAIFieldFct )
			AutoSteeringEngine.initFruitBuffer( self )
			self.acLastSteeringAngle = nil
			self.acTurnStage	 = 198
		end
	end
end

function AIVehicleExtension:getSteerPauseText()
	if self.aiIsStarted then
		if not self.aiveIsStarted then 
			return ""
		elseif self.acPause then
			return AIVEHud.getText( "AIVE_PAUSE_OFF" )
		else
			return AIVEHud.getText( "AIVE_PAUSE_ON" )
		end
	elseif self.isServer then
		if self.acTurnStage >= 198 then
			return AIVEHud.getText( "AIVE_STEER_OFF" )
		else
			return AIVEHud.getText( "AIVE_STEER_ON" )
		end
	end
	return ""
end

function AIVehicleExtension:getSteerPauseImage()
	if self.aiIsStarted then
		if not self.aiveIsStarted then 
			return "empty.dds"
		elseif self.acPause then
			return "dds/pause.dds"
		else
			return "dds/no_pause.dds"
		end
	elseif self.isServer then
		if self.acTurnStage >= 198 then
			return "dds/auto_steer_off.dds"
		else
			return "dds/auto_steer_on.dds"
		end
	end
	return "empty.dds"
end

function AIVehicleExtension.showGui(self,on)
	if on then
		if self.atMogliInitDone == nil or not self.atMogliInitDone then
			AIVehicleExtension.initMogliHud(self)
		end
		AIVEHud.showGui(self,true)
	elseif self.atMogliInitDone then
		AIVEHud.showGui(self,false)
	end
end

function AIVehicleExtension:evalUTurn()
	return not self.acParameters.upNDown
end

function AIVehicleExtension:setUTurn(enabled)
	self.acParameters.upNDown = enabled
end

function AIVehicleExtension:evalAreaLeft()
	return not self.acParameters.leftAreaActive
end

function AIVehicleExtension:setAreaLeft(enabled)
--if not enabled then return end
	self.acParameters.leftAreaActive	= enabled
	self.acParameters.rightAreaActive = not enabled
end

function AIVehicleExtension:evalAreaRight()
	return not self.acParameters.rightAreaActive
end

function AIVehicleExtension:setAreaRight(enabled)
--if not enabled then return end
	self.acParameters.rightAreaActive = enabled
	self.acParameters.leftAreaActive	= not enabled
end

function AIVehicleExtension:evalStart()
	return not self.aiIsStarted or not self:canStartAIVehicle()
end

function AIVehicleExtension:getStartImage()
	if self.aiIsStarted then
		return "dds/on.dds"
	elseif self:canStartAIVehicle() then
		return "dds/off.dds"
	end
	return "empty.dds"
end

function AIVehicleExtension:evalEnable()
	if     self.aiIsStarted          then
		return not ( self.aiveIsStarted )
	elseif self.acParameters.enabled then
		return false
	end
	return not ( self.aiveIsStarted )
end

function AIVehicleExtension:onEnable(enabled)
	if not ( self.aiIsStarted ) then
		self.acParameters.enabled = enabled
	end
end

function AIVehicleExtension:getTurnOffset(old)
	local new = ""
	if self.acDimensions == nil or self.acDimensions.headlandCount == nil then
		new = string.format(old..": %0.2fm",self.acParameters.turnOffset)
	else
		new = string.format(old..": %0.2fm (%i x)",self.acParameters.turnOffset,self.acDimensions.headlandCount)
	end
	return new
end

function AIVehicleExtension:getTurnIndexComp( upNDown )
	local u = upNDown
	if upNDown == nil and self.acParameters ~= nil then
		u = self.acParameters.upNDown
	end
	
	if not ( u ) then
		return "turnModeIndexC"
	end
	return "turnModeIndex"
end

function AIVehicleExtension:evalTurnStage()
	if self.aiIsStarted then
		if self.aiveIsStarted then
			for _,ts in pairs( AIVehicleExtension.turnStageNoNext ) do
				if self.acTurnStage == ts then
					return false
				end
			end
			return true
	--else
	--	if self.turnStage > 0 and self.turnStage < 4 then
	--		return true
	--	end
		end
	end
	
	return false
end

function AIVehicleExtension:nextTurnStage()
	AIVehicleExtension.setNextTurnStage(self)
end

function AIVehicleExtension:evalPause()
	if not self.aiveIsStarted then 
		return true 
	end 
	if not self.aiIsStarted then
		return true
	end
	if not self.acPause then
		return true
	end
	return false
end

function AIVehicleExtension:setPause(enabled)
	if not self.aiveIsStarted then 
		return	
	end 
	if not self.aiIsStarted then
		return 
	end
	
	self.acPause = enabled
	
	if enabled then
		AIVehicleExtension.setInt32Value( self, "speed2Level", 0 )
	else
		AIVehicleExtension.setInt32Value( self, "speed2Level", 2 )
	end
	
	if g_server ~= nil then
		g_server:broadcastEvent(AIVEPauseEvent:new(self,enabled), nil, nil, self)
	else
		g_client:getServerConnection():sendEvent(AIVEPauseEvent:new(self,enabled))
	end
end


function AIVehicleExtension:getPauseImage()
	if not self.aiveIsStarted then 
		return "empty.dds"
	end 
	if not self.aiIsStarted then
		return "empty.dds"
	end
	if not self.acPause then
		return "dds/no_pause.dds"
	end
	return "dds/pause.dds"
end

function AIVehicleExtension:evalAutoSteer()
	return self.aiIsStarted or self.acTurnStage < 198
end

function AIVehicleExtension:onAutoSteer(enabled)
	if self.aiIsStarted then
		if self.acTurnStage >= 198 then
			self.acTurnStage	 = 0
		end
	elseif enabled then
		AIVehicleExtension.initMogliHud(self)
		AutoSteeringEngine.invalidateField( self, self.acParameters.useAIFieldFct )
		AutoSteeringEngine.initFruitBuffer( self )
		self.acLastSteeringAngle = nil
		self.acTurnStage	 = 198
	else
		self.acTurnStage	 = 0
		self.stopMotorOnLeave = true
		self.deactivateOnLeave = true
	end
end

function AIVehicleExtension:onMagic(enabled)
	AIVehicleExtension.initMogliHud(self)
	AIVehicleExtension.invalidateState( self )
end

function AIVehicleExtension:onRaiseImpl(enabled)
	if		 self.aiIsStarted 
			or self.acParameters == nil then
	-- do nothing
	else
		AIVehicleExtension.setAIImplementsMoveDown(self,enabled,true)
		if self.acParameters ~= nil and not enabled and self.acParameters.upNDown then
			self.acParameters.leftAreaActive	= not self.acParameters.leftAreaActive 
			self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive
			AIVehicleExtension.sendParameters( self )
		end
	end
end

function AIVehicleExtension:evalRaiseImpl()
	if AutoSteeringEngine.areToolsLowered( self ) then
		return false
	end
	return true
end

function AIVehicleExtension:getRaiseImplImage()
	if		 self.aiIsStarted 
			or self.acParameters == nil then
		return "empty.dds"
	elseif self.acImplementsMoveDown then
		return "dds/raise_impl.dds"
	end
	return "dds/lower_impl.dds"
end

function AIVehicleExtension:setTurnMode()
	AIVehicleExtension.checkAvailableTurnModes( self, true )
	local c = AIVehicleExtension.getTurnIndexComp(self)
	self.acParameters[c] = self.acParameters[c] + 1
	if self.acParameters[c] > table.getn( self.acTurnModes ) then
		self.acParameters[c] = 1
	end
	self.acTurnMode = self.acTurnModes[self.acParameters[c]]
end

function AIVehicleExtension:getTurnModeImage()
	local img = "empty.dds"
	
	if     self.acTurnMode == "8" then
		img = "dds/bigUTurn8.dds"
	elseif self.acTurnMode == "O" then
		img = "dds/noRevUTurn.dds"
	elseif self.acTurnMode == "A" then
		img = "dds/smallUTurn.dds"
	elseif self.acTurnMode == "Y" then
		img = "dds/smallUTurn2.dds"
	elseif self.acTurnMode == "T" then
		img = "dds/bigUTurn.dds"
	elseif self.acTurnMode == "C" then
		img = "dds/noRevSide.dds"
	elseif self.acTurnMode == "L" then
		img = "dds/smallSide.dds"
	elseif self.acTurnMode == "K" then
		img = "dds/bigSide.dds"
	elseif self.acTurnMode == "7" then
		img = "dds/bigSide7.dds"
	end

	if AIVEGlobals.devFeatures > 0 then
		if self.acLastBigImg == nil or self.acLastBigImg ~= img then
			self.acLastBigImg = img
			print(img)
		end
	end
	
	return img
end

function AIVehicleExtension:getTurnModeText(old)
	return AIVEHud.getText("AIVE_TURN_MODE_"..self.acTurnMode)
end

function AIVehicleExtension:onToggleTrace()
	self.acShowTrace = not ( self.acShowTrace )
end
------------------------------------------------------------------------
-- keyEvent
------------------------------------------------------------------------
function AIVehicleExtension:keyEvent(unicode, sym, modifier, isDown)
	if self.isEntered and self.isClient then
		if sym == Input.KEY_lshift then
			self.acLShiftPressed = isDown
		end
		if sym == Input.KEY_lctrl then
			self.acLCtrlPressed = isDown
		end
		if sym == Input.KEY_lalt then
			self.acLAltPressed = isDown
		end
	end
end

------------------------------------------------------------------------
-- update
------------------------------------------------------------------------

function AIVehicleExtension:update(dt)

	if self.aiveIsStarted and not self.aiIsStarted then
		self.aiveIsStarted   = false
	end
	
	if not ( self.aiveIsStarted ) and self.aiSteeringSpeed ~= self.acSteeringSpeed then
		self.aiSteeringSpeed = self.acSteeringSpeed
	end

	if type( self.setIsReverseDriving ) == "function" and self.isReverseDriving then
		self.acParameters.inverted = true
	else
		self.acParameters.inverted = false
	end		
	
	if self.aiToolsDirtyFlag or self.aiveToolsDirtyFlag then
		self.aiveToolsDirtyFlag = self.aiToolsDirtyFlag
		AIVehicleExtension.invalidateState( self )
	end
	
	if AIVEGlobals.otherAIColli > 0 and self.isServer and self.acCollidingVehicles == nil then
		self.acCollidingVehicles = {}
		if self.acOtherCombineCollisionTriggerR ~= 0 then
			local triggerID = self.acOtherCombineCollisionTriggerR
			self.acCollidingVehicles[triggerID] = {}
			addTrigger( triggerID, "onOtherAICollisionTrigger", self )
		end
		if self.acOtherCombineCollisionTriggerL ~= 0 then
			local triggerID = self.acOtherCombineCollisionTriggerL
			self.acCollidingVehicles[triggerID] = {}
			addTrigger( triggerID, "onOtherAICollisionTrigger", self )
		end
	end
	
	if self.aiveIsStarted or self.acTurnStage >= 198 then
		if			self.articulatedAxis                          ~= nil 
				and self.articulatedAxis.componentJoint           ~= nil
				and self.articulatedAxis.componentJoint.jointNode ~= nil 
				and self.acDimensions                             ~= nil 
				and self.acDimensions.wheelBase                   ~= nil 
				and self.acDimensions.acRefNodeZ                  ~= nil then	
			
			local node = getParent( self.acRefNode )
			local dx = 0
			local dz = 0
			local dn = 0
			for n,i in pairs( self.acDimensions.wheelParents ) do
				local x,_,z	=AutoSteeringEngine.getRelativeTranslation( node, n )
				dx = dx + x
				dz = dz + z
				dn = dn + i
			end
			dx = dx / dn
			dz = dz / dn
			local _,angle,_ = getRotation( self.articulatedAxis.componentJoint.jointNode )
			angle = 0.5 * angle
			angle = AIVEGlobals.artAxisRot *  angle
			if self.isReverseDriving then
				angle = angle + math.pi
			end
			setRotation( self.acRefNode, 0, angle, 0 )				
			setTranslation( self.acRefNode, AIVEGlobals.artAxisShift * dx, 0, AIVEGlobals.artAxisShift * dz + self.acDimensions.acRefNodeZ )			
		else
			local angle = 0
			if self.isReverseDriving then
				angle = angle + math.pi
			end
			local _,y,_ = getRotation( self.acRefNode )
			if math.abs( y - angle ) > 0.01 then
				setRotation( self.acRefNode, 0, AIVEGlobals.artAxisRot * angle, 0 )				
			end
		end
	end

	if atDump and self:getIsActiveForInput(false) then
		AIVehicleExtension.acDump2(self)
	end

	if not g_gui:getIsGuiVisible() and not g_currentMission.isPlayerFrozen and self.isEntered then
	--if self.acParameters.enabled and self.acTurnStage < 198 and not self.aiveIsStarted then
	--	AIVehicleExtension.checkState( self )
	--end
	
		if AIVehicleExtension.mbHasInputEvent( "AIVE_HELPPANEL" ) then
			local guiActive = false
			if self.atHud ~= nil and self.atHud.GuiActive ~= nil then
				guiActive = self.atHud.GuiActive
			end
			AIVehicleExtension.showGui( self, not guiActive )
		end
		if      AIVehicleExtension.mbHasInputEvent( "AIVE_START_AIVE" ) then
			AIVehicleExtension.onAIVEScreen( self )
		elseif AIVehicleExtension.mbHasInputEvent( "AIVE_SWAP_SIDE" ) then
			self.acParameters.leftAreaActive	= self.acParameters.rightAreaActive
			self.acParameters.rightAreaActive = not self.acParameters.leftAreaActive
			AIVehicleExtension.sendParameters(self)
			if self.isServer then AutoSteeringEngine.setChainStraight( self ) end
			if			self.acParameters ~= nil
					and not ( self.aiIsStarted ) then
				if self.acParameters.leftAreaActive then
					AIVehicle.aiRotateLeft(self)
				else
					AIVehicle.aiRotateRight(self)
				end			
			end
		elseif AIVehicleExtension.mbHasInputEvent( "AIVE_STEER" ) then
			if self.acTurnStage < 198 then
				AIVehicleExtension.onAutoSteer(self, true)
			else
				AIVehicleExtension.onAutoSteer(self, false)
			end
		elseif AIVehicleExtension.mbHasInputEvent( "AIVE_UTURN_ON_OFF" ) then
			self.acParameters.upNDown = not self.acParameters.upNDown
			AIVehicleExtension.sendParameters(self)
		elseif AIVehicleExtension.mbHasInputEvent( "AIVE_STEERING" ) then
			self.acParameters.noSteering = not self.acParameters.noSteering
			AIVehicleExtension.sendParameters(self)
		elseif AIVehicleExtension.mbHasInputEvent( "IMPLEMENT_EXTRA" ) then
			self.acCheckPloughSide = true
		elseif AIVehicleExtension.mbHasInputEvent( "AIVE_RAISE" ) then
			AIVehicleExtension.onRaiseImpl( self, AIVehicleExtension.evalRaiseImpl( self ) )
		end
		
		if self.isHired and InputBinding.hasEvent(InputBinding.SWITCH_IMPLEMENT) then
			self:selectNextSelectableImplement();
		end
				
		if  not ( self.aiveIsStarted ) 
				and ( AIVehicleExtension.mbHasInputEvent( "LOWER_IMPLEMENT" ) or AIVehicleExtension.mbHasInputEvent( "LOWER_ALL_IMPLEMENTS" ) ) then
			self.acImplementsMoveDown = nil
		end
		
		if      self.isEntered 
				and self.isClient 
				and self:getIsActive() 
				and not self.acParameters.noSteering
				and ( self.aiveIsStarted or self.acTurnStage >= 198 ) then
			local axisSide = InputBinding.getDigitalInputAxis(InputBinding.AXIS_MOVE_SIDE_VEHICLE)
			if InputBinding.isAxisZero(axisSide) then
				axisSide = InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_SIDE_VEHICLE)
      end
			AIVehicleExtension.setAxisSide( self, axisSide )
		elseif self.acAxisSide ~= 0 then
			AIVehicleExtension.setAxisSide( self, 0 )
    end
		
		if self.aiIsStarted then		
			if AIVehicleExtension.mbHasInputEvent( "TOGGLE_CRUISE_CONTROL" ) then
				if self.speed2Level == nil or self.speed2Level > 0 then
					AIVehicleExtension.setPause( self, true )
				else
					AIVehicleExtension.setPause( self, false )
				end
			end
		end
	end
	
	if     self.aiveIsStarted      then
		if AIVEGlobals.devFeatures <= 0 or self.atHud.InfoText == nil or self.atHud.InfoText == "" then
			AIVEHud.setInfoText( self )
			if self.acDimensions ~= nil and self.acDimensions.distance ~= nil then
				AIVEHud.setInfoText( self, AIVEHud.getText( "AIVE_WORKWIDTH" ) .. string.format(" %0.2fm", self.acDimensions.distance+self.acDimensions.distance) )
			end
			if self.acTurnStage ~= nil and self.acTurnStage ~= 0 and self.acTurnStage < 198 then
				AIVEHud.setInfoText( self, AIVEHud.getInfoText(self) .. string.format(" (%i)", self.acTurnStage) )
			end
		end
		
		if      self.courseplayers              ~= nil 
				and table.getn( self.courseplayers ) > 0
				and self.specializations            ~= nil
				and self.overloading                ~= nil					
				and SpecializationUtil.hasSpecialization(Combine, self.specializations)
				and self:getUnitCapacity(self.overloading.fillUnitIndex) <= 0 then
			self.acChopperWithCourseplay = true
		else
			self.acChopperWithCourseplay = false 
		end
		
	elseif self.isServer and self.acTurnStage >= 198 then
		self.stopMotorOnLeave = false
		self.deactivateOnLeave = false
		
		AIVehicleExtension.autoSteer(self,dt)
	else
		self.acTurnStage = 0
	end
	
	if			self.isEntered 
			and self.isClient 
			and self.isServer 
			and self:getIsActive() 
			and self.atMogliInitDone 
			and self.atHud.GuiActive then	

		if self.acParameters ~= nil and self.acShowTrace and ( self.aiveIsStarted or self.acTurnStage >= 198 ) then			
			if			AIVEGlobals.showTrace > 0 
					and self.acDimensions ~= nil
					and ( self.aiIsStarted or self.acTurnStage >= 198 ) then	
				AutoSteeringEngine.drawLines( self )
			else
			--if not ( self.aiIsStarted or self.acTurnStage >= 198 ) then	
			--	AIVehicleExtension.checkState( self )
			--end
				AutoSteeringEngine.drawMarker( self )
			end
		end
	end	
	
	if  not self.aiveIsStarted 
			and self.acImplementsMoveDown == nil
			and ( self.attacherJointCombos == nil or not self.attacherJointCombos.isRunning ) then
		self.acImplementsMoveDown = AutoSteeringEngine.areToolsLowered( self )
	end
	
	if      self.isServer 
			and self.articulatedAxis ~= nil 
			and ( self.aiveCanStartArtAxisTimer == nil or g_currentMission.time > self.aiveCanStartArtAxisTimer + 1000 ) then
		self.aiveCanStartArtAxisTimer = g_currentMission.time
		AIVehicleExtension.checkState( self )
		local backup = 0
		if self.aiveCanStartArtAxis then
			backup = 1
		end
		local canStart = 0
		
		if self.aiveChain ~= nil then			
			AutoSteeringEngine.checkTools( self )
			for _,tool in pairs(self.aiveChain.tools) do
				if tool.aiForceTurnNoBackward then
					canStart = 1
				else
					canStart = 0
					break
				end
			end
		end
		
		if canStart ~= backup then
			AIVehicleExtension.setInt32Value( self, "aiveCanStartArtAxis", canStart )
		end
	end
end

------------------------------------------------------------------------
-- AIVehicleExtension.setAxisSide
------------------------------------------------------------------------
function AIVehicleExtension:setAxisSide( axisSide )
	local intValue = 1e6
	if math.abs( axisSide - self.acAxisSide ) > 1e-3 then
		if     axisSide < -1 then
			intValue = 0
		elseif axisSide >  1 then
			intValue = 2e6
		elseif axisSide == 0 then
			intValue = 1e6
		else
			intValue = math.min( math.max( math.ceil( 1e6 * ( axisSide + 1 ) + 0.5 ), 0 ), 2e6 )
		end
		AIVehicleExtension.setInt32Value( self, "axisSide", intValue )
	end
end

------------------------------------------------------------------------
-- AIVehicleExtension.shiftAIMarker
------------------------------------------------------------------------
function AIVehicleExtension:shiftAIMarker()
	
	local h = 0
	
	if			self.aiIsStarted 
			and self.turnStage		 == 0 
			and self.acParameters ~= nil 
			and self.acParameters.headland 
			and not ( self.aiveIsStarted ) then 
		if self.acDimensions == nil then
			AIVehicleExtension.calculateDimensions( self )
		end
		local d, t, z = AutoSteeringEngine.checkTools( self )
		h = math.max( 0, math.max( 0, t-z ) + math.max( 0, -t-self.acDimensions.zOffset ) + AIVehicleExtension.calculateHeadland( "T", d, z, t, self.acDimensions.radius, self.acDimensions.wheelBase, self.acParameters.bigHeadland, AutoSteeringEngine.getNoReverseIndex( self ) ) + self.acParameters.turnOffset )
	end 
	
	if math.abs( h ) < 0.01 and self.atShiftedMarker == nil then
		return 
	end

	if self.atShiftedMarker == nil then
	--print("creating shifted marker")
		self.atLastMarkerShift = 0
		self.atShiftedMarker	 = {}
		for _,marker in pairs( {"aiCurrentLeftMarker", "aiCurrentRightMarker", "aiCurrentBackMarker"} ) do
			self.atShiftedMarker[marker] = createTransformGroup( "shifted_"..marker )
		end
	end
	
	for _,marker in pairs( {"aiCurrentLeftMarker", "aiCurrentRightMarker", "aiCurrentBackMarker"} ) do 						
		if self[marker] == nil then
		--print("unlink marker "..marker)
			link( self.aiVehicleDirectionNode, self.atShiftedMarker[marker] )
		elseif self[marker] ~= self.atShiftedMarker[marker] then
		--print("linking marker "..marker)
			link( self[marker], self.atShiftedMarker[marker] )
			self[marker] = self.atShiftedMarker[marker] 
			setTranslation( self.atShiftedMarker[marker], 0, 0, h )
		elseif math.abs( self.atLastMarkerShift - h ) > 0.01 then 
		--print("shifting marker "..marker)
			setTranslation( self.atShiftedMarker[marker], 0, 0, h )
		end
	end
		
	self.atLastMarkerShift = h
end 

------------------------------------------------------------------------
-- AIVehicleExtension.resetAIMarker
------------------------------------------------------------------------
function AIVehicleExtension:resetAIMarker()
	if self.atShiftedMarker ~= nil then 
	--print("resetting shifted marker")
		self.atLastMarkerShift = 0
		for _,marker in pairs( {"aiCurrentLeftMarker", "aiCurrentRightMarker", "aiCurrentBackMarker"} ) do 						
			setTranslation( self.atShiftedMarker[marker], 0, 0, 0 )
		end 		
	end 		
end 

------------------------------------------------------------------------
-- AIVehicle:setAIImplementsMoveDown(moveDown)
------------------------------------------------------------------------
function AIVehicleExtension:setAIImplementsMoveDown( moveDown, immediate, noEventSend )

	if not ( noEventSend ) then
		local value = 0
		if moveDown then
			value = value + 2
		end
		if immediate then
			value = value + 1
		end
		AIVehicleExtension.setInt32Value( self, "moveDown", value )
	end
	
	if self.acImplementsMoveDown == nil or self.acImplementsMoveDown ~= moveDown then
		self.acImplementsMoveDown = moveDown
		AutoSteeringEngine.setToolsAreLowered( self, moveDown, immediate )
	end
	if immediate then
		AutoSteeringEngine.ensureToolIsLowered( self, self.acImplementsMoveDown )
	end
end

------------------------------------------------------------------------
-- setStatus
------------------------------------------------------------------------
function AIVehicleExtension:setStatus( newStatus, noEventSend )
	
	if self ~= nil and self.atMogliInitDone and self.atHud ~= nil and ( self.atHud.Status == nil or self.atHud.Status ~= newStatus ) then
		AIVehicleExtension.setInt32Value( self, "status", Utils.getNoNil( newStatus, 0 ) )
	end
	
end

------------------------------------------------------------------------
-- getAvailableTurnModes
------------------------------------------------------------------------
function AIVehicleExtension:getAvailableTurnModes( upNDown )

	turnModes = {}
	
	if self.acDimensions == nil then
		AIVehicleExtension.calculateDimensions( self )
	end

	local sut, rev, revS, noHire = AutoSteeringEngine.getTurnMode( self )

	if upNDown then
		if rev	then
			if self.acDimensions.zBack ~= nil and self.acDimensions.zBack > 0 then
				table.insert( turnModes, "Y" )
			elseif AIVEGlobals.enableAUTurn > 0 and sut then
				table.insert( turnModes, "A" )
			end
		end
		if revS then
			table.insert( turnModes, "T" )
		end
		table.insert( turnModes, "O" )
		if self.acDimensions.zBack ~= nil and self.acDimensions.zBack < 0 then
			table.insert( turnModes, "8" )
		end
	else
		if self.acDimensions.zBack ~= nil and self.acDimensions.zBack > 0 then
			if revS then --and not self.acChopperWithCourseplay then
				table.insert( turnModes, "7"	)
			end
			if rev	then
				table.insert( turnModes, "L"	)
			end
		else
			if rev	then
				table.insert( turnModes, "L"	)
			end
			if revS then
				table.insert( turnModes, "7"	)
			end
		end
		if AIVEGlobals.enableKUTurn > 0 then
			table.insert( turnModes, "K"	)
		end
		table.insert( turnModes, "C"	)
	end
		
	return turnModes
end

------------------------------------------------------------------------
-- checkAvailableTurnModes
------------------------------------------------------------------------
function AIVehicleExtension:checkAvailableTurnModes( noEventSend )

	if noHire then
		self.acParameters.isHired = false
	end
	
	self.acTurnModes = AIVehicleExtension.getAvailableTurnModes( self, self.acParameters.upNDown )
	
	local c = AIVehicleExtension.getTurnIndexComp(self)
	
	if		 self.acParameters[c] == nil
			or self.acParameters[c] < 1 then
		self.acParameters[c] = 1
		if noEventSend == nil or not noEventSend then
			AIVehicleExtension.sendParameters(self)
		end
	elseif self.acParameters[c] > table.getn( self.acTurnModes ) then
		self.acParameters[c] = table.getn( self.acTurnModes )
		if noEventSend == nil or not noEventSend then
			AIVehicleExtension.sendParameters(self)
		end
	end

	self.acTurnMode = self.acTurnModes[self.acParameters[c]]
end

------------------------------------------------------------------------
-- invalidateState
------------------------------------------------------------------------
function AIVehicleExtension:invalidateState( detachIndex )

	AIVEHud.setInfoText( self )
	AutoSteeringEngine.checkTools1( self, true )
	AutoSteeringEngine.invalidateField( self, true )		
	AutoSteeringEngine.initFruitBuffer( self )
	if self.acDimensions ~= nil then
		self.acDimensions = nil
		AIVehicleExtension.checkState( self, true, true )
	end
	self.acCheckStateTimer = nil
	
end

------------------------------------------------------------------------
-- checkState
------------------------------------------------------------------------
function AIVehicleExtension:checkState( force, clientOnly )

	if self.aiToolsDirtyFlag then
		self.acDimensions      = nil
		self.acCheckStateTimer = nil
		return 
	end
	
	if      not ( force )
			and self.acCheckStateTimer ~= nil
			and self.acDimensions			~= nil
			and self.acCheckStateTimer > g_currentMission.time then
		return 
	end
	
	if self.acDimensions == nil then
		AIVehicleExtension.calculateDimensions( self )
	end
	
	self.acCheckStateTimer = g_currentMission.time + AIVEGlobals.maxDtSumT
	
	local s = AutoSteeringEngine.getSpecialToolSettings( self )
	
	if s.rightOnly then
		self.acParameters.upNDown				 = false
		self.acParameters.leftAreaActive	= true
		self.acParameters.rightAreaActive = false
	end
	if s.leftOnly then
		self.acParameters.upNDown				 = false
		self.acParameters.leftAreaActive	= false
		self.acParameters.rightAreaActive = true
	end
	
	AIVehicleExtension.checkAvailableTurnModes( self )
	
	AIVehicleExtension.calculateDistances( self )
	
	local h = 0
	local c = 0
--if			self.acParameters.collision
--		and self.acParameters.upNDown
--	--and self.acTurnStage ~=	-3 
--	--and self.acTurnStage ~= -13 
--	--and self.acTurnStage ~= -23 
--		then
--	c = self.acDimensions.collisionDist
--end
	if			self.acParameters.headland 
			and self.acParameters.upNDown 
		--and self.acTurnStage ~=	-3 
		--and self.acTurnStage ~= -13 
		--and self.acTurnStage ~= -23 
			then
		h = self.acDimensions.headlandDist
	end
	
	if not ( clientOnly ) then
		AutoSteeringEngine.initTools( self, self.acDimensions.maxSteeringAngle, self.acParameters.leftAreaActive, self.acParameters.widthOffset, h, c, self.acTurnMode )
	end
end

------------------------------------------------------------------------
-- autoSteer
------------------------------------------------------------------------
function AIVehicleExtension:autoSteer(dt)

	if not self.isServer then
		self.acTurnStage = 0
		return
	end
	
	AIVehicleExtension.checkState( self )

	if not AutoSteeringEngine.hasTools( self ) then
		self.acTurnStage = 0
		return
	end

	local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( self )
	local fruitsAdvance = fruitsDetected
	if not fruitsAdvance and AutoSteeringEngine.hasFruits( self, true ) then
		fruitsAdvance = true
	end
	
	local doSteer = true
	if self.movingDirection < -1E-2 then	
		self.acTurnStage          = 198
		AIVehicleExtension.setStatus( self, 2 )
		return
	elseif not AutoSteeringEngine.areToolsLowered( self ) then
		self.acTurnStage          = 198
		AIVehicleExtension.setStatus( self, 2 )
	end
	
--==============================================================		
	if fruitsAdvance and self.acImplementsMoveDown then
		AutoSteeringEngine.getIsAIReadyForWork( self )
	end
		
	local vX,vY,vZ = getWorldTranslation( self.acRefNode )
	AutoSteeringEngine.setAiWorldPosition( self, vX, vY, vZ )
	
	local inField, target, angleFactor, nilAngle

	if self.acTurnStage == 199 then
		inField     = true
		angleFactor = self.acParameters.angleFactor
		nilAngle    = "L"
		
		if	   self.turnTimer < 0 
				or AutoSteeringEngine.getIsAtEnd( self ) then
			target = math.min( math.max( 0.5 * AutoSteeringEngine.getTurnAngle(self), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
			if AutoSteeringEngine.getNoReverseIndex( self ) <= 0 then
				target = math.max( target, 0 )
			end
			if not self.acParameters.leftAreaActive then
				target = -target
			end
		end
	else
		inField     = false
		angleFactor = 1
		nilAngle    = "M"
	end

	local detected, angle, border, tX, _, tZ, dist = AutoSteeringEngine.processChain( self, inField, target, angleFactor, nilAngle )	
--==============================================================						
		
	self.turnTimer = self.turnTimer - dt
	
	if fruitsDetected and detected and border <= 0 then
		AIVehicleExtension.setStatus( self, 1 )
		if self.acTurnStage ~= 199 then
			self.acTurnStage = 199
			AutoSteeringEngine.clearTrace( self )
			AutoSteeringEngine.saveDirection( self, false, false, true )
		elseif AutoSteeringEngine.getIsAtEnd( self ) then
			if self.acParameters.leftAreaActive then
				angle = math.max( angle, 0 )
			else
				angle = math.min( angle, 0 )
			end
		end
		AutoSteeringEngine.saveDirection( self, true, true, true )
		self.turnTimer = self.acDeltaTimeoutRun
	elseif self.acTurnStage == 199 and self.turnTimer >= 0 then
		if border <= 0 then
			if AutoSteeringEngine.getIsAtEnd( self ) then
				angle = 0
			else
				angle = -self.acDimensions.maxSteeringAngle
			end
			if not self.acParameters.leftAreaActive then
				angle = -angle		
			end
			if fruitsDetected then
				self.turnTimer = self.acDeltaTimeoutRun
			end			
		end
		AIVehicleExtension.setStatus( self, 2 )
	else
		if self.acTurnStage == 199 and border <= 0 then
		--AIVehicleExtension.onRaiseImpl( self, false )
			self:setCruiseControlState( Drivable.CRUISECONTROL_STATE_OFF )
		end
		
		self.acTurnStage = 198
		AIVehicleExtension.setStatus( self, 2 )
		angle = 0
	end
	
	if self.acAxisSideFactor == nil then
		self.acAxisSideFactor = 0
	elseif math.abs( self.acAxisSide ) >= 0.1 then
		self.acAxisSideFactor = math.max( self.acAxisSideFactor - dt, 0 )
	elseif self.acAxisSideFactor < 1000  then
		self.acAxisSideFactor = math.min( self.acAxisSideFactor + dt, 1000 )
	end
	
	local f = 0.001 * self.acAxisSideFactor
	
	if self.isEntered and doSteer then -- and detected and doSteer then
		if f <= 0 then
			angle = -self.acAxisSide * self.acDimensions.maxSteeringAngle
		elseif f < 1 then
			angle = f * angle - (1-f) * self.acAxisSide * self.acDimensions.maxSteeringAngle
		end
		AutoSteeringEngine.steer( self, dt, angle, self.acSteeringSpeed, (f >= 0.999 ) and (self.acTurnStage == 199) )
	end
end

------------------------------------------------------------------------
-- getSaveAttributesAndNodes
------------------------------------------------------------------------

function AIVehicleExtension:getSaveAttributesAndNodes(nodeIdent)
	
	local attributes = 'acVersion="2.2"'
	
	local skip = true
	
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if self.acParameters[n] ~= p.default then
			skip = false
		end
		if self.acParameters[n] ~= p.default or p.always then
			if		 p.tp == "B" then
				attributes = attributes..' '..p.xml..'="'..AIVEHud.bool2int(self.acParameters[n]).. '"'
			else
				attributes = attributes..' '..p.xml..'="'..self.acParameters[n].. '"'
			end
		end
	end

	if skip then
		return ""
	end
	
	return attributes
end

------------------------------------------------------------------------
-- loadFromAttributesAndNodes
------------------------------------------------------------------------
function AIVehicleExtension:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	local version = AIVEHud.getXmlFloat(xmlFile, key.."#acVersion", 0 )

	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if		 p.tp == "B" then
			self.acParameters[n] = AIVEHud.getXmlBool( xmlFile, key.."#"..p.xml, self.acParameters[n])
		elseif p.tp == "I" then
			self.acParameters[n] = AIVEHud.getXmlInt(	xmlFile, key.."#"..p.xml, self.acParameters[n])
		else--if p.tp == "F" then
			self.acParameters[n] = AIVEHud.getXmlFloat(xmlFile, key.."#"..p.xml, self.acParameters[n])
		end
	end		
	
	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive
	self.acDimensions								 = nil
	
	if type( self.setIsReverseDriving ) == "function" and self.acParameters.inverted then
		self:setIsReverseDriving( self.acParameters.inverted, false )
	end
	
	if version < 1.5 then
		self.acParameters.turnModeIndexC = self.acParameters.turnModeIndex
		if self.acParameters.upNDown and self.acParameters.turnModeIndex > 1 then
			self.acParameters.turnModeIndex = self.acParameters.turnModeIndex - 1
		end
	end
	
	return BaseMission.VEHICLE_LOAD_OK
end

------------------------------------------------------------------------
-- getCorrectedMaxSteeringAngle
------------------------------------------------------------------------
function AIVehicleExtension:getCorrectedMaxSteeringAngle()

	local steeringAngle = self.acDimensions.maxSteeringAngle
	if			self.articulatedAxis ~= nil 
			and self.articulatedAxis.componentJoint ~= nil
			and self.articulatedAxis.componentJoint.jointNode ~= nil 
			and self.articulatedAxis.rotMax then
		-- Ropa
		steeringAngle = steeringAngle + 0.15 * self.articulatedAxis.rotMax
	end

	return steeringAngle
end

------------------------------------------------------------------------
-- calculateDimensions
------------------------------------------------------------------------
function AIVehicleExtension.calculateDimensions( self )
	if     self.aiToolsDirtyFlag    then
		self.acDimensions = nil
		return
	elseif self.acDimensions ~= nil then
		return
	end
	
	self.acDimensions								 	 = {}
	self.acDimensions.zOffset				 	 = 0 
	self.acDimensions.acRefNodeZ       = 0
	self.acDimensions.maxSteeringAngle = Utils.getNoNil( self.maxRotation, math.rad( 25 ))
	self.acDimensions.radius           = Utils.getNoNil( self.maxTurningRadius, 6.25 )
	self.acDimensions.wheelBase        = math.tan( self.acDimensions.maxSteeringAngle ) * self.acDimensions.radius
	
	local wheel = self.wheels[self.maxTurningRadiusWheel] 
	if wheel ~= nil then
		local diffX, _, diffZ = localToLocal(wheel.node, self.steeringCenterNode, wheel.positionX, wheel.positionY, wheel.positionZ)
		self.acDimensions.radius         = self.acDimensions.radius - math.abs( diffX )
	else
		self.acDimensions.radius         = self.acDimensions.radius - 1.25
	end
	
	if			self.articulatedAxis ~= nil 
			and self.articulatedAxis.componentJoint ~= nil
			and self.articulatedAxis.componentJoint.jointNode ~= nil 
			and self.articulatedAxis.rotMax then
			
		self.acDimensions.wheelParents = {}
	--_,_,self.acDimensions.acRefNodeZ = AutoSteeringEngine.getRelativeTranslation(refNodeParent,self.articulatedAxis.componentJoint.jointNode)
	--local n=0
		for _,wheel in pairs(self.wheels) do
	--	local temp1 = { getRotation(wheel.driveNode) }
	--	local temp2 = { getRotation(wheel.repr) }
	--	setRotation(wheel.driveNode, 0, 0, 0)
	--	setRotation(wheel.repr, 0, 0, 0)
	--	local x,y,z = AutoSteeringEngine.getRelativeTranslation(self.articulatedAxis.componentJoint.jointNode,wheel.driveNode)
	--	setRotation(wheel.repr, unpack(temp2))
	--	setRotation(wheel.driveNode, unpack(temp1))
  --
	--	if n==0 then
	--		self.acDimensions.wheelBase = math.abs(z)
	--		n = 1
	--	else
	--		self.acDimensions.wheelBase = self.acDimensions.wheelBase + math.abs(z)
	--		n	= n	+ 1
	--	--self.acDimensions.wheelBase = math.max( math.abs(z) )
	--	end
			
			local node = getParent( wheel.driveNode )
			if self.acDimensions.wheelParents[node] == nil then
				self.acDimensions.wheelParents[node] = 1
			else
				self.acDimensions.wheelParents[node] = self.acDimensions.wheelParents[node] + 1
			end
		end
	--if n > 1 then
	--	self.acDimensions.wheelBase = self.acDimensions.wheelBase / n
	--end
	---- divide max. steering angle by 2 because it is for both sides
	--self.acDimensions.maxSteeringAngle = 0.25 * (math.abs(self.articulatedAxis.rotMin)+math.abs(self.articulatedAxis.rotMax))
	---- reduce wheel base according to max. steering angle
	--self.acDimensions.wheelBase				= self.acDimensions.wheelBase * math.cos( self.acDimensions.maxSteeringAngle ) 
	end
	
	setTranslation( self.acRefNode, 0, 0, self.acDimensions.acRefNodeZ )
	
	if AIVEGlobals.devFeatures > 0 then
		print(string.format("wb: %0.3fm, r: %0.3fm, z: %0.3fm", self.acDimensions.wheelBase, self.acDimensions.radius, self.acDimensions.acRefNodeZ ))
	end
	
end

------------------------------------------------------------------------
-- getHeadlandSmallBig
------------------------------------------------------------------------
function AIVehicleExtension:getHeadlandSmallBig()
	if self.acDimensions == nil then
		AIVehicleExtension.calculateDimensions( self )
	end
	AIVehicleExtension.calculateDistances( self )
	local nri   = AutoSteeringEngine.getNoReverseIndex( self )
  local small = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.radius, self.acDimensions.wheelBase, false, nri )
	local big   = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.radius, self.acDimensions.wheelBase, true,  nri )
	
	return small, big
end

------------------------------------------------------------------------
-- calculateHeadland
------------------------------------------------------------------------
function AIVehicleExtension.calculateHeadland( turnMode, realWidth, zBack, toolDist, radius, wheelBase, big, noRevIdx )

	local width = 1.5
	if big then
		if realWidth ~= nil and realWidth > width then
			width = realWidth
		end
		width = width + 2
	end
	
	local frontToBack = 1
	if noRevIdx ~= nil and noRevIdx <= 0 and turnMode == "T" then
		frontToBack = math.max( -zBack, 1 )
	elseif big then
		frontToBack = math.max( toolDist - zBack, 1 )
	end
	
	local ret = 0
	if		 turnMode == "A"
			or turnMode == "L" then
		ret	 = math.max( 2, toolDist ) + math.abs( wheelBase ) + math.abs( zBack ) + frontToBack
		if big then
			ret = ret + 3
		end
		ret	 = math.max( ret, width ) 
	elseif turnMode == "C" then
		ret	 = width + math.max( -zBack, 0 ) + radius
	elseif turnMode == "O" or turnMode == "8" then
		local beta = math.acos( math.min(math.max(realWidth / radius, 0),1) )
		local z		= 2.2 * radius * math.sin( beta )
		if big then
			z = z + 1.1
		end
		ret	 = width + math.max( -zBack, 0 ) + math.max( frontToBack, z ) + math.max( toolDist, 0 ) + radius
	else
		ret	 = width + math.max( -zBack, 0 ) + frontToBack + math.max( toolDist, 0 ) + radius
	end
	
	if ret < 0 then
		ret = 0
	end
	
	return ret
end

------------------------------------------------------------------------
-- calculateDistances
------------------------------------------------------------------------
function AIVehicleExtension.calculateDistances( self )

	self.acDimensions.distance		 = 99
	self.acDimensions.toolDistance = 99
	
	local wb = self.acDimensions.wheelBase
	local ms = self.acDimensions.maxSteeringAngle
	
	AutoSteeringEngine.checkChain( self, self.acRefNode, wb, ms, self.acParameters.widthOffset, self.acParameters.turnOffset, self.isReverseDriving, self.acParameters.frontPacker, self.acParameters.useAIFieldFct )

	self.acDimensions.distance, self.acDimensions.toolDistance, self.acDimensions.zBack = AutoSteeringEngine.checkTools( self )
	
	self.acDimensions.distance0				= self.acDimensions.distance
	if self.acParameters.widthOffset ~= nil then
		self.acDimensions.distance			= self.acDimensions.distance0 + self.acParameters.widthOffset
	end
	
	local optimDist = self.acDimensions.distance
	if self.acDimensions.radius > optimDist then
		self.acDimensions.uTurnAngle		 = math.acos( optimDist / self.acDimensions.radius )
	else
		self.acDimensions.uTurnAngle		 = 0
	end

	self.acDimensions.insideDistance = math.max( 0, self.acDimensions.toolDistance - 1 - self.acDimensions.distance +(self.acDimensions.radius * math.cos( self.acDimensions.maxSteeringAngle )) )
	self.acDimensions.uTurnDistance	= math.max( 0, self.acDimensions.toolDistance, self.acDimensions.distance - self.acDimensions.radius )
	self.acDimensions.headlandDist	 = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.radius, self.acDimensions.wheelBase, self.acParameters.bigHeadland, AutoSteeringEngine.getNoReverseIndex( self ) )
	self.acDimensions.collisionDist	= 1 + AIVehicleExtension.calculateHeadland( self.acTurnMode, math.max( self.acDimensions.distance, 1.5 ), self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.radius, self.acDimensions.wheelBase, self.acParameters.bigHeadland, AutoSteeringEngine.getNoReverseIndex( self ) )
	self.acDimensions.uTurnDist4x   = 1 + math.max( math.max( self.acDimensions.toolDistance - self.acDimensions.radius, self.acDimensions.distance ) - self.acDimensions.radius, 0 )
	--if self.acShowDistOnce == nil then
	--	self.acShowDistOnce = 1
	--else
	--	self.acShowDistOnce = self.acShowDistOnce + 1
	--end
	--if self.acShowDistOnce <= 30 then
	--	print(string.format("max( %0.3f , 1.5 ) + max( - %0.3f, 0 ) + max( %0.3f - %0.3f, 1 ) + %0.3f = %0.3f", self.acDimensions.distance, zBack, self.acDimensions.toolDistance, zBack, self.acDimensions.radius, self.acDimensions.headlandDist ) )
	--end
	
	if self.acParameters.turnOffset ~= nil then
		self.acDimensions.insideDistance = math.max( 0, self.acDimensions.insideDistance + self.acParameters.turnOffset )
		self.acDimensions.uTurnDistance	 = math.max( 0, self.acDimensions.uTurnDistance	 + self.acParameters.turnOffset )
		self.acDimensions.headlandDist	 = math.max( 0, self.acDimensions.headlandDist	 + self.acParameters.turnOffset )
		self.acDimensions.collisionDist	 = math.max( 0, self.acDimensions.collisionDist	 + self.acParameters.turnOffset )
		self.acDimensions.uTurnDist4x    = self.acDimensions.uTurnDist4x + self.acParameters.turnOffset
	end
	
	self.acDimensions.headlandCount = 0
	if self.acDimensions.distance > 0 then
		local w = self.acDimensions.distance + self.acDimensions.distance
		self.acDimensions.headlandCount	= math.ceil( ( self.acDimensions.headlandDist ) / w )
		--self.acDimensions.headlandDist	 = w * self.acDimensions.headlandCount
	end
	--self.acDimensions.headlandDist		 = math.min( math.max( self.acDimensions.headlandDist, 0 ), AIVEGlobals.chainMinLen )
end

------------------------------------------------------------------------
-- Manually switch to next turn stage
------------------------------------------------------------------------
function AIVehicleExtension:setNextTurnStage(noEventSend)

	if self.isServer and self.driveStrategies ~= nil then
		for i,d in pairs( self.driveStrategies ) do
			if type( d.gotoNextStage ) == "function" then
				d:gotoNextStage()
			end
		end
	end

	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(AIVENextTSEvent:new(self), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(AIVENextTSEvent:new(self))
		end
	end
end

function AIVehicleExtension:setIsReverseDriving( isReverseDriving, noEventSend )
	if self.acParameters ~= nil then
		self.acParameters.inverted = isReverseDriving
		AIVehicleExtension.sendParameters( self )
	end
end

------------------------------------------------------------------------
-- Event stuff
------------------------------------------------------------------------
function AIVehicleExtension.getParameterDefaults()
	parameters = {}

	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		parameters[n] = p.default
	end
	parameters.leftAreaActive	= not parameters.rightAreaActive

	return parameters
end

function AIVehicleExtension:getParameters()
	if self.acParameters == nil then
		self.acParameters = AIVehicleExtension.getParameterDefaults( )
	end
	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive

	return self.acParameters
end

function AIVehicleExtension.readStreamHelper(streamId)
	local parameters = {}
	
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if		 p.tp == "B" then
			parameters[n] = streamReadBool(streamId)
		elseif p.tp == "I" then
			parameters[n] = streamReadInt8(streamId)
		else--if p.tp == "F" then
			parameters[n] = streamReadFloat32(streamId)
		end
	end
	
	return parameters
end

function AIVehicleExtension.writeStreamHelper(streamId, parameters)
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if		 p.tp == "B" then
			streamWriteBool(streamId, Utils.getNoNil( parameters[n], p.default ))
		elseif p.tp == "I" then
			streamWriteInt8(streamId, Utils.getNoNil( parameters[n], p.default ))
		else--if p.tp == "F" then
			streamWriteFloat32(streamId, Utils.getNoNil( parameters[n], p.default ))
		end
	end
end

local AIVESetParametersdLog
function AIVehicleExtension:setParameters(parameters)

	if self == nil then
		if AIVESetParametersdLog < 10 then
			AIVESetParametersdLog = AIVESetParametersdLog + 1
			print("------------------------------------------------------------------------")
			print("AIVehicleExtension:setParameters: self == nil")
			AIVEHud.printCallstack()
			print("------------------------------------------------------------------------")
		end
		return
	end

	local turnOffset = 0
	if self.acParameters ~= nil and self.acParameters.turnOffset ~= nil then
		turnOffset = self.acParameters.turnOffset
	end
	local widthOffset = 0
	if self.acParameters ~= nil and self.acParameters.widthOffset ~= nil then
		widthOffset = self.acParameters.widthOffset
	end
	
	self.acParameters = {}
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		self.acParameters[n] = Utils.getNoNil( parameters[n], p.default )
	end

	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive
end

function AIVehicleExtension:readStream(streamId, connection)
	AIVehicleExtension.setParameters( self, AIVehicleExtension.readStreamHelper(streamId) )
end

function AIVehicleExtension:writeStream(streamId, connection)
	AIVehicleExtension.writeStreamHelper(streamId,AIVehicleExtension.getParameters(self))
end

function AIVehicleExtension:sendParameters(noEventSend)
	if self.acDimensions ~= nil then
		AIVehicleExtension.calculateDistances( self )
	end

	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(AIVEParametersEvent:new(self, AIVehicleExtension.getParameters(self)), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(AIVEParametersEvent:new(self, AIVehicleExtension.getParameters(self)))
		end
	end
end


if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acReset", "Reset global AIVehicleExtension variables to defaults.", "acReset", AIVehicleExtension)
end
function AIVehicleExtension:acReset()
	AutoSteeringEngine.globalsReset()
	AutoSteeringEngine.resetCounter = AutoSteeringEngine.resetCounter + 1
	for name,value in pairs(AIVEGlobals) do
		print(tostring(name).." "..tostring(value))		
	end
end

-- acSave
if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acSave", "Save the global AIVehicleExtension variables.", "acSave", AIVehicleExtension)
end
function AIVehicleExtension:acSave()
	AutoSteeringEngine.globalsCreate()	
	for name,value in pairs(AIVEGlobals) do
		print(tostring(name).." "..tostring(value))		
	end
end

-- acSet
if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acSet", "Change one of the global AIVehicleExtension variables.", "acSet", AIVehicleExtension)
end
function AIVehicleExtension:acSet(name,svalue)

	local value
	if svalue ~= nil then
		value = tonumber( svalue )
	end
	
	print("acSet "..tostring(name).." "..tostring(value))

	local found = false
	
	local old=nil
	for n,o in pairs(AIVEGlobals) do
		if n == name then
			found = true
			old	 = o
			break
		end
	end
	
	if found then
		if value == nil or old == new then
			print(tostring(AIVEGlobals[name]))
		else
			AIVEGlobals[name]=value
			print("Old value: "..tostring(old).." new value: "..tostring(value))
			AutoSteeringEngine.resetCounter = AutoSteeringEngine.resetCounter + 1
		end
	else
		print("Usage: acSet <name> <value>")
		print("Possible names are:")
		
		for n,old in pairs(AIVEGlobals) do
			print("	" .. n .. ": "..tostring(AIVEGlobals[n]))
		end
	end
	
end

-- acDump
if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acDump", "Dump internal state of AIVehicleExtension", "acDump", AIVehicleExtension)
end
function AIVehicleExtension:acDump()
	atDump = true
end

function AIVehicleExtension:acDump2()	
	atDump = nil
	for i=1,AIVEGlobals.chainMax+1 do
		local text = string.format("i: %i, a: %i",i,self.aseChain.nodes[i].angle)
		if self.aseChain.nodes[i].status >=	1 then
			text = text .. string.format(" s: %i",math.deg( self.aseChain.nodes[i].steering ))
		end
		if self.aseChain.nodes[i].status >=	2 then
			text = text .. string.format(" r: %i",math.deg( self.aseChain.nodes[i].rotation ))
		end
		if self.aseChain.nodes[i].status >=	3 then
			for j=1,table.getn(self.aseTools) do
				if			self.aseChain.nodes[i].tool[j]	 ~= nil 
						and self.aseChain.nodes[i].tool[j].x ~= nil 
						and self.aseChain.nodes[i].tool[j].z ~= nil then
					local x1,y1,z1 = localToWorld( self.aseChain.nodes[i].index, self.aseChain.nodes[i].tool[j].x, 0, self.aseChain.nodes[i].tool[j].z )
					local x2,y2,z2 = worldToLocal( self.aseChain.refNode, x1, y1, z1 )
					text = text .. string.format( " x: %0.3f z: %0.3f",x2,z2)							
				end
			end
		end
		
		print(text)
	end
end

--==============================================================				
--==============================================================			
------------------------------------------------------------------------
-- AIVehicleExtension:detectAngle
------------------------------------------------------------------------
function AIVehicleExtension:detectAngle( smooth )
	return AutoSteeringEngine.processChain( self, ( self.acTurnStage == 0 or self.acTurnStage == 199 ) )
end

------------------------------------------------------------------------
-- AIVehicleExtension:getMaxAngleWithTool
------------------------------------------------------------------------
function AIVehicleExtension:getMaxAngleWithTool( outside )
	
--local angle
--local toolAngle = AutoSteeringEngine.getToolAngle( self )	
--if not self.acParameters.leftAreaActive then
--	toolAngle = -toolAngle
--end
--
--if outside then
--	angle = -self.acDimensions.maxSteeringAngle + math.min( 2 * math.max( -toolAngle - AIVEGlobals.maxToolAngle, 0 ), 0.9 * self.acDimensions.maxSteeringAngle )	-- 75° => 1,3089969389957471826927680763665
--else
--	angle =  self.acDimensions.maxSteeringAngle - math.min( 2 * math.max(  toolAngle - AIVEGlobals.maxToolAngle, 0 ), 0.9 * self.acDimensions.maxSteeringAngle )	-- 75° => 1,3089969389957471826927680763665
--end
--
--if AIVEGlobals.devFeatures > 0 and math.abs( toolAngle ) >= AIVEGlobals.maxToolAngle - 0.01745 then
--	self:acDebugPrint( string.format("Tool angle: a: %0.1f° ms: %0.1f° to: %0.1f°", math.deg(angle), math.deg(self.acDimensions.maxSteeringAngle), math.deg(toolAngle) ) )
--end
--
--
--return angle
	if outside then
		return -self.acDimensions.maxSteeringAngle
	end
	return self.acDimensions.maxSteeringAngle
end

------------------------------------------------------------------------
-- AIVehicleExtension:waitForAnimTurnStage
------------------------------------------------------------------------
function AIVehicleExtension:waitForAnimTurnStage( turnStage )
	if     turnStage <  0
			or ( turnStage == 0 and AIVEGlobals.raiseNoFruits > 0 )
			or turnStage == 3
			or turnStage == 8
			or turnStage == 26 or turnStage == 27
			or turnStage == 38
			or turnStage == 48 or turnStage == 49
			or turnStage == 59 or turnStage == 60 or turnStage == 61 
			or turnStage == 77 or turnStage == 78 or turnStage == 79 then
		return true
	end
	return false
end			

------------------------------------------------------------------------
-- AIVehicleExtension:checkCorrectField
------------------------------------------------------------------------
function AIVehicleExtension:checkIsCorrectField()
--local wx,_,wz = localToWorld( self.aseChain.refNode, 0.5 * ( self.aseActiveX + self.aseOtherX ), 0, 0.5 * ( self.aseStart + self.aseDistance ) )
--if self.aseCurrentField ~= nil and not AutoSteeringEngine.checkField( self, wx, wz ) then
--	local checkFunction, areaTotalFunction = AutoSteeringEngine.getCheckFunction( self )
--	if AutoSteeringEngine.checkFieldNoBuffer( wx, wz, checkFunction ) then
--		return false 
--	end
--end
	
	return true
end

------------------------------------------------------------------------
-- AIVehicleExtension:stopWaiting
------------------------------------------------------------------------
function AIVehicleExtension:stopWaiting( angle )
	local a
	if self.acParameters.leftAreaActive then
		a = angle 
	else	 
		a = -angle 
	end
	
	if math.abs( a - AutoSteeringEngine.currentSteeringAngle( self, self.isReverseDriving ) ) < 0.05236 then -- 3° 
		return true 
	end
	return false
end

------------------------------------------------------------------------
-- AIVehicleExtension:navigationFallbackRetry
------------------------------------------------------------------------
function AIVehicleExtension:navigationFallbackRetry( uTurn )
	local x, z, allowedToDrive = AIVehicleExtension.getTurnVector( self, uTurn )
	local a = AutoSteeringEngine.normalizeAngle( math.pi - AutoSteeringEngine.getTurnAngle( self )	)
	local angle = 0

	if z < 1 and math.abs( a ) > 0.9 * math.pi then
		angle = 0
	elseif x > 0 then
		-- D: turn away from target point for next try
		angle = -self.acDimensions.maxSteeringAngle
	else
		-- E: turn away from target point for next try
		angle =  self.acDimensions.maxSteeringAngle
	end
	
	return angle
end

------------------------------------------------------------------------
-- AIVehicleExtension:navigationFallbackRotateMinus
------------------------------------------------------------------------
function AIVehicleExtension:navigationFallbackRotateMinus( uTurn )
	local angle = -self.acDimensions.maxSteeringAngle					
	if not self.acParameters.leftAreaActive then
		angle = -angle		
	end	
	return angle
end

------------------------------------------------------------------------
-- AIVehicleExtension:getTurnVector
------------------------------------------------------------------------
function AIVehicleExtension:getTurnVector( uTurn, turn2Outside )

	local x, z = AutoSteeringEngine.getTurnVector( self, Utils.getNoNil( uTurn, false ), Utils.getNoNil( turn2Outside, false ) )
 
	return x, z, true
end

------------------------------------------------------------------------
-- AIVehicleExtension:getToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getToolAngle()

	local toolAngle = AutoSteeringEngine.getToolAngle( self )
	if not self.acParameters.leftAreaActive then
		toolAngle = -toolAngle
	end
	
	return toolAngle
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getStraighBackwardsAngle
------------------------------------------------------------------------
function AIVehicleExtension:getStraighBackwardsAngle( iTarget )

	local target = math.rad( Utils.getNoNil( iTarget, 0 ) )

	local turnAngle = AutoSteeringEngine.getTurnAngle( self ) 
	if self.acParameters.leftAreaActive then
		turnAngle = -turnAngle
	end
	
	local ta  = turnAngle
	turnAngle = AutoSteeringEngine.normalizeAngle( turnAngle - target )
	
	self:acDebugPrint( "gSBA init: target: "..AutoSteeringEngine.degToString( iTarget ).." current: "..AutoSteeringEngine.radToString( ta ).." delta: "..AutoSteeringEngine.radToString( turnAngle ))
	
	return AIVehicleExtension.getStraighBackwardsAngle2( self, turnAngle, target )
end

------------------------------------------------------------------------
-- AIVehicleExtension:getStraighBackwardsAngle2
------------------------------------------------------------------------
function AIVehicleExtension:getStraighBackwardsAngle2( turnAngle, iTarget )
	
	local taJoints = AutoSteeringEngine.getTaJoints1( self, self.acRefNode, self.acDimensions.zOffset )

	if 	 	 AutoSteeringEngine.tableGetN( taJoints  ) < 1
			or self.aiveChain         == nil
			or self.aiveChain.trace   == nil
			or self.aiveChain.trace.a == nil then
		self:acDebugPrint( "gSBA: no tools with joint found: "..AutoSteeringEngine.radToString( -turnAngle ))
		return -turnAngle
	end

	local yv = -self.aiveChain.trace.a - math.pi
	if iTarget ~= nil then
		if self.acParameters.leftAreaActive then
			yv = AutoSteeringEngine.normalizeAngle( yv + iTarget )
		else
			yv = AutoSteeringEngine.normalizeAngle( yv - iTarget )
		end
	end
	
	local yt = AutoSteeringEngine.getWorldYRotation( taJoints[1].nodeTrailer )
	
	local maxWorldRatio = 0.75 / AutoSteeringEngine.tableGetN( taJoints  )
	local ratio  = Utils.clamp( 3 * AutoSteeringEngine.normalizeAngle( yv - yt ) / AIVEGlobals.maxToolAngle, -maxWorldRatio, maxWorldRatio )
	local target = ratio

	local sumTargetFactors = 0
	for _,joint in pairs( taJoints ) do
		sumTargetFactors = sumTargetFactors + joint.targetFactor
	end
	
	local maxToolDegrees = AIVEGlobals.maxToolAngle / sumTargetFactors
	for _,joint in pairs( taJoints ) do
		target    = joint.targetFactor * ratio
		degree    = AutoSteeringEngine.getRelativeYRotation( joint.nodeVehicle, joint.nodeTrailer )
		if joint.otherDirection then
			degree  = AutoSteeringEngine.normalizeAngle( degree + math.pi )
		end
		angle     = Utils.clamp( degree / maxToolDegrees, -1, 1 )	
		ratio     = Utils.clamp( target + 1.5 * ( angle - ratio ), -1, 1 )
	end
	
	angle = ratio * self.acDimensions.maxSteeringAngle
	
	if not self.acParameters.leftAreaActive then
		angle = -angle 
	end
	
	self:acDebugPrint( "gSBA: current: "..AutoSteeringEngine.radToString( yt ).." target: "..AutoSteeringEngine.radToString( yv ).." => angle: "..AutoSteeringEngine.radToString( angle ).." ("..tostring( self.acParameters.leftAreaActive ).." / "..tostring( iTarget ).." / "..AutoSteeringEngine.radToString( self.aiveChain.trace.a )..")")
	
	return angle 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getStraighForwardsAngle( iTarget )

	local target = math.rad( Utils.getNoNil( iTarget, 0 ) )

	local toolAngle = AutoSteeringEngine.getToolAngle( self )
	local turnAngle = AutoSteeringEngine.getTurnAngle( self ) 
	if self.acParameters.leftAreaActive then
		turnAngle = -turnAngle
	else
		toolAngle = -toolAngle
	end
	turnAngle = turnAngle - target 
	
	angle = 0
	
	if      math.abs( toolAngle ) > math.abs( turnAngle ) then
		angle = -toolAngle 
	else
		angle = turnAngle 
	end
	
	self:acDebugPrint( "gSFA: "..AutoSteeringEngine.degToString( iTarget ).." "..AutoSteeringEngine.radToString( toolAngle ).." "..AutoSteeringEngine.radToString( turnAngle ).." => "..AutoSteeringEngine.radToString( angle ))
	
	angle = Utils.clamp( angle, -self.acDimensions.maxSteeringAngle, self.acDimensions.maxSteeringAngle )

	return angle 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getLimitedToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getLimitedToolAngle( iLimit )

	local toolAngle = AIVehicleExtension.getToolAngle( self )
	local limit     = Utils.getNoNil( iLimit, 0.5 * self.acDimensions.maxSteeringAngle )
	
	if     toolAngle >=  limit then
		toolAngle =  limit
	elseif toolAngle <= -limit then
		toolAngle = -limit
	else
		local x   = toolAngle / limit
		toolAngle = toolAngle * 2 / ( 1 + x^2 )
	end
	
	return toolAngle
end

------------------------------------------------------------------------
-- AIVehicleExtension:onAttachImplement
------------------------------------------------------------------------
function AIVehicleExtension:onAttachImplement(implement)
	self.aiveToolsDirtyFlag = true
end

------------------------------------------------------------------------
-- AIVehicleExtension:onDetachImplement
------------------------------------------------------------------------
function AIVehicleExtension:onDetachImplement(implementIndex)
	self.aiveToolsDirtyFlag = true
end

------------------------------------------------------------------------
-- AIVehicleExtension:stopCoursePlayMode2
------------------------------------------------------------------------
function AIVehicleExtension:stopCoursePlayMode2( stopCP )
	if      ( stopCP or self.acStopCP ) 
			and self.courseplayers       ~= nil
			and self.courseplayers[1]    ~= nil
			and self.courseplayers[1].cp ~= nil then
		
		if stopCP then
			if not ( self.courseplayers[1].cp.forcedToStop ) then
				self.courseplayers[1].cp.forcedToStop = true
				self.acStopCP = true
			end
		elseif self.acStopCP then
			self.acStopCP = nil
			self.courseplayers[1].cp.forcedToStop = false
		end
	end
end

--==============================================================				
--==============================================================			
function AIVehicleExtension:afterSetDriveStrategies()	
	if self.acParameters == nil then
		self.aiveIsStarted = false
	elseif self.aiIsStarted and self.acParameters.enabled then
		self.aiveIsStarted = true
	end
	if self.aiveIsStarted and self.driveStrategies ~= nil and #self.driveStrategies > 0 then
		for i,d in pairs( self.driveStrategies ) do
			local driveStrategyMogli = nil
			if     d:isa(AIDriveStrategyStraight) then
				driveStrategyMogli = AIDriveStrategyMogli:new()
			elseif d:isa(AIDriveStrategyCombine)  then
				driveStrategyMogli = AIDriveStrategyCombine131:new()
			end
			if driveStrategyMogli ~= nil then
				driveStrategyMogli:setAIVehicle(self)
				self.driveStrategies[i] = driveStrategyMogli
			end
		end
		
		if AIVEGlobals.otherAIColli > 0 then
			local driveStrategyOtherAI = AIDriveStrategyCollisionOtherAI:new()
			driveStrategyOtherAI:setAIVehicle(self)
			table.insert( self.driveStrategies, 1, driveStrategyOtherAI )
		end
		
		AutoSteeringEngine.invalidateField( self, self.acParameters.useAIFieldFct )
		AutoSteeringEngine.initFruitBuffer( self )
		self.aiRescueTimer = self.acDeltaTimeoutStop
		self.hasStopped    = true
	else
		self.aiveIsStarted = false
	end
end

AIVehicle.setDriveStrategies = Utils.appendedFunction( AIVehicle.setDriveStrategies, AIVehicleExtension.afterSetDriveStrategies )

--==============================================================		
-- AIVehicle.canStartAIVehicle		
--==============================================================				
---Returns true if ai can start
-- @return boolean canStart can start ai
-- @includeCode
function AIVehicleExtension:newCanStartAIVehicle( superFunc, ... )
	-- check if reverse driving is available and used, we do not allow the AI to work when reverse driving is enabled

	if      self.acParameters ~= nil
			and self.acParameters.enabled
			and self.articulatedAxis ~= nil
			and not ( self.aiveCanStartArtAxis ) then
		return false
	end
	
	local backup = self.isReverseDriving
	
	if      self.acParameters ~= nil
			and self.acParameters.enabled then
		self.isReverseDriving = false
	end

	local res = { superFunc( self, ... ) }
	
	self.isReverseDriving = backup
	
	return unpack( res )
end

AIVehicle.canStartAIVehicle = Utils.overwrittenFunction( AIVehicle.canStartAIVehicle, AIVehicleExtension.newCanStartAIVehicle )

------------------------------------------------------------------------
-- onOtherAICollisionTrigger
------------------------------------------------------------------------
function AIVehicleExtension:onOtherAICollisionTrigger(triggerId, otherId, onEnter, onLeave, onStay, otherShapeId)
--print(" HIT @:"..self.configFileName.."   IN   "..getName(triggerId).."   BY   "..getName(otherId)..", "..getName(otherShapeId))

	if g_currentMission.players[otherId] == nil then
		local vehicle = g_currentMission.nodeToVehicle[otherId]
		local otherAI = nil
			
		if vehicle ~= nil then
			if vehicle.specializations ~= nil and SpecializationUtil.hasSpecialization( AIVehicle, vehicle.specializations ) then
				otherAI = vehicle 
			elseif type( vehicle.getRootAttacherVehicle ) == "function" then
				otherAI = vehicle:getRootAttacherVehicle()
				if otherAI.specializations == nil or not SpecializationUtil.hasSpecialization( AIVehicle, otherAI.specializations ) then
					otherAI = nil
				end
			end
		end
			
		if      otherAI ~= nil
				and otherAI ~= self then
			if onLeave then
				self.acCollidingVehicles[triggerId][otherAI] = nil
			else
				self.acCollidingVehicles[triggerId][otherAI] = true
			end
		end		
	end
end