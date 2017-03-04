--
-- AIVehicleExtension
-- Extended AIVehicle
--
-- @author	mogli aka biedens
-- @version 1.1.0.4
-- @date		23.03.2014
--
--	code source: AIVehicle.lua by Giants Software		
 
AIVehicleExtension = {};
local AtDirectory = g_currentModDirectory;

------------------------------------------------------------------------
-- INCLUDES
------------------------------------------------------------------------
source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
_G[g_currentModName..".mogliBase"].newClass( "AIVehicleExtension", "acParameters" )
------------------------------------------------------------------------
source(Utils.getFilename("mogliHud.lua", g_currentModDirectory));
_G[g_currentModName..".mogliHud"].newClass( "AIVEHud", "atHud" )
------------------------------------------------------------------------
source(Utils.getFilename("AIVEEvents.lua", g_currentModDirectory));
------------------------------------------------------------------------
source(Utils.getFilename("FieldBitmap.lua", g_currentModDirectory));
source(Utils.getFilename("FrontPacker.lua", g_currentModDirectory));
source(Utils.getFilename("AutoSteeringEngine.lua", g_currentModDirectory));
source(Utils.getFilename("AIDriveStrategyMogli.lua", g_currentModDirectory));
source(Utils.getFilename("AIDriveStrategyCombine131.lua", g_currentModDirectory));

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
																			enabled         = { xml = "acDefaultOn",	 tp = "B", default = false },
																			upNDown				  = { xml = "acUTurn",			 tp = "B", default = false, always = true },
																			rightAreaActive = { xml = "acAreaRight",	 tp = "B", default = false },
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
																			safetyFactor		= { xml = "acSafetyFactor",tp = "I", default = AIVEGlobals.safetyFactor },
																			angleFactor		  = { xml = "acAngleFactorN",tp = "F", default = 0.5 },
																			speedFactor		  = { xml = "acSpeedFactor", tp = "F", default = 1 },
																			noSteering			= { xml = "acNoSteering",	 tp = "B", default = false } };																															
AIVehicleExtension.turnStageNoNext = { 21, 22, 23 } --{ 0 }
AIVehicleExtension.turnStageEnd	= { { 4, -1 },
															{ 8, -1 },
															{ 9, -1 },
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
		 and SpecializationUtil.hasSpecialization(AIVehicle, specializations) -- )
			--or ( SpecializationUtil.hasSpecialization(Motorized, specializations)	
			 --and SpecializationUtil.hasSpecialization(Steerable, specializations)
			 --and SpecializationUtil.hasSpecialization(Mower, specializations) )
		 --and not SpecializationUtil.hasSpecialization(ArticulatedAxis, specializations)
end;

------------------------------------------------------------------------
-- load
------------------------------------------------------------------------
function AIVehicleExtension:load(saveGame)

	-- for courseplay	
	self.acNumCollidingVehicles = 0
	self.acIsCPStopped				= false
	self.acTurnStage					= 0
	self.acPause							= false	
	self.acParameters				  = AIVehicleExtension.getParameterDefaults( )
	self.acAxisSide					  = 0
	self.acSentSpeedFactor		= 0.8
	self.acDebugPrint			  	= AIVehicleExtension.debugPrint
	self.aiveAddDebugText     = AIVehicleExtension.aiveAddDebugText
	self.acShowTrace					= false
	self.waitForTurnTime      = 0
	self.turnTimer            = 0
	self.aiRescueTimer        = 0
	
	self.acDeltaTimeoutWait	  = math.max(Utils.getNoNil( self.waitForTurnTimeout, 1600 ), 1000 ); 
	self.acDeltaTimeoutRun		= math.max(Utils.getNoNil( self.turnTimeout, 800 ), 500 );
	self.acDeltaTimeoutStop	  = math.max(Utils.getNoNil( self.turnStage1Timeout , 20000), 10000);
	self.acDeltaTimeoutStart	= math.max(Utils.getNoNil( self.turnTimeoutLong	 , 6000 ), 4000 );
	self.acDeltaTimeoutNoTurn = 2 * self.acDeltaTimeoutWait --math.max(Utils.getNoNil( self.waitForTurnTimeout , 2000 ), 1000 );
	self.acRecalculateDt			= 0;
	self.acTurn2Outside	      = false;
	self.acCollidingVehicles	= {};
	self.acTurnStageSent			= 0;
	self.acWaitTimer					= 0;
	self.acTurnOutsideTimer   = 0;
	self.acSteeringSpeed      = self.aiSteeringSpeed
	
	detected = nil;	
	fruitsDetected = nil;
	
	self.acAutoRotateBackSpeedBackup = self.autoRotateBackSpeed;	

	local tempNode = self.aiVehicleDirectionNode;
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
	
	self.acHasRoueSpec = false;
	if AIVEGlobals.roueSupport > 0 then
		for name,entry in pairs( SpecializationUtil.specializations ) do
			local s,e = string.find( entry.className, ".Roue" )
			if s ~= nil and e == string.len( entry.className ) then
				local c = SpecializationUtil.getSpecialization(entry.name);
				if SpecializationUtil.hasSpecialization(c, self.specializations) then
					--print("found Roue spec.")--print( self.name.." has Roue spec." );
					if c.changeSteer ~= nil then
						self.acHasRoueSpec = true;
						self.acRoueUpdate = c.update
						c.changeSteer = Utils.appendedFunction( c.changeSteer, AIVehicleExtension.roueChangeSteer );
						print( "AIVehicleExtension connection to 4-wheel steering registered" );
					end
				end
			end
		end
	end	

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
	
	local mogliRows = 4
	local mogliCols = 6
	if AIVEGlobals.devFeatures > 0 then
		mogliCols = mogliCols + 1
	end
	--(												directory,	 hudName, hudBackground, onTextID, offTextID, showHudKey, x,y, nx, ny, w, h, cbOnClick )
	AIVEHud.init( self, AtDirectory, "AIVEHud", 0.4, "AUTO_TRACTOR_TEXTHELPPANELON", "AUTO_TRACTOR_TEXTHELPPANELOFF", InputBinding.AUTO_TRACTOR_HELPPANEL, 0.395, 0.0108, mogliCols, mogliRows, AIVehicleExtension.sendParameters )--, nil, nil, 0.8 )
	AIVEHud.setTitle( self, "AUTO_TRACTOR_VERSION" )
	
	if AIVEGlobals.devFeatures > 0 then
		AIVEHud.addButton(self, nil, nil, AIVehicleExtension.test1, nil, mogliCols,1, "Turn Outside");
		AIVEHud.addButton(self, nil, nil, AIVehicleExtension.test2, nil, mogliCols,2, "Turn Inside" );
		AIVEHud.addButton(self, nil, nil, AIVehicleExtension.test3, nil, mogliCols,3, "Trace" );
		AIVEHud.addButton(self, nil, nil, AIVehicleExtension.test4, nil, mogliCols,4, "Points" );
	end

	AIVEHud.addButton(self, "dds/off.dds",						"dds/on.dds",					  AIVehicleExtension.setAIVEStarted,AIVehicleExtension.evalStart,		1,1, "HireEmployee", "DismissEmployee", nil, AIVehicleExtension.getStartImage );
	AIVEHud.addButton(self, "dds/ai_combine.dds",		  "dds/auto_combine.dds", AIVehicleExtension.onEnable,			AIVehicleExtension.evalEnable,		 2,1, "AUTO_TRACTOR_STOP", "AUTO_TRACTOR_START" );
	AIVEHud.addButton(self, "dds/no_uturn2.dds",			"dds/uturn.dds",				AIVehicleExtension.setUTurn,			AIVehicleExtension.evalUTurn,			3,1, "AUTO_TRACTOR_UTURN_OFF", "AUTO_TRACTOR_UTURN_ON") ;
	AIVEHud.addButton(self, "dds/next.dds",					  "dds/no_next.dds",			AIVehicleExtension.nextTurnStage, AIVehicleExtension.evalTurnStage,	4,1, "AUTO_TRACTOR_NEXTTURNSTAGE", nil );
	AIVEHud.addButton(self, "dds/no_pause.dds",			  "dds/pause.dds",				AIVehicleExtension.setPause,			AIVehicleExtension.evalPause,			5,1, "AUTO_TRACTOR_PAUSE_OFF", "AUTO_TRACTOR_PAUSE_ON", nil, AIVehicleExtension.getPauseImage );
