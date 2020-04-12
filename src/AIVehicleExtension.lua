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
--source(Utils.getFilename("FieldScanner.lua", g_currentModDirectory))
source(Utils.getFilename("AIAnimCurve.lua", g_currentModDirectory))
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
	if      AIVEGlobals.devFeatures > 0
			and ( type( self ) ~= "table" 
				 or type( self.getIsEntered ) ~= "function" 
				 or self:getIsEntered() ) then
		print( ... )
	end
	if self ~= nil and AIVEGlobals.showInfo > 0 and self.atMogliInitDone then
		self.atHud.InfoText = tostring( ... )
	end	
end

function AIVehicleExtension:aiveAddDebugText( s )
	AIVehicleExtension.debugPrint( self, s )
end

AIVehicleExtension.saveAttributesMapping = { 
		enabled         = { xml = "acDefaultOn",	 tp = "B", default = true  },
		upNDown				  = { xml = "acUTurn",			 tp = "B", default = false },
		straight			  = { xml = "acStraight",		 tp = "B", default = false },
		rightAreaActive = { xml = "acAreaRight",	 tp = "B", default = false },
		headland				= { xml = "acHeadland",		 tp = "B", default = false },
		collision			  = { xml = "acCollision",	 tp = "B", default = true },
		inverted				= { xml = "acInverted",		 tp = "B", default = false },
		isHired				  = { xml = "acIsHired",		 tp = "B", default = false },
		bigHeadland		  = { xml = "acBigHeadland", tp = "B", default = true  },
		turnModeIndex	  = { xml = "acTurnMode",		 tp = "I", default = 1 },
		turnModeIndexC	= { xml = "acTurnModeC",	 tp = "I", default = 1 },
		widthOffset		  = { xml = "acWidthOffset", tp = "F", default = 0 },
		turnOffset			= { xml = "acTurnOffset",	 tp = "F", default = 0 },
		angleFactor		  = { xml = "acAngleFactorN",tp = "F", default = 0.5 },
		precision		    = { xml = "acPrecision",   tp = "I", default = 1 },
		noSteering			= { xml = "acNoSteering",	 tp = "B", default = false },
		useAIFieldFct		= { xml = "acUseAIField",	 tp = "B", default = false },
		waitForPipe			= { xml = "acWaitForPipe", tp = "B", default = true  },
		showTrace 			= { xml = "acShowTrace",   tp = "B", default = false } }																															
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
	return true
end

function AIVehicleExtension.registerEventListeners(vehicleType)
	for _,n in pairs( { "onLoad", 
											"onPostLoad", 
											"onPreUpdate", 
											"onUpdate", 
											"onDraw",
											"onLeaveVehicle",
											"onEnterVehicle",
											"onReadStream", 
											"onWriteStream", 
											"onReadUpdateStream",
											"onWriteUpdateStream", 
											"saveToXMLFile", 
											"onRegisterActionEvents",
											"onStateChange",
											"onPreDelete",
											"onAIStart",
											"onAIEnd",
											"onAITurnProgress"} ) do
		SpecializationUtil.registerEventListener(vehicleType, n, AIVehicleExtension)
	end 
end 
------------------------------------------------------------------------
-- load
------------------------------------------------------------------------
function AIVehicleExtension:onLoad(saveGame)

	-- for courseplay	
	self.acIsCPStopped				= false
	self.acTurnStage					= 0
	self.acPause							= false	
	self.acParameters				  = AIVehicleExtension.getParameterDefaults( )
	self.acAxisSide					  = 0
	self.acIsLowered          = 0
	self.acTurnMode           = ""
	self.acDebugPrint			  	= AIVehicleExtension.debugPrint
	self.aiveAddDebugText     = AIVehicleExtension.aiveAddDebugText
	self.waitForTurnTime      = 0
	self.turnTimer            = 0
	self.aiRescueTimer        = 0
	
	self.acDeltaTimeoutWait	  = 1600
	self.acDeltaTimeoutRun		= 80
	self.acDeltaTimeoutStop	  = 30000
	self.acDeltaTimeoutStart	= 6000
	self.acDeltaTimeoutNoTurn = 2 * self.acDeltaTimeoutWait --math.max(AIVEUtils.getNoNil( self.waitForTurnTimeout , 2000 ), 1000 )
	self.acRecalculateDt			= 0
	self.acWaitTimer					= 0
	self.acTurnOutsideTimer   = 0
	self.acImplMoveDownTimer  = 0
	self.acSteeringSpeed      = self.spec_aiVehicle.aiSteeringSpeed
	self.aiveCanStartArtAxis  = false
	
	self.acAutoRotateBackSpeedBackup = self.autoRotateBackSpeed	
	
	local tempNode = self:getAIVehicleDirectionNode()
	if tempNode == nil then
		tempNode = self.components[1].node
	end
	
	self.acRefNode = createTransformGroup( "acNewRefNode" )
	link( tempNode, self.acRefNode )

	self.acOtherCombineCollisionTriggerL = 0
	self.acOtherCombineCollisionTriggerR = 0
	self.onOtherAICollisionTrigger = AIVehicleExtension.onOtherAICollisionTrigger
	
	AIVehicleExtension.addCollisionTriggers( self )
	
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
	local mogliCols = 8
	--(												directory,	 hudName, hudBackground, onTextID, offTextID, showHudKey, x,y, nx, ny, w, h, cbOnClick )
	AIVEHud.init( self, AtDirectory, "AIVEHud", 0.8, "AIVE_TEXTHELPPANELON", "AIVE_TEXTHELPPANELOFF", "AIVE_HELPPANEL", 0.5-0.015*mogliCols, 0.0108, mogliCols, mogliRows, AIVehicleExtension.sendParameters )--, nil, nil, 0.8 )
	AIVEHud.setTitle( self, "AIVE_VERSION" )

	AIVEHud.addButton(self, "dds/ai_combine.dds",     "dds/auto_combine.dds",  AIVehicleExtension.onEnable,      AIVehicleExtension.evalEnable,     1,1, "AIVE_STOP", "AIVE_START", nil, AIVehicleExtension.getEnableImage )
	AIVEHud.addButton(self, "dds/active_right.dds",   "dds/active_left.dds",   AIVehicleExtension.setAreaLeft,   AIVehicleExtension.evalAreaLeft,   2,1, "AIVE_ACTIVESIDERIGHT", "AIVE_ACTIVESIDELEFT" )
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.setUTurn,      nil,                               3,1, "AIVE_SETTINGS", "AIVE_SETTINGS", AIVehicleExtension.getUTurnText, AIVehicleExtension.getUTurnImage ) 
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.setHeadland,   nil,                               4,1, "AIVE_SETTINGS", "AIVE_SETTINGS", AIVehicleExtension.getHeadlandText, AIVehicleExtension.getHeadlandImage )
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.setTurnMode,   nil,                               5,1, "AIVE_SETTINGS", "AIVE_SETTINGS", AIVehicleExtension.getTurnModeText, AIVehicleExtension.getTurnModeImage )
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.onSteerPause,  nil,                               6,1, "AIVE_SETTINGS", "AIVE_SETTINGS", AIVehicleExtension.getSteerPauseText, AIVehicleExtension.getSteerPauseImage )
	AIVEHud.addButton(self, nil,                      nil,                     AIVehicleExtension.onRaiseNext,   nil,                               7,1, "AIVE_SETTINGS", "AIVE_SETTINGS", AIVehicleExtension.getRaiseNextText, AIVehicleExtension.getRaiseNextImage )
	AIVEHud.addButton(self, "dds/setings.dds",        nil,                     AIVehicleExtension.onAIVEScreen,  nil,                               8,1, "AIVE_SETTINGS", "AIVE_SETTINGS" )


	if type( self.atHud ) == "table" then
		self.atMogliInitDone = true
	else
		print("ERROR: Initialization of AIVehicleExtension HUD failed")
	end
end

------------------------------------------------------------------------
-- draw
------------------------------------------------------------------------
function AIVehicleExtension:onDraw()
	if self.atMogliInitDone then
		local alwaysDrawTitle = false
		if self.aiveIsStarted or self.aiveAutoSteer then
			alwaysDrawTitle = true
		end
		AIVEHud.draw(self,true,alwaysDrawTitle)
	end	
end

------------------------------------------------------------------------
-- onLeaveVehicle
------------------------------------------------------------------------
function AIVehicleExtension:onLeaveVehicle()
	if self.atMogliInitDone then
		AIVEHud.onLeave(self)
	end
end

------------------------------------------------------------------------
-- onEnterVehicle
------------------------------------------------------------------------
function AIVehicleExtension:onEnterVehicle()
	if self.atMogliInitDone then
		AIVEHud.onEnter(self)
	end
end

------------------------------------------------------------------------
-- addCollisionTriggers
------------------------------------------------------------------------
function AIVehicleExtension:addCollisionTriggers()
	if not ( self.isServer ) then 
		return 
	end 
	if self.acI3D == nil then 
		AIVehicleExtension.debugPrint( self, "loading collision I3D..." )
		AIVehicleExtension.removeCollisionTriggers( self )
		self.acI3D = getChild(g_i3DManager:loadSharedI3DFile("AutoCombine.i3d", AtDirectory),"AutoCombine")	
	--self.acBackTrafficCollisionTrigger   = getChild(self.acI3D,"backCollisionTrigger")
		self.acOtherCombineCollisionTriggerL = getChild(self.acI3D,"otherCombColliTriggerL")
		self.acOtherCombineCollisionTriggerR = getChild(self.acI3D,"otherCombColliTriggerR")
		link(self.acRefNode,self.acI3D)
		AIVehicleExtension.disableCollisionTriggers( self, true )
	end 
	if self.acCollidingVehicles == nil then 				
		self.acCollidingVehicles = {}
		if self.acOtherCombineCollisionTriggerR ~= 0 then
			AIVehicleExtension.debugPrint( self, "adding right trigger..." )
			local triggerID = self.acOtherCombineCollisionTriggerR
			self.acCollidingVehicles[triggerID] = {}
			addTrigger( triggerID, "onOtherAICollisionTrigger", self )
		end
		if self.acOtherCombineCollisionTriggerL ~= 0 then
			AIVehicleExtension.debugPrint( self, "adding left trigger..." )
			local triggerID = self.acOtherCombineCollisionTriggerL
			self.acCollidingVehicles[triggerID] = {}
			addTrigger( triggerID, "onOtherAICollisionTrigger", self )
		end
	end 
end 