--AIVEHud.addButton(self, "dds/auto_steer_off.dds", "dds/auto_steer_on.dds",AIVehicleExtension.onAutoSteer,	 AIVehicleExtension.evalAutoSteer,	6,1, "AUTO_TRACTOR_STEER_ON", "AUTO_TRACTOR_STEER_OFF" );

	AIVEHud.addButton(self, "dds/noHeadland.dds",		  "dds/headland.dds",		  AIVehicleExtension.setHeadland,	 AIVehicleExtension.evalHeadland,	 1,2, "AUTO_TRACTOR_HEADLAND_ON", "AUTO_TRACTOR_HEADLAND_OFF" );
	AIVEHud.addButton(self, nil,											nil,										AIVehicleExtension.setBigHeadland,nil,												2,2, "AUTO_TRACTOR_HEADLAND", nil, AIVehicleExtension.getBigHeadlandText, AIVehicleExtension.getBigHeadlandImage );
	AIVEHud.addButton(self, "dds/collision_off.dds",	"dds/collision_on.dds", AIVehicleExtension.setCollision,	AIVehicleExtension.evalCollision,	3,2, "AUTO_TRACTOR_COLLISION_OFF", "AUTO_TRACTOR_COLLISION_ON" );
	AIVEHud.addButton(self, nil,											nil,										AIVehicleExtension.setTurnMode,	 nil,												4,2, nil, nil, AIVehicleExtension.getTurnModeText, AIVehicleExtension.getTurnModeImage );
	AIVEHud.addButton(self, "dds/hire_off.dds",			  "dds/hire_on.dds",			AIVehicleExtension.setIsHired,		AIVehicleExtension.evalIsHired,		5,2, "AUTO_TRACTOR_HIRE_OFF", "AUTO_TRACTOR_HIRE_ON");
	AIVEHud.addButton(self, "dds/raise_impl.dds",		  "dds/lower_impl.dds",	  AIVehicleExtension.onRaiseImpl,	 AIVehicleExtension.evalRaiseImpl,	6,2, "AUTO_TRACTOR_STEER_LOWER", "AUTO_TRACTOR_STEER_RAISE", nil, AIVehicleExtension.getRaiseImplImage );

	AIVEHud.addButton(self, "dds/inactive_left.dds",	"dds/active_left.dds",	AIVehicleExtension.setAreaLeft,	 AIVehicleExtension.evalAreaLeft,	 1,3, "AUTO_TRACTOR_ACTIVESIDERIGHT", "AUTO_TRACTOR_ACTIVESIDELEFT" );
	AIVEHud.addButton(self, "dds/inactive_right.dds", "dds/active_right.dds", AIVehicleExtension.setAreaRight,	AIVehicleExtension.evalAreaRight,	2,3, "AUTO_TRACTOR_ACTIVESIDELEFT", "AUTO_TRACTOR_ACTIVESIDERIGHT" );	
	AIVEHud.addButton(self, "dds/bigger.dds",				  nil,										AIVehicleExtension.setWidthUp,		nil,												3,3, "AUTO_TRACTOR_WIDTH_OFFSET", nil, AIVehicleExtension.getWidth);
	AIVEHud.addButton(self, "dds/smaller.dds",				nil,										AIVehicleExtension.setWidthDown,	nil,												4,3, "AUTO_TRACTOR_WIDTH_OFFSET", nil, AIVehicleExtension.getWidth);
	AIVEHud.addButton(self, "dds/forward.dds",				nil,										AIVehicleExtension.setForward,		nil,												5,3, "AUTO_TRACTOR_TURN_OFFSET", nil, AIVehicleExtension.getTurnOffset);
	AIVEHud.addButton(self, "dds/backward.dds",			  nil,										AIVehicleExtension.setBackward,	 nil,												6,3, "AUTO_TRACTOR_TURN_OFFSET", nil, AIVehicleExtension.getTurnOffset);

	AIVEHud.addButton(self, "dds/notInverted.dds",		"dds/inverted.dds",		  AIVehicleExtension.setInverted,	 AIVehicleExtension.evalInverted,	 1,4, "AUTO_TRACTOR_INVERTED_OFF", "AUTO_TRACTOR_INVERTED_ON" );	
	AIVEHud.addButton(self, "dds/noFrontPacker.dds",	"dds/frontPacker.dds",	AIVehicleExtension.setFrontPacker,AIVehicleExtension.evalFrontPacker,2,4, "AUTO_TRACTOR_FRONT_PACKER_OFF", "AUTO_TRACTOR_FRONT_PACKER_ON" );
	AIVEHud.addButton(self, "dds/safety_ina.dds",		  nil,										AIVehicleExtension.onToggleTrace, nil,												3,4, "AUTO_TRACTOR_TRACE", nil );
	AIVEHud.addButton(self, "dds/refresh.dds",				nil,										AIVehicleExtension.onMagic,			 nil,												4,4, "AUTO_TRACTOR_MAGIC", nil );
	AIVEHud.addButton(self, "dds/angle_plus.dds",		  nil,										AIVehicleExtension.setAngleUp,		AIVehicleExtension.evalAngleUp,		5,4, "AUTO_TRACTOR_ANGLE_OFFSET", nil, AIVehicleExtension.getAngleFactor);
	AIVEHud.addButton(self, "dds/angle_minus.dds",		nil,										AIVehicleExtension.setAngleDown,	AIVehicleExtension.evalAngleDown,	6,4, "AUTO_TRACTOR_ANGLE_OFFSET", nil, AIVehicleExtension.getAngleFactor);
	
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
		if			self.acParameters ~= nil
				and ( self.aiIsStarted or self.acTurnStage >= 197 ) then
			alwaysDrawTitle = true
		end
		AIVEHud.draw(self,self.acLCtrlPressed,alwaysDrawTitle);
	elseif self.acLCtrlPressed == nil or not self.acLCtrlPressed then
		g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_TEXTHELPPANELON"), InputBinding.AUTO_TRACTOR_HELPPANEL);
	end

	if     self.acLCtrlPressed then
		if AIVehicleExtension.evalAutoSteer(self) then
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_STEER_ON"), InputBinding.AUTO_TRACTOR_STEER);
		elseif self.acTurnStage >= 198 then
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_STEER_OFF"),InputBinding.AUTO_TRACTOR_STEER);
		end	
	elseif self.acLAltPressed then
		if self.acParameters.upNDown then
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_UTURN_ON"), InputBinding.AUTO_TRACTOR_UTURN_ON_OFF)
		else
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_UTURN_OFF"), InputBinding.AUTO_TRACTOR_UTURN_ON_OFF)
		end
		if self.acParameters.noSteering then
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_STEERING_OFF"), InputBinding.AUTO_TRACTOR_STEERING)
		else
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_STEERING_ON"), InputBinding.AUTO_TRACTOR_STEERING)
		end
	else
		if self.aiIsStarted then
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_STOP"), InputBinding.AUTO_TRACTOR_START_AIVE);
		else
			g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_START"), InputBinding.AUTO_TRACTOR_START_AIVE);
		end

		if not ( self.acLShiftPressed ) then
			if self.acParameters.rightAreaActive then
				g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_ACTIVESIDERIGHT"), InputBinding.AUTO_TRACTOR_SWAP_SIDE)
			else
				g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_ACTIVESIDELEFT"), InputBinding.AUTO_TRACTOR_SWAP_SIDE)
			end
		end
	end	
	
	if self.acPause then
		g_currentMission:addHelpButtonText(AIVEHud.getText("AUTO_TRACTOR_CONTINUE"), InputBinding.TOGGLE_CRUISE_CONTROL)
	end
	
end;

------------------------------------------------------------------------
-- onLeave
------------------------------------------------------------------------
function AIVehicleExtension:onLeave()
	if self.atMogliInitDone then
		AIVEHud.onLeave(self);
	end
end;

------------------------------------------------------------------------
-- onEnter
------------------------------------------------------------------------
function AIVehicleExtension:onEnter()
	if self.atMogliInitDone then
		AIVEHud.onEnter(self);
	end
end;

------------------------------------------------------------------------
-- mouseEvent
------------------------------------------------------------------------
function AIVehicleExtension:mouseEvent(posX, posY, isDown, isUp, button)
	if self.isEntered and self.isClient and self.atMogliInitDone then
		AIVEHud.mouseEvent(self, posX, posY, isDown, isUp, button);	
	end
end

------------------------------------------------------------------------
-- delete
------------------------------------------------------------------------
function AIVehicleExtension:delete()
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
end;

------------------------------------------------------------------------
-- mouse event callbacks
------------------------------------------------------------------------
function AIVehicleExtension.showGui(self,on)
	if on then
		if self.atMogliInitDone == nil or not self.atMogliInitDone then
			AIVehicleExtension.initMogliHud(self)
		end
		AIVEHud.showGui(self,true)
	elseif self.atMogliInitDone then
		AIVEHud.showGui(self,false)
	end
end;

function AIVehicleExtension:evalUTurn()
	return not self.acParameters.upNDown;
end;

function AIVehicleExtension:setUTurn(enabled)
	self.acParameters.upNDown = enabled;
end;

function AIVehicleExtension:evalHeadland()
	return not ( self.acParameters.upNDown and self.acParameters.headland );
end

function AIVehicleExtension:setHeadland(enabled)
	if not enabled then
		self.acParameters.headland = enabled;
	elseif	self.acParameters.upNDown 				 
			and ( not self.aiIsStarted or self.acTurnStage == 0 ) then
		self.acParameters.headland = enabled;
	end
end

function AIVehicleExtension:evalIsHired()
	return not self.acParameters.isHired
end

function AIVehicleExtension:setIsHired(enabled)
	self.acParameters.isHired = enabled
end 

function AIVehicleExtension:evalCollision()
	return not ( self.acParameters.upNDown and self.acParameters.collision );
end

function AIVehicleExtension:setCollision(enabled)
	if not enabled then
		self.acParameters.collision = enabled;
	elseif	self.acParameters.upNDown then
		self.acParameters.collision = enabled;
	end
end

function AIVehicleExtension:evalInverted()
	return not self.acParameters.inverted
end

function AIVehicleExtension:setInverted(enabled)
	self.acParameters.inverted = enabled;
end

function AIVehicleExtension:evalFrontPacker()
	return not self.acParameters.frontPacker
end

function AIVehicleExtension:setFrontPacker(enabled)
	self.acParameters.frontPacker = enabled
end

function AIVehicleExtension:evalAreaLeft()
	return not self.acParameters.leftAreaActive;
end;

function AIVehicleExtension:setAreaLeft(enabled)
	if not enabled then return; end;
	self.acParameters.leftAreaActive	= enabled;
	self.acParameters.rightAreaActive = not enabled;
end;

function AIVehicleExtension:evalAreaRight()
	return not self.acParameters.rightAreaActive;
end;

function AIVehicleExtension:setAreaRight(enabled)
	if not enabled then return; end;
	self.acParameters.rightAreaActive = enabled;
	self.acParameters.leftAreaActive	= not enabled;
end;

function AIVehicleExtension:evalStart()
	return not self.aiIsStarted or not AIVehicle.canStartAIVehicle(self);
end;

function AIVehicleExtension:getStartImage()
	if self.aiIsStarted then
		return "dds/on.dds"
	elseif AIVehicle.canStartAIVehicle(self) then
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
end;

function AIVehicleExtension:onEnable(enabled)
	if not ( self.aiIsStarted ) then
		self.acParameters.enabled = enabled
	end
end;

function AIVehicleExtension:setWidthUp()
	self.acParameters.widthOffset = self.acParameters.widthOffset + 0.125;
end;

function AIVehicleExtension:setWidthDown()
	self.acParameters.widthOffset = self.acParameters.widthOffset - 0.125;
end;

function AIVehicleExtension:getWidth(old)
	new = string.format(old..": %0.2fm",self.acParameters.widthOffset+self.acParameters.widthOffset);
	return new
end

function AIVehicleExtension:setForward()
	self.acParameters.turnOffset = self.acParameters.turnOffset + 0.25;
end;																							 

function AIVehicleExtension:setBackward()							 
	self.acParameters.turnOffset = self.acParameters.turnOffset - 0.25;
end;

function AIVehicleExtension:getTurnOffset(old)
	local new = ""
	if self.acDimensions == nil or self.acDimensions.headlandCount == nil then
		new = string.format(old..": %0.2fm",self.acParameters.turnOffset)
	else
		new = string.format(old..": %0.2fm (%i x)",self.acParameters.turnOffset,self.acDimensions.headlandCount)
	end
	return new
end

function AIVehicleExtension:getTurnIndexComp()
	if self.acParameters ~= nil and	not ( self.acParameters.upNDown ) then
		return "turnModeIndexC"
	end
	return "turnModeIndex"
end

function AIVehicleExtension:evalSafetyUp()
	local enabled = self.acParameters.safetyFactor < 10
	return enabled
end

function AIVehicleExtension:evalSafetyDown()
	local enabled = self.acParameters.safetyFactor > 0
	return enabled
end

function AIVehicleExtension:setSafetyUp(enabled)
	if enabled then self.acParameters.safetyFactor = math.min(10, self.acParameters.safetyFactor + 1 ) end
end

function AIVehicleExtension:setSafetyDown(enabled)
	if enabled then self.acParameters.safetyFactor = math.max( 0, self.acParameters.safetyFactor - 1 ) end
end

function AIVehicleExtension:evalAngleUp()
	local enabled = self.acParameters.angleFactor < 1;
	return enabled
end

function AIVehicleExtension:evalAngleDown()
	local enabled = self.acParameters.angleFactor >= 0.1;
	return enabled
end

function AIVehicleExtension:setAngleUp(enabled)
	if enabled then self.acParameters.angleFactor = Utils.clamp( self.acParameters.angleFactor + 0.05, 0.1, 1 ) end
end

function AIVehicleExtension:setAngleDown(enabled)
	if enabled then self.acParameters.angleFactor = Utils.clamp( self.acParameters.angleFactor - 0.05, 0.1, 1 ) end
end

function AIVehicleExtension:getMaxLookingAngleValue( noScale )
	if self.acDimensions == nil then
		return AIVEGlobals.maxLooking
	end
	
	local ml = Utils.getNoNil( self.acDimensions.maxSteeringAngle, AIVEGlobals.maxLooking )
	
	if			self.acParameters									~= nil
			and self.acParameters.angleFactor			~= nil then
		ml	= math.max( ml * self.acParameters.angleFactor, 0.0174533 )
	end

	return ml
end

function AIVehicleExtension:getAngleFactor(old)

	if			self.acParameters									~= nil
			and self.acParameters.angleFactor			~= nil then
		new = string.format(old..": %2.1f°",math.deg(AIVehicleExtension.getMaxLookingAngleValue( self )));
		new = string.format(new.." / %3d%%",math.floor(20*self.acParameters.angleFactor+0.5) * 5)
	else
		return old
	end
	
	return new
end

function AIVehicleExtension:getSafetyFactor(old)
	new = old..string.format(": %3d%%",self.acParameters.safetyFactor*10);
	if self.aseChain ~= nil and self.aseChain.offsetAvg ~= nil and self.aseOffsetStd ~= nil then
		new = new.. string.format( ": %4.2fm",self.aseChain.offsetAvg - self.aseOffsetStd )
	end
	return new
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
	--		return true;
	--	end
		end
	end
	
	return false
end

function AIVehicleExtension:nextTurnStage()
	AIVehicleExtension.setNextTurnStage(self);
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