------------------------------------------------------------------------
-- removeCollisionTriggers
------------------------------------------------------------------------
function AIVehicleExtension:removeCollisionTriggers()
	if self.acOtherCombineCollisionTriggerL ~= 0 then 
		AIVehicleExtension.debugPrint( self, "removing left trigger..." )
		removeTrigger( self.acOtherCombineCollisionTriggerL )
	end 
	if self.acOtherCombineCollisionTriggerR ~= 0 then 
		AIVehicleExtension.debugPrint( self, "removing right trigger..." )
		removeTrigger( self.acOtherCombineCollisionTriggerR )
	end 
	if self.acI3D ~= nil then 
		AIVehicleExtension.debugPrint( self, "deleting collision I3D..." )
		AutoSteeringEngine.deleteNode( self.acI3D )
	end
	self.acI3D = nil 
	self.acOtherCombineCollisionTriggerL = 0 
	self.acOtherCombineCollisionTriggerR = 0 
	self.acCollidingVehicles = nil
end 

------------------------------------------------------------------------
-- enableCollisionTriggers
------------------------------------------------------------------------
function AIVehicleExtension:enableCollisionTriggers()
	if not ( self.aiveCollisionTriggersEnabled ) then 
		setTranslation( self.acI3D, 0, 0, 0 )
		self.aiveCollisionTriggersEnabled = true 
	end 
end 

------------------------------------------------------------------------
-- disableCollisionTriggers
------------------------------------------------------------------------
function AIVehicleExtension:disableCollisionTriggers( noUnlink )
	if noUnlink or self.aiveCollisionTriggersEnabled == nil or self.aiveCollisionTriggersEnabled then 
		setTranslation( self.acI3D, 1000000, 1000000, 1000000 )
		self.aiveCollisionTriggersEnabled = false 
	end 
end 

------------------------------------------------------------------------
-- delete
------------------------------------------------------------------------
function AIVehicleExtension:onPreDelete()
	AIVehicleExtension.removeCollisionTriggers( self )
	
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
function AIVehicleExtension:onDelete()
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
	if g_AIVEScreen == nil then
		-- settings screen
		g_AIVEScreen = AIVEScreen:new()
		for n,t in pairs( AIVehicleExtensionRegister.mogliTexts ) do
			g_AIVEScreen.mogliTexts[n] = t
		end
		g_gui:loadGui(AIVehicleExtensionRegister.g_currentModDirectory .. "gui/AIVEScreen.xml", "AIVEScreen", g_AIVEScreen)	
		g_AIVEScreen:setTitle( "AIVE_VERSION" )
	end
	
	self.aiveUI = {}
	
	self.aiveUI.upNDown  = { AIVEHud.getText("AIVE_UTURN_OFF"),
													 AIVEHud.getText("AIVE_UTURN_ON"),
													 AIVEHud.getText("AIVE_UTURN_ON2") }
	
	local st, bt = " (-)", " (+)"
	local sbtt   = false
	if self.aiveIsStarted or ( self.acTurnStage ~= nil and self.acTurnStage >= 198 ) then
		sbtt = true
	elseif self.isServer then
		sbtt = true
	end
	
	if sbtt then
		local s, b = AIVehicleExtension.getHeadlandSmallBig( self )
		st = string.format("%5.2fm",s)
		bt = string.format("%5.2fm",b)
	end

	self.aiveUI.headland = { "0.0m", st, bt }
	self.aiveUI.rightAreaActive = { AIVEHud.getText("AIVE_ACTIVESIDELEFT"),  AIVEHud.getText("AIVE_ACTIVESIDERIGHT") }
	self.aiveUI.turnModeIndex = {}
	if type( self.acTurnModes ) == "table" then 
		for i,v in pairs( self.acTurnModes ) do 
			self.aiveUI.turnModeIndex[i] = AIVEHud.getText("AIVE_TURN_MODE_"..v)	
		end 
	end
	
	if AIVehicleExtension.Distance == nil then
		AIVehicleExtension.Distance = {}
		for d=-10,-4 do
			table.insert( AIVehicleExtension.Distance, d )
		end
		for d=-3.5,-1.5,0.5 do
			table.insert( AIVehicleExtension.Distance, d )
		end
		for d=-1.25,1.25,0.25 do
			table.insert( AIVehicleExtension.Distance, d )
		end
		for d=1.5,3.5,0.5 do
			table.insert( AIVehicleExtension.Distance, d )
		end
		for d=4,10 do
			table.insert( AIVehicleExtension.Distance, d )
		end
	end
	
	self.aiveUI.turnOffset = {}
	for _,d in pairs(AIVehicleExtension.Distance) do
		table.insert( self.aiveUI.turnOffset, string.format("%5.2fm",d) )
	end			
	
	self.aiveUI.widthOffset = {}
	for i=-16,16 do
		table.insert( self.aiveUI.widthOffset, string.format("%5.3fm",i*0.125) )
	end
	
	self.aiveUI.precision = { AIVEHud.getText("AIVE_PRECISION_0"),
														AIVEHud.getText("AIVE_PRECISION_1"),
														AIVEHud.getText("AIVE_PRECISION_2") }
	
	
	g_AIVEScreen:setVehicle( self )
	g_gui:showGui( "AIVEScreen" )
end

--*****************************************************************

function AIVehicleExtension:aiveUIGetheadland()
	if self.acParameters == nil then 
		return 0 
	end 
	if not self.acParameters.headland then 
		return 1 
	end 
	if self.acParameters.bigHeadland then 
		return 3 
	end 
	return 2 
end 
function AIVehicleExtension:aiveUISetheadland( value )
	if self.acParameters == nil then 
		return 
	end 
	if value <= 1 then 
		self.acParameters.headland = false 
	else
		self.acParameters.headland = true 
		if value >= 3 then 	
			self.acParameters.bigHeadland = true 
		else 
			self.acParameters.bigHeadland = false 
		end 
	end 
end 

function AIVehicleExtension:aiveUIGetupNDown()
	if self.acParameters == nil then 
		return 0 
	end 
	if     not self.acParameters.upNDown then 
		return 1 
	elseif not self.acParameters.straight then 
		return 2 
	end 
	return 3 
end 
function AIVehicleExtension:aiveUISetupNDown( value )
	if self.acParameters == nil then 
		return 
	end 
	if value <= 1 then 
		self.acParameters.upNDown  = false 
		self.acParameters.straight = false 
	else
		self.acParameters.upNDown  = true  
		if value >= 3 then 	
			self.acParameters.straight = true 
		else 
			self.acParameters.straight = false 
		end 
	end 
end 

function AIVehicleExtension:aiveUIGetrightAreaActive()
	if self.acParameters == nil then 
		return 0
	end 
	if self.acParameters.rightAreaActive then 
		return 2
	end 
	return 1	
end 
function AIVehicleExtension:aiveUISetrightAreaActive( value )
	if self.acParameters == nil then 
		return
	end 
	if value >= 2 then 
		self.acParameters.rightAreaActive = true 		
		self.acParameters.leftAreaActive	= false 
	else 
		self.acParameters.rightAreaActive = false 
		self.acParameters.leftAreaActive	= true
	end 
end 

function AIVehicleExtension:aiveUIGetturnModeIndex()
	if self.acParameters == nil then 
		return 0
	end 
	local turnIndexComp = AIVehicleExtension.getTurnIndexComp( self )
	return self.acParameters[turnIndexComp]
end 
function AIVehicleExtension:aiveUISetturnModeIndex( value )
	if self.acParameters == nil then 
		return
	end 
	local turnIndexComp = AIVehicleExtension.getTurnIndexComp( self )
	self.acParameters[turnIndexComp] = value 
end 

function AIVehicleExtension:aiveUIGetwidthOffset()
	if self.acParameters == nil then 
		return 0
	end 
	local i = math.floor( self.acParameters.widthOffset * 8 + 17.5 )
	return i
end 
function AIVehicleExtension:aiveUISetwidthOffset( value )
	if self.acParameters == nil then 
		return
	end 
	self.acParameters.widthOffset = ( value - 17 ) / 8
end 

function AIVehicleExtension:aiveUIGetturnOffset()
	if self.acParameters == nil then 
		return 0
	end 
	local i = table.getn(AIVehicleExtension.Distance)
	for j=1,i-1 do
		local d2 = 0.5 * ( AIVehicleExtension.Distance[j] + AIVehicleExtension.Distance[j+1] )
		if self.acParameters.turnOffset < d2 then
			i = j 
			break 
		end
	end
	return i
end 
function AIVehicleExtension:aiveUISetturnOffset( value )
	if self.acParameters == nil or AIVehicleExtension.Distance[value] == nil then 
		return
	end 
	self.acParameters.turnOffset = AIVehicleExtension.Distance[value]
end 



--*****************************************************************

function AIVehicleExtension:onRaiseNext()
	if self.spec_aiVehicle.isActive then
		if self.aiveIsStarted then 
			AIVehicleExtension.setNextTurnStage(self)
		end
	else
		local moveDown = not ( AIVehicleExtension.getIsLowered( self ) )
		AIVehicleExtension.setImplMoveDownClient(self, moveDown,true)
		if self.acParameters ~= nil and not moveDown and self.acParameters.upNDown then
			self.acParameters.leftAreaActive	= not self.acParameters.leftAreaActive 
			self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive
			AIVehicleExtension.sendParameters( self )
		end
	end
end

function AIVehicleExtension:getRaiseNextText()
	if self.spec_aiVehicle.isActive then
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
		if AIVehicleExtension.getIsLowered( self ) == nil then
			return ""
		elseif AIVehicleExtension.getIsLowered( self ) then
			return AIVEHud.getText( "AIVE_STEER_RAISE" )
		else
			return AIVEHud.getText( "AIVE_STEER_LOWER" )
		end
	end
	return ""
end

function AIVehicleExtension:getRaiseNextImage()
	if self.spec_aiVehicle.isActive then
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
		if AIVehicleExtension.getIsLowered( self ) == nil then
			return "empty.dds"
		elseif AIVehicleExtension.getIsLowered( self ) then
			return "dds/raise_impl.dds"
		else
			return "dds/lower_impl.dds"
		end
	end
	return "empty.dds"
end

function AIVehicleExtension:onSteerPause()
	if self.spec_aiVehicle.isActive then
		if self.aiveIsStarted then 
			self.acPause = not self.acPause
		end
	else
		AIVehicleExtension.onAutoSteer( self, not ( self.aiveAutoSteer ) )
	end
end

function AIVehicleExtension:getSteerPauseText()
	if self.spec_aiVehicle.isActive then
		if not self.aiveIsStarted then 
			return ""
		elseif self.acPause then
			return AIVEHud.getText( "AIVE_PAUSE_OFF" )
		else
			return AIVEHud.getText( "AIVE_PAUSE_ON" )
		end
	else
		if self.aiveAutoSteer then
			return AIVEHud.getText( "AIVE_STEER_OFF" )
		else
			return AIVEHud.getText( "AIVE_STEER_ON" )
		end
	end
	return ""
end

function AIVehicleExtension:getSteerPauseImage()
	if self.spec_aiVehicle.isActive then
		if not self.aiveIsStarted then 
			return "empty.dds"
		elseif self.acPause then
			return "dds/pause.dds"
		else
			return "dds/no_pause.dds"
		end
	else
		if self.aiveAutoSteer then
			return "dds/auto_steer_on.dds"
		else
			return "dds/auto_steer_off.dds"
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

function AIVehicleExtension:setUTurn(enabled)
	if not self.acParameters.upNDown then 
		self.acParameters.upNDown  = true 
		self.acParameters.straight = false 
	elseif not self.acParameters.straight then 
		self.acParameters.upNDown  = true   
		self.acParameters.straight = true  
	else 
		self.acParameters.upNDown  = false  
		self.acParameters.straight = false 
	end
end

function AIVehicleExtension:getUTurnImage()
	if not self.acParameters.upNDown then 
		return "dds/no_uturn2.dds"
	elseif not self.acParameters.straight then 
		return "dds/uturn.dds"
	else 
		return "dds/no_uturn.dds"
	end
	return "empty.dds"
end

function AIVehicleExtension:getUTurnText()
	if not self.acParameters.upNDown then 
		return AIVEHud.getText("AIVE_UTURN_OFF")
	elseif not self.acParameters.straight then 
		return AIVEHud.getText("AIVE_UTURN_ON")
	else 
		return AIVEHud.getText("AIVE_UTURN_ON2")
	end
	return ""
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
	return not self.spec_aiVehicle.isActive or not self:getCanStartAIVehicle()
end

function AIVehicleExtension:getStartImage()
	if self.spec_aiVehicle.isActive then
		return "dds/on.dds"
	elseif self:getCanStartAIVehicle() then
		return "dds/off.dds"
	end
	return "empty.dds"
end

function AIVehicleExtension:evalEnable()
	if     self.spec_aiVehicle.isActive          then
		return not ( self.aiveIsStarted )
	elseif self.acParameters.enabled then
		return false
	end
	return not ( self.aiveIsStarted )
end

function AIVehicleExtension:onEnable(enabled)
	if self:getCanStartAIVehicle() then
		if not ( self.spec_aiVehicle.isActive ) then
			self.acParameters.enabled = enabled
		end
	end
end

function AIVehicleExtension:getEnableImage()
	if not self:getCanStartAIVehicle()  then
		return "dds/off.dds"	
	elseif self.acParameters.enabled then
		return "dds/auto_combine.dds"
	else
		return "dds/ai_combine.dds"
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
	if self.spec_aiVehicle.isActive then
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
	if not self.spec_aiVehicle.isActive then
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
	if not self.spec_aiVehicle.isActive then
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
	if not self.spec_aiVehicle.isActive then
		return "empty.dds"
	end
	if not self.acPause then
		return "dds/no_pause.dds"
	end
	return "dds/pause.dds"
end

function AIVehicleExtension:evalAutoSteer()
	return self.spec_aiVehicle.isActive or not ( self.aiveAutoSteer )
end

function AIVehicleExtension:onAutoSteer(enabled)
	if self.spec_aiVehicle.isActive then
		if self.aiveAutoSteer then
			AIVehicleExtension.setInt32Value( self, "autoSteer", 2 )
		end
	elseif enabled then
		AIVehicleExtension.setInt32Value( self, "autoSteer", 1 )
		AIVehicleExtension.setImplMoveDownClient(self,true,true)
	else
		AIVehicleExtension.setInt32Value( self, "autoSteer", 0 )
	end
end

function AIVehicleExtension:onMagic(enabled)
	AIVehicleExtension.initMogliHud(self)
	AIVehicleExtension.invalidateState( self )
end

function AIVehicleExtension:onRaiseImpl(enabled)
	if		 self.spec_aiVehicle.isActive 
			or self.acParameters == nil then
	-- do nothing
	else
		AIVehicleExtension.setImplMoveDownClient(self,enabled,true)
		if self.acParameters ~= nil and not enabled and self.acParameters.upNDown then
			self.acParameters.leftAreaActive	= not self.acParameters.leftAreaActive 
			self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive
			AIVehicleExtension.sendParameters( self )
		end
	end
end

function AIVehicleExtension:evalRaiseImpl()
	if AIVehicleExtension.getIsLowered( self ) then
		return false
	end
	return true
end

function AIVehicleExtension:getRaiseImplImage()
	if		 self.spec_aiVehicle.isActive 
			or self.acParameters == nil then
		return "empty.dds"
	elseif AIVehicleExtension.getIsLowered( self ) == nil then
		return "empty.dds"
	elseif AIVehicleExtension.getIsLowered( self ) then
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
	
	if     self.acTurnMode == nil then
		img = "empty.dds"
	elseif self.acTurnMode == "8" then
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
	if self.acTurnMode ~= nil then
		return AIVEHud.getText("AIVE_TURN_MODE_"..self.acTurnMode)
	end
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

function AIVehicleExtension:setHeadland(old)
	if self.acParameters ~= nil and self.acParameters.upNDown then
		if not self.acParameters.headland then
			self.acParameters.headland    = true
			self.acParameters.bigHeadland = false
		elseif not self.acParameters.bigHeadland then
			self.acParameters.headland    = true
			self.acParameters.bigHeadland = true
		else
			self.acParameters.headland    = false
			self.acParameters.bigHeadland = false
		end
	end
end

function AIVehicleExtension:getHeadlandImage()
	if self.acParameters ~= nil and self.acParameters.upNDown then
		if not self.acParameters.headland then
			return "dds/noHeadland.dds"
		elseif not self.acParameters.bigHeadland then
			return "dds/small_headland.dds"
		else
			return "dds/big_headland.dds"
		end
	end
	return "dds/noHeadland.dds"
end

function AIVehicleExtension:getHeadlandText(old)
	if self.acParameters ~= nil and self.acParameters.upNDown then
		local st, bt = " (-)", " (+)"
		if self.isServer and ( self.acCheckStateTimer ~= nil or self.aiveIsStarted or self.aiveAutoSteer ) then
			local s, b = AIVehicleExtension.getHeadlandSmallBig( self )
			st = string.format(" (%5.2fm)",s)
			bt = string.format(" (%5.2fm)",b)
		end
		if not self.acParameters.headland then
			return AIVEHud.getText("AIVE_HEADLAND_ON")
		elseif not self.acParameters.bigHeadland then
			return AIVEHud.getText("AIVE_HEADLAND")..st
		else
			return AIVEHud.getText("AIVE_HEADLAND")..bt
		end
	end
	return AIVEHud.getText("AIVE_HEADLAND_ON")
end

function AIVehicleExtension:onToggleTrace()
	if self.acParameters ~= nil then 
		self.acParameters.showTrace = not ( self.acParameters.showTrace )
	end 
end

------------------------------------------------------------------------
-- update
------------------------------------------------------------------------

function AIVehicleExtension:onRegisterActionEvents(isSelected, isOnActiveVehicle)
	if self.isClient and self:getIsActiveForInput(true, true) then
		if self.aiveActionEvents == nil then 
			self.aiveActionEvents = {}
		else	
			self:clearActionEventsTable( self.aiveActionEvents )
		end 
		
		local actions = {}
		
		if self.aiveIsStarted then
			actions = { "AIVE_HELPPANEL" 	  
                 ,"AIVE_SWAP_SIDE"      
                 ,"AIVE_UTURN_ON_OFF"   
                 ,"AIVE_STEERING"         
                 ,"AIVE_START_AIVE"
                 ,"AXIS_MOVE_SIDE_VEHICLE"
								 ,"TOGGLE_CRUISE_CONTROL" }
		elseif self.spec_aiVehicle.isActive then 
		elseif self.aiveAutoSteer then 
			actions = { "AIVE_HELPPANEL" 	  
                 ,"AIVE_STEER"          
                 ,"AIVE_SWAP_SIDE"      
                 ,"AIVE_ENABLE"         
                 ,"AIVE_UTURN_ON_OFF"   
                 ,"AIVE_RAISE"            
                 ,"AIVE_START_AIVE" }
		else 
			actions = { "AIVE_HELPPANEL" 	  
                 ,"AIVE_STEER"          
                 ,"AIVE_SWAP_SIDE"      
                 ,"AIVE_ENABLE"         
                 ,"AIVE_UTURN_ON_OFF"   
                 ,"AIVE_STEERING"         
                 ,"AIVE_RAISE"            
                 ,"AIVE_START_AIVE" }
		end 
		
		for _,actionName in pairs( actions ) do
			local pBool1, pBool2, pBool3, pBool4 = false, true, false, true 
			if actionName == "AXIS_MOVE_SIDE_VEHICLE" then 
				pBool1 = true 
			end 
			local _, eventName = self:addActionEvent(self.aiveActionEvents, InputAction[actionName], self, AIVehicleExtension.actionCallback, pBool1, pBool2, pBool3, pBool4);
		end
	end
end