function AIVehicleExtension:setAIVEStarted(enabled)
	if enabled and not self.aiIsStarted and AIVehicle.canStartAIVehicle(self) then
		self.aiveIsStarted = true 
		if g_server ~= nil then
			g_server:broadcastEvent(AIVEStartEvent:new(self,enabled), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(AIVEStartEvent:new(self,enabled))
		end
		AIVehicleExtension.setInt32Value( self, "speed2Level", 2 )
		self:startAIVehicle()
	elseif not enabled and self.aiveIsStarted then
		if self.aiIsStarted then
			self:stopAIVehicle()
		else
			self.aiveIsStarted = false 
		end
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
		AutoSteeringEngine.invalidateField( self )
		self.acLastSteeringAngle = nil;
		self.acTurnStage	 = 198
		self.acRotatedTime = 0
	else
		self.acTurnStage	 = 0
		self.stopMotorOnLeave = true
		self.deactivateOnLeave = true
	end
end

function AIVehicleExtension:onMagic(enabled)
	AIVehicleExtension.initMogliHud(self)
	AutoSteeringEngine.invalidateField( self, true )		
	AutoSteeringEngine.checkTools1( self, true )
--AIVehicleExtension.processImplementsOfImplement(self,self,true)	
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
	if self.acImplementsMoveDown then
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
	return AIVEHud.getText("AUTO_TRACTOR_TURN_MODE_"..self.acTurnMode)
end

function AIVehicleExtension:setBigHeadland()
	if self.acParameters.upNDown then
		self.acParameters.bigHeadland = not self.acParameters.bigHeadland
	end
end

function AIVehicleExtension:getBigHeadlandImage()
	local img = "empty.dds"
	
	if self.acParameters ~= nil and self.acParameters.upNDown and self.acParameters.headland then
		if self.acParameters.bigHeadland then		
			img = "dds/big_headland.dds"
		else
			img = "dds/small_headland.dds"
		end
	end
	
	return img
end

function AIVehicleExtension:getBigHeadlandText(old)
	if			self.acDimensions ~= nil 
			and self.acDimensions.headlandDist ~= nil
			and self.acParameters.upNDown then
		new = string.format(old..": %0.2fm",self.acDimensions.headlandDist );
	else
		new = old
	end
	return new
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

	if self.setIsReverseDriving ~= nil then
		self.acParameters.inverted = self.isReverseDriving
	end		

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
		local _,angle,_ = getRotation( self.articulatedAxis.componentJoint.jointNode );
		angle = 0.5 * angle
		setRotation( self.acRefNode, 0, AIVEGlobals.artAxisRot * angle, 0 )				
		setTranslation( self.acRefNode, AIVEGlobals.artAxisShift * dx, 0, AIVEGlobals.artAxisShift * dz + self.acDimensions.acRefNodeZ )			
	end

	if atDump and self:getIsActiveForInput(false) then
		AIVehicleExtension.acDump2(self);
	end

	if self.isEntered and self.isClient and self:getIsActive() then
		if self.acParameters.enabled and self.acTurnStage < 198 and not self.aiveIsStarted then
			AIVehicleExtension.checkState( self )
		end
	
		if AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_HELPPANEL" ) then
			local guiActive = false
			if self.atHud ~= nil and self.atHud.GuiActive ~= nil then
				guiActive = self.atHud.GuiActive
			end
			AIVehicleExtension.showGui( self, not guiActive );
		end;
		if      AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_START_AIVE" ) then
			if self.aiIsStarted then
				if self.aiveIsStarted then
					self:stopAIVehicle()
				end
			elseif AIVehicle.canStartAIVehicle(self) and self.acParameters ~= nil then
				AIVehicleExtension.setAIVEStarted( self, true )
			end
		elseif AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_SWAP_SIDE" ) then
			self.acParameters.leftAreaActive	= self.acParameters.rightAreaActive
			self.acParameters.rightAreaActive = not self.acParameters.leftAreaActive
			AIVehicleExtension.sendParameters(self);
			if self.isServer then AutoSteeringEngine.setChainStraight( self ) end
			if			self.acParameters ~= nil
					and not ( self.aiIsStarted ) then
				if self.acParameters.leftAreaActive then
					AIVehicle.aiRotateLeft(self);
				else
					AIVehicle.aiRotateRight(self);
				end			
			end
		elseif AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_STEER" ) then
			if self.acTurnStage < 198 then
				AIVehicleExtension.onAutoSteer(self, true)
			else
				AIVehicleExtension.onAutoSteer(self, false)
			end
		elseif AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_UTURN_ON_OFF" ) then
			self.acParameters.upNDown = not self.acParameters.upNDown
			AIVehicleExtension.sendParameters(self);
		elseif AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_STEERING" ) then
			self.acParameters.noSteering = not self.acParameters.noSteering
			AIVehicleExtension.sendParameters(self);
		elseif AIVehicleExtension.mbHasInputEvent( "IMPLEMENT_EXTRA" ) then
			self.acCheckPloughSide = true
		elseif AIVehicleExtension.mbHasInputEvent( "AUTO_TRACTOR_RAISE" ) then
			AIVehicleExtension.onRaiseImpl( self, AIVehicleExtension.evalRaiseImpl( self ) )
		end
		
		if self.aiIsStarted then
		--local cc = InputBinding.getDigitalInputAxis(InputBinding.AXIS_CRUISE_CONTROL)
		--local cd = false
		--if InputBinding.isAxisZero(cc) then
		--	cc = InputBinding.getAnalogInputAxis(InputBinding.AXIS_CRUISE_CONTROL)
		--	if InputBinding.isAxisZero(cc) then
		--		cc = 0
		--	else
		--		self.acParameters.speedFactor = Utils.clamp( self.acParameters.speedFactor + 0.00025 * dt * cc, 0.1, 1.1 )
		--	end
		--else
		--	local maxSpeed = AutoSteeringEngine.getToolsSpeedLimit( self )
		--	local cs = math.floor( 0.5 + self.acParameters.speedFactor * maxSpeed )
		--	if		 cc > 0 then
		--		cs = cs + 1
		--	elseif cc < 0 then
		--		cs = cs - 1
		--	end
		--	self.acParameters.speedFactor = Utils.clamp( cs / maxSpeed, 0.1, 1.1 )
		--end
		--if self.aiveIsStarted then
		--	self:setCruiseControlMaxSpeed( self.acParameters.speedFactor * AutoSteeringEngine.getToolsSpeedLimit( self ) )
		--end
		--	
		--if math.abs( self.acSentSpeedFactor - self.acParameters.speedFactor ) > 0.1 then
		--	AIVehicleExtension.sendParameters(self);
		--end
			
			if AIVehicleExtension.mbHasInputEvent( "TOGGLE_CRUISE_CONTROL" ) then
				if self.speed2Level == nil or self.speed2Level > 0 then
					AIVehicleExtension.setPause( self, true )
				else
					AIVehicleExtension.setPause( self, false )
				end
			end
		end
	end;
	
	if     self.aiveIsStarted      then
		if AIVEGlobals.devFeatures <= 0 or self.atHud.InfoText == nil or self.atHud.InfoText == "" then
			AIVEHud.setInfoText( self )
			if self.acDimensions ~= nil and self.acDimensions.distance ~= nil then
				AIVEHud.setInfoText( self, AIVEHud.getText( "AUTO_TRACTOR_WORKWIDTH" ) .. string.format(" %0.2fm", self.acDimensions.distance+self.acDimensions.distance) )
			end
			if self.acTurnStage ~= nil and self.acTurnStage ~= 0 and self.acTurnStage < 197 then
				AIVEHud.setInfoText( self, AIVEHud.getInfoText(self) .. string.format(" (%i)", self.acTurnStage) )
			end
		end
	elseif self.acTurnStage >= 198 then
		self.stopMotorOnLeave = false
		self.deactivateOnLeave = false
	end
	
	if			self.isEntered 
			and self.isClient 
			and self.isServer 
			and self:getIsActive() 
			and self.atMogliInitDone 
			and self.atHud.GuiActive then	

		if self.acParameters ~= nil and self.aiveIsStarted and self.acShowTrace then			
			if			AIVEGlobals.showTrace > 0 
					and self.acDimensions ~= nil
					and ( self.aiIsStarted or self.acTurnStage >= 198 ) then	
				AutoSteeringEngine.drawLines( self );
			else
				if not ( self.aiIsStarted or self.acTurnStage >= 198 ) then	
					AIVehicleExtension.checkState( self )
				end
				AutoSteeringEngine.drawMarker( self );
			end
		end
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
		local d, t, z = AutoSteeringEngine.checkTools( self );
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
	
	if		 self.acImplementsMoveDown == nil
			or self.acImplementsMoveDown ~= moveDown then
		self.acImplementsMoveDown = moveDown
		AutoSteeringEngine.setToolsAreLowered( self, moveDown, immediate )
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
-- checkAvailableTurnModes
------------------------------------------------------------------------
function AIVehicleExtension:checkAvailableTurnModes( noEventSend )

	if self.acDimensions == nil then
		AIVehicleExtension.calculateDimensions( self )
	end

	local sut, rev, revS, noHire = AutoSteeringEngine.getTurnMode( self )

	if noHire then
		self.acParameters.isHired = false
	end

	self.acTurnModes = {}
	
	if self.acParameters.upNDown then
		if rev	then
			if self.acDimensions.zBack ~= nil and self.acDimensions.zBack > 0 then
				table.insert( self.acTurnModes, "Y" )
			elseif AIVEGlobals.enableAUTurn > 0 and sut then
				table.insert( self.acTurnModes, "A" )
			end
		end
		if revS then
			table.insert( self.acTurnModes, "T" )
		end
		table.insert( self.acTurnModes, "O" )
		if self.acDimensions.zBack ~= nil and self.acDimensions.zBack < 0 then
			table.insert( self.acTurnModes, "8" )
		end
	else
		if rev	then
			table.insert( self.acTurnModes, "L"	)
		end
		if revS then
			table.insert( self.acTurnModes, "7"	)
		end
		if AIVEGlobals.enableKUTurn > 0 then
			table.insert( self.acTurnModes, "K"	)
		end
		table.insert( self.acTurnModes, "C"	)
	end
	
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
-- checkState
------------------------------------------------------------------------
function AIVehicleExtension:checkState( force )

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
	
	local h = 0;
	local c = 0;
	if			self.acParameters.collision
			and self.acParameters.upNDown
		--and self.acTurnStage ~=	-3 
		--and self.acTurnStage ~= -13 
		--and self.acTurnStage ~= -23 
			then
		c = self.acDimensions.collisionDist
	end
	if			self.acParameters.headland 
			and self.acParameters.upNDown 
		--and self.acTurnStage ~=	-3 
		--and self.acTurnStage ~= -13 
		--and self.acTurnStage ~= -23 
			then
		h = self.acDimensions.headlandDist
	end
	
	local maxLooking = self.acDimensions.maxLookingAngle
	if     maxLooking >= self.acDimensions.maxSteeringAngle then
		self.acFullAngle = true
	elseif self.acFullAngle then
		maxLooking = self.acDimensions.maxSteeringAngle
	end
	
	if self.isServer and self.aiveIsStarted then 
		AutoSteeringEngine.initTools( self, maxLooking, self.acParameters.leftAreaActive, self.acParameters.widthOffset, self.acParameters.safetyFactor, h, c, self.acTurnMode );
	end
end

------------------------------------------------------------------------
-- autoSteer
------------------------------------------------------------------------
function AIVehicleExtension:autoSteer(dt)
	
	AIVehicleExtension.checkState( self )

	if not AutoSteeringEngine.hasTools( self ) then
		self.acTurnStage = 0;
		return;
	end

--==============================================================		
	local smooth = 0
	local traceLength = AutoSteeringEngine.getTraceLength(self)

	if self.acTurnStage == 199 and traceLength > 3 then
		smooth = math.min( math.max( 0.1 * ( traceLength - 1 ), 0 ), 0.875 )
	end
	
	local detected, angle, border = AIVehicleExtension.detectAngle( self, smooth )			
--==============================================================						
	
	self.turnTimer = self.turnTimer - dt;
	
	if detected and border <= 0 then
		AIVehicleExtension.setStatus( self, 1 )
		if self.acTurnStage ~= 199 then
			self.acTurnStage = 199
			AutoSteeringEngine.clearTrace( self );
			AutoSteeringEngine.saveDirection( self, false );
		elseif AutoSteeringEngine.getIsAtEnd( self ) then
			if self.acParameters.leftAreaActive then
				angle = math.max( angle, 0 )
			else
				angle = math.min( angle, 0 )
			end
		end
		AutoSteeringEngine.saveDirection( self, true );
		self.turnTimer = self.acDeltaTimeoutRun
	elseif self.acTurnStage == 199 and self.turnTimer >= 0 then
		if border > 0 then
			angle = self.acDimensions.maxSteeringAngle
		elseif AutoSteeringEngine.getIsAtEnd( self ) then
			angle = 0
		else
			angle = -self.acDimensions.maxSteeringAngle
		end
		
		if not self.acParameters.leftAreaActive then
			angle = -angle;		
		end
	else
		self.acTurnStage = 198
		AIVehicleExtension.setStatus( self, 2 )
		angle = 0;
	end
	
--	if not self.acParameters.leftAreaActive then angle = -angle end
	if self.movingDirection < -1E-2 then 
		noReverseIndex = AutoSteeringEngine.getNoReverseIndex( self );
		if noReverseIndex > 0 then
			local toolAngle = AutoSteeringEngine.getToolAngle( self )
			angle = math.min( math.max( toolAngle - angle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
			detected = true
		else
			angle = -angle 
		end
		self.acTurnStage = 198
	end
	
	local targetRotTime = 0
	
	if self.acRotatedTime == nil then
		self.rotatedTime = 0
	else
		self.rotatedTime = self.acRotatedTime
	end
	
	local aiSteeringSpeed = self.aiSteeringSpeed;
	--if detected then aiSteeringSpeed = aiSteeringSpeed * 0.5 end
	
	if self.isEntered and detected and math.abs( self.acAxisSide ) < 0.1 then
		AutoSteeringEngine.steer( self, dt, angle, aiSteeringSpeed, detected );
	end
	
	self.acRotatedTime = self.rotatedTime
end

------------------------------------------------------------------------
-- getSaveAttributesAndNodes
------------------------------------------------------------------------

function AIVehicleExtension:getSaveAttributesAndNodes(nodeIdent)
	
	local attributes = 'acVersion="2.2"';
	
	local skip = true
	
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if self.acParameters[n] ~= p.default then
			skip = false
		end
		if self.acParameters[n] ~= p.default or p.always then
			if		 p.tp == "B" then
				attributes = attributes..' '..p.xml..'="'..AIVEHud.bool2int(self.acParameters[n]).. '"';
			else
				attributes = attributes..' '..p.xml..'="'..self.acParameters[n].. '"';
			end
		end
	end

	if skip then
		return ""
	end
	
	return attributes
end;

------------------------------------------------------------------------
-- loadFromAttributesAndNodes
------------------------------------------------------------------------
function AIVehicleExtension:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	local version = AIVEHud.getXmlFloat(xmlFile, key.."#acVersion", 0 )

	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if		 p.tp == "B" then
			self.acParameters[n] = AIVEHud.getXmlBool( xmlFile, key.."#"..p.xml, self.acParameters[n]);
		elseif p.tp == "I" then
			self.acParameters[n] = AIVEHud.getXmlInt(	xmlFile, key.."#"..p.xml, self.acParameters[n]);
		else--if p.tp == "F" then
			self.acParameters[n] = AIVEHud.getXmlFloat(xmlFile, key.."#"..p.xml, self.acParameters[n]);
		end
	end		
	
	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive;
	self.acDimensions								 = nil;
	
	if self.setIsReverseDriving ~= nil then
		self:setIsReverseDriving( self.acParameters.inverted, false )
	end
	
	if version < 1.5 then
		self.acParameters.turnModeIndexC = self.acParameters.turnModeIndex
		if self.acParameters.upNDown and self.acParameters.turnModeIndex > 1 then
			self.acParameters.turnModeIndex = self.acParameters.turnModeIndex - 1
		end
	end
	if version < 2.2 then
		self.acParameters.speedFactor = math.max( 1, self.acParameters.speedFactor )
	end
	
	return BaseMission.VEHICLE_LOAD_OK;
end

------------------------------------------------------------------------
-- getCorrectedMaxSteeringAngle
------------------------------------------------------------------------
function AIVehicleExtension:getCorrectedMaxSteeringAngle()

	local steeringAngle = self.acDimensions.maxSteeringAngle;
	if			self.articulatedAxis ~= nil 
			and self.articulatedAxis.componentJoint ~= nil
			and self.articulatedAxis.componentJoint.jointNode ~= nil 
			and self.articulatedAxis.rotMax then
		-- Ropa
		steeringAngle = steeringAngle + 0.15 * self.articulatedAxis.rotMax;
	end

	return steeringAngle
end

------------------------------------------------------------------------
-- calculateDimensions
------------------------------------------------------------------------
function AIVehicleExtension.calculateDimensions( self )
	if self.acDimensions ~= nil then
		return;
	end;
	
	AIVehicleExtension.roueSet( self, nil, AIVEGlobals.maxLooking )

	self.acDimensions								 	 = {};
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
	--_,_,self.acDimensions.acRefNodeZ = AutoSteeringEngine.getRelativeTranslation(refNodeParent,self.articulatedAxis.componentJoint.jointNode);
	--local n=0;
		for _,wheel in pairs(self.wheels) do
	--	local temp1 = { getRotation(wheel.driveNode) }
	--	local temp2 = { getRotation(wheel.repr) }
	--	setRotation(wheel.driveNode, 0, 0, 0)
	--	setRotation(wheel.repr, 0, 0, 0)
	--	local x,y,z = AutoSteeringEngine.getRelativeTranslation(self.articulatedAxis.componentJoint.jointNode,wheel.driveNode);
	--	setRotation(wheel.repr, unpack(temp2))
	--	setRotation(wheel.driveNode, unpack(temp1))
  --
	--	if n==0 then
	--		self.acDimensions.wheelBase = math.abs(z)
	--		n = 1
	--	else
	--		self.acDimensions.wheelBase = self.acDimensions.wheelBase + math.abs(z);
	--		n	= n	+ 1;
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
	--	self.acDimensions.wheelBase = self.acDimensions.wheelBase / n;
	--end
	---- divide max. steering angle by 2 because it is for both sides
	--self.acDimensions.maxSteeringAngle = 0.25 * (math.abs(self.articulatedAxis.rotMin)+math.abs(self.articulatedAxis.rotMax))
	---- reduce wheel base according to max. steering angle
	--self.acDimensions.wheelBase				= self.acDimensions.wheelBase * math.cos( self.acDimensions.maxSteeringAngle ) 
	end
	
	
	if self.acParameters.inverted then
		self.acDimensions.wheelBase = -self.acDimensions.wheelBase 
	end
	
	setTranslation( self.acRefNode, 0, 0, self.acDimensions.acRefNodeZ )
	
	if AIVEGlobals.devFeatures > 0 then
		print(string.format("wb: %0.3fm, r: %0.3fm, z: %0.3fm", self.acDimensions.wheelBase, self.acDimensions.radius, self.acDimensions.acRefNodeZ ))
	end
	
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

	self.acDimensions.distance		 = 99;
	self.acDimensions.toolDistance = 99;
	
	local wb = self.acDimensions.wheelBase;
	local ms = self.acDimensions.maxSteeringAngle;
	
	self.acDimensions.maxLookingAngle = AIVehicleExtension.getMaxLookingAngleValue( self )
	
	------------------------------------------------------------------------
	-- Roue mode
	------------------------------------------------------------------------
	AIVehicleExtension.roueSet( self, nil, self.acDimensions.maxLookingAngle )
	AutoSteeringEngine.checkChain( self, self.acRefNode, wb, ms, self.acParameters.widthOffset, self.acParameters.turnOffset, self.acParameters.inverted, self.acParameters.frontPacker, self.acParameters.speedFactor );

	self.acDimensions.distance, self.acDimensions.toolDistance, self.acDimensions.zBack = AutoSteeringEngine.checkTools( self );
	
	self.acDimensions.distance0				= self.acDimensions.distance;
	if self.acParameters.widthOffset ~= nil then
		self.acDimensions.distance			= self.acDimensions.distance0 + self.acParameters.widthOffset;
	end
	
	local optimDist = self.acDimensions.distance;
	if self.acDimensions.radius > optimDist then
		self.acDimensions.uTurnAngle		 = math.acos( optimDist / self.acDimensions.radius );
	else
		self.acDimensions.uTurnAngle		 = 0;
	end;

	self.acDimensions.insideDistance = math.max( 0, self.acDimensions.toolDistance - 1 - self.acDimensions.distance +(self.acDimensions.radius * math.cos( self.acDimensions.maxSteeringAngle )) );
	self.acDimensions.uTurnDistance	= math.max( 0, 1 + self.acDimensions.toolDistance + self.acDimensions.distance - self.acDimensions.radius);	
	self.acDimensions.headlandDist	 = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.radius, self.acDimensions.wheelBase, self.acParameters.bigHeadland, AutoSteeringEngine.getNoReverseIndex( self ) )
	self.acDimensions.collisionDist	= 1 + AIVehicleExtension.calculateHeadland( self.acTurnMode, math.max( self.acDimensions.distance, 1.5 ), self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.radius, self.acDimensions.wheelBase, self.acParameters.bigHeadland, AutoSteeringEngine.getNoReverseIndex( self ) )
	local r = self.acDimensions.radius
	self.acDimensions.uTurnDist4x   = math.max( 1 + self.acDimensions.toolDistance - r-r, self.acDimensions.distance - 0.7 * r, 0 )
	--if self.acShowDistOnce == nil then
	--	self.acShowDistOnce = 1
	--else
	--	self.acShowDistOnce = self.acShowDistOnce + 1
	--end
	--if self.acShowDistOnce <= 30 then
	--	print(string.format("max( %0.3f , 1.5 ) + max( - %0.3f, 0 ) + max( %0.3f - %0.3f, 1 ) + %0.3f = %0.3f", self.acDimensions.distance, zBack, self.acDimensions.toolDistance, zBack, self.acDimensions.radius, self.acDimensions.headlandDist ) )
	--end
	
	if self.acParameters.turnOffset ~= nil then
		self.acDimensions.insideDistance = math.max( 0, self.acDimensions.insideDistance + self.acParameters.turnOffset );
		self.acDimensions.uTurnDistance	 = math.max( 0, self.acDimensions.uTurnDistance	 + self.acParameters.turnOffset );
		self.acDimensions.headlandDist	 = math.max( 0, self.acDimensions.headlandDist	 + self.acParameters.turnOffset );
		self.acDimensions.collisionDist	 = math.max( 0, self.acDimensions.collisionDist	 + self.acParameters.turnOffset );
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
-- AIVehicleExtension:roueChangeSteer
------------------------------------------------------------------------
function AIVehicleExtension:roueChangeSteer( ... )
	AIVehicleExtension.roueSaveWheels( self );
end

------------------------------------------------------------------------
-- AIVehicleExtension:roueInitWheels
------------------------------------------------------------------------
function AIVehicleExtension:roueInitWheels()
	
	AIVehicleExtension.roueSaveWheels( self )

	if self.acRoueWheels == nil then return end
	
	for i=1,table.getn(self.wheels) do
		self.acRoueWheels[i].rotMax2	 = self.wheels[i].rotMax;
		self.acRoueWheels[i].rotMin2	 = self.wheels[i].rotMin;
		self.acRoueWheels[i].rotSpeed2 = self.wheels[i].rotSpeed;		
	end
	
	for i=0,99 do
		self.changeWheel = i
		self.acRoueUpdate( self, 0 )
		
		if self.changeWheel == 0 then break end
	
		for i=1,table.getn(self.wheels) do
			self.acRoueWheels[i].rotMax2	 = math.max( self.acRoueWheels[i].rotMax2	, self.wheels[i].rotMax	 )
			self.acRoueWheels[i].rotMin2	 = math.min( self.acRoueWheels[i].rotMin2	, self.wheels[i].rotMin	 )
			self.acRoueWheels[i].rotSpeed2 = math.max( self.acRoueWheels[i].rotSpeed2, self.wheels[i].rotSpeed )
		end
	end
end

------------------------------------------------------------------------
-- AIVehicleExtension:roueSaveWheels
------------------------------------------------------------------------
function AIVehicleExtension:roueSaveWheels()

	if self.acHasRoueSpec then
		if self.acRoueWheels == nil then
			self.acRoueWheels = {};
			for i=1,table.getn(self.wheels) do
				wheel = {}
				wheel.rotMax	 = self.wheels[i].rotMax;
				wheel.rotMin	 = self.wheels[i].rotMin;
				wheel.rotSpeed = self.wheels[i].rotSpeed;		
				self.acRoueWheels[i] = wheel;
			end
		else
			for i=1,table.getn(self.wheels) do
				self.acRoueWheels[i].rotMax	 = self.wheels[i].rotMax;
				self.acRoueWheels[i].rotMin	 = self.wheels[i].rotMin;
				self.acRoueWheels[i].rotSpeed = self.wheels[i].rotSpeed;	
			end
		end
	else
		self.acRoueWheels = nil;
	end	
	
end

------------------------------------------------------------------------
--AIVehicleExtension:roueReset
------------------------------------------------------------------------
function AIVehicleExtension:roueReset( )
	if self.acRoueWheels ~= nil then 
		for i=1,table.getn(self.wheels) do
			self.wheels[i].rotMax	 = self.acRoueWheels[i].rotMax;
			self.wheels[i].rotMin	 = self.acRoueWheels[i].rotMin;
			self.wheels[i].rotSpeed = self.acRoueWheels[i].rotSpeed;		
		end
		
		self.acRoueWheels				= nil
		self.acRoueWheelsChanged = nil

		AIVehicleExtension.roueSetMR( self )
	end
end

------------------------------------------------------------------------
--AIVehicleExtension:roueSet
------------------------------------------------------------------------
function AIVehicleExtension:roueSet( target, angleMax )

	if self.acRoueWheels == nil then return 0, angleMax end
	
	local zShift = 0;
	local iRef, iOther = 1,3;
	local x1,_,z1 = AutoSteeringEngine.getRelativeTranslation( self.acRefNode, self.wheels[1].driveNode )
	local x3,_,z3 = AutoSteeringEngine.getRelativeTranslation( self.acRefNode, self.wheels[3].driveNode )
	local wb			= z1 - z3;
	
	if z1 < z3 then
		iRef		= 3;
		iOthers = 1;
		wb			= z3 - z1;
	end
	
	if		 target == nil 
			or target > 0
			or wb		 < 1
			or table.getn(self.wheels) ~= 4
			or self.wheels[iRef].rotMax <= math.tan( self.acDimensions.maxLookingAngle ) or math.abs( self.wheels[iRef].rotSpeed ) < 1E-3 then
		if self.acRoueWheelsChanged then
			self.acRoueWheelsChanged = false;
			
			for i=1,table.getn(self.wheels) do
				self.wheels[i].rotMax	 = self.acRoueWheels[i].rotMax2;
				self.wheels[i].rotMin	 = self.acRoueWheels[i].rotMin2;
				self.wheels[i].rotSpeed = self.acRoueWheels[i].rotSpeed2;		
			end
		else
			return 0, angleMax
		end
	else
		self.acRoueWheelsChanged = true;
		local angleMax = math.atan( math.tan( self.acDimensions.maxLookingAngle ) * ( 1 - target / wb ) )
		
		if angleMax > self.wheels[iRef].rotMax then
			zShift	 = ( math.tan( self.wheels[iRef].rotMax ) / math.tan( self.acDimensions.maxLookingAngle ) - 1 ) * wb
			angleMax = self.wheels[iRef].rotMax
		else
			zShift	 = -target;
		end
		
		local f = zShift / ( wb + zShift );
		
		for i=0,1 do
			self.wheels[iOther+i].rotMax	 = math.atan( math.tan( self.wheels[iRef+i].rotMax ) * f );
			self.wheels[iOther+i].rotMin	 = math.atan( math.tan( self.wheels[iRef+i].rotMin ) * f );
			self.wheels[iOther+i].rotSpeed = self.wheels[iRef+i].rotSpeed * self.wheels[iOther+i].rotMax / self.wheels[iRef+i].rotMax;
		end
	end
	
	AIVehicleExtension.roueSetMR( self )

	return zShift, angleMax
end

------------------------------------------------------------------------
--AIVehicleExtension:roueSetMR
------------------------------------------------------------------------
function AIVehicleExtension:roueSetMR( )
	if self.isRealistic then
		for i=1,table.getn(self.wheels) do
			self.wheels[i].realRotMaxSpeed = 0;
			self.wheels[i].realRotMinSpeed = 0;
	
			if self.wheels[i].rotMax~=0 and self.wheels[i].rotMin~=0 and self.wheels[i].rotSpeed~=0 then	

				if math.abs(self.wheels[i].rotMax)>math.abs(self.wheels[i].rotMin) then
					self.wheels[i].realRotMaxSpeed = self.wheels[i].rotSpeed;
					self.wheels[i].realRotMinSpeed = math.abs(self.wheels[i].rotMin/self.wheels[i].rotMax)*self.wheels[i].rotSpeed;
				else
					self.wheels[i].realRotMinSpeed = self.wheels[i].rotSpeed;
					self.wheels[i].realRotMaxSpeed = math.abs(self.wheels[i].rotMax/self.wheels[i].rotMin)*self.wheels[i].rotSpeed;
				end;
		
				if self.wheels[i].rotSpeed<0 then
					local tmp = self.wheels[i].realRotMaxSpeed;
					self.wheels[i].realRotMaxSpeed = self.wheels[i].realRotMinSpeed;
					self.wheels[i].realRotMinSpeed = tmp;
				end
			end
		end
	end
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
end;

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
	parameters.leftAreaActive	= not parameters.rightAreaActive;

	return parameters
end

function AIVehicleExtension:getParameters()
	if self.acParameters == nil then
		self.acParameters = AIVehicleExtension.getParameterDefaults( )
	end;
	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive;
	self.acSentSpeedFactor						= self.acParameters.speedFactor

	return self.acParameters;
end;

function AIVehicleExtension.readStreamHelper(streamId)
	local parameters = {};
	
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if		 p.tp == "B" then
			parameters[n] = streamReadBool(streamId);
		elseif p.tp == "I" then
			parameters[n] = streamReadInt8(streamId);
		else--if p.tp == "F" then
			parameters[n] = streamReadFloat32(streamId);
		end
	end
	
	return parameters;
end

function AIVehicleExtension.writeStreamHelper(streamId, parameters)
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if		 p.tp == "B" then
			streamWriteBool(streamId, Utils.getNoNil( parameters[n], p.default ));
		elseif p.tp == "I" then
			streamWriteInt8(streamId, Utils.getNoNil( parameters[n], p.default ));
		else--if p.tp == "F" then
			streamWriteFloat32(streamId, Utils.getNoNil( parameters[n], p.default ));
		end
	end
end

local AIVESetParametersdLog
function AIVehicleExtension:setParameters(parameters)

	if self == nil then
		if AIVESetParametersdLog < 10 then
			AIVESetParametersdLog = AIVESetParametersdLog + 1;
			print("------------------------------------------------------------------------");
			print("AIVehicleExtension:setParameters: self == nil");
			AIVEHud.printCallstack();
			print("------------------------------------------------------------------------");
		end
		return
	end

	local turnOffset = 0;
	if self.acParameters ~= nil and self.acParameters.turnOffset ~= nil then
		turnOffset = self.acParameters.turnOffset
	end
	local widthOffset = 0;
	if self.acParameters ~= nil and self.acParameters.widthOffset ~= nil then
		widthOffset = self.acParameters.widthOffset
	end
	
	self.acParameters = {}
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		self.acParameters[n] = Utils.getNoNil( parameters[n], p.default )
	end

	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive;
	self.acSentSpeedFactor						= self.acParameters.speedFactor
end

function AIVehicleExtension:readStream(streamId, connection)
	AIVehicleExtension.setParameters( self, AIVehicleExtension.readStreamHelper(streamId) );
end

function AIVehicleExtension:writeStream(streamId, connection)
	AIVehicleExtension.writeStreamHelper(streamId,AIVehicleExtension.getParameters(self));
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
end;


if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acReset", "Reset global AIVehicleExtension variables to defaults.", "acReset", AIVehicleExtension);
end
function AIVehicleExtension:acReset()
	AutoSteeringEngine.globalsReset();
	AutoSteeringEngine.resetCounter = AutoSteeringEngine.resetCounter + 1;
	for name,value in pairs(AIVEGlobals) do
		print(tostring(name).." "..tostring(value));		
	end
end

-- acSave
if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acSave", "Save the global AIVehicleExtension variables.", "acSave", AIVehicleExtension);
end
function AIVehicleExtension:acSave()
	AutoSteeringEngine.globalsCreate()	
	for name,value in pairs(AIVEGlobals) do
		print(tostring(name).." "..tostring(value));		
	end
end

-- acSet
if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acSet", "Change one of the global AIVehicleExtension variables.", "acSet", AIVehicleExtension);
end
function AIVehicleExtension:acSet(name,svalue)

	local value;
	if svalue ~= nil then
		value = tonumber( svalue );
	end
	
	print("acSet "..tostring(name).." "..tostring(value));

	local found = false;
	
	local old=nil
	for n,o in pairs(AIVEGlobals) do
		if n == name then
			found = true;
			old	 = o;
			break;
		end
	end
	
	if found then
		if value == nil or old == new then
			print(tostring(AIVEGlobals[name]));
		else
			AIVEGlobals[name]=value;
			print("Old value: "..tostring(old).."; new value: "..tostring(value));
			AutoSteeringEngine.resetCounter = AutoSteeringEngine.resetCounter + 1;
		end
	else
		print("Usage: acSet <name> <value>");
		print("Possible names are:");
		
		for n,old in pairs(AIVEGlobals) do
			print("	" .. n .. ": "..tostring(AIVEGlobals[n]));
		end
	end
	
end

-- acDump
if AIVEGlobals.devFeatures > 0 then
	addConsoleCommand("acDump", "Dump internal state of AIVehicleExtension", "acDump", AIVehicleExtension);
end
function AIVehicleExtension:acDump()
	atDump = true;
end

function AIVehicleExtension:acDump2()	
	atDump = nil;
	for i=1,AIVEGlobals.chainMax+1 do
		local text = string.format("i: %i, a: %i",i,self.aseChain.nodes[i].angle);
		if self.aseChain.nodes[i].status >=	1 then
			text = text .. string.format(" s: %i",math.deg( self.aseChain.nodes[i].steering ));
		end
		if self.aseChain.nodes[i].status >=	2 then
			text = text .. string.format(" r: %i",math.deg( self.aseChain.nodes[i].rotation ));
		end
		if self.aseChain.nodes[i].status >=	3 then
			for j=1,table.getn(self.aseTools) do
				if			self.aseChain.nodes[i].tool[j]	 ~= nil 
						and self.aseChain.nodes[i].tool[j].x ~= nil 
						and self.aseChain.nodes[i].tool[j].z ~= nil then
					local x1,y1,z1 = localToWorld( self.aseChain.nodes[i].index, self.aseChain.nodes[i].tool[j].x, 0, self.aseChain.nodes[i].tool[j].z );
					local x2,y2,z2 = worldToLocal( self.aseChain.refNode, x1, y1, z1 );
					text = text .. string.format( " x: %0.3f z: %0.3f",x2,z2);							
				end
			end
		end
		
		print(text);
	end
end

function AIVehicleExtension.test1( self )
	self.acTurn2Outside = true;
	self.acTurnStage = 1;
	self.turnTimer = self.acDeltaTimeoutWait;
end

function AIVehicleExtension.test2( self )
	self.acTurn2Outside = false;
	self.acTurnStage = 1;
	self.turnTimer = self.acDeltaTimeoutWait;
end

function AIVehicleExtension.test3( self )
	if AIVEGlobals.showTrace > 0 then
		AIVEGlobals.showTrace = 0
	else
		AIVEGlobals.showTrace = 1
	end
end

function AIVehicleExtension.test4( self )
	if AIVEGlobals.showChannels > 0 then
		AIVEGlobals.showChannels = 0
	else
		AIVEGlobals.showChannels = 1
		AIVEGlobals.showTrace = 1
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
--local toolAngle = AutoSteeringEngine.getToolAngle( self );	
--if not self.acParameters.leftAreaActive then
--	toolAngle = -toolAngle
--end
--
--if outside then
--	angle = -self.acDimensions.maxSteeringAngle + math.min( 2 * math.max( -toolAngle - AIVEGlobals.maxToolAngle, 0 ), 0.9 * self.acDimensions.maxSteeringAngle );	-- 75° => 1,3089969389957471826927680763665
--else
--	angle =  self.acDimensions.maxSteeringAngle - math.min( 2 * math.max(  toolAngle - AIVEGlobals.maxToolAngle, 0 ), 0.9 * self.acDimensions.maxSteeringAngle );	-- 75° => 1,3089969389957471826927680763665
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
	
	if math.abs( a - AutoSteeringEngine.currentSteeringAngle( self, self.acParameters.inverted ) ) < 0.05236 then -- 3° 
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
		angle = -angle;		
	end	
	return angle
end

------------------------------------------------------------------------
-- AIVehicleExtension:getTurnVector
------------------------------------------------------------------------
function AIVehicleExtension:getTurnVector( uTurn, turn2Outside )

	local x, z = AutoSteeringEngine.getTurnVector( self, Utils.getNoNil( uTurn, false ), Utils.getNoNil( turn2Outside, self.acTurn2Outside ) )
 
	return x, z, true
end

------------------------------------------------------------------------
-- AIVehicleExtension:getToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getToolAngle()

	local toolAngle = AutoSteeringEngine.getToolAngle( self )
	if not self.acParameters.leftAreaActive then
		toolAngle = -toolAngle;
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



--==============================================================				
--==============================================================			
function AIVehicleExtension:afterSetDriveStrategies()	
	if self.aiIsStarted and self.acParameters.enabled then
		self.aiveIsStarted = true
	end
	if self.aiveIsStarted and self.driveStrategies ~= nil and #self.driveStrategies > 0 then
		for i,d in pairs( self.driveStrategies ) do
			local driveStrategyMogli = nil
			if     d:isa(AIDriveStrategyStraight) then
				driveStrategyMogli = AIDriveStrategyMogli:new();
			elseif d:isa(AIDriveStrategyCombine)  then
				driveStrategyMogli = AIDriveStrategyCombine131:new();
			end
			if driveStrategyMogli ~= nil then
				driveStrategyMogli:setAIVehicle(self);
				self.driveStrategies[i] = driveStrategyMogli
			end
		end
				
		AutoSteeringEngine.initFruitBuffer( self )
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
function AIVehicleExtension:newCanStartAIVehicle( superFunc )
	-- check if reverse driving is available and used, we do not allow the AI to work when reverse driving is enabled
	if     self.isReverseDriving == nil 
			or not self.isReverseDriving
			or self.acParameters     == nil
			or not self.acParameters.enabled then
		return superFunc( self )
	end
	
	if self.isChangingDirection then
		return false;
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

AIVehicle.canStartAIVehicle = Utils.overwrittenFunction( AIVehicle.canStartAIVehicle, AIVehicleExtension.newCanStartAIVehicle )