function AIVehicleExtension:actionCallback(actionName, keyStatus, arg4, arg5, arg6)

	AIVehicleExtension.debugPrint( self, tostring(actionName)..": "..tostring(keyStatus) )

	local guiActive = false
	if self.atHud ~= nil and self.atHud.GuiActive ~= nil then
		guiActive = self.atHud.GuiActive
	end

	if     actionName == "AIVE_HELPPANEL"  then
		AIVehicleExtension.showGui( self, not guiActive )
	elseif actionName == "AIVE_START_AIVE" then
		AIVehicleExtension.onAIVEScreen( self )
	elseif actionName == "AIVE_ENABLE" then
		if self.acParameters ~= nil then 
			AIVehicleExtension.onEnable( self, not self.acParameters.enabled )
			AIVehicleExtension.sendParameters(self)
		end
	elseif actionName == "AIVE_SWAP_SIDE"  then
		self.acParameters.leftAreaActive	= self.acParameters.rightAreaActive
		self.acParameters.rightAreaActive = not self.acParameters.leftAreaActive
		AIVehicleExtension.sendParameters(self)
	elseif actionName == "AIVE_STEER" then
		AIVehicleExtension.onAutoSteer(self, not ( self.aiveAutoSteer ))
	elseif actionName == "AIVE_UTURN_ON_OFF" then
		if     not self.acParameters.upNDown then 
			self.acParameters.upNDown  = true 
			self.acParameters.straight = false 
		elseif not self.acParameters.straight then 
			self.acParameters.upNDown  = true 
			self.acParameters.straight = true
		else 
			self.acParameters.upNDown  = false  
			self.acParameters.straight = false 
		end 
		AIVehicleExtension.sendParameters(self)
	elseif actionName == "AIVE_STEERING" then
		self.acParameters.noSteering = not self.acParameters.noSteering
		AIVehicleExtension.sendParameters(self)
	elseif actionName == "IMPLEMENT_EXTRA" then
		self.acCheckPloughSide = true
	elseif actionName == "AIVE_RAISE" and not self.aiveIsStarted then
		if self.acParameters ~= nil and self.acParameters.upNDown and self.acImplementsMoveDown then
			self.acParameters.leftAreaActive	= not self.acParameters.leftAreaActive 
			self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive
			AIVehicleExtension.sendParameters( self )
		end
		AIVehicleExtension.setImplMoveDownClient(self, not ( AIVehicleExtension.getIsLowered( self ) ), true)
	elseif  actionName == "AXIS_MOVE_SIDE_VEHICLE" 
			and self.aiveIsStarted 
			and self.acParameters ~= nil 
			and not self.acParameters.noSteering then 
		if math.abs( keyStatus ) > 0.05 then 
			self.acAxisSide = keyStatus
		else 
			self.acAxisSide = 0
		end 
	elseif  actionName == "TOGGLE_CRUISE_CONTROL" 
			and self.aiveIsStarted then 
		if self.speed2Level == nil or self.speed2Level > 0 then
			AIVehicleExtension.setPause( self, true )
		else
			AIVehicleExtension.setPause( self, false )
		end
	end
end 

------------------------------------------------------------------------
-- AIVehicleExtension.onPreUpdate
------------------------------------------------------------------------
function AIVehicleExtension:onPreUpdate( dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected )

	if      self.aiveAutoSteer
			and self.isClient
			and self.getIsEntered  ~= nil
			and self.acParameters  ~= nil 
			and self.spec_drivable ~= nil
			and self:getIsEntered()
			and self:getIsActiveForInput(true, true)
		--and ( self.aiveAutoSteer or ( self.aiveIsStarted and not self.acParameters.noSteering ) )
			and math.abs( self.spec_drivable.lastInputValues.axisSteer ) > 0.05 then 
		self.acAxisSide = self.spec_drivable.lastInputValues.axisSteer
	elseif self.aiveIsStarted then
	else 
		self.acAxisSide = 0
	end 
end

------------------------------------------------------------------------
-- AIVehicleExtension.onUpdate
------------------------------------------------------------------------

AIVehicleExtension.activeExtendedWorkers   = {}
AIVehicleExtension.numberOfExtendedWorkers = 0
AIVehicleExtension.extendedFrequencyDelay  = 1
function AIVehicleExtension:onUpdate( dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected )

	if self.aiveIsStarted and not ( self.spec_aiVehicle.isActive ) then 
		self.aiveIsStarted = false
	end 
	
	if self.aiveIsStarted then 
		if not ( AIVehicleExtension.activeExtendedWorkers[self] ) then 
			AIVehicleExtension.activeExtendedWorkers[self] = true 
			AIVehicleExtension.numberOfExtendedWorkers     = 0
			for v,b in pairs( AIVehicleExtension.activeExtendedWorkers ) do 
				if b then 
					AIVehicleExtension.numberOfExtendedWorkers = AIVehicleExtension.numberOfExtendedWorkers + 1 
				end 
			end 
		end 
	else
		if AIVehicleExtension.activeExtendedWorkers[self] then 
			AIVehicleExtension.activeExtendedWorkers[self] = nil 
			AIVehicleExtension.numberOfExtendedWorkers     = 0
			for v,b in pairs( AIVehicleExtension.activeExtendedWorkers ) do 
				if b then 
					AIVehicleExtension.numberOfExtendedWorkers = AIVehicleExtension.numberOfExtendedWorkers + 1 
				end 
			end 
		end
	end

	if self.aiveIsStarted and AIVehicle.aiUpdateLowFrequencyDelay ~= AIVehicleExtension.extendedFrequencyDelay then 
		if AIVehicleExtension.aiUpdateLowFrequencyDelay == nil then 
			AIVehicleExtension.aiUpdateLowFrequencyDelay = AIVehicle.aiUpdateLowFrequencyDelay
		end 
		AIVehicle.aiUpdateLowFrequencyDelay = AIVehicleExtension.extendedFrequencyDelay 
	end 

	if      self.acParameters ~= nil
			and self.acParameters.enabled
			and ( self.aiveIsStarted or self:getCanStartAIVehicle() ) then 
		AIVehicleExtension.checkState( self, false, true )
	end 
	
	if not ( self.aiveIsStarted ) and self.spec_aiVehicle.aiSteeringSpeed ~= self.acSteeringSpeed then
		self.spec_aiVehicle.aiSteeringSpeed = self.acSteeringSpeed
	end
	
	if self.aiveToolsDirty then 
		AIVehicleExtension.invalidateState( self )
		self.aiveToolsDirty = nil
	end 
	
	if atDump and self:getIsActiveForInput(false) then
		AIVehicleExtension.acDump2(self)
	end

	
	if self.isServer then		
-- in MP on server only 

		if      AIVEGlobals.otherAIColli > 0
				and self.aiveIsStarted
				and self.acParameters ~= nil
				and self.acParameters.collision
				and not self.acParameters.upNDown then 
			AIVehicleExtension.enableCollisionTriggers( self )
		else
			AIVehicleExtension.disableCollisionTriggers( self )
		end 
	
		if      ( self.aiveIsStarted or self.aiveAutoSteer )
				and self.acDimensions              ~= nil
				and self.acDimensions.acRefNodeZ   ~= nil
				and self.acDimensions.wheelBase    ~= nil 
				and self.acDimensions.wheelParents ~= nil then
				
			if AutoSteeringEngine.hasArticulatedAxis( self, true ) then	
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
				local _,angle,_ = getRotation( self.spec_articulatedAxis.rotationNode )
				self.acDimensions.artAxisR = angle 
				angle = 0.5 * angle
				self.acDimensions.artAxisX = dx 
				self.acDimensions.artAxisZ = dz 
				self.acDimensions.refNodeAngle = angle 
			else
				self.acDimensions.artAxisX = 0 
				self.acDimensions.artAxisZ = 0 
				self.acDimensions.refNodeAngle = 0
			end
			
			if self.acParameters.inverted then
				self.acDimensions.refNodeAngle = self.acDimensions.refNodeAngle + math.pi
			end
			local _,y,_ = getRotation( self.acRefNode )
			if math.abs( y - self.acDimensions.refNodeAngle ) > 0.01 then
				setRotation( self.acRefNode, 0, self.acDimensions.refNodeAngle, 0 )				
			end
			
			if self.acDimensions.refNodeTranslation == nil then 
				self.acDimensions.refNodeTranslation = { 0, 0, 0 }
			end 
			local lx,ly,lz = unpack( self.acDimensions.refNodeTranslation )
			local wx,wy,wz = getWorldTranslation( self.acRefNode )
			local ty       = getTerrainHeightAtWorldPos( g_currentMission.terrainRootNode, wx,wy,wz )		
			local rx,ry,rz = self.acDimensions.artAxisX, ly + ty - wy, self.acDimensions.artAxisZ + self.acDimensions.acRefNodeZ
		
			if self.acDimensions.refNodeTranslation == nil or math.abs( lx-rx ) > 0.01 or math.abs( ly-ry ) > 0.01 or math.abs( lz-rz ) > 0.01 then
				self.acDimensions.refNodeTranslation = { rx,ry,rz }
				setTranslation( self.acRefNode, rx,ry,rz )
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
			
			if self.acParameters.straight then 
				if not ( self.acIsStraight ) then 
					AIVehicleExtension.setAIDirection( self )
				end 
				
				self.acIsStraight = true  
			else 
				self.acIsStraight = false 
			end 
			
		elseif self.aiveAutoSteer then
			self.stopMotorOnLeave = false
			self.deactivateOnLeave = false
		else
			self.acTurnStage = 0
		end
	
		if      AutoSteeringEngine.hasArticulatedAxis( self )
				and ( self.aiveCanStartArtAxisTimer == nil or g_currentMission.time > self.aiveCanStartArtAxisTimer + 1000 ) then
				
			AIVehicleExtension.checkState( self )

			self.aiveCanStartArtAxisTimer = g_currentMission.time
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

		local lb = AIVehicleExtension.getIsLoweredServer( self )
		local lv
		if lb == nil then
			lv = 0
		elseif lb then
			lv = 2
		else
			lv = 1
		end
		if self.acIsLowered ~= lv then
			AIVehicleExtension.setInt32Value( self, "lowered", lv )
		end
	end
	
	if			self:getIsEntered() 
			and self.isClient 
			and self.isServer 
			and self.acParameters ~= nil and self.acParameters.showTrace 
			and self.atHud ~= nil and self.atHud.GuiActive 
			and ( self.aiveIsStarted or self.aiveAutoSteer ) then			
		if			AIVEGlobals.showTrace > 0 
				and self.acDimensions ~= nil
				and ( self.spec_aiVehicle.isActive or self.aiveAutoSteer ) then	
			AutoSteeringEngine.drawLines( self )
		else
			AutoSteeringEngine.drawMarker( self )
		end
	end	
	
	if self.aiveRequestActionEventUpdate then 
		self.aiveRequestActionEventUpdate = nil 
		self:requestActionEventUpdate()
	end 
end

------------------------------------------------------------------------
-- AIVehicleExtension.onStateChange
------------------------------------------------------------------------
function AIVehicleExtension:onStateChange(state, data)
	if state == Vehicle.STATE_CHANGE_ATTACH or state == Vehicle.STATE_CHANGE_DETACH then
    self.aiveToolsDirty = true
	end
end

------------------------------------------------------------------------
-- AIVehicleExtension.shiftAIMarker
------------------------------------------------------------------------
function AIVehicleExtension:setAIDirection()
	local dx,_,dz = localDirectionToWorld(self.acRefNode, 0, 0, 1)
	if g_currentMission.snapAIDirection then
		local snapAngle = self:getDirectionSnapAngle()
		snapAngle = math.max(snapAngle, math.pi/(g_currentMission.terrainDetailAngleMaxValue+1))
		local angleRad = MathUtil.getYRotationFromDirection(dx, dz)
		angleRad = math.floor(angleRad / snapAngle + 0.5) * snapAngle
		dx, dz = MathUtil.getDirectionFromYRotation(angleRad)
	else
		local length = MathUtil.vector2Length(dx,dz)
		dx = dx / length
		dz = dz / length
	end
	self.aiDriveDirection = {dx, dz}
	local x,_,z = getWorldTranslation(self.acRefNode)
	self.aiDriveTarget = {x, z}
	
	if self.isServer then 
		AIVehicleExtension.checkState( self )
		if self.aiveChain.toolCount > 0 then 
			local dir
			if self.acParameters.leftAreaActivethen then 
				dir = -1 
			else 
				dir = 1
			end 
			local dir2 = 0
			
			local best,prev = nil, nil
			for i=0,24 do 
				local d = i * dir2 * dir * 0.125
				local x = self.aiveChain.activeX + d
				
				local sx
				local sz
				local hasField1 = true  
				local hasFruit  = false 
				for z=0,30 do 
					z1 = z + 1
					sx = self.aiDriveTarget[1] + x * self.aiDriveDirection[2] + ( math.max( 0, self.aiveChain.maxZ ) + z ) * self.aiDriveDirection[1]
				  sz = self.aiDriveTarget[2] - x * self.aiDriveDirection[1] + ( math.max( 0, self.aiveChain.maxZ ) + z ) * self.aiDriveDirection[2]
					if AutoSteeringEngine.checkField( self, sx,sz ) then
						break 
					end 
				end 
				for z=1,100 do 
					local wx = sx + z * self.aiDriveDirection[1]
					local wz = sz + z * self.aiDriveDirection[2]
					if AutoSteeringEngine.checkField( self, wx,wz ) then 
						hasField1 = true  
						if AutoSteeringEngine.hasFruitsSimple( self, sx, sz, wx, dz, dir ) then 
							hasFruit = true 
							AIVehicleExtension.debugPrint( self, "Fruits at "..tostring(i)..", "..tostring(dir2)..", "..tostring(z1).." .. "..tostring(z))
							break 
						end 
					elseif hasField1 then 
						hasField1 = false 
					else 
						AIVehicleExtension.debugPrint( self, "EOF at "..tostring(i)..", "..tostring(dir2)..", "..tostring(z1).." .. "..tostring(z))
						break 
					end 
				end 
				if i == 0 then 
					if hasFruit then 
						dir2 = 1 
					else 
						dir2 = -1 
					end 
				elseif dir2 < 0 then  
					if hasFruit then 
						AIVehicleExtension.debugPrint( self,  "Exit at "..tostring(i).." / "..tostring(dir2).." / "..tostring(prev))
						best = prev 
						break 
					end 
				else 
					if not hasFruit then 
						AIVehicleExtension.debugPrint( self,  "Exit at "..tostring(i).." / "..tostring(dir2).." / "..tostring(prev))
						best = d 
						break 
					end 
				end 
				prev = d
			end 
			
			if best ~= nil then 
				local x,_,z = localToWorld(self.acRefNode, best, 0, 0 )
				self.aiDriveTarget = {x, z}
			end 
		end 
	end 
end 

------------------------------------------------------------------------
-- AIVehicleExtension.resetAIMarker
------------------------------------------------------------------------
function AIVehicleExtension:resetAIMarker()
	if self.atShiftedMarker ~= nil then 
	--AIVehicleExtension.debugPrint( self, "resetting shifted marker")
		self.atLastMarkerShift = 0
		for _,marker in pairs( {"aiCurrentLeftMarker", "aiCurrentRightMarker", "aiCurrentBackMarker"} ) do 						
			setTranslation( self.atShiftedMarker[marker], 0, 0, 0 )
		end 		
	end 		
end 

------------------------------------------------------------------------
-- AIVehicle:setImplMoveDownClient(moveDown)
------------------------------------------------------------------------
function AIVehicleExtension:setImplMoveDownClient( moveDown, immediate, noEventSend )

	local value = 0
	if moveDown then
		value = value + 2
	end
	if immediate then
		value = value + 1
	end
	AIVehicleExtension.setInt32Value( self, "moveDown", value )
	
end
	
------------------------------------------------------------------------
-- AIVehicle:setAIImplementsMoveDown(moveDown)
------------------------------------------------------------------------
function AIVehicleExtension:setAIImplementsMoveDown( moveDown, immediate )
	if self.acImplementsMoveDown == nil or self.acImplementsMoveDown ~= moveDown then
		AutoSteeringEngine.setToolsAreLowered( self, moveDown, immediate )
	end
	if immediate then
		AutoSteeringEngine.ensureToolIsLowered( self, moveDown )
	end
	
	self.acImplementsMoveDown  = moveDown
	self.acImplementsMoveDown2 = moveDown
	self.acImplMoveDownTimer   = 0 
end

------------------------------------------------------------------------
-- setStatus
------------------------------------------------------------------------
function AIVehicleExtension:setStatus( newStatus, noEventSend )
	
	if self ~= nil and self.atMogliInitDone and self.atHud ~= nil and ( self.atHud.Status == nil or self.atHud.Status ~= newStatus ) then
		AIVehicleExtension.setInt32Value( self, "status", AIVEUtils.getNoNil( newStatus, 0 ) )
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
			and self.acCheckStateTimer > g_currentMission.time
			and ( clientOnly or self.acCheckStateServer ) then
		return 
	end
	
	if self.acDimensions == nil then
		AIVehicleExtension.calculateDimensions( self )
	end
	
	self.acCheckStateTimer  = g_currentMission.time + AIVEGlobals.maxDtSumT
	self.acCheckStateServer = not ( clientOnly )
	
	local s = AutoSteeringEngine.getSpecialToolSettings( self )
	
	if s.rightOnly then
		self.acParameters.upNDown				  = false
		self.acParameters.straight			  = false
		self.acParameters.leftAreaActive	= true
		self.acParameters.rightAreaActive = false
	end
	if s.leftOnly then
		self.acParameters.upNDown				  = false
		self.acParameters.straight			  = false
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
	
	AutoSteeringEngine.initTools( self, self.acDimensions.maxSteeringAngle, self.acParameters.leftAreaActive, self.acParameters.widthOffset, h, c, self.acTurnMode )
	
	if not ( clientOnly ) then
		AutoSteeringEngine.initSteering( self )
	end
end

------------------------------------------------------------------------
-- autoSteer
------------------------------------------------------------------------
function AIVehicleExtension:newUpdateVehiclePhysics( superFunc, axisForward, axisSide, doHandbrake, dt )

	if self.isServer and self.aiveAutoSteer then 	
		self.acParameters.straight = false 
		AIVehicleExtension.checkState( self )
		
		local doit = true  
		if self.acTurnStage ~= 199 then
			self.acTurnStage = 198
		end
		
		if not AutoSteeringEngine.hasTools( self ) then
			self.acTurnStage = 0
			AIVehicleExtension.setStatus( self, 0 )
			doit = false 
		end

		if doit then 
			local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( self )
			local fruitsAdvance = fruitsDetected
			if not fruitsAdvance and AutoSteeringEngine.hasFruits( self, true ) then
				fruitsAdvance = true
			end
			
			local isMovedDown = AIVehicleExtension.getIsLoweredServer( self )
			
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
			--nilAngle    = "L"
				
			--if	   self.turnTimer < 0 
			--		or AutoSteeringEngine.getIsAtEnd( self ) then
			--	target = math.min( math.max( 0.5 * AutoSteeringEngine.getTurnAngle(self), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
			--	if AutoSteeringEngine.getNoReverseIndex( self ) <= 0 then
			--		target = math.max( target, 0 )
			--	end
			--	if not self.acParameters.leftAreaActive then
			--		target = -target
			--	end
			--end
			else
				inField     = false
				angleFactor = 1
			--nilAngle    = "M"
			end
			
			local detected, angle, border, tX, _, tZ, dist
			
			if fruitsAdvance then 
				detected, angle, border, tX, _, tZ, dist = AutoSteeringEngine.processChain( self, inField, target, angleFactor, nilAngle )	
			else 
				detected, angle, border, tX, _, tZ, dist = false, 0, 0, 0, 0 
			end 
			
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
				if border > 0 then
					AIVehicleExtension.setStatus( self, 3 )
				else
					if AutoSteeringEngine.getIsAtEnd( self ) then
						if self.acParameters.leftAreaActive then
							angle = math.max( angle, 0 )
						else
							angle = math.min( angle, 0 )
						end
					end
					if fruitsDetected then
						self.turnTimer = self.acDeltaTimeoutRun
					end			
					AIVehicleExtension.setStatus( self, 2 )
				end
			else
				if self.acTurnStage == 199 and border <= 0 then
					self:setCruiseControlState( Drivable.CRUISECONTROL_STATE_OFF )
				end

				if border > 0 then
					AIVehicleExtension.setStatus( self, 3 )
				else
					AIVehicleExtension.setStatus( self, 2 )
				end
				
				self.acTurnStage = 198
			end
						
			if     self.acAxisSideFactor == nil then
				self.acAxisSideFactor = 0
			elseif self.movingDirection < -1E-2 or not self.acImplementsMoveDown then	
				self.acAxisSideFactor = math.max( self.acAxisSideFactor - dt, 0 )
			elseif self:getIsEntered() and math.abs( self.acAxisSide ) > 0 then
				self.acAxisSideFactor = math.max( self.acAxisSideFactor - dt, 0 )
			elseif border > 0 then 
				self.acAxisSideFactor = math.min( self.acAxisSideFactor + 10 * dt, 1000 )
			elseif not detected then 
				self.acAxisSideFactor = math.max( self.acAxisSideFactor - dt, 0 )
			else
				self.acAxisSideFactor = math.min( self.acAxisSideFactor + dt, 1000 )
			end
			
			local f = 0.001 * self.acAxisSideFactor
			
			local newAxisSide = - angle / self.acDimensions.maxSteeringAngle
	
			if self.lastAxisSide ~= nil and border <= 0 and self.acTurnStage ~= 199 then 
			--local d = 0.0005 * ( 2 + math.min( 18, self.lastSpeed * 3600 ) ) * dt
				local d = 0.002 * dt 
				newAxisSide = AIVEUtils.clamp( newAxisSide, self.lastAxisSide-d, self.lastAxisSide+d )
			end 
	
			if     f <= 0 then
				newAxisSide = axisSide
			elseif f  < 1 then
				newAxisSide = (1-f) * axisSide + f * newAxisSide
			end
			
			axisSide = AIVEUtils.clamp( newAxisSide, -1, 1)		
		end
		
		self.lastAxisSide = axisSide 
	end

	return superFunc( self, axisForward, axisSide, doHandbrake, dt )
end

Drivable.updateVehiclePhysics = Utils.overwrittenFunction( Drivable.updateVehiclePhysics, AIVehicleExtension.newUpdateVehiclePhysics )

------------------------------------------------------------------------
-- getSaveAttributesAndNodes
------------------------------------------------------------------------

function AIVehicleExtension:saveToXMLFile(xmlFile, key)
	for n,p in pairs( AIVehicleExtension.saveAttributesMapping ) do
		if self.acParameters[n] ~= p.default or p.always then			
			if		 p.tp == "B" then
				setXMLBool(xmlFile, key.."#"..p.xml, self.acParameters[n])
			elseif p.tp == "I" then
				setXMLInt(xmlFile, key.."#"..p.xml, self.acParameters[n])
			else--if p.tp == "F" then
				setXMLFloat(xmlFile, key.."#"..p.xml, self.acParameters[n])
			end
		end
	end
end

------------------------------------------------------------------------
-- loadFromAttributesAndNodes
------------------------------------------------------------------------
function AIVehicleExtension:onPostLoad(savegame)
	if savegame ~= nil then
		local xmlFile = savegame.xmlFile
		local key     = savegame.key.."."..AIVehicleExtensionRegister.specName

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
		self.acDimensions								  = nil
		
	--if type( self.setIsReverseDriving ) == "function" and self.acParameters.inverted then
	--	self:setIsReverseDriving( self.acParameters.inverted, false )
	--end
	end
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
	
	local r = self.maxRotation
	if r == nil then 
		r = 25
	elseif r < 2 then 
		r = math.deg( r ) 
	end 
	self.acDimensions.maxSteeringAngle = math.rad( math.min( r, 60 ) )
	self.acDimensions.radius           = AIVEUtils.getNoNil( self.maxTurningRadius, 6 ) * 1.2

--max rotation is for the inner radius
	local d = 1.25
	local wheel = self.spec_wheels.wheels[self.maxTurningRadiusWheel] 
	if wheel ~= nil then
		local diffX, _, diffZ = localToLocal(wheel.node, self.spec_wheels.steeringCenterNode, wheel.positionX, wheel.positionY, wheel.positionZ)
		d = math.abs( diffX )
	end 
	self.acDimensions.radius           = math.max( 0, self.acDimensions.radius - d )					
	self.acDimensions.wheelBase        = math.tan( self.acDimensions.maxSteeringAngle ) * self.acDimensions.radius

	self.acDimensions.artAxisR         = 0
	self.acDimensions.artAxisX         = 0
	self.acDimensions.artAxisZ         = 0
	
	self.acDimensions.wheelParents = {}

	for _,wheel in pairs(self.spec_wheels.wheels) do
		local node = getParent( wheel.driveNode )
		if self.acDimensions.wheelParents[node] == nil then
			self.acDimensions.wheelParents[node] = 1
		else
			self.acDimensions.wheelParents[node] = self.acDimensions.wheelParents[node] + 1
		end
	end
	
	AIVehicleExtension.debugPrint( self, string.format("wb: %0.3fm, r: %0.3fm, z: %0.3fm", self.acDimensions.wheelBase, self.acDimensions.radius, self.acDimensions.acRefNodeZ ))
	
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
  local small = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, 
																											self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.frontToBack,
																											self.acDimensions.radius, self.acDimensions.radius75, self.acDimensions.wheelBase, false, nri )
	local big   = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, 
																											self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.frontToBack,
																											self.acDimensions.radius, self.acDimensions.radius75, self.acDimensions.wheelBase, true,  nri )
	
	return small, big
end

------------------------------------------------------------------------
-- calculateHeadland
------------------------------------------------------------------------
function AIVehicleExtension.calculateHeadland( turnMode, realWidth, zBack, toolDist, frontToBack, radius, radius75, wheelBase, big, noRevIdx )

	local width = 1.5
	if big then
		if realWidth ~= nil and realWidth > width then
			width = realWidth
		end
		width = width + 2
	end
	
--local frontToBack = 1
--if noRevIdx ~= nil and noRevIdx <= 0 and turnMode == "T" then
--	frontToBack = math.max( -zBack, 1 )
--elseif big then
--	frontToBack = math.max( toolDist - zBack, 1 )
--end
	
	
	local ret = 0
	if		 turnMode == "A"
			or turnMode == "L" then
	--ret	 = math.max( 2, toolDist ) + math.abs( wheelBase ) + math.abs( zBack ) + frontToBack
		ret	 = 1 + math.max( frontToBack - toolDist + math.abs( wheelBase ) + 1, 
												 - toolDist - zBack )
		if big then
			ret = ret + 3
		end
		ret	 = math.max( ret, width ) 
	elseif turnMode == "C" then
		ret	 = width + math.max( -zBack, 0 ) + radius
	else
		local r = radius
		local z = 0
	--if turnMode == "O" or turnMode == "8" then
	--	r = 0.5 * ( radius + radius75 )
	--end 
		if turnMode == "O" then -- or turnMode == "8" then
			local beta = math.acos( math.min(math.max(realWidth / r, 0),1) )
			z	= 2.2 * radius * math.sin( beta )
			if big then
				z = z + 1.1
			end
		end
		ret	= width + r + math.max( frontToBack - toolDist + z, toolDist )
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
	
	local rd = false 
	if self.spec_reverseDriving ~= nil and self.spec_reverseDriving.isReverseDriving then
		rd = true 
	end 
	
	AutoSteeringEngine.checkChain( self, self.acRefNode, self.acDimensions.wheelBase, self.acDimensions.maxSteeringAngle, self.acDimensions.radius,
																 self.acParameters.widthOffset, self.acParameters.turnOffset, rd, 
																 self.acParameters.useAIFieldFct, self.acParameters.precision )

	self.acDimensions.distance, self.acDimensions.toolDistance, self.acDimensions.zBack, self.acDimensions.frontToBack, self.acDimensions.radius75 
								= AutoSteeringEngine.checkTools( self )
	
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
	self.acDimensions.headlandDist	 = AIVehicleExtension.calculateHeadland( self.acTurnMode, self.acDimensions.distance, 
																					self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.frontToBack, 
																					self.acDimensions.radius, self.acDimensions.radius75, self.acDimensions.wheelBase, self.acParameters.bigHeadland, 
																					AutoSteeringEngine.getNoReverseIndex( self ) )
	self.acDimensions.collisionDist	= 1 + AIVehicleExtension.calculateHeadland( self.acTurnMode, math.max( self.acDimensions.distance, 1.5 ), 
																					self.acDimensions.zBack, self.acDimensions.toolDistance, self.acDimensions.frontToBack,
																					self.acDimensions.radius, self.acDimensions.radius75, self.acDimensions.wheelBase, self.acParameters.bigHeadland,
																					AutoSteeringEngine.getNoReverseIndex( self ) )
	self.acDimensions.uTurnDist4x   = 1 + math.max( math.max( self.acDimensions.toolDistance - self.acDimensions.radius, self.acDimensions.distance ) - self.acDimensions.radius, 0 )
	--if self.acShowDistOnce == nil then
	--	self.acShowDistOnce = 1
	--else
	--	self.acShowDistOnce = self.acShowDistOnce + 1
	--end
	--if self.acShowDistOnce <= 30 then
	--	AIVehicleExtension.debugPrint( self, string.format("max( %0.3f , 1.5 ) + max( - %0.3f, 0 ) + max( %0.3f - %0.3f, 1 ) + %0.3f = %0.3f", self.acDimensions.distance, zBack, self.acDimensions.toolDistance, zBack, self.acDimensions.radius, self.acDimensions.headlandDist ) )
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
	local spec = self.spec_aiVehicle

	if self.isServer and spec.driveStrategies ~= nil then
		for i,d in pairs( spec.driveStrategies ) do
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
			streamWriteBool(streamId, AIVEUtils.getNoNil( parameters[n], p.default ))
		elseif p.tp == "I" then
			streamWriteInt8(streamId, AIVEUtils.getNoNil( parameters[n], p.default ))
		else--if p.tp == "F" then
			streamWriteFloat32(streamId, AIVEUtils.getNoNil( parameters[n], p.default ))
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
		self.acParameters[n] = AIVEUtils.getNoNil( parameters[n], p.default )
	end

	self.acParameters.leftAreaActive	= not self.acParameters.rightAreaActive
end

function AIVehicleExtension:onReadStream(streamId, connection)
	AIVehicleExtension.setParameters( self, AIVehicleExtension.readStreamHelper(streamId) )
end

function AIVehicleExtension:onWriteStream(streamId, connection)
	AIVehicleExtension.writeStreamHelper(streamId,AIVehicleExtension.getParameters(self))
end

function AIVehicleExtension:onReadUpdateStream(streamId, timestamp, connection)
  if connection:getIsServer() then
		if streamReadBool( streamId ) then
			self.acTurnStage = streamReadUInt8( streamId ) - 10
			self.acAxisSide  = streamReadInt8( streamId ) * 0.01
		end
  end 
end 

function AIVehicleExtension:onWriteUpdateStream(streamId, connection, dirtyMask)
  if not connection:getIsServer() then
		if self.aiveIsStarted or self.aiveAutoSteer then
			streamWriteBool(streamId, true )
			streamWriteUInt8(streamId, AIVEUtils.clamp( 10 + self.acTurnStage, 0, 255 ) )
			streamWriteInt8(streamId, math.floor( AIVEUtils.clamp( 0.5 + 100 * self.acAxisSide, -100, 100 ) ) )
		else
			streamWriteBool(streamId, false )
		end
	end 
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
function AIVehicleExtension:getMaxAngleWithTool( outside, wide )
	
	if AutoSteeringEngine.getNoReverseIndex( self ) <= 0 then
		if outside then
			return -self.acDimensions.maxSteeringAngle
		end
		return self.acDimensions.maxSteeringAngle
	end
	
	local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self )
	local angle
	local toolAngle = AutoSteeringEngine.getToolAngle( self )	
	if not self.acParameters.leftAreaActive then
		toolAngle = -toolAngle
	end
	
	local maxToolAngle = AutoSteeringEngine.getMaxToolAngle( self )
	local maxAngle     = self.acDimensions.maxSteeringAngle
	local extremeTA    = math.pi * 0.5
	local extremeAngle = -self.acDimensions.maxSteeringAngle
	local targetAngle  = turn75.alpha
	local midAngle     = math.min(1.1*targetAngle,maxAngle)

	if wide then 
		maxAngle         = turn75.alpha
	end 	
	if outside then 
		maxToolAngle = -maxToolAngle 
		maxAngle     = -maxAngle 
		extremeTA    = -extremeTA
		extremeAngle = -extremeAngle
		targetAngle  = -targetAngle 
		midAngle     = -midAngle
	end 
	
	angle = AIVEUtils.interpolate( toolAngle,{{ 0,                maxAngle },
																						{ 0.8*maxToolAngle, midAngle },
																						{ 0.97*maxToolAngle,targetAngle },
																						{ 1.03*maxToolAngle,0.5*targetAngle },
																						{ 1.1*maxToolAngle, 0 },
																						{	extremeTA,        extremeAngle }} )
	
--local f = 2
--if AutoSteeringEngine.hasArticulatedAxis( self ) then
--	f = 1
--end
--
--if outside then
--	angle = AIVEUtils.clamp( -turn75.alpha + f * ( -toolAngle - maxToolAngle ), -self.acDimensions.maxSteeringAngle, 0 )
--else                                                                                                   
--	angle = AIVEUtils.clamp(  turn75.alpha - f * (  toolAngle - maxToolAngle ), 0, self.acDimensions.maxSteeringAngle )
--end
	
	if AIVEGlobals.devFeatures > 0 then -- and math.abs( toolAngle ) >= maxToolAngle - 0.01745 then
		self:acDebugPrint( string.format("Tool angle: ts: %d a: %0.1f° mt: %0.1f° ms: %0.1f° to: %0.1f°", self.acTurnStage, math.deg(angle), math.deg(maxToolAngle), math.deg(self.acDimensions.maxSteeringAngle), math.deg(toolAngle) ) )
	end
	
	return angle
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
	
	local rd = false 
	if self.spec_reverseDriving ~= nil and self.spec_reverseDriving.isReverseDriving then
		rd = true 
	end 
	if math.abs( a - AutoSteeringEngine.currentSteeringAngle( self, rd ) ) < 0.05236 then -- 3° 
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

	local x, z = AutoSteeringEngine.getTurnVector( self, AIVEUtils.getNoNil( uTurn, false ), AIVEUtils.getNoNil( turn2Outside, false ) )
 
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

	local target = math.rad( AIVEUtils.getNoNil( iTarget, 0 ) )

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
		local m = self.acDimensions.maxSteeringAngle
		return AIVEUtils.clamp( -turnAngle, -m, m )
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
	
	local maxToolAngle = AIVEGlobals.maxToolAngle
	
	local maxWorldRatio = 0.75 / AutoSteeringEngine.tableGetN( taJoints  )
	local ratio  = AIVEUtils.clamp( AutoSteeringEngine.normalizeAngle( yv - yt ) / maxToolAngle, -maxWorldRatio, maxWorldRatio )
	local target = ratio

	self:acDebugPrint( AutoSteeringEngine.radToString( yv ) .." - " ..AutoSteeringEngine.radToString( yt ) .." => "..string.format("ratio: %5.3f", ratio) )
	
	local sumTargetFactors = 0
	for _,joint in pairs( taJoints ) do
		sumTargetFactors = sumTargetFactors + joint.targetFactor
	end
	
	local maxToolDegrees = maxToolAngle / sumTargetFactors
	for _,joint in pairs( taJoints ) do
		target    = joint.targetFactor * ratio
		degree    = AutoSteeringEngine.getRelativeYRotation( joint.nodeVehicle, joint.nodeTrailer )
		self:acDebugPrint( "f: "..tostring(joint.targetFactor)
											.." / "..tostring(sumTargetFactors)
											..", d: "..AutoSteeringEngine.radToString(degree)
											..", t: "..AutoSteeringEngine.radToString(target))
		if joint.otherDirection then
			degree  = AutoSteeringEngine.normalizeAngle( degree + math.pi )
		end
		angle     = AIVEUtils.clamp( degree / maxToolDegrees, -1, 1 )	
		ratio     = AIVEUtils.clamp( target + 1.5 * ( angle - ratio ), -1, 1 )
	end
	
	if AutoSteeringEngine.hasArticulatedAxis( self, true, true ) then 
		ratio = AIVEUtils.clamp( ratio, -0.5, 0.5 )
	end 
	
	angle = ratio * self.acDimensions.maxSteeringAngle
	
	if not self.acParameters.leftAreaActive then
		angle = -angle 
	end
	
	self:acDebugPrint( "gSBA: current: "..AutoSteeringEngine.radToString( yt ).." target: "..AutoSteeringEngine.radToString( yv ).." => angle: "..AutoSteeringEngine.radToString( angle ).." ("..tostring( self.acParameters.leftAreaActive ).." / "..AutoSteeringEngine.radToString( iTarget ).." / "..AutoSteeringEngine.radToString( self.aiveChain.trace.a )..")")
	
	return angle 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getIsLowered
------------------------------------------------------------------------
function AIVehicleExtension:getIsLoweredServer()
	if self.acImplementsMoveDown == nil then
		if self.acImplMoveDownTimer < g_currentMission.time then
			self.acImplMoveDownTimer   = g_currentMission.time + 250
			self.acImplementsMoveDown2 = AutoSteeringEngine.areToolsLowered( self )
		end
		return self.acImplementsMoveDown2
	end
	return self.acImplementsMoveDown
end

function AIVehicleExtension:getIsLowered()
	if     self.acIsLowered == 1 then
		return false
	elseif self.acIsLowered == 2 then
		return true 
	end
	return false 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:onChangeLowered
------------------------------------------------------------------------
function AIVehicleExtension:onChangeLowered( isLowered )
	if self.aiveIsStarted and isLowered and AIVEGlobals.devFeatures > 0 then 
		AIVehicleExtension.printCallstack() 
	end
	if  not self.aiveIsStarted 
			and self.acImplementsMoveDown ~= nil
			and self.acImplementsMoveDown ~= isLowered then
		self.acImplementsMoveDown = nil
		self.acImplMoveDownTimer  = 0
	end
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getStraighForwardsAngle( iTarget )

	local target = math.rad( AIVEUtils.getNoNil( iTarget, 0 ) )

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
	
	angle = AIVEUtils.clamp( angle, -self.acDimensions.maxSteeringAngle, self.acDimensions.maxSteeringAngle )

	return angle 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getLimitedToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getLimitedToolAngle( iLimit )

	local toolAngle = AIVehicleExtension.getToolAngle( self )
	local limit     = AIVEUtils.getNoNil( iLimit, 0.5 * self.acDimensions.maxSteeringAngle )
	
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
-- AIVehicleExtension:onStopAiVehicle
------------------------------------------------------------------------
function AIVehicleExtension:onStopAiVehicle()
	self.acImplementsMoveDown = nil
	self.acImplMoveDownTimer  = 0
	self.acTurnStage          = 0
	self.aiveIsStarted        = false
	AIVehicleExtension.setStatus( self, 0 )
end

function AIVehicleExtension:onSetLowered(lowered)
	AIVehicleExtension.onChangeLowered( self, lowered )
end
function AIVehicleExtension:onLowerAll(doLowering)
	AIVehicleExtension.onChangeLowered( self, doLowering )
end
function AIVehicleExtension:onTurnedOn()
	AIVehicleExtension.onChangeLowered( self, true )
end
function AIVehicleExtension:onTurnedOff()
	AIVehicleExtension.onChangeLowered( self, false )
end
function AIVehicleExtension:setFoldState(direction, moveToMiddle)
	AIVehicleExtension.onChangeLowered( self, not ( moveToMiddle ) )
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
function AIVehicleExtension:afterUpdateAIDriveStrategies()	

	local spec = self.spec_aiVehicle
	
	if self.acParameters == nil then
		self.aiveIsStarted = false
	elseif self.spec_aiVehicle.isActive and self.acParameters.enabled then
		self.aiveIsStarted = true
	end
	if self.aiveIsStarted and spec.driveStrategies ~= nil and #spec.driveStrategies > 0 then
		for i,d in pairs( spec.driveStrategies ) do
			local driveStrategyMogli = nil
			if     d:isa(AIDriveStrategyStraight) then
				driveStrategyMogli = AIDriveStrategyMogli:new()
			elseif d:isa(AIDriveStrategyCombine ) then 
				driveStrategyMogli = AIDriveStrategyCombine131:new()
			end
			if driveStrategyMogli ~= nil then
				driveStrategyMogli:setAIVehicle(self)
				spec.driveStrategies[i]:delete()
				spec.driveStrategies[i] = driveStrategyMogli
			end
		end
		
		if AIVEGlobals.otherAIColli > 0 then
			local driveStrategyOtherAI = AIDriveStrategyCollisionOtherAI:new()
			driveStrategyOtherAI:setAIVehicle(self)
			table.insert( spec.driveStrategies, 1, driveStrategyOtherAI )
		end
		
		AutoSteeringEngine.invalidateField( self, self.acParameters.useAIFieldFct )
		AutoSteeringEngine.initFruitBuffer( self )
		AIVehicleExtension.setInt32Value( self, "autoSteer", 2 )
	else
		self.aiveIsStarted = false
	end
	
end

AIVehicle.updateAIDriveStrategies = Utils.appendedFunction( AIVehicle.updateAIDriveStrategies, AIVehicleExtension.afterUpdateAIDriveStrategies )

--==============================================================		
-- AIVehicle.getCanStartAIVehicle		
--==============================================================				
---Returns true if ai can start
-- @return boolean canStart can start ai
-- @includeCode
function AIVehicleExtension:newGetCanStartAIVehicle( superFunc, ... )
	-- check if reverse driving is available and used, we do not allow the AI to work when reverse driving is enabled

	if      self.acParameters ~= nil
			and self.acParameters.enabled
			and AutoSteeringEngine.hasArticulatedAxis( self )
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

AIVehicle.getCanStartAIVehicle = Utils.overwrittenFunction( AIVehicle.getCanStartAIVehicle, AIVehicleExtension.newGetCanStartAIVehicle )

------------------------------------------------------------------------
-- onOtherAICollisionTrigger
------------------------------------------------------------------------
function AIVehicleExtension:onOtherAICollisionTrigger(triggerId, otherId, onEnter, onLeave, onStay, otherShapeId)
--print(" HIT @:"..self.configFileName.." in "..getName(triggerId).." by "..getName(otherId)..", "..getName(otherShapeId)..": "..
--			tostring(onEnter)..", "..tostring(onLeave)..", "..tostring(onLeave))

	if self.acCollidingVehicles == nil or self.acCollidingVehicles[triggerId] == nil then 
		return
	end 

	if g_currentMission.players[otherId] == nil then
		local vehicle = g_currentMission.nodeToObject[otherId]
		local otherAI = nil
			
		if vehicle ~= nil then
			if vehicle.specializations ~= nil and SpecializationUtil.hasSpecialization( AIVehicle, vehicle.specializations ) then
				otherAI = vehicle 
			elseif type( vehicle.getRootVehicle ) == "function" then 
				otherAI = vehicle:getRootVehicle()
				if otherAI.specializations == nil or not SpecializationUtil.hasSpecialization( AIVehicle, otherAI.specializations ) then
					otherAI = nil
				end
			end
		end
			
		if      otherAI ~= nil
				and otherAI ~= self then
			if not onLeave then
				self.acCollidingVehicles[triggerId][otherAI] = true
			elseif self.acCollidingVehicles[triggerId][otherAI] then
				self.acCollidingVehicles[triggerId][otherAI] = nil
			end
		end		
	end
end


------------------------------------------------------------------------
-- newDriveToPoint
------------------------------------------------------------------------
function AIVehicleExtension.newDriveToPoint( self, superFunc, dt, acceleration, allowedToDrive, moveForwards, tX, tZ, maxSpeed, doNotSteer, ... )
	if not ( self.aiveIsStarted ) then 
		return superFunc( self, dt, acceleration, allowedToDrive, moveForwards, tX, tZ, maxSpeed, doNotSteer, ... )
	end 
	
	if not ( self.firstTimeRun ) then
		return 
	end 
	
	if not allowedToDrive then
		self.aiveLastSpeedLimit = AIVEGlobals.minSpeed
	else 		
		local tX_2 = tX * 0.5
		local tZ_2 = tZ * 0.5
		local d1X, d1Z = tZ_2, -tX_2
		if tX > 0 then
			d1X, d1Z = -tZ_2, tX_2
		end
		local hit,_,f2 = MathUtil.getLineLineIntersection2D(tX_2,tZ_2, d1X,d1Z, 0,0, tX, 0)
		if doNotSteer == nil or not doNotSteer then
			local rotTime = 0
			if hit and math.abs(f2) < 100000 then
				local radius = tX * f2
				rotTime = self.wheelSteeringDuration * ( math.atan(1/radius) / math.atan(1/self.maxTurningRadius) )
			end
			local targetRotTime
			if rotTime >= 0 then
				targetRotTime = math.min(rotTime, self.maxRotTime)
			else
				targetRotTime = math.max(rotTime, self.minRotTime)
			end
			if targetRotTime > self.rotatedTime then
				self.rotatedTime = math.min(self.rotatedTime + dt*self:getAISteeringSpeed(), targetRotTime)
			else
				self.rotatedTime = math.max(self.rotatedTime - dt*self:getAISteeringSpeed(), targetRotTime)
			end
			-- adjust maxSpeed
			local steerDiff = targetRotTime - self.rotatedTime
			local fac = math.abs(steerDiff) / math.max(self.maxRotTime, -self.minRotTime)
			local speedReduction = 1.0 - math.pow(fac, 0.25)
			maxSpeed = math.max( math.min( 2, maxSpeed ), maxSpeed * speedReduction )
			
			if self.aiveLastSpeedLimit == nil then 
				self.aiveLastSpeedLimit = maxSpeed
			else 
				self.aiveLastSpeedLimit = math.max( self.aiveLastSpeedLimit - 0.002 * dt, maxSpeed ) 
			end 
			maxSpeed = self.aiveLastSpeedLimit
		end
	end
	
	self:getMotor():setSpeedLimit(math.min(maxSpeed, self:getCruiseControlSpeed()))
	if self:getCruiseControlState() ~= Drivable.CRUISECONTROL_STATE_ACTIVE then
		self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_ACTIVE)
	end
	if not allowedToDrive then
		acceleration = 0
	end
	
	-- wait before changing direction
	if     self.aiveLastForwards == nil
			or self.aiveLastForwards ~= moveForwards then 
		self.aiveForwardsTimer = 750 
	end 
	if     self.aiveForwardsTimer == nil then 
	elseif self.aiveForwardsTimer > 0 then 
		self.aiveForwardsTimer = self.aiveForwardsTimer - dt
		acceleration = 0
	else 
		self.aiveForwardsTimer = nil
	end 
	self.aiveLastForwards = moveForwards 
	
	if not moveForwards then
		acceleration = -acceleration
	end
	
	-- brake before changing direction
	if acceleration == 0 and self.lastSpeedReal > 0.0005 then 
		if moveForwards and self.movingDirection < 0 then 
			acceleration = 1 
		end 
		if not moveForwards and self.movingDirection > 0 then 
			acceleration = -1 
		end 
	end 
	
	WheelsUtil.updateWheelsPhysics(self, dt, self.lastSpeedReal*self.movingDirection, acceleration, not allowedToDrive, true)
end

AIVehicleUtil.driveToPoint = Utils.overwrittenFunction( AIVehicleUtil.driveToPoint, AIVehicleExtension.newDriveToPoint )

function AIVehicleExtension:getImplementObjectList()
	local obj = { self }
	
	for _, implement in ipairs(self:getAttachedAIImplements()) do
		table.insert( obj, implement.object )
	end

	return obj
end 


function AIVehicleExtension:newCrabSteeringOnAIImplementStart( superFunc )
	local rootVehicle = self:getRootVehicle()
	if rootVehicle.acParameters ~= nil and rootVehicle.acParameters.enabled then 
		rootVehicle.aiveSetCrabSteeringState = true 
		rootVehicle.aiveSetCrabSteeringEnd   = nil
		self.aiveCrabSteeringState  = self.spec_crabSteering.state
		
		local spec = self.spec_crabSteering
		local crab = spec.steeringModes[self.aiveCrabSteeringState]
		local test = {}
		
		for s,c in pairs( spec.steeringModes ) do 
			if s ~= self.aiveCrabSteeringState then
				test[s] = true 
				for i,w in pairs( crab.wheels ) do
					local v = c.wheels[i] 
					if v == nil then 
						test[s] = false 
					elseif w.locked and not ( v.locked ) then 
						test[s] = false 
					elseif v.locked and not ( w.locked ) then 
						test[s] = false 
					elseif math.abs( w.offset + v.offset ) > 0.01 then 
						test[s] = false 
					end 
					if not ( test[s] ) then 
						break 
					end 
				end 
				
				if crab.articulatedAxis ~= nil then 
					local w = crab.articulatedAxis
					local v = c.articulatedAxis
					if v == nil then 
						test[s] = false 
					elseif w.locked and not ( v.locked ) then 
						test[s] = false 
					elseif v.locked and not ( w.locked ) then 
						test[s] = false 
					elseif math.abs( w.offset + v.offset ) > 0.01 then 
						test[s] = false 
					end 
				end 
			end 
		end 
		
		self.aiveCrabSteeringState1 = self.aiveCrabSteeringState 
		self.aiveCrabSteeringState2 = self.aiveCrabSteeringState 
		for s,b in pairs( test ) do 
			if b then 
				self.aiveCrabSteeringState2 = s
			end 
		end 
		
		return 
	end 
	return superFunc( self ) 
end 

CrabSteering.onAIImplementStart = Utils.overwrittenFunction( CrabSteering.onAIImplementStart, AIVehicleExtension.newCrabSteeringOnAIImplementStart )


function AIVehicleExtension:onAITurnProgress( progress, left )
	if      self.acParameters       ~= nil
			and self.acParameters.enabled
			and self.aiveSetCrabSteeringState
			and progress ~= nil 
			and progress > 0.05 then 
		local target = progress > 0.95
		
		if self.aiveSetCrabSteeringEnd == nil or self.aiveSetCrabSteeringEnd ~= target then 	
			self.aiveSetCrabSteeringEnd = target
			
			for _,o in pairs( AIVehicleExtension.getImplementObjectList( self ) ) do 
				if      o.spec_crabSteering     ~= nil
						and o.spec_crabSteering.stateMax > 0
						and o.spec_crabSteering.aiSteeringModeIndex > 0 then 
					local state = o.spec_crabSteering.state 
					if not target then 
						state = o.spec_crabSteering.aiSteeringModeIndex 
					else 
						state = o.aiveCrabSteeringState1
						
						if      o.aiveCrabSteeringState1 ~= nil 
								and o.aiveCrabSteeringState2 ~= nil 
								and o.aiveCrabSteeringState2 ~= o.aiveCrabSteeringState1
								and self.aiveChain           ~= nil 
								and self.aiveChain.trace     ~= nil 
								and self.aiveChain.trace.isUTurn then 
							state = o.aiveCrabSteeringState2
							o.aiveCrabSteeringState2 = o.aiveCrabSteeringState1
							o.aiveCrabSteeringState1 = state 
						end 	
					end 
					
					o:setCrabSteering(state)
				end 
			end 
		end 
	end 
end 

function AIVehicleExtension:onAIStart()
	if self.isServer and self.acParameters ~= nil then 
		if self.acParameters.enabled and self.acParameters.straight then 
			AIVehicleExtension.setAIDirection( self )
			self.acIsStraight = true  
		else 
			self.acIsStraight = false 
		end 
	end 
end 

function AIVehicleExtension:onAIEnd()
	if      self.acParameters       ~= nil
			and self.acParameters.enabled 
			and self.aiveSetCrabSteeringState then 
		for _,o in pairs( AIVehicleExtension.getImplementObjectList( self ) ) do 
			if      o.aiveCrabSteeringState ~= nil
					and o.spec_crabSteering     ~= nil
					and o.spec_crabSteering.stateMax > 0 then 
				o:setCrabSteering(o.aiveCrabSteeringState)
				o.aiveCrabSteeringState  = nil 
				o.aiveCrabSteeringState1 = nil 
				o.aiveCrabSteeringState2 = nil 
			end 
		end 
	end 	
	self.aiveSetCrabSteeringState = nil
	self.aiveSetCrabSteeringEnd   = nil 
	if      AIVEGlobals.devFeatures > 0
			and self.acParameters       ~= nil
			and self.acParameters.enabled then 
		AIVehicleExtension.printCallstack()
	end 	
end 

function AIVehicleExtension:afterCutterOnEndWorkAreaProcessing(dt, hasProcessed)
	local spec = self.spec_cutter
	local rootVehicle = self:getRootVehicle()
	if rootVehicle.aiveIsStarted and spec.aiNoValidGroundTimer ~= nil and spec.aiNoValidGroundTimer > 0 then 
		spec.aiNoValidGroundTimer = 0
	end 
end 

Cutter.onEndWorkAreaProcessing = Utils.appendedFunction( Cutter.onEndWorkAreaProcessing, AIVehicleExtension.afterCutterOnEndWorkAreaProcessing )

