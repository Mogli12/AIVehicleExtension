AutoSteeringEngine = {}

AIVECurrentModDir = g_currentModDirectory
AIVEModsDirectory = g_modsDirectory.."/"

function AutoSteeringEngine.globalsReset( createIfMissing )

	AIVEGlobals = {}
	AIVEGlobals.devFeatures  = 0
	AIVEGlobals.staticRoot   = 0
	AIVEGlobals.oldAIArea    = 0
	AIVEGlobals.chainBorder  = 0
	AIVEGlobals.chainLen     = { 2, 4, 6, 8, 10, 12 }
	AIVEGlobals.chain2Len    = { 2, 4, 6, 8, 10, 12 }
	AIVEGlobals.chain3Len    = { 2, 4, 6, 8, 10, 12 }
	AIVEGlobals.chainStart   = 0
	AIVEGlobals.chainDivideP1 = 0
	AIVEGlobals.chainDivideP2 = 0
	AIVEGlobals.chainDivideP3 = 0
	AIVEGlobals.widthDec     = 0
	AIVEGlobals.widthMaxDec  = 0
	AIVEGlobals.ignoreFactor = 0
	AIVEGlobals.angleStep    = 0
	AIVEGlobals.angleStepInc = 0
	AIVEGlobals.angleStepDec = 0
	AIVEGlobals.angleStepMax = 0
	AIVEGlobals.fixAngleStep = 0
	AIVEGlobals.angleSafety  = 0
	AIVEGlobals.maxLooking   = 0
	AIVEGlobals.minLooking   = 0
	AIVEGlobals.minLkgFactor = 0
	AIVEGlobals.maxRotation  = 0
	AIVEGlobals.maxRotationC = 0
	AIVEGlobals.maxRotationU = 0
	AIVEGlobals.maxRotationT = 0
	AIVEGlobals.maxRotationL = 0
	AIVEGlobals.minRadius    = 0
	AIVEGlobals.aiSteering   = 0
	AIVEGlobals.aiSteeringD  = 0
	AIVEGlobals.artSteering  = 0
	AIVEGlobals.artSteeringD = 0
  AIVEGlobals.average      = 0
  AIVEGlobals.reverseDir   = 0
	AIVEGlobals.minMidDist   = 0
	AIVEGlobals.showTrace    = 0
	AIVEGlobals.showChannels = 0
	AIVEGlobals.stepLog2     = 0
	AIVEGlobals.yieldCount   = 0
	AIVEGlobals.zeroAngle    = 0
	AIVEGlobals.colliMask    = 0
	AIVEGlobals.ignoreDist   = 0
	AIVEGlobals.colliStep    = 0
	AIVEGlobals.shiftFixZ    = 0
	AIVEGlobals.zeroWidth    = 0
	AIVEGlobals.limitOutside = 0
	AIVEGlobals.limitInside  = 0
	AIVEGlobals.maxDtSumT     = 0
	AIVEGlobals.maxDtSumP0N   = 0
	AIVEGlobals.maxDtSumP1N   = 0
	AIVEGlobals.maxDistSqN    = 0
	AIVEGlobals.maxDtSumP0L   = 0
	AIVEGlobals.maxDtSumP1L   = 0
	AIVEGlobals.maxDistSqL    = 0
	AIVEGlobals.maxDtSumP0H   = 0
	AIVEGlobals.maxDtSumP1H   = 0
	AIVEGlobals.maxDistSqH    = 0
	AIVEGlobals.maxDtSumF     = 0
	AIVEGlobals.maxDtDistF    = 0
	AIVEGlobals.fruitBuffer   = 0
	AIVEGlobals.showStat      = 0
	AIVEGlobals.maxTurnCheck  = 0
	AIVEGlobals.maxToolAngle  = 0
	AIVEGlobals.maxToolAngle2 = 0
	AIVEGlobals.maxToolAngleF = 0
	AIVEGlobals.maxToolAngleA = 0
	AIVEGlobals.enableAUTurn  = 0
	AIVEGlobals.enableYUTurn  = 0
	AIVEGlobals.enableKUTurn  = 0
	AIVEGlobals.aiRescueDistSq= 0
	AIVEGlobals.raiseNoFruits = 0
	AIVEGlobals.fruitsAdvance = 0
	AIVEGlobals.lowerAdvance  = 0
	AIVEGlobals.upperAdvance  = 0
	AIVEGlobals.fruitsInFront = 0
	AIVEGlobals.showInfo      = 0
	AIVEGlobals.borderBuffer  = 0
	AIVEGlobals.chainStep0    = 0
	AIVEGlobals.chainStep1    = 0
	AIVEGlobals.chainStep2    = 0
	AIVEGlobals.chain2Step0   = 0
	AIVEGlobals.chain2Step1   = 0
	AIVEGlobals.chain2Step2   = 0
	AIVEGlobals.chain3Step0   = 0
	AIVEGlobals.chain3Step1   = 0
	AIVEGlobals.chain3Step2   = 0
	AIVEGlobals.collectCbr    = 0
	AIVEGlobals.testOutside   = 0
	AIVEGlobals.debug1        = 0
	AIVEGlobals.debug2        = 0
	AIVEGlobals.useFBB123     = 0
	AIVEGlobals.FBB123disq1   = 0
	AIVEGlobals.FBB123disq2   = 0
	AIVEGlobals.angleBuffer   = 0
	AIVEGlobals.otherAIColli  = 0
	AIVEGlobals.minOffset     = 0
	AIVEGlobals.minOffsetArt  = 0
	AIVEGlobals.ignoreBorder  = 0
	AIVEGlobals.minTraceLen   = 0
	AIVEGlobals.offTracking   = 0
	AIVEGlobals.prohibitAI    = 0
	AIVEGlobals.lastBestFactor= 0
	AIVEGlobals.tm7StopEarly  = 0
	AIVEGlobals.minSpeed      = 0
	
	local file
	file = AIVECurrentModDir.."autoSteeringEngineConfig.xml"
	if fileExists(file) then	
	--print('AutoSteeringEngine: loading settings from "'..tostring(file)..'"')
		AutoSteeringEngine.globalsLoad( file )	
	else
		print("ERROR: NO GLOBALS IN "..file)
	end
	
	file = getUserProfileAppPath().. "modsSettings/FS19_AIVehicleExtension/autoSteeringEngineConfig.xml"
	if fileExists(file) then	
		print('AutoSteeringEngine: loading settings from "'..tostring(file)..'"')
		AutoSteeringEngine.globalsLoad( file, true )	
	elseif createIfMissing then
		AutoSteeringEngine.globalsCreate()
	end
	
	print("AutoSteeringEngine initialized")
end

AIVEUtils = {}
---Returns value between given min and max
-- @param float value to clamp
-- @param float minVal min value
-- @param float maxVal max value
-- @return float value value
function AIVEUtils.clamp(value, minVal, maxVal)
    return math.min(math.max(value, minVal), maxVal);
end;

---Returns second parameter if the first is nil
-- @param any_type value value
-- @param any_type setTo set to value
-- @return any_type value not nil value
function AIVEUtils.getNoNil(value, setTo)
    if value == nil then
        return setTo;
    end;
    return value;
end;

function AIVEUtils.splitString(splitPattern, text)
    local results = {};
    if text ~= nil then
        local start = 1;
        local splitStart, splitEnd = string.find(text, splitPattern, start, true);
        while splitStart ~= nil do
            table.insert(results, string.sub(text, start, splitStart-1));
            start = splitEnd + 1;
            splitStart, splitEnd = string.find(text, splitPattern, start, true);
        end
        table.insert(results, string.sub(text, start));
    end
    return results;
end;

---Returns vector from string separated by a whitespace
-- @param string input input
-- @return any_type unpackedValues returns unpacked values found in string
function AIVEUtils.getVectorFromString(input)
    if input == nil then
        return nil;
    end;
    local vals = AIVEUtils.splitString(" ", input);
    local num = table.getn(vals);
    for i=1, num do
        vals[i] = tonumber(vals[i]);
    end;
    return unpack(vals, 1, num);
end;
function AIVEUtils.getXZWidthAndHeight(_, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
    return startWorldX, startWorldZ, widthWorldX-startWorldX, widthWorldZ-startWorldZ, heightWorldX-startWorldX, heightWorldZ-startWorldZ;
end;

---Returns length of vector
-- @param float x x
-- @param float y y
-- @return float length length
function AIVEUtils.vector2Length(x,y)
    return math.sqrt(x*x + y*y);
end;

function AIVEUtils.vector2LengthSq(x,y)
    return x*x + y*y;
end;

---Returns length of vector
-- @param float x x
-- @param float y y
-- @param float z z
-- @return float length length
function AIVEUtils.vector3Length(x,y,z)
    return math.sqrt(x*x + y*y + z*z);
end;

function AIVEUtils.vector3LengthSq(x,y,z)
    return x*x + y*y + z*z;
end;


-- this returns the angle to rotate from the z axis around the y axis (if x==0, the angle is 0 or 180°)
-- this is unlike the default specification, where the rotation is 0 at the x axis
function AIVEUtils.getYRotationFromDirection(dx, dz)
    return math.atan2(dx, dz);
end;	

function AIVEUtils.interpolate( value, map )
	if type( map ) ~= "table" then 
		print("Error 1 calculating turn progess")
		return 0.5
	end 
	if #map < 1 then 
		print("Error 2 calculating turn progess")
		return 0.5 
	end 
	
	if #map < 2 then 
		return map[1].progress
	else
		local p1 = map[1]
		local p2 = map[#map]
		
		if type( p1 ) ~= "table" or #p1 ~= 2 then 
			print("Error 3 calculating turn progess")
		end 
		if type( p2 ) ~= "table" or #p2 ~= 2 then 
			print("Error 4 calculating turn progess")
		end 
		
		if     math.abs( p1[1] - p2[1] ) < 0.001 then 
			return p1[2]
		elseif p1[1] < p2[1] then 
			if     value < p1[1] then 
				return p1[2] 
			elseif value > p2[1] then 
				return p2[2] 
			end 
		else 
			if     value > p1[1] then 
				return p1[2] 
			elseif value < p2[1] then 
				return p2[2] 
			end 
		end
	end 
	
	local v1, v2, r1, r2 = nil,nil,nil,nil
	
	for i=2,#map do
		local p1 = map[i-1]
		local p2 = map[i]

		if type( p2 ) ~= "table" or #p2 ~= 2 then 
			print("Error 5 calculating turn progess")
		end 
		
		if     p1[1] <= value and value <= p2[1] then
			v1 = p1[1]
			v2 = p2[1] 
			r1 = p1[2] 
			r2 = p2[2]
			break 
		elseif p1[1] >= value and value >= p2[1] then 
			v1 = p2[1]
			v2 = p1[1] 
			r1 = p2[2] 
			r2 = p1[2]
			break 
		end 
	end 
	
	if v1 == nil or v2 == nil or r1 == nil or r2 == nil then 
		print("Error 6 calculating turn progess")
		return 0.5 
	end 
	
	if v2 - v1 < 0.001 then 
		return p1 
	end 
	
	return r1 + ( r2 - r1 ) * ( value - v1 ) / ( v2 - v1 )
end

AIVEUtils.quot2RadData = {{ -22.9037655484312,  -3.05432619099008 },
													{ -7.59575411272514,  -2.87979326579064 },
													{ -4.51070850366206,  -2.70526034059121 },
													{ -3.17159480236321,  -2.53072741539178 },
													{ -2.41421356237309,  -2.35619449019234 },
													{ -1.92098212697117,  -2.18166156499291 },
													{ -1.56968557711749,  -2.00712863979348 },
													{ -1.30322537284121,  -1.83259571459405 },
													{ -1.09130850106927,  -1.65806278939461 },
													{ -0.916331174017423, -1.48352986419518 },
													{ -0.76732698797896,  -1.30899693899575 },
													{ -0.637070260807493, -1.13446401379631 },
													{ -0.520567050551746, -0.959931088596881 },
													{ -0.414213562373095, -0.785398163397448 },
													{ -0.315298788878984, -0.610865238198015 },
													{ -0.22169466264294,  -0.436332312998582 },
													{ -0.131652497587396, -0.261799387799149 },
													{ -0.0436609429085119,-0.0872664625997165 },
													{ 0.0436609429085119, 0.0872664625997165 },
													{ 0.131652497587396,  0.261799387799149 },
													{ 0.22169466264294,   0.436332312998582 },
													{ 0.315298788878984,  0.610865238198015 },
													{ 0.414213562373095,  0.785398163397448 },
													{ 0.520567050551746,  0.959931088596881 },
													{ 0.637070260807493,  1.13446401379631 },
													{ 0.76732698797896,   1.30899693899575 },
													{ 0.916331174017423,  1.48352986419518 },
													{ 1.09130850106927,   1.65806278939461 },
													{ 1.30322537284121,   1.83259571459405 },
													{ 1.56968557711749,   2.00712863979348 },
													{ 1.92098212697117,   2.18166156499291 },
													{ 2.41421356237309,   2.35619449019234 },
													{ 3.17159480236321,   2.53072741539178 },
													{ 4.51070850366206,   2.70526034059121 },
													{ 7.59575411272514,   2.87979326579064 },
													{ 22.9037655484312,   3.05432619099008 }}

function AIVEUtils.quot2Rad( q )
	return AIVEUtils.interpolate( q, AIVEUtils.quot2RadData )
end 

function AIVEDrawDebugPoint( vehicle, x, y, z, r, g, b, s, c )
	if     vehicle == nil
			or x == nil or y == nil or z == nil
			or r == nil or g == nil or b == nil
			or s == nil then 
		AIVehicleExtension.printCallstack()
		return 
	end 
	if vehicle.aiveDirection == nil then 
		return 
	end 
--local sx,sy,sz = project(x,y,z)
--setTextColor(r,g,b,s) 
--if 0 < sz and sz <= 1 and 0 <= sx and sx <= 1 and 0 <= sy and sy <= 1 then 
--	renderText(sx, sy, getCorrectTextSize(0.05) * sz, Utils.getNoNil( c, "O") )
--end 
	setTextAlignment( RenderText.ALIGN_CENTER ) 
	setTextVerticalAlignment( RenderText.VERTICAL_ALIGN_MIDDLE )
	setTextColor(r,g,b,s) 
	renderText3D( x,y+0.5,z, vehicle.aiveDirection[1],vehicle.aiveDirection[2],vehicle.aiveDirection[3], 0.2, Utils.getNoNil( c, "O") )
end 
function AIVEDrawDebugLine( vehicle, x1,y1,z1, r1,g1,b1, x2,y2,z2, r2,g2,b2 )
	if     vehicle == nil
			or x1 == nil or y1 == nil or z1 == nil
			or r1 == nil or g1 == nil or b1 == nil
			or x2 == nil or y2 == nil or z2 == nil
			or r2 == nil or g2 == nil or b2 == nil then 
		AIVehicleExtension.printCallstack()
		return 
	end 
	
	local l = AIVEUtils.vector3Length(x1-x2,y1-y2,z1-z2)
	local s = math.floor( l * 10 )
	local t = 1
	if s > 1 then 
		t = 1 / s 
	end 

	setTextAlignment( RenderText.ALIGN_CENTER ) 
	setTextVerticalAlignment( RenderText.VERTICAL_ALIGN_MIDDLE )

	local ax, ay, az 
	if vehicle.aiveDirection == nil then 	
		ax = math.atan2( z2-z1, y2-y1 )
		ay = math.atan2( x2-x1, z2-z1 )
		az = math.atan2( y2-y1, x2-x1 )		
	else
		ax = vehicle.aiveDirection[1]
		ay = vehicle.aiveDirection[2]
		az = vehicle.aiveDirection[3]
	end
		
	for i=0,s do 
		local x = x1 + i * t * ( x2 - x1 )
		local y = y1 + i * t * ( y2 - y1 )
		local z = z1 + i * t * ( z2 - z1 )
		local r = r1 + i * t * ( r2 - r1 )
		local g = g1 + i * t * ( g2 - g1 )
		local b = b1 + i * t * ( b2 - b1 )
		setTextColor(r,g,b,s) 	
		renderText3D( x,y,z, ax,ay,az, 0.2, "." )
	end 
--vehicle:addAIDebugLine({x1,y1,z1}, {x2,y2,z2}, {r1,g1,b1})
end 

function AutoSteeringEngine.globalsLoad( file, debugPrint )	

	local xmlFile = loadXMLFile( "AIVE", file, "AIVEGlobals" )
	for name,value in pairs(AIVEGlobals) do
		local tp = AIVEUtils.getNoNil( getXMLString(xmlFile, "AIVEGlobals." .. name .. "#type"), "int" )
		local nn = false
		if     tp == "bool" then
			local bool = getXMLBool( xmlFile, "AIVEGlobals." .. name .. "#value" )
			if bool ~= nil then
				nn = debugPrint
				if bool then AIVEGlobals[name] = 1 else AIVEGlobals[name] = 0 end
			end
		elseif tp == "float" then
			local float = getXMLFloat( xmlFile, "AIVEGlobals." .. name .. "#value" )
			if float ~= nil then nn = debugPrint; AIVEGlobals[name] = float end
		elseif tp == "degree" then
			local float = getXMLFloat( xmlFile, "AIVEGlobals." .. name .. "#value" )
			if float ~= nil then nn = debugPrint; AIVEGlobals[name] = math.rad( float ) end
		elseif tp == "int" then
			local int = getXMLInt( xmlFile, "AIVEGlobals." .. name .. "#value" )
			if int ~= nil then nn = debugPrint; AIVEGlobals[name] = int end
		elseif tp == "vector" then
			local str = getXMLString( xmlFile, "AIVEGlobals." .. name .. "#value" )
			if str ~= nil then nn = debugPrint; AIVEGlobals[name] = { AIVEUtils.getVectorFromString( str ) } end
		else
			print(file..": "..name..": invalid XML type : "..tp)
		end
		if nn then print('    <'..tostring(name)..' type="'..tostring(tp)..'" value="'..tostring(AIVEGlobals[name])..'"/>') end
	end
end

function AutoSteeringEngine.globalsCreate()	

	local file = g_modsDirectory.."/autoSteeringEngineConfig.xml"

	local xmlFile = createXMLFile( "AIVE", file, "AIVEGlobals" )
	for name,value in pairs(AIVEGlobals) do
		if     value == 0 then
			setXMLString( xmlFile, "AIVEGlobals." .. name .. "#type", "bool" )
			setXMLBool( xmlFile, "AIVEGlobals." .. name .. "#value", false )
		elseif value == 1 then
			setXMLString( xmlFile, "AIVEGlobals." .. name .. "#type", "bool" )
			setXMLBool( xmlFile, "AIVEGlobals." .. name .. "#value", true )
		elseif math.abs( value - math.floor( value ) ) > 1E-6 then
			setXMLString( xmlFile, "AIVEGlobals." .. name .. "#type", "float" )
			setXMLFloat( xmlFile, "AIVEGlobals." .. name .. "#value", value )
		else 
			setXMLInt( xmlFile, "AIVEGlobals." .. name .. "#value", value )
		end
	end
	
	saveXMLFile(xmlFile)	
end
	

AutoSteeringEngine.resetCounter = 0
AutoSteeringEngine.globalsReset( false )

AIVEStatus = {}
AIVEStatus.initial  = 0
AIVEStatus.steering = 1
AIVEStatus.rotation = 2
AIVEStatus.position = 3
AIVEStatus.border   = 4


function AutoSteeringEngine.hasArticulatedAxis( vehicle, useCurrentState, whileTurning )
	if     vehicle == nil or vehicle.spec_articulatedAxis == nil or vehicle.spec_wheels == nil then 
		return false 
	elseif vehicle.spec_articulatedAxis.componentJoint == nil
			or vehicle.spec_articulatedAxis.rotationNode   == nil 
			or vehicle.spec_articulatedAxis.rotMax         == nil
			or vehicle.spec_articulatedAxis.rotSpeed       == nil then
		return false 
	end
	
	local firstNode  = nil 
	local singleNode = true
	for _,wheel in pairs(vehicle.spec_wheels.wheels) do
		local node = getParent( wheel.driveNode )
		if firstNode == nil then 
			firstNode = node 
		elseif firstNode ~= node then 
			singleNode = false 
			break
		end 
	end 
	if singleNode then 
		return false 
	end 
	
	if whileTurning then 
		return true 
	end 
	if      vehicle.spec_crabSteering          ~= nil 
			and vehicle.spec_crabSteering.stateMax > 0
			and vehicle.spec_crabSteering.state    > 0 then
		local spec    = vehicle.spec_crabSteering 
		local state   = spec.state 
		if useCurrentState then 
		elseif vehicle.aiveIsStarted and vehicle.aiveCrabSteeringState ~= nil then 
			state       = vehicle.aiveCrabSteeringState 
		end 
		local curMode = spec.steeringModes[state]
		if curMode.articulatedAxis ~= nil and curMode.articulatedAxis.locked then
			return false 
		end 
	end 
	return true 
end 

------------------------------------------------------------------------
-- skipIfNotServer
------------------------------------------------------------------------
function AutoSteeringEngine.skipIfNotServer( vehicle )
	if vehicle == nil or not ( vehicle.isServer ) then
		if vehicle.aiveShowError == nil then
			vehicle.aiveShowError = 0
		end
		vehicle.aiveShowError = vehicle.aiveShowError + 1
		if vehicle.aiveShowError <= 17 then		
			print("ERROR: AutoSteeringEngine.setChainStatus called at client")
			AIVehicleExtension.printCallstack()
		end
		return true
	end
	return false
end

------------------------------------------------------------------------
-- processChainRotateRefNode
------------------------------------------------------------------------
function AutoSteeringEngine.processChainRotateRefNode( vehicle, tp, tool )

	local ofs, idx
	if vehicle.aiveChain.leftActive	then
		ofs = -tp.offset 
		idx = tp.nodeLeft 
	else
		ofs = tp.offset 
		idx = tp.nodeRight
	end

	local vx, vy, vz = getWorldRotation( vehicle.aiveChain.refNode )
	local tx, ty, tz = getWorldRotation( idx )
	unlink( tool.refNodeRot )
	link( idx, tool.refNodeRot )
	setTranslation( tool.refNodeRot, ofs, 0, 0 )
	setRotation( tool.refNodeRot, vx-tx, vy-ty, vz-tz )
	
end

------------------------------------------------------------------------
-- processChainSetAngle
------------------------------------------------------------------------
function AutoSteeringEngine.processChainSetAngle( vehicle, a, indexStart, indexMax )

	if a == nil or indexStart == nil or indexMax == nil then
		AIVehicleExtension.printCallstack()
	end

	local indexStraight = indexMax + 1
	
	if     a == 0 then
		for j=1,indexMax do
			if math.abs( vehicle.aiveChain.nodes[j].angle ) > 1E-6 then
				AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
			end
			vehicle.aiveChain.nodes[j].angle = 0
		end
	elseif a > 0 then
		for j=1,indexStart do
			local aRel = a
			if indexStart > vehicle.aiveChain.chainStep0 then
				local f = 0
				if j > vehicle.aiveChain.chainStep0 then
					f = (j - vehicle.aiveChain.chainStep0) / (indexStart - vehicle.aiveChain.chainStep0)
				end
				aRel = a ^ ( 1.3 - 0.6 * f ) 
			end
			if math.abs( vehicle.aiveChain.nodes[j].angle - aRel ) > 1E-6 then
				AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
			end
			vehicle.aiveChain.nodes[j].angle = aRel
		end		
		for j=indexStart+1,indexMax do
			if math.abs( vehicle.aiveChain.nodes[j].angle ) > 1E-6 then
				AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
			end
			vehicle.aiveChain.nodes[j].angle = 0
		end
	else
		for j=1,indexStart do
			if math.abs( vehicle.aiveChain.nodes[j].angle - a ) > 1E-6 then
				AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
			end
			vehicle.aiveChain.nodes[j].angle = a
		end
		indexStraight = indexStart+1
	end

	AutoSteeringEngine.setChainStraight( vehicle, indexStraight )		
	
	if     AIVEGlobals.angleBuffer <= 0
			or AutoSteeringEngine.hasArticulatedAxis( vehicle ) then
		AutoSteeringEngine.applyRotation( vehicle )
	else	
		if vehicle.aiveChain.angleBuffer == nil then
			vehicle.aiveChain.angleBuffer = {}
		end
		local id = string.format("%d,%d,%8g",indexMax,indexStart,a)
		if vehicle.aiveChain.angleBuffer[id] == nil or AutoSteeringEngine.tableGetN( vehicle.aiveChain.angleBuffer[id] ) <= vehicle.aiveChain.chainMax then 
			AutoSteeringEngine.applyRotation( vehicle )
			vehicle.aiveChain.angleBuffer[id] = {}
			for j=1,vehicle.aiveChain.chainMax+1 do
				vehicle.aiveChain.angleBuffer[id][j] = { p = vehicle.aiveChain.nodes[j].radius,
																								 q = vehicle.aiveChain.nodes[j].invRadius, 
																								 r = vehicle.aiveChain.nodes[j].rotation,
																								 a = vehicle.aiveChain.nodes[j].angle,
																								 w = vehicle.aiveChain.nodes[j].steering,
																								 c = vehicle.aiveChain.nodes[j].cumulRot,
																								 s = vehicle.aiveChain.nodes[j].status }
			end
		else
			local j0 = vehicle.aiveChain.chainMax+2
			local j1 = vehicle.aiveChain.chainMax+1
			for j=1,vehicle.aiveChain.chainMax+1 do
				if math.abs( vehicle.aiveChain.nodes[j].angle - vehicle.aiveChain.angleBuffer[id][j].a ) > 1e-2 then
					if j >= indexStraight then
						j1 = j
					else
						if AIVEGlobals.devFeatures > 0 then 
							print("*************************************************************************************************")
							print("ERROR in AutoSteeringEngine:")
							print("Wrong angle in buffer: "..tostring(j).."; "..tostring(indexMax).."; "..tostring(indexStart).."; "..tostring(a)
										.."; "..tostring(vehicle.aiveChain.nodes[j].angle)
										.."; "..tostring(vehicle.aiveChain.angleBuffer[id][j].a))
						end
						j0 = j
					end
				end
				if j0 > j and vehicle.aiveChain.nodes[j].status < AIVEStatus.rotation then
					j0 = j
				end
				if j >= j0 then
					vehicle.aiveChain.nodes[j].tool      = {}
					vehicle.aiveChain.nodes[j].radius    = vehicle.aiveChain.angleBuffer[id][j].p
					vehicle.aiveChain.nodes[j].invRadius = vehicle.aiveChain.angleBuffer[id][j].q
					vehicle.aiveChain.nodes[j].rotation  = vehicle.aiveChain.angleBuffer[id][j].r
					vehicle.aiveChain.nodes[j].angle     = vehicle.aiveChain.angleBuffer[id][j].a
					vehicle.aiveChain.nodes[j].steering  = vehicle.aiveChain.angleBuffer[id][j].w
					vehicle.aiveChain.nodes[j].cumulRot  = vehicle.aiveChain.angleBuffer[id][j].c
					setRotation( vehicle.aiveChain.nodes[j].index2, 0, vehicle.aiveChain.nodes[j].rotation, 0 )
					vehicle.aiveChain.nodes[j].status    = math.min( AIVEStatus.rotation, vehicle.aiveChain.angleBuffer[id][j].s )
				end
			end
			if j1 < vehicle.aiveChain.chainMax+1 then
				AutoSteeringEngine.setChainStraight( vehicle, j1 )		
			end
			AutoSteeringEngine.applyRotation( vehicle )
		end
	end
end


AutoSteeringEngine.nothingFoundMin = 1001
AutoSteeringEngine.nothingFoundMax = 1010

------------------------------------------------------------------------
-- processChainGetScore
------------------------------------------------------------------------
function AutoSteeringEngine.processChainGetScore( vehicle, a, bi, ti, bo, to, bw, tw, ll, lo )
	
	if bi > AIVEGlobals.ignoreBorder or ( bi > 0 and ll > 10 ) then
		if ll > 100 then
			return 1e4 + 5 - a
		end
		return 1e4 + 5 + math.ceil( ( 100 - ll ) * 4 ) - a
	end
	
	if bo > 0 and ( bw <= 0 or bo * lo > 10 ) then
		local ls = math.max( 0, 43 - lo ) * 22
		local bs = math.min( bo, 10 ) * 2.1
		
		return - a + math.min( AutoSteeringEngine.nothingFoundMin - 13, math.max( 11, ls + bs ) )
	end
	
	if bw > 0 then
		return math.min( a - 1 - bw * 22 + math.min( bo, 10 ) * 2.1 , 0 )
	end
	
		
	local b = a + 1
	if vehicle.aiveChain.nilAngle ~= nil and vehicle.aiveChain.nilAngle > -1 then
		b = math.abs( a - vehicle.aiveChain.nilAngle )
	end
	
	--     1..3
	return b + AutoSteeringEngine.nothingFoundMin 
end

------------------------------------------------------------------------
-- processChainResult
------------------------------------------------------------------------
function AutoSteeringEngine.processChainResult( vehicle, best, a, bi, ti, bo, to, bw, tw, ll, lo, j, m )
	local s = AutoSteeringEngine.processChainGetScore( vehicle, a, bi, ti, bo, to, bw, tw, ll, lo )
	if best.score == nil or best.score > s then
		best.score    = s
		best.indexMax = m
		best.angle    = a		
		best.border   = bi
		best.total    = ti
		best.border2  = bo
		best.total2   = to
		best.border3  = bw
		best.distance = ll
		best.distanc2 = lo
				
		if j == nil then
			best.angles = {}
			for j=1,m do
				best.angles[j] = vehicle.aiveChain.nodes[j].angle 
			end
		else
			best.indexMin = j
		end
	end
	if best.maxAngle == nil then 
		best.maxAngle = a 
		best.minAngle = a 
	elseif a > best.maxAngle then 
		best.maxAngle = a 
	elseif a < best.minAngle then 
		best.minAngle = a 
	end 
	
	if bi > 0 or bo > 0 then -- or bw > 0 then
		best.detected = true
	end
	return s
end

------------------------------------------------------------------------
-- processChainStep
------------------------------------------------------------------------
function AutoSteeringEngine.processChainStep( vehicle, best, a, j, m )
	AutoSteeringEngine.processChainSetAngle( vehicle, a, j, m )
	
	local offsetInsideFactor
--if     vehicle.aiveChain.noReverseIndex > 0
--    or vehicle.aiveChain.minZ           > 0 then
--	offsetInsideFactor = 1
--elseif a >= 0.1 then
--	offsetInsideFactor = 0
--elseif a > -0.2 then
--	offsetInsideFactor = 1 - 10 * a
--else
--	offsetInsideFactor = 3
--end
	local st = AutoSteeringEngine.chainAngle2Steering( vehicle, a )
	if not vehicle.aiveChain.leftActive	then
		st = -st
	end
	
	if     vehicle.aiveChain.noReverseIndex > 0
	    or vehicle.aiveChain.minZ           > 0 then
		if     math.abs( st ) >= 0.15 then
			offsetInsideFactor = 1
		elseif math.abs( st ) >  0.05 then
			offsetInsideFactor = 10 * ( math.abs( st ) - 0.05 )
		else
			offsetInsideFactor = 0
		end
	else
		if     st >= 0.25 then
			offsetInsideFactor = 1
		elseif st >  0.15 then
			offsetInsideFactor = 10 * ( st - 0.15 )		
		elseif st >= 0   then
			offsetInsideFactor = 0
		elseif st > -0.15 then
			offsetInsideFactor = -20 * st
		else
			offsetInsideFactor = 3
		end
	end
		
	local bi, ti, bo, to, bw, tw, ll, lo = AutoSteeringEngine.getAllChainBorders( vehicle, vehicle.aiveChain.chainStart, m, vehicle.aiveChain.inField, offsetInsideFactor )
	local s
	if best == nil then
		s = AutoSteeringEngine.processChainGetScore( vehicle, a, bi, ti, bo, to, bw, tw, ll, lo )
	else
		s  = AutoSteeringEngine.processChainResult( vehicle, best, a, bi, ti, bo, to, bw, tw, ll, lo, j, m )	
	end
	if bi > 0 or bo > 0 then
		return true, bi, bo, bw, ll, s
	end
	return false, bi, bo, bw, ll, s
end

------------------------------------------------------------------------
-- processOneAngle
------------------------------------------------------------------------
function AutoSteeringEngine.processOneAngle( vehicle, steering )
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then
		return 
	end
	
	if vehicle.aiveChain == nil or vehicle.aiveChain.chainMax == nil then
		return 0
	end
	
	AutoSteeringEngine.initWorldToDensity( vehicle )
	AutoSteeringEngine.initSteering( vehicle )	
	AutoSteeringEngine.syncRootNode( vehicle )
	vehicle.aiveChain.inField = false

	local a = AutoSteeringEngine.steering2ChainAngle( vehicle, steering )
	local i = AutoSteeringEngine.getChainIndexMax( vehicle )
	vehicle.aiveChain.nilAngle = a
	return AutoSteeringEngine.processChainStep( vehicle, nil, a, i, i )
end

------------------------------------------------------------------------
-- getChainIndexMax
------------------------------------------------------------------------
function AutoSteeringEngine.getChainIndexMax( vehicle )
	local indexMax
	if vehicle.aiveChain.inField then 
		indexMax   = math.min( vehicle.aiveChain.chainMax, vehicle.aiveChain.chainStep2 )
	else 
		indexMax   = math.min( vehicle.aiveChain.chainMax, vehicle.aiveChain.chainStep1 )
	end

	while   indexMax < vehicle.aiveChain.chainMax
			and vehicle.aiveChain.nodes[indexMax].distance < 2 + math.max( vehicle.aiveChain.width, vehicle.aiveChain.radius ) do
		indexMax = indexMax + 1
	end
	
	if vehicle.aiveCollisionDistance ~= nil then
		while   indexMax > 1
				and vehicle.aiveChain.nodes[indexMax+1].distance > vehicle.aiveCollisionDistance do
			indexMax = indexMax - 1
		end
	end		
	
	return indexMax
end

function AutoSteeringEngine.processChainRepeatLast( vehicle )
	if vehicle.aiveChain == nil or vehicle.aiveChain.lastBest == nil then
		return 
	end
	AutoSteeringEngine.initFruitBuffer( vehicle )
	AutoSteeringEngine.processChainSetAngle( vehicle, vehicle.aiveChain.lastBest.angle, vehicle.aiveChain.lastBest.indexMin, vehicle.aiveChain.lastBest.indexMax )
	return AutoSteeringEngine.getAllChainBorders( vehicle, vehicle.aiveChain.chainStart, vehicle.aiveChain.lastBest.indexMax, vehicle.aiveChain.inField )
end

------------------------------------------------------------------------
-- processChainEvasiveAction
------------------------------------------------------------------------
function AutoSteeringEngine.processChainEvasiveAction( vehicle, best, indexMax )
	while true do
		local bi, ti, bo, to, bw, tw, ll, lo = AutoSteeringEngine.getAllChainBorders( vehicle, vehicle.aiveChain.chainStart, indexMax, vehicle.aiveChain.inField )
		local index = 0
		
		if     bi > AIVEGlobals.ignoreBorder then
			local i = 1
			while i <= indexMax and vehicle.aiveChain.nodes[i].distance < ll - 1e-3 do
				i = i + 1
			end
			index = i
			while index > 0 and vehicle.aiveChain.nodes[index].angle > 0.999 do
				index = index - 1
			end
			
			if index > 0 then
				local d = 0.2 / ( index * ( index+1 ) )
				for j=1,index do
					local o = vehicle.aiveChain.nodes[j].angle 
					vehicle.aiveChain.nodes[j].angle = math.min( 1, vehicle.aiveChain.nodes[j].angle + j * d )
					if math.abs( vehicle.aiveChain.nodes[j].angle - o ) > 1e-6 then
						AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
					end
				end
				AutoSteeringEngine.setChainStatus( vehicle, index, AIVEStatus.initial )
				local d = 0.2 / ( (index-indexMax) * ( index-indexMax+1 ) )
				for j=index+1,indexMax do
					vehicle.aiveChain.nodes[j].angle = math.max( -1, vehicle.aiveChain.nodes[j].angle + ( j-index ) * d )
				end
				AutoSteeringEngine.applyRotation( vehicle )
			end
		elseif bo > AIVEGlobals.ignoreBorder then
			for j=1,vehicle.aiveChain.chainStep0 do
				if vehicle.aiveChain.nodes[j].angle < 0.999999 then
					index = vehicle.aiveChain.chainStep0
				end
			end
			if index > 0 then
				for j=1,vehicle.aiveChain.chainStep0 do
					local o = vehicle.aiveChain.nodes[j].angle 
					vehicle.aiveChain.nodes[j].angle = math.min( 1, vehicle.aiveChain.nodes[j].angle + 0.01 )
					if math.abs( vehicle.aiveChain.nodes[j].angle - o ) > 1e-6 then
						AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
					end
				end
			end
		end
		
		AutoSteeringEngine.processChainResult( vehicle, best, vehicle.aiveChain.nodes[1].angle, bi, ti, bo, to, bw, tw, ll, lo, nil, indexMax )
		
		if index <= 0 then
			return bi, bo, bw, ll, lo
		end
	end
end

------------------------------------------------------------------------
-- processChain
------------------------------------------------------------------------
function AutoSteeringEngine.processChain( vehicle, inField, targetSteering, insideAngleFactor, nilAngleMode )
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then
		return 
	end
	
	AutoSteeringEngine.initWorldToDensity( vehicle )

	if vehicle.aiveChain.toolParams == nil or table.getn( vehicle.aiveChain.toolParams ) < 1 then
		return false, 0,0
	end
	
	AutoSteeringEngine.initSteering( vehicle )	
	
	if vehicle.aiveChain.width <= 0 then
		print("Empty width!")
		return false, 0,0
	end
	
	-- previous run was alread at end 
	if inField and vehicle.aiveChain.isAtEnd and AutoSteeringEngine.hasNoFruitsAtAll( vehicle ) then 
	-- verify that were are really at the end 
		AutoSteeringEngine.processIsAtEnd( vehicle )	

		if vehicle.aiveChain.isAtEnd then 
			vehicle.aiveChain.collectCbr = nil
			vehicle.aiveChain.cbr	       = nil
			vehicle.aiveChain.pcl        = nil
			vehicle.aiveProcessChainInfo = "found nothing at all"
			vehicle.aiveChain.fullSpeed = false 
			vehicle.acIamDetecting      = false
			
			AutoSteeringEngine.syncRootNode( vehicle )
			
			return false, 0, 0, 0, 0, 0, 0
		end 
	end 
	
	------------------------------------------------------------------------
	-- only straight, no detection
	if      vehicle.acParameters     ~= nil
			and vehicle.acParameters.upNDown 
			and vehicle.acParameters.straight then 
		vehicle.aiveChain.collectCbr = nil
		vehicle.aiveChain.cbr	       = nil
		vehicle.aiveChain.pcl        = nil
		vehicle.aiveProcessChainInfo = "straight"

		AutoSteeringEngine.syncRootNode( vehicle )
		
		if vehicle.aiDriveDirection == nil or vehicle.aiDriveTarget == nil then 
			return false, 0, 0, 0, 0, 0, 0
		end 
	
		local detected = false 
		local wx,wy,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		
		if inField then 
			vehicle.aiveChain.inField = true	
			AutoSteeringEngine.processIsAtEnd( vehicle )	
			
			if     AutoSteeringEngine.hasFruits( vehicle )        then 
				vehicle.aiveChain.lastStraightPos = { wx, wz } 
				detected = true 
			elseif AutoSteeringEngine.hasFruitsInFront( vehicle ) then 
				detected = true 
			elseif  vehicle.aiveChain.lastStraightPos ~= nil 
					and AIVEUtils.vector2LengthSq( vehicle.aiveChain.lastStraightPos[1] - wx,
																				 vehicle.aiveChain.lastStraightPos[2] - wz ) < vehicle.aiveChain.backZ^2 then 
				detected = true 
			end 
		else 
			vehicle.aiveChain.inField = false 
			vehicle.aiveChain.isAtEnd = false 
			vehicle.aiveChain.lastStraightPos = nil
			
			if AutoSteeringEngine.hasFruits( vehicle ) then 
				detected = true 
			else 
				-- calculate direction difference
				local x, y, z = worldDirectionToLocal( vehicle.aiveChain.refNode, vehicle.aiDriveDirection[1], 0, vehicle.aiDriveDirection[2] )
				local dot = z
				dot = dot / AIVEUtils.vector2Length(x, z)
				local angle = math.acos(dot)
				if x < 0 then
					angle = -angle
				end
				
				-- ok, less than 10° ?
				if math.abs( angle ) < 0.1745 then 
				-- calculated distance to side
					local d2 = ( vehicle.aiDriveTarget[1] - wx ) * vehicle.aiDriveDirection[2] - ( vehicle.aiDriveTarget[2] - wx ) * vehicle.aiDriveDirection[1]
					detected = d2 < 1
				end 
			end 
		end 
		
		vehicle.aiveChain.fullSpeed = not vehicle.aiveChain.isAtEnd
		vehicle.acIamDetecting      = false
		
		local pX, pZ   = MathUtil.projectOnLine(wx, wz, vehicle.aiDriveTarget[1], vehicle.aiDriveTarget[2], vehicle.aiDriveDirection[1], vehicle.aiDriveDirection[2])
		
		wx = pX + vehicle.aiDriveDirection[1] * vehicle.maxTurningRadius
		wz = pZ + vehicle.aiDriveDirection[2] * vehicle.maxTurningRadius

		vehicle.aiveChain.lastWorldTarget = { wx, wy, wz }

		return detected, AutoSteeringEngine.getSteeringAngleFromWorldTarget( vehicle, wx, wy, wz ), 0, wx, wy, wz, 5
	end 
	------------------------------------------------------------------------

	local indexMax    = AutoSteeringEngine.getChainIndexMax( vehicle )
	local chainBorder
	
	vehicle.aiveProcessChainInfo = ""
	vehicle.acIamDetecting = true

	local turnAngle = AutoSteeringEngine.getTurnAngle( vehicle )
	if vehicle.aiveChain.leftActive then
		turnAngle = -turnAngle
	end
	
	if      vehicle.aiveChain.inField
			and vehicle.aiveChain.chainStep1 > 0 
			and vehicle.aiveChain.chainStep1 < indexMax 
			and vehicle.aiveChain.maxLooking > 0.1 then
		
		local ma = 0.2 * vehicle.aiveChain.maxLooking
		if -vehicle.aiveChain.maxLooking < turnAngle and turnAngle < ma then
			local im
			if AutoSteeringEngine.hasFruits( vehicle ) then
				im = vehicle.aiveChain.chainStep1
			else
				im = math.min( indexMax, math.max( 1, AIVEGlobals.chainBorder ) )
			end
		
			if turnAngle > -ma and im < indexMax then
				im = math.min( indexMax, im + math.floor( ( indexMax - im ) * ( turnAngle + ma ) / ( ma + ma ) + 0.5 ) )
			end
			local tl = AutoSteeringEngine.getTraceLength( vehicle )
			local ml = math.max( vehicle.aiveChain.nodes[indexMax].distance - tl, math.max( vehicle.aiveChain.width, vehicle.aiveChain.radius ) )
			while   indexMax > im
 			    and vehicle.aiveChain.nodes[indexMax-1].distance >= ml do
				indexMax = indexMax - 1
			end
		end
		
	--print(tostring(math.floor( math.deg( turnAngle ) + 0.5 )).." => "..tostring( indexMax ).." / "..tostring( vehicle.aiveChain.chainStep2 ))
	end
	
	AutoSteeringEngine.processIsAtEnd( vehicle )	
	
	chainBorder = AIVEUtils.clamp( AIVEGlobals.chainBorder, 1, indexMax )
	local best = {}
	
	if not ( vehicle.aiveChain.inField ) and inField then
		vehicle.aiveChain.valid = nil
	end
	if vehicle.aiveChain.inField and not ( inField ) then
		vehicle.aiveChain.valid = nil
	end
	vehicle.aiveChain.inField = false
	vehicle.aiveChain.widthDecFactor = nil
	if inField then
		vehicle.aiveChain.inField = true	
		if insideAngleFactor ~= nil and 0 < insideAngleFactor and insideAngleFactor < 1 then
			vehicle.aiveChain.widthDecFactor = 1 - insideAngleFactor
		end
	end
				
	if      vehicle:getIsEntered() 
			and AIVEGlobals.collectCbr > 0 
			and vehicle.acParameters ~= nil and vehicle.acParameters.showTrace 
			and vehicle.atHud        ~= nil and vehicle.atHud.GuiActive 
			then
		vehicle.aiveChain.collectCbr = true
		vehicle.aiveChain.cbr	       = {} 
		vehicle.aiveChain.pcl        = {}
	else
		vehicle.aiveChain.collectCbr = nil
		vehicle.aiveChain.cbr	       = nil
		vehicle.aiveChain.pcl        = nil
	end		

	local fromStart = true
	
	vehicle.acDistPerFrame = nil
	
	if     nilAngleMode               == nil
			or nilAngleMode               ~= "L"
			or vehicle.aiveChain.valid    == nil 
			or vehicle.aiveChain.lastBest == nil
			or g_currentMission.time - vehicle.aiveChain.valid > vehicle.aiveChain.maxDtSumP1 then
		vehicle.aiveChain.averageAngle = nil
	end
	
	if     nilAngleMode == nil then
		vehicle.aiveChain.nilAngle = nil
	elseif nilAngleMode == "I" then
		vehicle.aiveChain.nilAngle = nil
	elseif nilAngleMode == "M" then
		vehicle.aiveChain.nilAngle =  0
	elseif nilAngleMode == "O" then
		vehicle.aiveChain.nilAngle =  1
	elseif nilAngleMode == "L" and vehicle.aiveChain.averageAngle ~= nil then
	--vehicle.aiveChain.nilAngle =  math.max( 0, vehicle.aiveChain.averageAngle )
		vehicle.aiveChain.nilAngle = nil
	else
		vehicle.aiveChain.nilAngle = nil
	end

	
	local detected = false
	
	if  not ( vehicle.aiveChain.valid == nil or vehicle.aiveChain.lastBest == nil )
			and g_currentMission.time - vehicle.aiveChain.valid < vehicle.aiveChain.maxDtSumP0
			and vehicle.aiveChain.lastBest.detected 
			and vehicle.aiveChain.lastBest.border <= 0 then
		local d0, bi0, bo0, to0, ll0 = AutoSteeringEngine.processChainStep( vehicle, best, vehicle.aiveChain.lastBest.angle, vehicle.aiveChain.lastBest.indexMin, vehicle.aiveChain.lastBest.indexMax )
		
		if d0 and bi0 <= AIVEGlobals.ignoreBorder then
			fromStart = false
			detected  = true
			
			AIVehicleExtension.statEvent( vehicle, "p0", 0 )
		end
	end
	
	if fromStart then	
	
		if     vehicle.aiveChain.valid    == nil
				or vehicle.aiveChain.lastBest == nil
				or g_currentMission.time - vehicle.aiveChain.valid > vehicle.aiveChain.maxDtSumP1 then
			if vehicle.aiveChain.valid == nil then
				vehicle.aiveProcessChainInfo = vehicle.aiveProcessChainInfo.."P1.0\n"
			else
				vehicle.aiveProcessChainInfo = vehicle.aiveProcessChainInfo..string.format("P1.1: %d\n",g_currentMission.time - vehicle.aiveChain.valid)
			end
			vehicle.aiveChain.valid       = nil
			vehicle.aiveChain.lastBest    = nil
--if vehicle.aiveChain.angleBuffer ~= nil then AIVehicleExtension.debugPrint( vehicle, "Reset angle buffer 1") end 
--			vehicle.aiveChain.angleBuffer = nil
			AutoSteeringEngine.syncRootNode( vehicle )
		elseif vehicle.aiveChain.staticRoot then  
			local sync = true 
		
			AutoSteeringEngine.processChainSetAngle( vehicle, vehicle.aiveChain.lastBest.angle, vehicle.aiveChain.lastBest.indexMin, vehicle.aiveChain.lastBest.indexMax )
			local xv, yv, zv = AutoSteeringEngine.getAiWorldPosition( vehicle )
			local x1, y1, z1 = getWorldTranslation( vehicle.aiveChain.nodes[1].index )
			if AIVEUtils.vector2LengthSq( xv - x1, zv - z1 ) < vehicle.aiveChain.maxDistSq then 
				local iii = 1
				while iii <= vehicle.aiveChain.chainStep0 and iii <= vehicle.aiveChain.chainMax do
					iii = iii + 1 
					local x2, y2, z2 = getWorldTranslation( vehicle.aiveChain.nodes[iii].index )
					if ( xv - x2 ) * ( x2 - x1 ) + ( zv - z2 ) * ( z2 - z1 ) <= 0 then 
						local d = math.abs( ( xv - x1 ) * ( z2 - z1 ) + ( zv - z1 ) * ( x2 - x1 ) ) / vehicle.aiveChain.nodes[2].length
						if d < 0.1 then 
							vehicle.aiveChain.chainStart = iii 
							sync = false 
						end 
						break 					
					end 
					x1 = x2 
					y1 = y2 
					z1 = z2 
				end 
			end  
		
			if sync then 
				AutoSteeringEngine.syncRootNode( vehicle, (vehicle.aiveChain.maxDistSq <= 0) )
			end 
		else 
			AutoSteeringEngine.syncRootNode( vehicle, true )
		end
		
		while true do
			local j0 = math.max(  1, math.min( indexMax,   vehicle.aiveChain.chainStep0 ) )
			local j1 = j0
			local j3 = math.max( j0, indexMax-1 )
			local j2 = j3
			local a0 = 0
			local j  = indexMax 
			if targetSteering ~= nil then
				a0 = AutoSteeringEngine.steering2ChainAngle( vehicle, targetSteering )
			elseif vehicle.aiveChain.lastBest ~= nil and AIVEGlobals.lastBestFactor > 0 then
				a0 = vehicle.aiveChain.lastBest.angle * AIVEGlobals.lastBestFactor
				if     a0 >= 1 then
					a0 = ( 1 - 1 / AIVEGlobals.chainDivideP3 )
				elseif a0 <= -1 then
					a0 = -( 1 - 1 / AIVEGlobals.chainDivideP3 )
				end
				if a0 >= 0 then
					j1 = j0
					j2 = math.min( j2, j0 + 2 )
				else
					if j1 < vehicle.aiveChain.lastBest.indexMin - 1 then
						j1 = vehicle.aiveChain.lastBest.indexMin - 1
					end
					if j2 > vehicle.aiveChain.lastBest.indexMin + 1 then
						j2 = vehicle.aiveChain.lastBest.indexMin + 1
					end
					j = j1
				end
			end
									
			local d0, bi0, bo0, to0, ll0 = AutoSteeringEngine.processChainStep( vehicle, best, a0, j, indexMax )
			if bi0 > 0 then
				j1 = j0
				j2 = j3
			end
			
		--if AIVEGlobals.chainDivideP2 <= 0 then
				vehicle.aiveChain.fullSpeed = true
		--elseif targetSteering == nil and vehicle.aiveChain.lastBest ~= nil then
		--	vehicle.aiveChain.fullSpeed = true
		--else
		--	vehicle.aiveChain.fullSpeed = false
		--end
			
			local pmf, pmt = 1,2
		--if bi0 <= 0 and bo0 <= 0 then 
		--	pmf = 2
		--end 
		--if bi0 > 0 or targetSteering ~= nil then 
		--	pmt = 1 
		--end 
								
			for plusMinus=pmf,pmt do						
				local delta3 = 3
				if AIVEGlobals.chainDivideP2 > 0 and targetSteering == nil and vehicle.aiveChain.lastBest ~= nil then
					delta3 = 1 / AIVEGlobals.chainDivideP2
				end
					
				local delta2 = 1 / AIVEGlobals.chainDivideP3
				local delta1 = delta2 
				if delta3 < 2.999999 or ( bi0 <= 0 and bo0 > 0 ) then
					delta1 = 1 / ( AIVEGlobals.chainDivideP1 * AIVEGlobals.chainDivideP2 )
				end
			
				if plusMinus == 2 and delta3 < 2.999999 and insideAngleFactor ~= nil and 0 < insideAngleFactor and insideAngleFactor < 1 then
					delta3 = delta3 * insideAngleFactor
				end
									
				local a = a0 + delta1 
				while math.abs( a ) <= 1.00001 do
					local j = indexMax
					
					if a < 0 then
						j = j1
					end
					
					local d, bi, bo, to = AutoSteeringEngine.processChainStep( vehicle, best, a, j, indexMax )
						
					if plusMinus == 1 then
					--if bi <= AIVEGlobals.ignoreBorder and bo <= AIVEGlobals.ignoreBorder then
						if bi <= 0 and bo <= 0 then 
							break
						end
					else
						if bi > 0 or bo > 0 then
							break
						end
					end
					
					if math.abs( a0 - a ) > delta3 + 1e-6 then
						if best.border <= 0 then
							break
						end
						vehicle.aiveProcessChainInfo = vehicle.aiveProcessChainInfo..string.format("P2.1: %6.4f, %6.4f, %d\n", a0, a, best.border)
					--vehicle.aiveChain.fullSpeed = false
						delta3 = 3
					end
					
					local doTheLast = math.abs( a ) < 1
					
					if plusMinus == 1 then
						if a < a0 + delta3 and a0 + delta3 < a + delta1 then
							a = a0 + delta3 
						else
							a = a + delta1 
						end
					else
						if a > a0 - delta3 and a0 - delta3 > a - delta1 then
							a = a0 - delta3 
						else
							a = a - delta1 
						end
					end
					
					if math.abs( a ) > 1 and doTheLast then 
						if a < 0 then a = -1 else a = 1 end 
					end 
					
					if delta1 < delta2 then
						delta1 = math.min( delta2, 1.41422 * delta1 )
					end
				end
			end
			
			if vehicle.aiveChain.fullSpeed and best.border > AIVEGlobals.ignoreBorder then
				vehicle.aiveProcessChainInfo = vehicle.aiveProcessChainInfo..string.format("P2.2: %6.4f, %6.4f, %d\n", a0, best.angle, best.border)
				vehicle.aiveChain.fullSpeed = false
			end
			
			if     vehicle.aiveChain.fullSpeed then
				AIVehicleExtension.statEvent( vehicle, "p1", 0 )
			elseif targetSteering == nil and vehicle.aiveChain.lastBest ~= nil and AIVEGlobals.chainDivideP2 > 0 then
				AIVehicleExtension.statEvent( vehicle, "p2", 0 )
			elseif vehicle.aiveChain.inField then
				AIVehicleExtension.statEvent( vehicle, "p3", 0 )
			else
				AIVehicleExtension.statEvent( vehicle, "p4", 0 )
			end
			
			if vehicle.aiveChain.fullSpeed and not best.detected then
				vehicle.aiveChain.fullSpeed = false
			end
			
--			if vehicle.aiveChain.fullSpeed then
--				if vehicle.aiveChain.valid == nil then
----print("No full speed V")
--					vehicle.aiveChain.fullSpeed = false
--				end
--			end

			if      vehicle.aiveChain.fixAttacher
					and turnAngle              > 0				
				--and best.border            > AIVEGlobals.ignoreBorder
				--and best.distance          < -vehicle.aiveChain.minZ-vehicle.aiveChain.minZ
					and vehicle.aiveChain.minZ < 0 then
				for step=1,AIVEGlobals.chainDivideP3 do
					local a = -step / AIVEGlobals.chainDivideP3
					local d, bi, bo, to = AutoSteeringEngine.processChainStep( vehicle, best, a, j0, indexMax )
					if bi <= AIVEGlobals.ignoreBorder then
						break
					end
				end
			end
				
			if best.border <= 0 and best.angle < 0 and ( best.angle == -1 or best.detected ) then
				local a = best.angle 
				for j=j1+1,j2 do
					local d, bi, bo, to = AutoSteeringEngine.processChainStep( vehicle, best, a, j, indexMax )
					if bi > 0 then
						break
					end
				end
			end
			
			if best.detected or indexMax >= vehicle.aiveChain.chainMax then
				break
			end
			
			indexMax  = indexMax + 1 
			
			if best.border <= 0 and best.border2 <= 0 and vehicle.aiveChain.isAtEnd and vehicle.aiveChain.nodes[indexMax+1].distance > AIVEGlobals.fruitsInFront then 
				break 
			end 
			
			if vehicle.aiveChain.valid ~= nil then
				vehicle.aiveChain.lastBest    = nil
				if vehicle.aiveChain.angleBuffer ~= nil then AIVehicleExtension.debugPrint( vehicle, "Reset angle buffer 2") end 
				vehicle.aiveChain.angleBuffer = nil
			end
		end

		detected = best.detected 
		
		if      best.border                <= AIVEGlobals.ignoreBorder 
				and not best.detected
				and targetSteering             == nil
				and vehicle.aiveChain.valid    ~= nil then
			detected = true
		end
		
		vehicle.aiveChain.lastBest = best
		
		if     best.border > AIVEGlobals.ignoreBorder then
			vehicle.aiveChain.valid = nil
		elseif best.detected and targetSteering == nil then
			vehicle.aiveChain.valid = g_currentMission.time
		elseif best.border <= 0 and best.border2 <= 0 and vehicle.aiveChain.isAtEnd then 
			vehicle.aiveChain.valid = g_currentMission.time
		end
				
		vehicle.aiveProcessChainInfo = vehicle.aiveProcessChainInfo.. string.format( "Angle: %6.4f; index: %d..%d; score: %10g", best.angle, best.indexMin, best.indexMax, best.score )
	end

	vehicle.aiveChain.averageAngle = math.max( -1, best.angle -0.05 )
	
	local length   = best.distance
	indexMax       = best.indexMax
	
	AutoSteeringEngine.processChainSetAngle( vehicle, best.angle, best.indexMin, best.indexMax )	
	
	local indexMin = math.min( vehicle.aiveChain.chainStart, indexMax )
	border, total  = AutoSteeringEngine.getAllChainBorders( vehicle, indexMin, indexMax, vehicle.aiveChain.inField )
	
	if      best.border <= AIVEGlobals.ignoreBorder and border > AIVEGlobals.ignoreBorder 
			and vehicle.isEntered
			and ( AIVEGlobals.showInfo > 0 or AIVEGlobals.devFeatures > 0 or AIVEGlobals.showTrace > 0 ) then
		print("ERROR in AutoSteeringEngine: Something went wrong 1: "..tostring(border).."; "..tostring(useBuffer))
		
		for j=1,indexMax do
			print("=====================================")
			for i,t in pairs( vehicle.aiveChain.nodes[j].tool ) do
				print(tostring(t.b))
			end
			
			print(tostring(vehicle.aiveChain.nodes[j].angle).."; "..tostring(vehicle.aiveChain.nodes[j].steering).."; "..tostring(vehicle.aiveChain.nodes[j].rotation).."; "..tostring(vehicle.aiveChain.nodes[j].status))
			
			local id = string.format("%d,%d,%5g",best.indexMax,best.indexMin,best.angle)
			
			if      vehicle.aiveChain.angleBuffer        ~= nil 
					and vehicle.aiveChain.angleBuffer[id]    ~= nil
					and vehicle.aiveChain.angleBuffer[id][j] ~= nil then
			--print("-------------------------------------")
				print(tostring(vehicle.aiveChain.angleBuffer[id][j].a).."; "..tostring(vehicle.aiveChain.angleBuffer[id][j].w))
				print(math.abs( vehicle.aiveChain.nodes[j].rotation - vehicle.aiveChain.angleBuffer[id][j].r ))
			end
		end
		
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.initial )
		AutoSteeringEngine.processChainSetAngle( vehicle, best.angle, best.indexMin, best.indexMax )	
		border, total  = AutoSteeringEngine.getAllChainBorders( vehicle, indexMin, indexMax, vehicle.aiveChain.inField )
		if best.border <= AIVEGlobals.ignoreBorder and border > AIVEGlobals.ignoreBorder then
			print("ERROR in AutoSteeringEngine: Something went wrong 2: "..tostring(border).."; "..tostring(useBuffer))
			
			vehicle.aiveChain.angleBuffer = nil
			AutoSteeringEngine.processChainSetAngle( vehicle, best.angle, best.indexMin, best.indexMax )	
			border, total  = AutoSteeringEngine.getAllChainBorders( vehicle, indexMin, indexMax, vehicle.aiveChain.inField )
			if best.border <= AIVEGlobals.ignoreBorder and border > AIVEGlobals.ignoreBorder then
				print("ERROR in AutoSteeringEngine: Something went wrong 3: "..tostring(border).."; "..tostring(useBuffer))			
			end	
		end	
	end	
		
	while border > AIVEGlobals.ignoreBorder  and indexMax > chainBorder do 
		indexMax      = indexMax - 1 
		border, total = AutoSteeringEngine.getAllChainBorders( vehicle, indexMin, indexMax, vehicle.aiveChain.inField )
		if total <= 0 then
			indexMax      = indexMax + 1 
			border, total = AutoSteeringEngine.getAllChainBorders( vehicle, indexMin, indexMax, vehicle.aiveChain.inField )
			break
		end 
	end
	
	if border <= AIVEGlobals.ignoreBorder then
		border = 0
	end
	
	local dist = 0.5*vehicle.aiveChain.radius 
	local wx,wy,wz 
	
	local angle = 0
	
--if math.abs( best.angle ) < 1e-6 then
--	wx,wy,wz = localToWorld( vehicle.aiveChain.refNode, 0, 0, dist )
--else
		angle = vehicle.aiveChain.nodes[vehicle.aiveChain.chainStep0].steering
		local i = math.min( math.max( vehicle.aiveChain.chainStep0, 2 ), indexMax )
		while i <= indexMax and vehicle.aiveChain.nodes[i].distance < dist do
			i = i + 1
		end		
		wx,wy,wz = getWorldTranslation( vehicle.aiveChain.nodes[i].index )
--end
	vehicle.aiveChain.lastWorldTarget = { wx, wy, wz }
	
	vehicle.aiveChain.lastIndexMax = indexMax 	
	
	if detected and border > 0 then
		detected = false 
	end
	
--local fx, fz, fl = 0,0,0
--if vehicle.lastAcAiPos ~= nil then
--	fx = vehicle.acAiPos[1] - vehicle.lastAcAiPos[1]
--	fz = vehicle.acAiPos[3] - vehicle.lastAcAiPos[3]
--	fl = AIVEUtils.vector2Length( fx, fz )
--	if fl > 1e-3 then
--		fx = fx / fl
--		fz = fz / fl
--	end
--end
--
--local dx = wx - vehicle.acAiPos[1]
--local dz = wz - vehicle.acAiPos[3]
--local dl = AIVEUtils.vector2Length( dx, dz )
--dx = dx / dl
--dz = dz / dl
--
--AIVehicleExtension.debugPrint( vehicle, string.format("(%7.3f, %7.3f) -> (%7.3f, %7.3f) / (%7.3f, %7.3f) -> (%7.3f, %7.3f), %7.3f",vehicle.acAiPos[1], vehicle.acAiPos[3], wx, wz, fx, fz, dx, dz, fl ))
--
	vehicle.lastAcAiPos = {} 
	vehicle.lastAcAiPos[1] = vehicle.acAiPos[1]
	vehicle.lastAcAiPos[2] = vehicle.acAiPos[2]
	vehicle.lastAcAiPos[3] = vehicle.acAiPos[3]
	
	return detected, angle, border, wx, wy, wz, length
end

------------------------------------------------------------------------
-- syncRootNode
------------------------------------------------------------------------
function AutoSteeringEngine.syncRootNode( vehicle, noClear )

	if vehicle.aiveChain.staticRoot then 
		local x0, y0, z0 = getWorldTranslation( g_currentMission.terrainRootNode )
		local x1, y1, z1 = AutoSteeringEngine.getAiWorldPosition( vehicle )
		x1 = x1 - x0
		y1 = y1 - y0
		z1 = z1 - z0
		local x2, y2, z2 = getTranslation( vehicle.aiveChain.rootNode )
		if     math.abs( x1-x2 ) > 1E-2 
				or math.abs( y1-y2 ) > 1E-2 
				or math.abs( z1-z2 ) > 1E-2 then 
			if not ( noClear ) then
				vehicle.aiveChain.valid       = nil
				vehicle.aiveChain.angleBuffer = nil
			end
			setTranslation( vehicle.aiveChain.rootNode, x1, y1, z1 )
		end 
		vehicle.aiveChain.rootTrans = { x1, y1, z1 }
			
		x0, y0, z0 = getWorldRotation( g_currentMission.terrainRootNode )
		x1, y1, z1 = getWorldRotation( vehicle.aiveChain.refNode )
		x1 = x1 - x0
		y1 = y1 - y0
		z1 = z1 - z0
		
		local x2, y2, z2 = getRotation( vehicle.aiveChain.rootNode )
		if     math.abs( x1-x2 ) > 1E-3 
				or math.abs( y1-y2 ) > 1E-3 
				or math.abs( z1-z2 ) > 1E-3 then 
			if not ( noClear ) then
				vehicle.aiveChain.valid       = nil
				vehicle.aiveChain.angleBuffer = nil
			end
			setRotation( vehicle.aiveChain.rootNode, x1, y1, z1 )
		end
		vehicle.aiveChain.rootRot = { x1, y1, z1 }
		
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.rotation )
		
		return true
	end 
	
	if not ( noClear ) then
		vehicle.aiveChain.valid       = nil
		vehicle.aiveChain.angleBuffer = nil
	end
	
	return false 
end 

------------------------------------------------------------------------
-- initFruitBuffer
------------------------------------------------------------------------
function AutoSteeringEngine.initFruitBuffer( vehicle, keepFruits )
	if vehicle.aiveChain ~= nil then
		if not ( keepFruits ) then
			vehicle.aiveChain.fruitBuffer = {}
			vehicle.aiveChain.fruitBufferSize = 0
		end
		vehicle.aiveChain.valid       = nil
		vehicle.aiveChain.angleBuffer = {}
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.initial )
	end
end

------------------------------------------------------------------------
-- setAiWorldPosition
------------------------------------------------------------------------
function AutoSteeringEngine.setAiWorldPosition( vehicle, vX, vY, vZ )
--vehicle.acAiPos = { vX, vY, vZ }
	if vehicle.acAiPos == nil then
		vehicle.acAiPos                  = { vX, vY, vZ }
		vehicle.aiveChain.fruitBuffer    = {}
		vehicle.aiveChain.fruitBufferPos = { vX, vY, vZ, g_currentMission.time + AIVEGlobals.maxDtSumF }
		vehicle.aiveChain.fruitBufferSize = 0
	else
		if     AIVEGlobals.maxDtDistF            <= 0
				or AIVEGlobals.maxDtSumF             <= 0
				or AutoSteeringEngine.tableGetN( vehicle.aiveChain.fruitBuffer ) <= 0
				or AutoSteeringEngine.tableGetN( vehicle.aiveChain.fruitBufferPos ) < 4
				or g_currentMission.time             > vehicle.aiveChain.fruitBufferPos[4]
				or AIVEUtils.vector2LengthSq( vehicle.aiveChain.fruitBufferPos[1] - vX, vehicle.aiveChain.fruitBufferPos[3] - vZ ) > AIVEGlobals.maxDtDistF then							
			vehicle.aiveChain.fruitBuffer       = {}
			vehicle.aiveChain.fruitBufferPos[1] = vX
			vehicle.aiveChain.fruitBufferPos[2] = vY
			vehicle.aiveChain.fruitBufferPos[3] = vZ
			vehicle.aiveChain.fruitBufferPos[4] = g_currentMission.time + AIVEGlobals.maxDtSumF
			vehicle.aiveChain.fruitBufferSize = 0
		end
		
		vehicle.acAiPos[1] = vX
		vehicle.acAiPos[2] = vY
		vehicle.acAiPos[3] = vZ
	end
end

------------------------------------------------------------------------
-- getAiWorldPosition
------------------------------------------------------------------------
function AutoSteeringEngine.getAiWorldPosition( vehicle )
	if      vehicle.acAiPos ~= nil
			and vehicle.isServer 
			and vehicle.spec_aiVehicle.isActive then
		return unpack( vehicle.acAiPos )
	end
	return getWorldTranslation( vehicle.aiveChain.refNode )
end

------------------------------------------------------------------------
-- getIsAtEnd
------------------------------------------------------------------------
function AutoSteeringEngine.getIsAtEnd( vehicle )		
	return vehicle.aiveChain.isAtEnd
end

------------------------------------------------------------------------
-- processIsAtEnd
------------------------------------------------------------------------
function AutoSteeringEngine.processIsAtEnd( vehicle )		

	vehicle.aiveChain.isAtEnd = false
	
	if      vehicle.aiveChain.inField 
			and AutoSteeringEngine.getTraceLength( vehicle ) > AIVEGlobals.minTraceLen
			and not AutoSteeringEngine.hasFruitsInFront( vehicle ) then
		vehicle.aiveChain.isAtEnd = true
	end

	return vehicle.aiveChain.isAtEnd 
end

------------------------------------------------------------------------
-- getMaxToolAngle
------------------------------------------------------------------------
function AutoSteeringEngine.getMaxToolAngle( vehicle )
	if vehicle.aiveChain == nil or vehicle.aiveChain.maxToolAngle == nil then
		return AIVEGlobals.maxToolAngle
	end
	return vehicle.aiveChain.maxToolAngle
end

------------------------------------------------------------------------
-- checkChain
------------------------------------------------------------------------
function AutoSteeringEngine.checkChain( vehicle, iRefNode, wheelBase, maxSteering, radius, widthOffset, turnOffset, isInverted, useAIFieldFct, precision )

	local resetTools = false
	
	
--local wz = AutoSteeringEngine.getAbsoulteZRotation( iRefNode )
--if math.abs( wz ) > 0.01 then 
--	local lx,ly,lz = getRotation( iRefNode )
--	AIVehicleExtension.debugPrint( self, string.format( "Adjusting Z rotation of reference node: %5.1f°, %5.1f°, %5.1f°", math.deg( wz ), math.deg( lz ), math.deg( lz - wz ) ) )
--	lz = lz - wz 
--	setRotation( iRefNode, lx,ly,lz )
--end 
	
	if     vehicle.aiveChain == nil
			or vehicle.aiveChain.resetCounter == nil
			or vehicle.aiveChain.resetCounter < AutoSteeringEngine.resetCounter then
		AutoSteeringEngine.initChain( vehicle, iRefNode, wheelBase, maxSteering, widthOffset, turnOffset )
	else
		if     vehicle.aiveChain.wheelBase == nil
				or math.abs( vehicle.aiveChain.wheelBase   - wheelBase   ) > 0.01
				or math.abs( vehicle.aiveChain.maxSteering - maxSteering ) > 0.01 then
if vehicle.aiveChain.angleBuffer ~= nil then AIVehicleExtension.debugPrint( vehicle, "Reset angle buffer 8") end 
			vehicle.aiveChain.angleBuffer = nil
		end
		
		vehicle.aiveChain.wheelBase   = wheelBase
		vehicle.aiveChain.invWheelBase = 1 / wheelBase
		vehicle.aiveChain.maxSteering = maxSteering
	end	
	vehicle.aiveChain.radius        = radius
	
	vehicle.aiveChain.maxToolAngle = AIVEGlobals.maxToolAngle	
	if AutoSteeringEngine.hasArticulatedAxis( vehicle ) then
		vehicle.aiveChain.maxToolAngle = math.min( vehicle.aiveChain.maxToolAngle + 0.5 * vehicle.spec_articulatedAxis.rotMax, AIVEGlobals.maxToolAngleA )
	end

	if      vehicle.aiveChain.useAIFieldFct ~= nil
			and vehicle.aiveChain.useAIFieldFct ~= useAIFieldFct then
		AutoSteeringEngine.invalidateField( vehicle, true )
	end
	vehicle.aiveChain.useAIFieldFct = useAIFieldFct
	
	if     precision == 0 then 
		vehicle.aiveChain.maxDtSumP0  = AIVEGlobals.maxDtSumP0L
		vehicle.aiveChain.maxDtSumP1  = AIVEGlobals.maxDtSumP1L
		vehicle.aiveChain.maxDistSq   = AIVEGlobals.maxDistSqL
	elseif precision == 2 then 
		vehicle.aiveChain.maxDtSumP0  = AIVEGlobals.maxDtSumP0H
		vehicle.aiveChain.maxDtSumP1  = AIVEGlobals.maxDtSumP1H
		vehicle.aiveChain.maxDistSq   = AIVEGlobals.maxDistSqH
	else 
		vehicle.aiveChain.maxDtSumP0  = AIVEGlobals.maxDtSumP0N
		vehicle.aiveChain.maxDtSumP1  = AIVEGlobals.maxDtSumP1N
		vehicle.aiveChain.maxDistSq   = AIVEGlobals.maxDistSqN
	end 
	
	vehicle.aiveChain.chainStart    = AIVEGlobals.chainStart
	AutoSteeringEngine.currentSteeringAngle( vehicle, isInverted )

	AutoSteeringEngine.checkTools1( vehicle, resetTools )
	vehicle.aiveChain.wantedSpeed    = AutoSteeringEngine.getToolsSpeedLimit( vehicle )
	
end

------------------------------------------------------------------------
-- getWidthOffsetStd
------------------------------------------------------------------------
function AutoSteeringEngine.getWidthOffsetStd( vehicle, width )
	local scale  = AIVEUtils.getNoNil( vehicle.aiTurnWidthScale, 0.95 )
	local diff   = AIVEUtils.getNoNil( vehicle.aiTurnWidthMaxDifference, 0.5 )
	local minOfs = AIVEGlobals.minOffset
	if AutoSteeringEngine.hasArticulatedAxis( vehicle ) then
		minOfs = AIVEGlobals.minOffsetArt
	end
	return math.max( AIVEGlobals.minOffset, 0.5 * ( width - math.max(width * scale, width - diff) ) )
end
------------------------------------------------------------------------
-- getWidthOffset
------------------------------------------------------------------------
function AutoSteeringEngine.getWidthOffset( vehicle, width, widthOffset, widthFactor )
	return -widthOffset
end

------------------------------------------------------------------------
-- addToolsRec
------------------------------------------------------------------------
function AutoSteeringEngine.addToolsRec( vehicle, obj )
	if obj ~= nil and obj.spec_attacherJoints ~= nil and obj.spec_attacherJoints.attachedImplements ~= nil then
		for _, implement in pairs(obj.spec_attacherJoints.attachedImplements) do
			if      implement.object                    ~= nil 
					and implement.object.spec_attachable.attacherJoint      ~= nil 
					and implement.object.spec_attachable.attacherJoint.node ~= nil then				
				local found = false
				for i,t in pairs( vehicle.aiveChain.tools ) do
					if implement.object == t.obj then
						found = true
						break
					end
				end
				if not found then
					AutoSteeringEngine.addTool( vehicle, implement )
				end
				AutoSteeringEngine.addToolsRec( vehicle, implement.object )
			end
		end	
	end
end

------------------------------------------------------------------------
-- checkTools1
------------------------------------------------------------------------
function AutoSteeringEngine.checkTools1( vehicle, reset )
	local state, message = pcall( AutoSteeringEngine.checkTools2, vehicle, reset )
	if not ( state ) then 
		AutoSteeringEngine.deleteTools( vehicle )
		vehicle.aiveChain.tools = {}
		print("Error in FS19_AIVehicleExtension.AutoSteeringEngine.checkTools2")
		print(tostring(message))
	end 
end

function AutoSteeringEngine.checkTools2( vehicle, reset )

	if      vehicle.aiveChain ~= nil 
			and ( vehicle.aiveChain.tools == nil or reset ) then
		AutoSteeringEngine.deleteTools( vehicle )
		vehicle.aiveChain.collisionDists = nil
		vehicle.aiveChain.lastBestAngle  = nil
		vehicle.aiveChain.savedAngles    = nil
if vehicle.aiveChain.angleBuffer ~= nil then AIVehicleExtension.debugPrint( vehicle, "Reset angle buffer 9") end 
		vehicle.aiveChain.angleBuffer    = nil	
		vehicle.aiveChain.minAngle       = -vehicle.aiveChain.maxSteering
		vehicle.aiveChain.maxAngle       = vehicle.aiveChain.maxSteering
		vehicle.aiveChain.width          = 0
		vehicle.aiveChain.maxZ           = 0
		vehicle.aiveChain.minZ           = 0
		vehicle.aiveChain.activeX        = 0
		vehicle.aiveChain.otherX         = 0
		vehicle.aiveChain.offsetZ        = 0
		vehicle.aiveChain.backZ          = 0
		vehicle.aiveChain.offsetStd      = 0
		
		
		if vehicle.aiveToolsDirty then	
			vehicle.aiveChain.tools = nil
		else
			vehicle.aiveChain.tools = {}
			for _,implement in pairs(vehicle.spec_aiVehicle.aiImplementList) do
				AutoSteeringEngine.addTool(vehicle,implement)
			end
			
			AutoSteeringEngine.addToolsRec( vehicle, vehicle )
		end
	end
end

------------------------------------------------------------------------
-- checkTools
------------------------------------------------------------------------
function AutoSteeringEngine.checkTools( vehicle, reset )
	
	AutoSteeringEngine.checkTools1( vehicle, reset )
	
	local dx,dz,zb,fb = 0,0,0,1
	
	if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		dz = -99
		zb =  99
		for i=1,vehicle.aiveChain.toolCount do
			local doNotIgnore = true
			if vehicle.aiveChain.tools[i].ignoreAI then
				doNotIgnore = false
			end
			if doNotIgnore then
				local _,_,zDist      = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, vehicle.aiveChain.tools[i].refNode )
				local xl, xr, z1, z2 = AutoSteeringEngine.getToolMarkerRange( vehicle, vehicle.aiveChain.tools[i] )
				
				local dx1 = xl - xr
				local dz1 = z1 + zDist - vehicle.aiveChain.tools[i].zOffset
				local zb1 = z2 + zDist - vehicle.aiveChain.tools[i].zOffset
				local fb1 = 1
				if vehicle.aiveChain.tools[i].isSprayer and zb1 < dz1 then
					zb1 = dz1 -1
				end
				if vehicle.aiveChain.tools[i].isPlow then --or vehicle.aiveChain.tools[i].aiForceTurnNoBackward then 
					fb1 = z1 - z2 
				else 
					fb1 = 0.5 * ( z1 - z2 )
				end 
				
				if dx < dx1 then dx = dx1 end
				if dz < dz1 then dz = dz1 end
				if zb > zb1 then zb = zb1 end
				if fb < fb1 then fb = fb1 end 
			end
		--local wo = AutoSteeringEngine.getWidthOffsetStd( vehicle, dx )
			local wo = vehicle.aiveChain.offsetZ
			if wo ~= nil and wo ~= 0 then
				dx = 0.5 * dx - wo
			else
				dx = 0.5 * dx
			end
		end
	end
	
	local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( vehicle )
	
	return dx,dz,zb,fb,turn75.radiusT
end

------------------------------------------------------------------------
-- getToolsSpeedLimit
------------------------------------------------------------------------
function AutoSteeringEngine.getToolsSpeedLimit( vehicle )

	local speedLimit = 25
	if vehicle.cruiseControl ~= nil and vehicle.cruiseControl.maxSpeed ~= nil then
		speedLimit = vehicle.cruiseControl.maxSpeed
	end

	local s, c = vehicle:getSpeedLimit()

	if speedLimit > s then
		speedLimit = s
	end
	
	if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		for i=1,vehicle.aiveChain.toolCount do
			object = vehicle.aiveChain.tools[i].obj
			if object.checkSpeedLimit and speedLimit > object.speedLimit then
				speedLimit = object.speedLimit
			end
		end
	end
	
	return speedLimit
end

------------------------------------------------------------------------
-- getWantedSpeed
------------------------------------------------------------------------
function AutoSteeringEngine.getWantedSpeed( vehicle, speedLevel )
	if vehicle.aiveChain.wantedSpeed == nil then
		vehicle.aiveChain.wantedSpeed = 0.8 *  AutoSteeringEngine.getToolsSpeedLimit( vehicle )
	else
		vehicle.aiveChain.wantedSpeed = math.min( vehicle.aiveChain.wantedSpeed, AutoSteeringEngine.getToolsSpeedLimit( vehicle ) )
	end
	if vehicle.aiveChain.wantedSpeed < AIVEGlobals.minSpeed then
		vehicle.aiveChain.wantedSpeed = AIVEGlobals.minSpeed
	end
	
	local wantedSpeed  = 12
		
	if     speedLevel == nil 
			or speedLevel == 2 then
		wantedSpeed = vehicle.aiveChain.wantedSpeed
	elseif speedLevel == 4 then
		wantedSpeed = math.min( 7, vehicle.aiveChain.wantedSpeed )
	elseif speedLevel == 5 then
		wantedSpeed = 1
	elseif speedLevel == 0 then
		wantedSpeed = 0
	elseif speedLevel == 1 then
		wantedSpeed  = math.min( math.max( 7, 0.667 * vehicle.aiveChain.wantedSpeed ), vehicle.aiveChain.wantedSpeed )
	end
	
	if not ( vehicle.aiveChain.fullSpeed ) then
		wantedSpeed = math.min( 7, wantedSpeed )
	end
	
	return wantedSpeed
end

------------------------------------------------------------------------
-- hasTools
------------------------------------------------------------------------
function AutoSteeringEngine.hasTools( vehicle )
	if      vehicle.aiveChain     ~= nil 
			and vehicle.aiveChain.leftActive  ~= nil 
			and vehicle.aiveChain.toolCount ~= nil 
			and vehicle.aiveChain.toolCount >= 1 then 
		for _,t in pairs(vehicle.aiveChain.tools) do
			if not (t.ignoreAI) then
				return true
			end
		end
	end
	return false 
end

------------------------------------------------------------------------
-- initTools
------------------------------------------------------------------------
function AutoSteeringEngine.initTools( vehicle, maxLooking, leftActive, widthOffset, headlandDist, collisionDist, turnMode )

	isTurnMode7 = ( vehicle.aiveChain.turnMode == "7" )
	
	local refreshBuffer = false
	
	if isTurnMode7 then
		if     vehicle.aiveChain.leftActive    == nil or vehicle.aiveChain.leftActive    ~= leftActive
				or vehicle.aiveChain.isTurnMode7 == nil or vehicle.aiveChain.isTurnMode7 ~= isTurnMode7 then
		--print("leftRight 1")
			refreshBuffer = true
		end
	elseif vehicle.aiveChain.leftActive == nil or vehicle.aiveChain.leftActive ~= leftActive
			or vehicle.aiveChain.headland == nil or math.abs( vehicle.aiveChain.headland - headlandDist ) > 0.1 then
	--print("leftRight 2: "..tostring(leftActive)..", "..tostring(headlandDist))
		refreshBuffer = true
	end
	
	if vehicle.aiveChain.maxLooking ~= nil and math.abs( vehicle.aiveChain.maxLooking - maxLooking ) > 1e-3 then
	--print("maxLooking: "..AutoSteeringEngine.radToString(vehicle.aiveChain.maxLooking).." - "..AutoSteeringEngine.radToString(maxLooking))
		refreshBuffer = true
	end
	
	if refreshBuffer then
		AutoSteeringEngine.initFruitBuffer( vehicle )
	end
	
	vehicle.aiveChain.isTurnMode7 = isTurnMode7
	
	vehicle.aiveChain.leftActive  = leftActive
	vehicle.aiveChain.headland    = headlandDist
	vehicle.aiveChain.turnMode    = turnMode
	vehicle.aiveChain.maxLooking  = maxLooking	
	vehicle.aiveChain.minLooking  = math.min( math.max( AIVEGlobals.minLooking, maxLooking * AIVEGlobals.minLkgFactor ), 0.5 * vehicle.aiveChain.maxLooking )
	
	local maxRot = AIVEGlobals.maxRotationT
	
	if not ( vehicle.aiveChain.inField ) then
		maxRot = AIVEGlobals.maxRotationT
	elseif vehicle.aiveChain.turnMode == "C"
			or vehicle.aiveChain.turnMode == "L"
			or vehicle.aiveChain.turnMode == "K"
			or vehicle.aiveChain.turnMode == "7" then
		maxRot = AIVEGlobals.maxRotationC
	else 
		maxRot = AIVEGlobals.maxRotationU
	end 
	
	if maxRot < AIVEGlobals.maxRotationT then
		local t = AutoSteeringEngine.getTraceLength( vehicle )
		if t < AIVEGlobals.maxRotationL then
			f = t / AIVEGlobals.maxRotationL
			maxRot = f * maxRot + ( 1-f ) * AIVEGlobals.maxRotationT
		end
	end	
	
	if vehicle.aiveChain.leftActive then
		vehicle.aiveChain.minRotation = -maxRot 
		vehicle.aiveChain.maxRotation =  math.pi*2/3
	else
		vehicle.aiveChain.minRotation = -math.pi*2/3
		vehicle.aiveChain.maxRotation =  maxRot 
	end
	
	if collisionDist > 1 then
		vehicle.aiveChain.collisionDist = collisionDist 
	else
		vehicle.aiveChain.collisionDist =  0
	end
	vehicle.aiveChain.toolParams  = {}
	
	
	
	if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then	
		local xa = {}
		local xo = {}
		for i=1,vehicle.aiveChain.toolCount do
			if vehicle.aiveChain.tools[i].obj.getAIMarkers ~= nil then 
				local l,r,b,p = vehicle.aiveChain.tools[i].obj:getAIMarkers()
				if      l ~= nil and l ~= 0 
						and r ~= nil and r ~= 0
						and b ~= nil and b ~= 0 then 
					vehicle.aiveChain.tools[i].marker   = { l, r, b }
					vehicle.aiveChain.tools[i].ignoreAI = false 
				elseif not vehicle.aiveChain.tools[i].ignoreAI then 
					vehicle.aiveChain.tools[i].marker   = {}
					vehicle.aiveChain.tools[i].ignoreAI = true 
				end 
			end 
			vehicle.aiveChain.tools[i].isTerrainDetailRequiredModified = false 
		
			local skip      = false
			local skipOther = false
			if vehicle.aiveChain.tools[i].ignoreAI then
				skip      = true
				skipOther = true
			elseif not vehicle.aiveChain.tools[i].isAIImplement and vehicle.aiveHas.aiImplement then 
				skip      = true
				skipOther = true
			elseif vehicle.aiveChain.tools[i].isCultivator and vehicle.aiveHas.sowingMachine then  
				skip      = true
				skipOther = true
			elseif vehicle.aiveChain.tools[i].isSprayer    and ( vehicle.aiveHas.sowingMachine or vehicle.aiveHas.cultivator ) then  
				skip      = true
				skipOther = true
			else 
				vehicle.aiveChain.tools[i].terrainDetailRequiredValueRanges = vehicle.aiveChain.tools[i].obj:getAITerrainDetailRequiredRange()
				vehicle.aiveChain.tools[i].fruitProhibitions                = vehicle.aiveChain.tools[i].obj:getAIFruitProhibitions()
			end 
			
			if not skip or not skipOther then
				for j=1,vehicle.aiveChain.toolCount do
					if i ~= j then
						if     ( vehicle.aiveChain.tools[i].isCombine      
									or vehicle.aiveChain.tools[i].isPlow       
									or vehicle.aiveChain.tools[i].isCultivator   
									or vehicle.aiveChain.tools[i].isSowingMachine
									or vehicle.aiveChain.tools[i].isSprayer      
									or vehicle.aiveChain.tools[i].isMower        
									or vehicle.aiveChain.tools[i].isTedder       
									or vehicle.aiveChain.tools[i].isWindrower      
									or vehicle.aiveChain.tools[i].outTerrainDetailChannel >= 0
									--or ( vehicle.aiveChain.tools[i].specialType ~= nil and vehicle.aiveChain.tools[i].specialType ~= "" ) 
									 )
								and not ( vehicle.aiveChain.tools[j].ignoreAI )
								and vehicle.aiveChain.tools[j].isAIImplement
								and vehicle.aiveChain.tools[i].isCombine       == vehicle.aiveChain.tools[j].isCombine      
								and vehicle.aiveChain.tools[i].isPlow          == vehicle.aiveChain.tools[j].isPlow       
								and vehicle.aiveChain.tools[i].isCultivator    == vehicle.aiveChain.tools[j].isCultivator   
								and vehicle.aiveChain.tools[i].isSowingMachine == vehicle.aiveChain.tools[j].isSowingMachine
								and vehicle.aiveChain.tools[i].isSprayer       == vehicle.aiveChain.tools[j].isSprayer      
								and vehicle.aiveChain.tools[i].isMower         == vehicle.aiveChain.tools[j].isMower        
								and vehicle.aiveChain.tools[i].isTedder        == vehicle.aiveChain.tools[j].isTedder        
								and vehicle.aiveChain.tools[i].isWindrower     == vehicle.aiveChain.tools[j].isWindrower        
								and vehicle.aiveChain.tools[i].outTerrainDetailChannel == vehicle.aiveChain.tools[j].outTerrainDetailChannel 
								--and vehicle.aiveChain.tools[i].specialType == vehicle.aiveChain.tools[j].specialType
								then
							
							local k = i
							for l=1,2 do
								if xa[k] == nil then	
									local tool = vehicle.aiveChain.tools[k]
									local xOffset,_,_ = AutoSteeringEngine.getRelativeTranslation( tool.steeringAxleNode, tool.refNode )
									for m=1,table.getn(tool.marker) do
										local xxx,_,_ = AutoSteeringEngine.getRelativeTranslation( tool.steeringAxleNode, tool.marker[m] )
										xxx = xxx - xOffset
										if tool.invert then xxx = -xxx end
										if xa[k] == nil then
											xa[k] = xxx
											xo[k] = xxx
										elseif vehicle.aiveChain.leftActive then
											if xa[k] < xxx then xa[k] = xxx end
											if xo[k] > xxx then xo[k] = xxx end
										else
											if xa[k] > xxx then xa[k] = xxx end
											if xo[k] < xxx then xo[k] = xxx end
										end
									end
									local xxx = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, tool.refNode )
									xa[k]  = xa[k] + xxx
									xo[k]  = xo[k] + xxx
								end
								
								k = j
							end
							
							if vehicle.aiveChain.leftActive then
								skip      = skip      or ( xa[i] + 0.2 < xa[j] )
								skipOther = skipOther or ( xo[i] - 0.2 > xo[j] )
							else
								skip      = skip      or ( xa[i] - 0.2 > xa[j] )
								skipOther = skipOther or ( xo[i] + 0.2 < xo[j] )
							end					
							
							if skip and skipOther then
								break
							end
						end
					end
				end
			end
			
			local tp = AutoSteeringEngine.getSteeringParameterOfTool( vehicle, i, maxLooking, widthOffset )			
			tp.skip      = skip
			tp.skipOther = skipOther
			vehicle.aiveChain.toolParams[i] = tp
		end
	end	
	
--vehicle.aiveChain.cbr    = nil
end

function AutoSteeringEngine.reinitToolsWithWidthFactor( vehicle, maxLooking, widthOffset, widthFactor )

	if vehicle.aiveChain.toolParams ~= nil then
		local tpNew = {}
		for i=1,table.getn( vehicle.aiveChain.toolParams ) do
			local tp = AutoSteeringEngine.getSteeringParameterOfTool( vehicle, vehicle.aiveChain.toolParams[i].i, maxLooking, widthOffset, widthFactor )
			tp.skip  = vehicle.aiveChain.toolParams[i].skip
			tpNew[vehicle.aiveChain.toolParams[i].i] = tp
		end
		vehicle.aiveChain.toolParams = tpNew
	end
end

------------------------------------------------------------------------
-- AutoSteeringEngineCallback
------------------------------------------------------------------------
AutoSteeringEngineCallback = {}
function AutoSteeringEngineCallback.create( vehicle )
	local self = {}
	self.vehicle = vehicle
	self.raycast = AutoSteeringEngineCallback.raycast
	self.overlap = AutoSteeringEngineCallback.overlap
	return self
end

------------------------------------------------------------------------
-- AutoSteeringEngineCallback:raycast
------------------------------------------------------------------------
function AutoSteeringEngineCallback:raycast( transformId, x, y, z, distance )
	
	if transformId == g_currentMission.terrainRootNode or ( transformId == nil and distance > 1 ) then
		return true
	end

	local other  = nil
	local nodeId = transformId
	repeat
		other  = g_currentMission.nodeToVehicle[nodeId]
		if other == nil then
			nodeId = getParent( nodeId )	
		end
	until other ~= nil or nodeId == nil or nodeId == 0
	
	if     other == nil then
	--	print("static  "..tostring(getName(transformId)).." @ x: "..tostring(x).." z: "..tostring(z))
		self.vehicle.aiveHasCollision = true

		if AIVECollisionPoints == nil then
			AIVECollisionPoints = {}
		end
		local p = {}
		p.x = x
		p.y = y 
		p.z = z
		table.insert( AIVECollisionPoints, p )
		
		return false
		
	elseif not( other == self.vehicle
					 or self.vehicle.trafficCollisionIgnoreList[transformId]
					 or self.vehicle.trafficCollisionIgnoreList[parent]
					 or self.vehicle.trafficCollisionIgnoreList[parentParent]
					 or AutoSteeringEngine.isAttachedImplement( self.vehicle, object ) ) then
	--	print("vehicle  "..tostring(getName(transformId)))
	--	self.vehicle.aiveHasCollision = true
	--	return false
	end

	return true	
end


------------------------------------------------------------------------
-- AutoSteeringEngineCallback:overlap
------------------------------------------------------------------------
function AutoSteeringEngineCallback:overlap( transformId )

	local parent = getParent(transformId)
	
	if     transformId         == g_currentMission.terrainRootNode 
			or parent              == g_currentMission.terrainRootNode then
		return true
	end

	local parentParent = getParent(parent)	
	local other = g_currentMission.nodeToVehicle[transformId]
	if other == nil then
		other = g_currentMission.nodeToVehicle[parent]
	end
	if other == nil then
		other = g_currentMission.nodeToVehicle[parentParent]
	end			
	
	if     other == nil 
			or not( other == self.vehicle
					 or self.vehicle.trafficCollisionIgnoreList[transformId]
					 or self.vehicle.trafficCollisionIgnoreList[parent]
					 or self.vehicle.trafficCollisionIgnoreList[parentParent]
					 or AutoSteeringEngine.isAttachedImplement( self.vehicle, object ) ) then
		self.vehicle.aiveHasCollision = true
		return false
	end

	return true	
end


------------------------------------------------------------------------
-- hasCollisionHelper
------------------------------------------------------------------------
function AutoSteeringEngine.hasCollisionHelper( vehicle, wx, wz, dx, dz, l, doBreak )
	if boBreak and vehicle.aiveHasCollision then
		return
	end
	
	if     not AutoSteeringEngine.checkField( vehicle, wx + l * dx, wz + l * dz )
			or not AutoSteeringEngine.checkField( vehicle, wx , wz )then										
		local wy = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, wx, 1, wz) 
		local dy = ( getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, wx + l * dx, 1, wz + l * dz) - wy ) / l
		local hasCollision = vehicle.aiveHasCollision
		vehicle.aiveHasCollision = false
		for y=0.5,1.5,AIVEGlobals.colliStep do					
			if vehicle.aiveHasCollision then
				break
			end
			raycastAll(wx, wy + y, wz, dx, dy, dz, "raycast", l, vehicle.aiveCallback )--, nil, AIVEGlobals.colliMask )
		end
		if hasCollision then
			vehicle.aiveHasCollision = true
		end
	end
end

------------------------------------------------------------------------
-- hasCollision
------------------------------------------------------------------------
function AutoSteeringEngine.hasCollision( vehicle, nodeId )
	if vehicle.aiveChain.collisionDist < 1 then return false end
	if AIVEGlobals.colliMask <= 0 then return false end
	if vehicle.aiveChain == nil or vehicle.aiveChain.headlandNode == nil then return false end
	if nodeId == nil then nodeId = vehicle.aiveChain.headlandNode end
	
	if vehicle.aiveChain.collisionDists == nil then
		vehicle.aiveChain.collisionDists = {}
	end
	
	if vehicle.aiveChain.collisionDists[nodeId] == nil then
		if vehicle.aiveCallback == nil then
			vehicle.aiveCallback = AutoSteeringEngineCallback.create( vehicle )
		end
		vehicle.aiveHasCollision = false
	
		if     not AutoSteeringEngine.isFieldAhead( vehicle,  vehicle.aiveChain.collisionDist, nodeId )
				or not AutoSteeringEngine.isFieldAhead( vehicle, -vehicle.aiveChain.collisionDist, nodeId ) then
			local r0 = 1.5
			if vehicle.aiveChain.radius ~= nil then
				r0 = math.max( r0, vehicle.aiveChain.radius )
			end
			if     vehicle.aiveChain.turnMode == "A"
					or vehicle.aiveChain.turnMode == "L" then
				r0 = r0 + math.max( 3, AIVEUtils.getNoNil( vehicle.aiveChain.wheelBase, 0 ) + 2 )
			end
			if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
				for _,tool in pairs(vehicle.aiveChain.tools) do
					r0 = math.max( r0, math.max( tool.xl, tool.xr ) )
				end
			end
			
			local wx, wy, wz = getWorldTranslation( nodeId )
			
			local cx1, cx2, cz1, cz2
			
			if AIVECollisionPoints ~= nil and table.getn( AIVECollisionPoints ) > 0 then
				local cl = AIVEUtils.vector2LengthSq( r0, vehicle.aiveChain.collisionDist )
			
				for _,p in pairs( AIVECollisionPoints ) do
					--print("x: "..tostring(wx).." z: "..tostring(wz).." p.x: "..tostring(p.x).." p.z: "..tostring(p.z))
					if AIVEUtils.vector2LengthSq( wx - p.x, wz - p.z ) <= cl then
						local lx, ly, lz = worldToLocal( nodeId, wx, wy, wz )
						local ax
						if     lx > 1.5 then
							ax = lx							
						elseif lx < -1.5 then
							ax = -lx
						else
							ax = 0
						end						
						local az = math.abs( lz )
						--print("ax: "..tostring(ax).." az: "..tostring(az))
						if ax < 1 and az < 1 then
							--print("found static 1")
							vehicle.aiveHasCollision = true
							break
						elseif  az <= vehicle.aiveChain.collisionDist 
						    and ( ax < 1E-3 or ax <= az * r0 / vehicle.aiveChain.collisionDist ) then
							--print("found static 2")
							vehicle.aiveHasCollision = true
							break
						end
					end
				end
			end
			
			if not vehicle.aiveHasCollision then
				--local maxCl = AIVEUtils.vector2Length( r0 + 1.5, vehicle.aiveChain.collisionDist )
				-- left & right
				for f=0,1,AIVEGlobals.colliStep do
					local r          = f * r0 
					local cl         = math.sqrt( r * r + vehicle.aiveChain.collisionDist * vehicle.aiveChain.collisionDist )
					cx1,_,cz1  = localDirectionToWorld( vehicle.aiveChain.headlandNode, r / cl, 0, vehicle.aiveChain.collisionDist / cl )
					cx2,_,cz2  = localDirectionToWorld( vehicle.aiveChain.headlandNode,-r / cl, 0, vehicle.aiveChain.collisionDist / cl )
					--cl = math.min( cl, maxCl )
													
					AutoSteeringEngine.hasCollisionHelper( vehicle, wx, wz, cx1, cz1, cl )
					AutoSteeringEngine.hasCollisionHelper( vehicle, wx, wz,-cx1,-cz1, cl )
					AutoSteeringEngine.hasCollisionHelper( vehicle, wx, wz, cx2, cz2, cl )
					AutoSteeringEngine.hasCollisionHelper( vehicle, wx, wz,-cx2,-cz2, cl )					
				end

				-- the T (front & back)
				cx1,_,cz1  = localDirectionToWorld( vehicle.aiveChain.headlandNode, 1, 0, 0 )
				cx2,_,cz2  = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )
				for z=-3,0,AIVEGlobals.colliStep do
					local vx, vz
					vx = wx + ( z + vehicle.aiveChain.collisionDist ) * cx2 - r0 * cx1
					vz = wz + ( z + vehicle.aiveChain.collisionDist ) * cz2 - r0 * cz1 					
					AutoSteeringEngine.hasCollisionHelper( vehicle, vx, vz, cx1, cz1, r0 + r0 )
					vx = wx - ( z + vehicle.aiveChain.collisionDist ) * cx2 - r0 * cx1                   
					vz = wz - ( z + vehicle.aiveChain.collisionDist ) * cz2 - r0 * cz1                   
					AutoSteeringEngine.hasCollisionHelper( vehicle, vx, vz, cx1, cz1, r0 + r0 )
				end
				
				-- the middle (vehicle width)
				for x=-1.5,1.5,AIVEGlobals.colliStep do
					vx = wx + x * cx1
					vz = wz + x * cz1 																
					AutoSteeringEngine.hasCollisionHelper( vehicle, vx, vz, cx2, cz2, vehicle.aiveChain.collisionDist )
					AutoSteeringEngine.hasCollisionHelper( vehicle, vx, vz,-cx2,-cz2, vehicle.aiveChain.collisionDist )
				end
			end
		end
		
		vehicle.aiveChain.collisionDists[nodeId] = vehicle.aiveHasCollision
	end
	
	return vehicle.aiveChain.collisionDists[nodeId]
end

------------------------------------------------------------------------
-- isAttachedImplement
------------------------------------------------------------------------
function AutoSteeringEngine.isAttachedImplement( vehicle, object )
	if vehicle == nil or object == nil then
		return false
	end
	if vehicle == object then
		return true
	end
	if vehicle.spec_attacherJoints == nil or vehicle.spec_attacherJoints.attachedImplements == nil then
		return false
	end	
	for _, implement in pairs(vehicle.spec_attacherJoints.attachedImplements) do
		if AutoSteeringEngine.isAttachedImplement( implement.object, object ) then
			return true
		end
	end		
	return false
end

------------------------------------------------------------------------
-- localToWorld
------------------------------------------------------------------------
function AutoSteeringEngine.localToWorld( reference, node, x, z, inverted )
	local one        = 1
	if inverted then
		one = -1
	end
	local xDx,_,xDz = localDirectionToWorld( reference, x * one, 0, 0 )
	local zDx,_,zDz = localDirectionToWorld( reference, 0, 0, z * one )
	local wx,wy,wz  = getWorldTranslation( node )
	
	return wx + xDx + zDx, wy, wz + xDz + zDz
end

------------------------------------------------------------------------
-- localToWorld
------------------------------------------------------------------------
function AutoSteeringEngine.toolLocalToWorld( vehicle, toolIndex, node, x, z )
	local tool = vehicle.aiveChain.tools[toolIndex]
	if tool.steeringAxleNode == nil then
		return AutoSteeringEngine.localToWorld( vehicle.aiveChain.refNode, node, x, z, false )
	end
	return AutoSteeringEngine.localToWorld( tool.steeringAxleNode, node, x, z, tool.invert )
end
------------------------------------------------------------------------
-- hasLeftFruits
------------------------------------------------------------------------
function AutoSteeringEngine.hasLeftFruits( vehicle )
	
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return false end
	
--if AIVEGlobals.useFBB123 > 0 then
--	local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
--	if vehicle.aiveChain.fbb3 ~= nil and AIVEUtils.vector2LengthSq( vehicle.aiveChain.fbb3.x - wx, vehicle.aiveChain.fbb3.z - wz ) < AIVEGlobals.FBB123disq1 then
--		return vehicle.aiveChain.fbb3.d
--	end
--end

	if vehicle.aiveFruitAreas == nil then
		vehicle.aiveFruitAreas = {}
	end
	vehicle.aiveFruitAreas[3] = {}
			
	local fruitsDetected = false
	
	if      vehicle.aiveChain      ~= nil 
			and vehicle.aiveChain.leftActive   ~= nil 
			and vehicle.aiveChain.toolCount  ~= nil 
			and vehicle.aiveChain.toolCount  == 1 
			and vehicle.aiveChain.toolParams ~= nil 
			and vehicle.aiveChain.toolCount  == table.getn( vehicle.aiveChain.toolParams ) then
		for i = 1,vehicle.aiveChain.toolCount do	
			local toolParam = vehicle.aiveChain.toolParams[i]
			local tool      = vehicle.aiveChain.tools[toolParam.i]				
			if not toolParam.skip then		 
			--local front     = math.min( toolParam.zReal, toolParam.zBack )
				local front     = vehicle.aiveChain.minZ - 0.5
				local back      = front - 2
							
				local dx,dz
				if tool.steeringAxleNode == nil then
					dx,_,dz = localDirectionToWorld( vehicle.aiveChain.refNode, 0, 0, 1 )
				elseif tool.invert then
					dx,_,dz = localDirectionToWorld( tool.steeringAxleNode, 0, 0, -1 )
				else
					dx,_,dz = localDirectionToWorld( tool.steeringAxleNode, 0, 0, 1 )
				end

				local w = math.min( 2, toolParam.width * 0.8 )
				local ofs, idx			
				if vehicle.aiveChain.leftActive	then
					ofs = w-toolParam.offset 
					idx = toolParam.nodeLeft 
				else
					ofs = toolParam.offset-w
					idx = toolParam.nodeRight
				end
				
				w = w + w
			
				if vehicle.aiveChain.leftActive then
					w = -w
				end

				local xw1,y,zw1 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, back )
				local xw2,y,zw2 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, front )
				
				local lx1,lz1,lx2,lz2,lx3,lz3,lx4,lz4
				dist = front - back
				repeat 
					xw2 = xw1 + dist * dx
					zw2 = zw1 + dist * dz
					lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( xw1,zw1,xw2,zw2, w, true )
					lx4 = lx3 + lx2 - lx1
					lz4 = lz3 + lz2 - lz1
					
					dist = dist - 0.5
				until dist < 0.5
						or ( vehicle.aiveChain.headland >= 1
						 and ( AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
								or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
								or AutoSteeringEngine.isChainPointOnField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )
						or ( vehicle.aiveChain.headland < 1
						 and ( AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
								or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
								or AutoSteeringEngine.checkField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )

				local lx5 = 0.25 * ( lx1 + lx2 + lx3 + lx4 )
				local lz5 = 0.25 * ( lz1 + lz2 + lz3 + lz4 )
				
				if vehicle.aiveChain.headland < 1 then
					if     AutoSteeringEngine.checkField( vehicle, lx1, lz1 )
							or AutoSteeringEngine.checkField( vehicle, lx2, lz2 )
							or AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
							or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
							or AutoSteeringEngine.checkField( vehicle, lx5, lz5 ) then
						if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
							table.insert( vehicle.aiveFruitAreas[3], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, true } )
							fruitsDetected = true
							break
						end			
						table.insert( vehicle.aiveFruitAreas[3], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, false } )
					end			
				else
					if     AutoSteeringEngine.isChainPointOnField( vehicle, lx1, lz1 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx2, lz2 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx5, lz5 ) then
						if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
							table.insert( vehicle.aiveFruitAreas[3], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, true } )
							fruitsDetected = true
							break
						end			
						table.insert( vehicle.aiveFruitAreas[3], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, false } )
					end			
				end			
			end
		end
	end
	
	if AIVEGlobals.useFBB123 > 0 then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		vehicle.aiveChain.fbb3 = { x=wx, z=wz, d=fruitsDetected }
	end
	
	return fruitsDetected
end

------------------------------------------------------------------------
-- hasLeftFruits
------------------------------------------------------------------------
function AutoSteeringEngine.hasFruitsInFront( vehicle )
	
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return false end
	
	if AIVEGlobals.useFBB123 > 0 then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		if      vehicle.aiveChain.fbb2   ~= nil 
				and vehicle.aiveChain.fbb2.x ~= nil 
				and vehicle.aiveChain.fbb2.z ~= nil 
				and AIVEUtils.vector2LengthSq( vehicle.aiveChain.fbb2.x - wx, vehicle.aiveChain.fbb2.z - wz ) < AIVEGlobals.FBB123disq2 then
			return vehicle.aiveChain.fbb2.d
		end
	end
			
	if vehicle.aiveFruitAreas == nil then
		vehicle.aiveFruitAreas = {}
	end
	vehicle.aiveFruitAreas[2] = {}
			
	local fruitsDetected = false
	local headlandDist   = 0
	if vehicle.aiveChain.headland >= 1 then
	-- avoid strange turn2Outside manoeuver with up to 45° border in front
		headlandDist = vehicle.aiveChain.headland + vehicle.aiveChain.width
	end
	
	AutoSteeringEngine.rotateHeadlandNode( vehicle )
	local dxh,_,dzh = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )
	local angle 
	if vehicle.aiveChain.leftActive then
		angle = math.rad(  9 )
	else
		angle = math.rad( -9 )
	end
	local dx9,_,dz9 = localDirectionToWorld( vehicle.aiveChain.headlandNode, math.sin( angle ), 0, math.cos( angle ) )
	local dxd,_,dzd = localDirectionToWorld( vehicle.aiveChain.refNode, 0, 0, 1 )

	if      vehicle.aiveChain            ~= nil 
			and vehicle.aiveChain.leftActive ~= nil 
			and vehicle.aiveChain.toolCount  ~= nil 
			and vehicle.aiveChain.toolCount  >= 1 
			and vehicle.aiveChain.toolParams ~= nil 
			and vehicle.aiveChain.toolCount  == table.getn( vehicle.aiveChain.toolParams ) then
		for i = 1,vehicle.aiveChain.toolCount do	
			local toolParam = vehicle.aiveChain.toolParams[i]
			local tool      = vehicle.aiveChain.tools[toolParam.i]		

			if not ( toolParam.skip ) then
				local gotFruits = false
				
				local back, dxb, dzb, dxf, dzf 
				
				back = math.max( AIVEGlobals.fruitsInFront, vehicle.aiveChain.radius, vehicle.aiveChain.maxZ - toolParam.zReal + AIVEGlobals.fruitsAdvance )
				if tool.aiForceTurnNoBackward then
					back = back + 2 
				end
				dxb  = dxh
				dzb  = dzh
				dxf  = dx9
				dzf  = dz9
				
				local w = toolParam.width
				
				if vehicle.aiveChain.leftActive then
					w = toolParam.x - vehicle.aiveChain.otherX
				else
					w = vehicle.aiveChain.otherX - toolParam.x 
				end			
				
				local ofs, idx			
				if vehicle.aiveChain.leftActive	then
					ofs = -toolParam.offset 
					idx = toolParam.nodeLeft 
				else
					ofs = toolParam.offset
					idx = toolParam.nodeRight
				end
				
				w = w + w
				if vehicle.aiveChain.leftActive then
					w = -w
				end

				local xw1,y,zw1 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, 0 )
				xw1 = xw1 + back * dxb
				zw1 = zw1 + back * dzb
			
				local lx1,lz1,lx2,lz2,lx3,lz3,lx4,lz4
				local dist = 2
				local xw2, zw2

				repeat 
					xw2 = xw1 + dist * dxf
					zw2 = zw1 + dist * dzf
					lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( xw1,zw1,xw2,zw2, w, true )
					
					if headlandDist ~= 0 then
						lx1 = lx1 + headlandDist * dxh
						lx2 = lx2 + headlandDist * dxh
						lx3 = lx3 + headlandDist * dxh
						lz1 = lz1 + headlandDist * dzh
						lz2 = lz2 + headlandDist * dzh
						lz3 = lz3 + headlandDist * dzh
					end
					lx4 = lx3 + lx2 - lx1
					lz4 = lz3 + lz2 - lz1
					
					dist = dist - math.max( 0.5, dist * 0.2 )
				until  dist < 0.5
						or AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
						or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
						or AutoSteeringEngine.checkField( vehicle, 0.5 * ( lx3 + lx4 ), 0.5 * ( lz3 + lz4 ) ) 

				local lx5 = 0.25 * ( lx1 + lx2 + lx3 + lx4 )
				local lz5 = 0.25 * ( lz1 + lz2 + lz3 + lz4 )
				
				if     AutoSteeringEngine.checkField( vehicle, lx1, lz1 )
						or AutoSteeringEngine.checkField( vehicle, lx2, lz2 )
						or AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
						or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
						or AutoSteeringEngine.checkField( vehicle, lx5, lz5 ) then
					if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
						gotFruits = true
					end			
				end			
				
				table.insert( vehicle.aiveFruitAreas[2], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, gotFruits } )
		
				if gotFruits then 
					fruitsDetected = true
					break
				end
			end
		end
	end
	
	if fruitsDetected == nil then
		fruitsDetected = false
	end
	
	if AIVEGlobals.useFBB123 > 0 then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		vehicle.aiveChain.fbb2 = { x=wx, z=wz, d=fruitsDetected }
	end
	
	return fruitsDetected
end

------------------------------------------------------------------------
-- isBeyondStartNode
------------------------------------------------------------------------
function AutoSteeringEngine.isBeforeStartNode( vehicle, node )
	if     vehicle.aiveChain == nil 
			or not ( vehicle.aiveChain.respectStartNode ) then
		return false
	end
	
	local n = node
	if node == nil then
		n = vehicle.aiveChain.refNode
	end
	if AutoSteeringEngine.getRelativeZTranslation( vehicle.aiveChain.startNode, n ) < 0 then
		return true
	end	
	
	return false
end

------------------------------------------------------------------------
-- hasFruits
------------------------------------------------------------------------
function AutoSteeringEngine.hasFruits( vehicle, checkLowerAdvance )

	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return false end
		
	if AIVEGlobals.useFBB123 > 0 and not ( checkLowerAdvance ) then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		local fbbd = AIVEGlobals.FBB123disq1
		if vehicle.aiveChain.inField then
			fbbd = AIVEGlobals.FBB123disq2
		end
		if      vehicle.aiveChain.fbb1   ~= nil 
				and vehicle.aiveChain.fbb1.x ~= nil 
				and vehicle.aiveChain.fbb1.z ~= nil 
				and AIVEUtils.vector2LengthSq( vehicle.aiveChain.fbb1.x - wx, vehicle.aiveChain.fbb1.z - wz ) < fbbd then
			return vehicle.aiveChain.fbb1.d, vehicle.aiveChain.fbb1.a 
		end
	end
			
	if AutoSteeringEngine.hasCollision( vehicle ) then 
		vehicle.aiveChain.fbb1 = { x=wx, z=wz, d=false, a=false }
		return false, false
	end
	
	local widthFactor = 0.95 --   = 0.8
	
	local fruitsDetected = false
	local fruitsAll      = true

	if vehicle.aiveFruitAreas == nil then
		vehicle.aiveFruitAreas = {}
	end
	vehicle.aiveFruitAreas[1] = {}
	
	if      vehicle.aiveChain            ~= nil 
			and vehicle.aiveChain.leftActive ~= nil 
			and vehicle.aiveChain.toolCount  ~= nil 
			and vehicle.aiveChain.toolCount  >= 1 
			and vehicle.aiveChain.toolParams ~= nil 
			and vehicle.aiveChain.toolCount  == table.getn( vehicle.aiveChain.toolParams ) then
		for i = 1,vehicle.aiveChain.toolCount do	
			local toolParam = vehicle.aiveChain.toolParams[i]
			local tool      = vehicle.aiveChain.tools[toolParam.i]
			local gotFruits = false
			local gotField  = false
			local back      = math.min( toolParam.zBack - toolParam.zReal, 0 )
			
			if      AIVEGlobals.tm7StopEarly              > 0 
					and vehicle.aiveChain.inField
					and vehicle.aiveChain.isAtEnd
					and ( vehicle.aiveChain.turnMode         == "7" 
						 or ( vehicle.aiveChain.turnMode       == "L"
							and toolParam.width + toolParam.zBack < vehicle.aiveChain.radius ) )
					and toolParam.width                       > 1 
					and toolParam.zBack                       < 0 then
				back = back + toolParam.width
			end
			
			local front     = math.max( back, 0 )

			if      tool.currentLowerState == nil then
				front = front + AIVEGlobals.fruitsAdvance
			elseif  tool.currentLowerState 
					and tool.changeLowerTime   ~= nil 
					and g_currentMission.time - tool.changeLowerTime < 1000 then			
				front = front + AIVEGlobals.upperAdvance
			elseif  tool.currentLowerState  then
				front = front + AIVEGlobals.fruitsAdvance
			elseif  checkLowerAdvance       then
				front = front + AIVEGlobals.lowerAdvance
			else
				front = front + AIVEGlobals.upperAdvance
			end
			
			tool.hasFruits = false
			
			local dx,dz
			if tool.steeringAxleNode == nil then
				dx,_,dz = localDirectionToWorld( vehicle.aiveChain.refNode, 0, 0, 1 )
			elseif tool.invert then
				dx,_,dz = localDirectionToWorld( tool.steeringAxleNode, 0, 0, -1 )
			else
				dx,_,dz = localDirectionToWorld( tool.steeringAxleNode, 0, 0, 1 )
			end

			local ofs, idx
			if vehicle.aiveChain.leftActive	then
				ofs = -toolParam.offset 
				idx = toolParam.nodeLeft 
			else
				ofs = toolParam.offset 
				idx = toolParam.nodeRight
			end
		
			local xw1,y,zw1 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, back )
			local xw2,y,zw2 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, front )
			
			local w = widthFactor * toolParam.width
			if vehicle.aiveChain.leftActive then
				w = -w
			end
			
			local lx1,lz1,lx2,lz2,lx3,lz3,lx4,lz4
			dist = front - back
			repeat 
				xw2 = xw1 + dist * dx
				zw2 = zw1 + dist * dz
				lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( xw1,zw1,xw2,zw2, w, true )
				lx4 = lx3 + lx2 - lx1
				lz4 = lz3 + lz2 - lz1
				
				dist = dist - 0.5
			until dist < 0.5
					or ( vehicle.aiveChain.headland >= 1
					 and ( AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
 						  or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
	 						or AutoSteeringEngine.isChainPointOnField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )
					or ( vehicle.aiveChain.headland < 1
					 and ( AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
					    or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
					    or AutoSteeringEngine.checkField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )

			local lx5 = 0.25 * ( lx1 + lx2 + lx3 + lx4 )
			local lz5 = 0.25 * ( lz1 + lz2 + lz3 + lz4 )
			
			if dist < front - back - 0.6 then
				dist = dist + 0.5
			end
			
			if vehicle.aiveChain.headland < 1 then
				if     AutoSteeringEngine.checkField( vehicle, lx1, lz1 )
						or AutoSteeringEngine.checkField( vehicle, lx2, lz2 )
						or AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
						or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
						or AutoSteeringEngine.checkField( vehicle, lx5, lz5 ) then
					gotField = true
					if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
						gotFruits = true
					end			
				end			
			else
				if     AutoSteeringEngine.isChainPointOnField( vehicle, lx1, lz1 )
						or AutoSteeringEngine.isChainPointOnField( vehicle, lx2, lz2 )
						or AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
						or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
						or AutoSteeringEngine.isChainPointOnField( vehicle, lx5, lz5 ) then
					gotField = true
					if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
						gotFruits = true
					end			
				end			
			end			
			
			table.insert( vehicle.aiveFruitAreas[1], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, gotFruits } )

      if not gotFruits then 
				if tool.ignoreAI then
				-- ignore 
				else
					fruitsAll = false
				end
			end
			
			if gotFruits then
				tool.hasFruits = true
				if     tool.ignoreAI then
				-- ignore 
				else
					fruitsDetected = true				
				end
			elseif tool.targetLowerState and not ( tool.currentLowerState ) and AIVEGlobals.lowerAdvance > 0 then
				-- lower tool in advance
				front = math.max( back, 0 ) + AIVEGlobals.lowerAdvance
				dist  = front - back
				repeat 
					xw2 = xw1 + dist * dx
					zw2 = zw1 + dist * dz
					lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( xw1,zw1,xw2,zw2, w, true )
					lx4 = lx3 + lx2 - lx1
					lz4 = lz3 + lz2 - lz1
					
					dist = dist - 0.5
				until dist < 0.5
						or ( vehicle.aiveChain.headland >= 1
						 and ( AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
								or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
								or AutoSteeringEngine.isChainPointOnField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )
						or ( vehicle.aiveChain.headland < 1
						 and ( AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
								or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
								or AutoSteeringEngine.checkField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )
								
				if vehicle.aiveChain.headland < 1 then
					if     AutoSteeringEngine.checkField( vehicle, lx1, lz1 )
							or AutoSteeringEngine.checkField( vehicle, lx2, lz2 )
							or AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
							or AutoSteeringEngine.checkField( vehicle, lx4, lz4 ) then
						if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
							gotFruits = true
						end			
					end			
				else
					if     AutoSteeringEngine.isChainPointOnField( vehicle, lx1, lz1 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx2, lz2 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx5, lz5 ) then
						if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
							gotFruits = true
						end			
					end			
				end			
				
				table.insert( vehicle.aiveFruitAreas[1], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, gotFruits } )
			end
			
			if      gotFruits then
				AutoSteeringEngine.ensureToolIsLowered( vehicle, true, i )
			elseif  AIVEGlobals.raiseNoFruits > 0
					and not ( gotField )
					and vehicle.aiveChain.inField
					and tool.currentLowerState
					and not ( vehicle.aiveHas.combine )
					and ( tool.isSowingMachine
						 or tool.isCultivator
						 or tool.isSprayer
						 or tool.isMower 
						 or tool.isTedder   
						 or tool.isWindrower ) then
				AutoSteeringEngine.raiseToolNoFruits( vehicle, tool.obj )
			end
		end
	end
	
	if AutoSteeringEngine.isBeforeStartNode( vehicle ) then
		fruitsDetected = false
		fruitsAll      = false
	elseif not fruitsDetected then
		fruitsAll      = false
	end
	
	if AIVEGlobals.useFBB123 > 0 and not ( checkLowerAdvance ) then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		vehicle.aiveChain.fbb1 = { x=wx, z=wz, d=fruitsDetected, a=fruitsAll }
	end
	
	return fruitsDetected, fruitsAll
end

------------------------------------------------------------------------
-- hasNoFruitsAtAll
------------------------------------------------------------------------
function AutoSteeringEngine.hasNoFruitsAtAll( vehicle )

	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return true end
		
	if AIVEGlobals.useFBB123 > 0 then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		local fbbd = AIVEGlobals.FBB123disq1
		if vehicle.aiveChain.inField then
			fbbd = AIVEGlobals.FBB123disq2
		end
		if      vehicle.aiveChain.fbb4   ~= nil 
				and vehicle.aiveChain.fbb4.x ~= nil 
				and vehicle.aiveChain.fbb4.z ~= nil 
				and AIVEUtils.vector2LengthSq( vehicle.aiveChain.fbb4.x - wx, vehicle.aiveChain.fbb4.z - wz ) < fbbd then
			return vehicle.aiveChain.fbb4.d 
		end
	end
			
	if     AutoSteeringEngine.hasCollision( vehicle )
			or AutoSteeringEngine.isBeforeStartNode( vehicle ) then

		vehicle.aiveChain.fbb4 = { x=wx, z=wz, d=true }
		return true
	end
	
	if vehicle.aiveFruitAreas == nil then
		vehicle.aiveFruitAreas = {}
	end
	vehicle.aiveFruitAreas[4] = {}
	
	local noFruitsDetected = false 
	
	if      vehicle.aiveChain            ~= nil 
			and vehicle.aiveChain.leftActive ~= nil 
			and vehicle.aiveChain.toolCount  ~= nil 
			and vehicle.aiveChain.toolCount  >= 1 
			and vehicle.aiveChain.toolParams ~= nil 
			and vehicle.aiveChain.toolCount  == table.getn( vehicle.aiveChain.toolParams ) then
		for i = 1,vehicle.aiveChain.toolCount do	
			local toolParam = vehicle.aiveChain.toolParams[i]
			local tool      = vehicle.aiveChain.tools[toolParam.i]
			if not ( tool.ignoreAI ) then 
				local gotFruits = false
				local gotField  = false
				local back      = AIVEGlobals.ignoreDist	
				local front     = math.max( back, 0 ) + AIVEGlobals.fruitsInFront

				local dx,dz
				if tool.steeringAxleNode == nil then
					dx,_,dz = localDirectionToWorld( vehicle.aiveChain.refNode, 0, 0, 1 )
				elseif tool.invert then
					dx,_,dz = localDirectionToWorld( tool.steeringAxleNode, 0, 0, -1 )
				else
					dx,_,dz = localDirectionToWorld( tool.steeringAxleNode, 0, 0, 1 )
				end

				local ofs, idx
				if vehicle.aiveChain.leftActive	then
					ofs = -3 
					idx = toolParam.nodeLeft 
				else
					ofs = 3 
					idx = toolParam.nodeRight
				end
			
				local xw1,y,zw1 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, back )
				local xw2,y,zw2 = AutoSteeringEngine.toolLocalToWorld( vehicle, toolParam.i, idx, ofs, front )
				
				local w = 3 + toolParam.width + 3
				if vehicle.aiveChain.leftActive then
					w = -w
				end
				
				local lx1,lz1,lx2,lz2,lx3,lz3,lx4,lz4
				dist = front - back
				repeat 
					xw2 = xw1 + dist * dx
					zw2 = zw1 + dist * dz
					lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( xw1,zw1,xw2,zw2, w, true )
					lx4 = lx3 + lx2 - lx1
					lz4 = lz3 + lz2 - lz1
					
					dist = dist - 0.5
				until dist < 0.5
						or ( vehicle.aiveChain.headland >= 1
						 and ( AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
								or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
								or AutoSteeringEngine.isChainPointOnField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )
						or ( vehicle.aiveChain.headland < 1
						 and ( AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
								or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
								or AutoSteeringEngine.checkField( vehicle, 0.5 * ( lx3 + lx4), 0.5 * ( lz3 + lz4 ) ) ) )

				local lx5 = 0.25 * ( lx1 + lx2 + lx3 + lx4 )
				local lz5 = 0.25 * ( lz1 + lz2 + lz3 + lz4 )
				
				if dist < front - back - 0.6 then
					dist = dist + 0.5
				end
				
				if vehicle.aiveChain.headland < 1 then
					if     AutoSteeringEngine.checkField( vehicle, lx1, lz1 )
							or AutoSteeringEngine.checkField( vehicle, lx2, lz2 )
							or AutoSteeringEngine.checkField( vehicle, lx3, lz3 )
							or AutoSteeringEngine.checkField( vehicle, lx4, lz4 )
							or AutoSteeringEngine.checkField( vehicle, lx5, lz5 ) then
						gotField = true
						if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
							gotFruits = true
						end			
					end			
				else
					if     AutoSteeringEngine.isChainPointOnField( vehicle, lx1, lz1 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx2, lz2 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx3, lz3 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx4, lz4 )
							or AutoSteeringEngine.isChainPointOnField( vehicle, lx5, lz5 ) then
						gotField = true
						if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, w, toolParam.i, true ) > 0 then
							gotFruits = true
						end			
					end			
				end			
				
				table.insert( vehicle.aiveFruitAreas[4], { lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4, gotFruits } )

				if gotFruits then
					noFruitsDetected = false 				
					break 
				elseif gotField then 
					noFruitsDetected = true 
				end 
			end 
		end
	end
	
	if AIVEGlobals.useFBB123 > 0 then
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		vehicle.aiveChain.fbb4 = { x=wx, z=wz, d=noFruitsDetected }
	end
	
	return noFruitsDetected
end

------------------------------------------------------------------------
-- hasFruitsSimple
------------------------------------------------------------------------
function AutoSteeringEngine.hasFruitsSimple( vehicle, xw1, zw1, xw2, zw2, off )
	for i=1,vehicle.aiveChain.toolCount do
		if AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, off, i, true ) > 0 then
			return true
		end
	end
	return false
end

------------------------------------------------------------------------
-- noTurnAtEnd
------------------------------------------------------------------------
function AutoSteeringEngine.noTurnAtEnd( vehicle )

	--local noTurn = false
	--if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
	--	for i=1,vehicle.aiveChain.toolCount do
  --    if vehicle.aiveChain.tools[i].isPlow or vehicle.aiveChain.tools[i].isSprayer or vehicle.aiveChain.tools[i].specialType == "Packomat" or vehicle.aiveChain.tools[i].doubleJoint
	--			then noTurn = true end
	--	end
	--end
	--
	--return noTurn
	
	if      ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 )
			and ( vehicle.aiveHas.plow or vehicle.aiveHas.sprayer or vehicle.aiveHas.doubleJoint ) then 
		return true 
	end
	return false 
end

------------------------------------------------------------------------
-- getNoReverseIndex
------------------------------------------------------------------------
function AutoSteeringEngine.getNoReverseIndex( vehicle )
	if vehicle.aiveChain == nil or vehicle.aiveChain.noReverseIndex == nil then
		return 0
	end
	return vehicle.aiveChain.noReverseIndex
end

------------------------------------------------------------------------
-- getTurnMode
------------------------------------------------------------------------
function AutoSteeringEngine.getTurnMode( vehicle )
	local revUTurn   = true
	local revStraight= true
	local smallUTurn = true
	local zb         = nil
	local noHire     = false
	
	if AutoSteeringEngine.hasArticulatedAxis( vehicle, false, true ) then 
		revUTurn   = false 
		smallUTurn = false
	end 
	
	if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		for i=1,vehicle.aiveChain.toolCount do
--		local _,_,z = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, vehicle.aiveChain.tools[i].refNode ) 
--		z = z + 0.5 * ( vehicle.aiveChain.tools[i].zb + vehicle.aiveChain.tools[i].z )
--		--print(tostring(zb).." "..tostring(z))
--		if      zb == nil then
--			zb = z
--		elseif  math.abs( z - zb ) > 2
--		    and ( zb > 0 and z < 0
--		       or zb < 0 and z > 0 ) then
--			smallUTurn = false
--		end
			
			if vehicle.aiveChain.tools[i].noRevStraight then
				revStraight= false
			end
			if      vehicle.aiveChain.tools[i].aiForceTurnNoBackward 
					and vehicle.aiveChain.tools[i].steeringAxleNode ~= nil then
				revUTurn   = false
				smallUTurn = false

			--if AutoSteeringEngine.hasArticulatedAxis( vehicle ) and AIVEGlobals.devFeatures <=0 then
			--	revStraight= false 
			--end
				
--			elseif  vehicle.aiveChain.tools[i].isSprayer then
--				revUTurn   = false
--				smallUTurn = false
--				break
--		elseif  vehicle.aiveChain.tools[i].isCombine 
--				or  vehicle.aiveChain.tools[i].isMower then
--			smallUTurn = false
			end			
		end
	end
	
	if not revStraight then
		revUTurn   = false
		smallUTurn = false
	end
	
	return smallUTurn, revUTurn, revStraight, noHire
end
		

------------------------------------------------------------------------
-- getToolAngle
------------------------------------------------------------------------
function AutoSteeringEngine.getToolAngle( vehicle )

  if not AutoSteeringEngine.hasTools( vehicle ) then
		return 0
	end

	local maxAngle = 0
	local refNode  = vehicle.aiveChain.refNode
	
	for i,tool in pairs( vehicle.aiveChain.tools ) do
		local toolAngle = 0
		if tool.aiForceTurnNoBackward then
			if tool.checkZRotation then
				local zAngle = AutoSteeringEngine.getRelativeZRotation( refNode, tool.steeringAxleNode )
				if math.abs( zAngle ) > 0.025 then
					local rx2, ry2, rz2 = getRotation( tool.steeringAxleNode )
					setRotation( tool.steeringAxleNode, rx2, ry2, rz2 -zAngle )
				end
			end
			
			toolAngle = AutoSteeringEngine.getRelativeYRotation( refNode, tool.steeringAxleNode )	
			
			if tool.offsetZRotation ~= nil then
				toolAngle = toolAngle + tool.offsetZRotation
			end
			
			if tool.invert then
				if toolAngle < 0 then
					toolAngle = toolAngle + math.pi
				else
					toolAngle = toolAngle - math.pi
				end
			end
		end
		if math.abs( maxAngle ) < math.abs( toolAngle ) then
			maxAngle = toolAngle
		end
	end
	
	return maxAngle
end

------------------------------------------------------------------------
-- getAngleFactor
------------------------------------------------------------------------
function AutoSteeringEngine.getAngleFactor( maxLooking )
	if AIVEGlobals.fixAngleStep > 0 or maxLooking == nil or maxLooking >= AIVEGlobals.maxLooking then
		return 1
	end
	return AIVEUtils.clamp( AIVEUtils.getNoNil( maxLooking, AIVEGlobals.maxLooking ) / AIVEGlobals.maxLooking, 0.1, 1 )
end

------------------------------------------------------------------------
-- getAngleStep
------------------------------------------------------------------------
function AutoSteeringEngine.getAngleStep( vehicle, j, af )
	local f = AIVEGlobals.angleStep + vehicle.aiveChain.nodes[j].length * AIVEGlobals.angleStepInc
	local d = vehicle.aiveChain.nodes[j].distance * AIVEGlobals.angleStepDec
	if d > 0.9 * f then
		f = 0.1 * f
	else
		f = f - d
	end
	f = math.min( f, AIVEGlobals.angleStepMax )
	return f * af
end

------------------------------------------------------------------------
-- isSetAngleZero
------------------------------------------------------------------------
function AutoSteeringEngine.isSetAngleZero( vehicle )
	if AutoSteeringEngine.hasArticulatedAxis( vehicle, true ) then 
		return false 
	end 
	if AIVEGlobals.zeroAngle > 0 then
		return true
	end
	if not ( vehicle.aiveChain.inField ) then
		return true
	end
	return false
end

------------------------------------------------------------------------
-- setSteeringAngle
------------------------------------------------------------------------
function AutoSteeringEngine.setSteeringAngle( vehicle, angle )
	if AutoSteeringEngine.isSetAngleZero( vehicle ) then
		vehicle.aiveChain.currentSteeringAngle = 0
	elseif vehicle.aiveChain.currentSteeringAngle == nil or math.abs( vehicle.aiveChain.currentSteeringAngle - angle ) > 1E-3 then
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.initial )
		vehicle.aiveChain.currentSteeringAngle = angle
	end 
	if vehicle.aiveChain.minAngle == nil or vehicle.aiveChain.maxAngle == nil then
		vehicle.aiveChain.currentSteeringAngle = angle
	else
		vehicle.aiveChain.currentSteeringAngle = math.min( math.max( angle, vehicle.aiveChain.minAngle ), vehicle.aiveChain.maxAngle )
	end
end

------------------------------------------------------------------------
-- currentSteeringAngle
------------------------------------------------------------------------
function AutoSteeringEngine.currentSteeringAngle( vehicle, isInverted )

	if vehicle.aiveChain == nil then return end

	local steeringAngle = 0		

	if      AutoSteeringEngine.hasArticulatedAxis( vehicle ) then
		steeringAngle = 0.5 * math.min( math.max( -vehicle.rotatedTime * vehicle.spec_articulatedAxis.rotMax, vehicle.spec_articulatedAxis.rotMin ), vehicle.spec_articulatedAxis.rotMax )
	else
		for _,wheel in pairs(vehicle.spec_wheels.wheels) do
			if math.abs(wheel.rotSpeed) > 1E-3 then
				if math.abs( wheel.steeringAngle ) > math.abs( steeringAngle ) then
					if wheel.rotSpeed > 0 then
						steeringAngle = wheel.steeringAngle
					else
						steeringAngle = -wheel.steeringAngle
					end
				end
			end
		end
	end	
	
	vehicle.aiveChain.realSteeringAngle = steeringAngle 
		
	if AutoSteeringEngine.isSetAngleZero( vehicle ) then
		AutoSteeringEngine.setSteeringAngle( vehicle, 0 )
	else
		AutoSteeringEngine.setSteeringAngle( vehicle, steeringAngle )
	end
	
	return steeringAngle
end

------------------------------------------------------------------------
-- steer
------------------------------------------------------------------------
function AutoSteeringEngine.steer( vehicle, ... )
	vehicle.aiveSteerParameteters = { ... }
	AutoSteeringEngine.steerDirect( vehicle, ... )
end
function AutoSteeringEngine.steerContinued( vehicle )
	if vehicle.aiveSteerParameteters ~= nil then
		AutoSteeringEngine.steerDirect( vehicle, unpack( vehicle.aiveSteerParameteters ) )
	end
end
function AutoSteeringEngine.steerDirect( vehicle, dt, angle, aiSteeringSpeed, directSteer )
-- precondition: vehicle.rotatedTime is filled from last steering

	if     angle == 0 then
		targetRotTime = 0
	elseif angle  > 0 then
		targetRotTime = vehicle.maxRotTime * math.min( angle / vehicle.aiveChain.maxSteering, 1)
	else
		targetRotTime = vehicle.minRotTime * math.min(-angle / vehicle.aiveChain.maxSteering, 1)
	end
	
	local aiDirectSteering = 1
	if not AutoSteeringEngine.hasArticulatedAxis( vehicle ) then
		if directSteer then
			aiDirectSteering = AIVEGlobals.aiSteeringD
		else
			aiDirectSteering = AIVEGlobals.aiSteering
		end
	else
		if directSteer then
			aiDirectSteering = AIVEGlobals.artSteeringD
		else
			aiDirectSteering = AIVEGlobals.artSteering
		end
		aiDirectSteering   = aiDirectSteering * math.max( math.min( vehicle.lastSpeed * 250, 1 ), 0.1 )			
	end
	
	local diff = dt * vehicle.spec_aiVehicle.aiSteeringSpeed
	if aiDirectSteering <= 0 then
		diff = math.min( diff+diff+diff+diff+diff+diff, math.abs( math.min( 1, -aiDirectSteering ) * ( targetRotTime - vehicle.rotatedTime ) ) )
	else
		diff = aiDirectSteering * diff
	end
	
	if targetRotTime > vehicle.rotatedTime then
		vehicle.rotatedTime = math.min(vehicle.rotatedTime + diff, targetRotTime)
	else
		vehicle.rotatedTime = math.max(vehicle.rotatedTime - diff, targetRotTime)
	end
	
	if AutoSteeringEngine.isSetAngleZero( vehicle ) then
		vehicle.aiveChain.currentSteeringAngle = 0
	elseif vehicle.aiveChain.currentSteeringAngle == nil or math.abs( vehicle.aiveChain.currentSteeringAngle - angle ) > 1E-3 then
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.initial )
		vehicle.aiveChain.currentSteeringAngle = angle
	end 
end

------------------------------------------------------------------------
-- getWorldTargetFromSteeringAngle
------------------------------------------------------------------------
function AutoSteeringEngine.getWorldTargetFromSteeringAngle( vehicle, angle, moveForwards )

	if     vehicle.aiveChain              == nil
			or vehicle.aiveChain.invWheelBase == nil
			or vehicle.aiveChain.maxSteering  == nil
			or vehicle.aiveChain.refNode      == nil then
		return 
	end
	
	local lx, lz = 0, 1
	
	local refNode = vehicle.aiveChain.refNode -- vehicle:getAIVehicleDirectionNode()
	
	if math.abs( angle ) > 0.001 then 
		local invR = vehicle.aiveChain.invWheelBase * math.tan( AIVEUtils.clamp( angle, -vehicle.aiveChain.maxSteering, vehicle.aiveChain.maxSteering ) )	
		local l    = math.min( 5, vehicle.aiveChain.radius ) -- math.max( 1, 0.2 * vehicle.aiveChain.radius )
		local rot  = 2 * math.asin( invR * 0.5 * l )
		lz = l * math.cos( rot )
		lx = l * math.sin( rot )
	end 
	
	tX,_,tZ = localToWorld( refNode, lx, 0, lz )
	
	local a2 = AutoSteeringEngine.getSteeringAngleFromWorldTarget( vehicle, tX, nil, tZ )
	
	return tX, tZ
end

------------------------------------------------------------------------
-- getSteeringAngleFromWorldTarget
------------------------------------------------------------------------
function AutoSteeringEngine.getSteeringAngleFromWorldTarget( vehicle, tX, tY, tZ )

	if     vehicle.aiveChain              == nil
			or vehicle.aiveChain.wheelBase    == nil
			or vehicle.aiveChain.refNode      == nil then
		return 0
	end

	local y
	if tY == nil then
		y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tX, 1, tZ)
	else
		y = tY
	end
	
	local refNode = vehicle.aiveChain.refNode -- vehicle:getAIVehicleDirectionNode()
		
	local lx,_,lz = worldToLocal( refNode, tX, y, tZ )
	local l       = AIVEUtils.vector2Length( lx, lz )
	
	if l < 1e-3 then 
		return 0
	end
	
	local rot  = math.atan2( lx, lz )
	local invR = 2 * math.sin( 0.5*rot ) / l
	
	return math.atan( vehicle.aiveChain.wheelBase * invR )
end

------------------------------------------------------------------------
-- drive
------------------------------------------------------------------------
function AutoSteeringEngine.drive( vehicle, ... )
	vehicle.aiveDriveParameteters = { ... }
	AutoSteeringEngine.driveDirect( vehicle, ... )
end
function AutoSteeringEngine.driveContinued( vehicle )
	if vehicle.aiveDriveParameteters ~= nil then
		AutoSteeringEngine.driveDirect( vehicle, unpack( vehicle.aiveDriveParameteters ) )
	end
end
function AutoSteeringEngine.driveDirect( vehicle, dt, acceleration, allowedToDrive, moveForwards, speedLevel, useReduceSpeed, slowMaxRpmFactor )
	
  if vehicle.firstTimeRun then
		maxSpeed = AutoSteeringEngine.getMaxSpeed( vehicle, dt, acceleration, allowedToDrive, moveForwards, speedLevel, useReduceSpeed, slowMaxRpmFactor )
		if maxSpeed <= 0 then
			allowedToDrive = false 
			maxSpeed       = 2
		end
		vehicle.motor:setSpeedLimit( maxSpeed )
		
		WheelsUtil.updateWheelsPhysics(vehicle, dt, vehicle.lastSpeed, vehicle.acLastAcc, not allowedToDrive, vehicle.requiredDriveMode)
  end
end

------------------------------------------------------------------------
-- getMaxSpeed
------------------------------------------------------------------------
function AutoSteeringEngine.getMaxSpeed( vehicle, dt, acceleration, allowedToDrive, moveForwards, speedLevel, useReduceSpeed, slowMaxRpmFactor )

  local acc = acceleration
	local disableChangingDirection = false
	local doHandBrake = false

	local wantedSpeed = AutoSteeringEngine.getWantedSpeed( vehicle, speedLevel )
  if useReduceSpeed then
    acc           = acc * slowMaxRpmFactor
		if speedLevel == 2 or speedLevel == 4 then
			wantedSpeed = wantedSpeed * slowMaxRpmFactor
		else 
			w2          = AutoSteeringEngine.getWantedSpeed( vehicle, 2 )
			wantedSpeed = math.min( wantedSpeed, w2 * slowMaxRpmFactor )
		end
  end
	
	if vehicle.aiveMaxCollisionSpeed ~= nil then
		wantedSpeed = math.max( 0, math.min( wantedSpeed, vehicle.aiveMaxCollisionSpeed - 0.2 ) )
	end
	
  if not moveForwards then
    acc = -acc
  end
	
  if not allowedToDrive then
    acc = 0
		wantedSpeed = 0
	end
	
--print("dt: "..tostring(dt)..", wantedSpeed: "..tostring(wantedSpeed).."("..tostring(speedLevel).."), acc:"..tostring(acc).."("..tostring(allowedToDrive)..")")
			
	if vehicle.acLastAcc == nil then
		vehicle.acLastAcc = 0
	end
	if vehicle.acLastWantedSpeed == nil then
		vehicle.acLastWantedSpeed = math.max( 2, vehicle.lastSpeed * 3600 )
	end
		
	if     math.abs( acc ) < 1E-4
			or ( acc > 0 and vehicle.acLastAcc < 0 )
			or ( acc < 0 and vehicle.acLastAcc > 0 ) then
		vehicle.acLastAcc = 0
		wantedSpeed       = 0
		vehicle.acLastWantedSpeed = 0
	else
		vehicle.acLastAcc = vehicle.acLastAcc + AIVEUtils.clamp( acc - vehicle.acLastAcc, - dt * 0.0005, dt * 0.0005)
	end
	
	local curSpeed = math.abs( vehicle.lastSpeed * 3600 )
			
	if     wantedSpeed < 1 then		
		vehicle.acLastWantedSpeed = 2
		return 0
	elseif wantedSpeed < 6.5 and wantedSpeed < curSpeed then
		vehicle.acLastWantedSpeed = wantedSpeed
	elseif math.abs( wantedSpeed - curSpeed ) < 0.5 then
		vehicle.acLastWantedSpeed = wantedSpeed
	else
		if wantedSpeed < curSpeed then
			vehicle.acLastWantedSpeed = math.min( vehicle.acLastWantedSpeed, curSpeed )
		else
			vehicle.acLastWantedSpeed = math.max( vehicle.acLastWantedSpeed, curSpeed )
		end
		if vehicle.acLastWantedSpeed < 2 then
			vehicle.acLastWantedSpeed = 2
		end
	
		vehicle.acLastWantedSpeed = vehicle.acLastWantedSpeed + AIVEUtils.clamp( wantedSpeed - vehicle.acLastWantedSpeed, -0.001 * dt, 0.001 * dt )
	end
	
	return vehicle.acLastWantedSpeed
 end

------------------------------------------------------------------------
-- drawMarker
------------------------------------------------------------------------
function AutoSteeringEngine.drawMarker( vehicle )

	if not vehicle.isServer then return end
	
	if vehicle.debugRendering then
		AutoSteeringEngine.displayDebugInfo( vehicle )
	end

  vehicle.aiveDirection = { getWorldRotation( vehicle.aiveChain.refNode ) }

	if vehicle.aiveChain.headland > 0 and vehicle.aiveChain.width ~= nil then		
		AutoSteeringEngine.rotateHeadlandNode( vehicle )
		local w = math.max( 1, 0.25 * vehicle.aiveChain.width )--+ 0.13 * vehicle.aiveChain.headland )		
		local x1,y1,z1 = localToWorld( vehicle.aiveChain.headlandNode, -2 * w, 1, vehicle.aiveChain.headland )
		local x2,y2,z2 = localToWorld( vehicle.aiveChain.headlandNode,  2 * w, 1, vehicle.aiveChain.headland )
		y1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x1, 1, z1) + 1
		y2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x2, 1, z2) + 1
		AIVEDrawDebugLine( vehicle, x1,y1,z1, 1,1,0, x2,y2,z2, 1,1,0 )
	end
	--if vehicle.aiveChain.collisionDistPoints ~= nil and table.getn( vehicle.aiveChain.collisionDistPoints ) > 0 then
	--	for _,p in pairs(vehicle.aiveChain.collisionDistPoints) do
	--		local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p.x, 1, p.z)
	--		AIVEDrawDebugLine( vehicle,  p.x,y,p.z, 1,0,0, p.x,y+2,p.z, 1,0,0 )
	--		AIVEDrawDebugPoint( vehicle, p.x,y+2,p.z, 1, 1, 1, 1 )
	--	end
	--end
	
--if vehicle.aiveChain.trace ~= nil and vehicle.aiveChain.trace.foundNext then
--	local lx1,lz1,lx2,lz2,lx3,lz3,b,t,wu = unpack( vehicle.aiveChain.trace.fn )
--	local lx4 = lx2 + lx3 - lx1
--	local lz4 = lz2 + lz3 - lz1
--	local ly1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx1, 1, lz1) + 0.25
--	local ly2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx2, 1, lz2) + 0.25
--	local ly3 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx3, 1, lz3) + 0.25
--	local ly4 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx4, 1, lz4) + 0.25
--	local c = { 0.2, 0.2, 0.2 }
--			
--	if b <= 0 then
--		c = { 0, 1, 0 }
--	elseif b >= t then
--		c = { 1, 0.5, 0.5 }
--	else
--		c = { 1, b/(t+t), b/(t+t) }
--	end
--	
--	AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c[1],c[2],c[3],lx3,ly3,lz3,c[1],c[2],c[3])
--	AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c[1],c[2],c[3],lx2,ly2,lz2,c[1],c[2],c[3])
--	AIVEDrawDebugLine( vehicle,lx4,ly4,lz4,c[1],c[2],c[3],lx3,ly3,lz3,c[1],c[2],c[3])
--	AIVEDrawDebugLine( vehicle,lx4,ly4,lz4,c[1],c[2],c[3],lx2,ly2,lz2,c[1],c[2],c[3])
--
--	local tx = 0.25*( lx1 + lx2 + lx3 + lx4 )
--	local tz = 0.25*( lz1 + lz2 + lz3 + lz4 )	
--	local ty = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tx, 1, tz)
--	local tt = string.format("(%d, %d)",b,t)
--
--	local sx,sy,sz = project(tx,ty,tz)
--	setTextColor(c[1],c[2],c[3],1) 
--	if 1 > sz and sz > 0 then 
--		renderText(sx, sy, getCorrectTextSize(0.02) * sz, tt )
--	end 
--end
	
	
	if vehicle.acIamDetecting and vehicle.aiveChain.toolParams ~= nil and table.getn( vehicle.aiveChain.toolParams ) > 0 then
		local px,py,pz
		local off = 1
		if not vehicle.aiveChain.leftActive then
			off = -off
		end
					
		for j,tp in pairs(vehicle.aiveChain.toolParams) do		
			if not ( tp.skip ) then
				local c = { 0.5, 0.5, 0.5 }
				
				if      vehicle.aiveChain.inField
						and vehicle.aiveChain.lastBest ~= nil then
					if     vehicle.aiveChain.lastBest.border > AIVEGlobals.ignoreBorder then
						c = { 1, 0, 0 }
					elseif vehicle.aiveChain.lastBest.border > 0 then
						c = { 0.7, 0.7, 0 }
					elseif vehicle.aiveChain.lastBest.detected then
						c = { 0, 1, 0 }
					end
				end
				
				local x1,y1,z1 = AutoSteeringEngine.getChainPoint( vehicle, 1, tp )
				y1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x1, y1, z1 )

				AIVEDrawDebugLine( vehicle, x1,y1,z1, c[1],c[2],c[3], x1,y1+1.2,z1, c[1],c[2],c[3] )
				AIVEDrawDebugPoint(vehicle, x1,y1+1.2,z1	, 1, 1, 1, 1 )
				
				for i=2,vehicle.aiveChain.chainMax+1 do
					if vehicle.aiveChain.nodes[i].distance > 10 then
						break
					end
					local x2,y2,z2 = AutoSteeringEngine.getChainPoint( vehicle, i, tp )
					y2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x2, y2, z2 )
					AIVEDrawDebugLine( vehicle,  x1,y1+0.1,z1, c[1],c[2],c[3], x2,y2+0.1,z2, c[1],c[2],c[3] )
					AIVEDrawDebugLine( vehicle,  x1,y1+0.2,z1, c[1],c[2],c[3], x2,y2+0.2,z2, c[1],c[2],c[3] )
					AIVEDrawDebugLine( vehicle,  x1,y1+0.3,z1, c[1],c[2],c[3], x2,y2+0.3,z2, c[1],c[2],c[3] )
					x1 = x2
					y1 = y2
					z1 = z2
				end
			end
		end
	end	
end
	
------------------------------------------------------------------------
-- drawLines
------------------------------------------------------------------------
function AutoSteeringEngine.drawLines( vehicle )

 	if not vehicle.isServer then return end
	
  vehicle.aiveDirection = { getWorldRotation( vehicle.aiveChain.refNode ) }

	if vehicle.debugRendering then
		AutoSteeringEngine.displayDebugInfo( vehicle )
	end

	local x,_,z = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
	AIVEDrawDebugLine( vehicle,  x, y, z,0,1,0, x, y+4, z,0,1,0)
	AIVEDrawDebugPoint( vehicle, x, y+4, z	, 1, 1, 1, 1 )
	
	if vehicle.aiveChain.lastWorldTarget ~= nil then
		local x1,y1,z1 = unpack( vehicle.aiveChain.lastWorldTarget )
		AIVEDrawDebugLine( vehicle,  x1, y1+4, z1,0,1,0, x, y+4, z,0,1,0)
	end
	
	if vehicle.aiveChain.rootNode ~= nil then
		local x1,y1,z1 = localDirectionToWorld( vehicle.aiveChain.rootNode, 0, 0, 4 )
		x1 = x+x1
		y1 = y+y1
		z1 = z+z1
		AIVEDrawDebugLine( vehicle,  x1, y1+4.5, z1,1,1,1, x, y+4.5, z,1,1,1)
	end
	
	if vehicle.aiveChain.respectStartNode then
		x,_,z = getWorldTranslation( vehicle.aiveChain.startNode )
		y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
		AIVEDrawDebugLine( vehicle,  x, y, z,0,1,0, x, y+4, z,0,1,0)
		AIVEDrawDebugPoint(vehicle, x, y+4, z	, 1, 1, 1, 1 )
		x1,_,z1 = localToWorld( vehicle.aiveChain.startNode ,0,0,2 )
		AIVEDrawDebugLine( vehicle,  x1, y+3, z1,0,1,0, x, y+3, z,0,1,0)
	end
	
	if  vehicle.aiveChain.trace   ~= nil then
			
		if vehicle.aiveChain.trace.itv1 ~= nil then
			local lx1,lz1,lx2,lz2,lx3,lz3 = unpack( vehicle.aiveChain.trace.itv1 )
			AIVEDrawDebugLine( vehicle,lx1,y+0.5,lz1,0,1,0,lx3,y+0.5,lz3,0,1,0)
			AIVEDrawDebugLine( vehicle,lx1,y+0.5,lz1,0,1,0,lx2,y+0.5,lz2,0,1,0)
		--local lx4 = lx3 + lx2 - lx1
		--local lz4 = lz3 + lz2 - lz1
		--AIVEDrawDebugLine( vehicle,lx4,y+0.5,lz4,0,1,1,lx2,y+0.5,lz2,0,1,1)
		--AIVEDrawDebugLine( vehicle,lx4,y+0.5,lz4,0,1,1,lx3,y+0.5,lz3,0,1,1)
		end
		
		if vehicle.aiveChain.trace.itv2 ~= nil then
			local lx1,lz1,lx2,lz2,lx3,lz3 = unpack( vehicle.aiveChain.trace.itv2 )
			AIVEDrawDebugLine( vehicle,lx1,y+0.5,lz1,0,0,1,lx3,y+0.5,lz3,0,0,1)
			AIVEDrawDebugLine( vehicle,lx1,y+0.5,lz1,0,0,1,lx2,y+0.5,lz2,0,0,1)
		--local lx4 = lx3 + lx2 - lx1
		--local lz4 = lz3 + lz2 - lz1
		--AIVEDrawDebugLine( vehicle,lx4,y+0.5,lz4,0,1,1,lx2,y+0.5,lz2,0,1,1)
		--AIVEDrawDebugLine( vehicle,lx4,y+0.5,lz4,0,1,1,lx3,y+0.5,lz3,0,1,1)
		end	
	end
	
	if      vehicle.aiveChain.trace    ~= nil 
			and vehicle.aiveChain.trace.cx ~= nil 
			and vehicle.aiveChain.trace.cz ~= nil then
		xw1 = vehicle.aiveChain.trace.cx
		zw1 = vehicle.aiveChain.trace.cz
		AIVEDrawDebugLine( vehicle, xw1, y, zw1, 1,0,1, xw1, y+2, zw1 ,1,1,1)
		AIVEDrawDebugPoint(vehicle, xw1, y+2, zw1 , 0, 1, 0, 1 )		
	end
	if      vehicle.aiveChain.trace    ~= nil 
			and vehicle.aiveChain.trace.ux ~= nil 
			and vehicle.aiveChain.trace.uz ~= nil then
		xw1 = vehicle.aiveChain.trace.ux
		zw1 = vehicle.aiveChain.trace.uz
		AIVEDrawDebugLine( vehicle, xw1, y, zw1, 1,0,1, xw1, y+2, zw1 ,1,1,1)
		AIVEDrawDebugPoint(vehicle, xw1, y+2, zw1 , 0, 0, 1, 1 )		
	end 
	if      vehicle.aiveChain.trace    ~= nil 
			and vehicle.aiveChain.trace.ox ~= nil 
			and vehicle.aiveChain.trace.oz ~= nil then	
		xw1 = vehicle.aiveChain.trace.ox
		zw1 = vehicle.aiveChain.trace.oz
		AIVEDrawDebugLine( vehicle, xw1, y, zw1, 1,0,1, xw1, y+2, zw1 ,1,1,1)
		AIVEDrawDebugPoint(vehicle, xw1, y+2, zw1 , 0, 0, 1, 1 )		
	end		
	
	
	
	if vehicle.aivePoints ~= nil then
		local x,y,z
		for _,p in pairs(vehicle.aivePoints) do
			x = p.wx
			z = p.wz
			y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
			AIVEDrawDebugLine( vehicle, x, y,   z, 1,1,1, x, y+2, z ,1,1,1)
			AIVEDrawDebugPoint(vehicle, x, y+2, z, 1,1,1, 1 )		
			
			if p.tool ~= nil then
				for _,t in pairs(p.tool) do
					x = t.wx
					z = t.wz
					y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
					AIVEDrawDebugLine( vehicle,  x, y,   z, 0,1,0, x, y+2, z ,0,1,0)
					AIVEDrawDebugPoint( vehicle, x, y+2, z, 0,1,0, 1 )		
				end
			end
		end
	end
	
	
		
	if vehicle.aiveChain.headland > 0 then		
		AutoSteeringEngine.rotateHeadlandNode( vehicle )
		local w = math.max( 1, 0.25 * vehicle.aiveChain.width )--+ 0.13 * vehicle.aiveChain.headland )
		for j=-2,2 do
			local d = vehicle.aiveChain.headland + 1
			local x,_,z = localToWorld( vehicle.aiveChain.headlandNode, j * w, 1, d )
			local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z) + 1
			if AutoSteeringEngine.checkField( vehicle, x,z) then
				AIVEDrawDebugPoint( vehicle, x,y,z	, 0, 1, 0, 1 )
			else
				AIVEDrawDebugPoint( vehicle, x,y,z	, 1, 0, 0, 1 )
			end
			if vehicle.aiveChain.respectStartNode then
				d = - vehicle.aiveChain.headland - 1
				x,_,z = localToWorld( vehicle.aiveChain.headlandNode, j * w, 1, d )
				y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z) + 1
				if AutoSteeringEngine.checkField( vehicle, x,z) then
					AIVEDrawDebugPoint( vehicle, x,y,z	, 0, 1, 0, 1 )
				else
					AIVEDrawDebugPoint( vehicle, x,y,z	, 1, 0, 0, 1 )
				end
			end
		end
	end

	local indexMax = AIVEUtils.getNoNil( vehicle.aiveChain.lastIndexMax, vehicle.aiveChain.chainMax )
		
	if vehicle.aiveChain.toolParams ~= nil and table.getn( vehicle.aiveChain.toolParams ) > 0 then
		local px,py,pz
		local off = 1
		if not vehicle.aiveChain.leftActive then
			off = -off
		end
					
	--for i=1,indexMax+1 do
	--	vehicle.aiveChain.nodes[i].status = AIVEStatus.rotation
	--end
			
		AutoSteeringEngine.getAllChainBorders( vehicle, AIVEGlobals.chainStart, indexMax )
					
		for j=1,table.getn(vehicle.aiveChain.toolParams) do
			local tp = vehicle.aiveChain.toolParams[j]
			if      vehicle.aiveChain.tools ~= nil
					and not ( tp.skip )
					and tp.i ~= nil 
					and vehicle.aiveChain.tools[tp.i] ~= nil 
					and vehicle.aiveChain.tools[tp.i].marker ~= nil then			
				for _,m in pairs(vehicle.aiveChain.tools[tp.i].marker) do
					local xl,_,zl = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, m )
					if AIVEUtils.vector2LengthSq( xl-tp.x, zl-tp.z ) > 0.01 then
						local x,_,z = getWorldTranslation( m )
						local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
						AIVEDrawDebugLine( vehicle,  x,y,z, 0,0,1, x,y+2,z, 0,0,1 )
						AIVEDrawDebugPoint( vehicle, x,y+2,z, 1, 1, 1, 1 )
					end
				end
			
				if vehicle.aiveChain.tools[tp.i].obj.spec_aiImplement.backMarker  ~= nil then
					local x,_,z = getWorldTranslation( vehicle.aiveChain.tools[tp.i].obj.spec_aiImplement.backMarker )
					local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
					AIVEDrawDebugLine( vehicle,  x,y,z, 0,1,0, x,y+2,z, 0,1,0 )
					AIVEDrawDebugPoint( vehicle, x,y+2,z	, 1, 1, 1, 1 )
				end
				
				if vehicle.aiveChain.tools[tp.i].aiForceTurnNoBackward then
					local x,y,z
					x,_,z = localToWorld( vehicle.aiveChain.refNode, 0, 0, tp.b1 )
					y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
					AIVEDrawDebugLine( vehicle,  x,y,z, 0.8,0,0, x,y+2,z, 0.8,0,0 )
					AIVEDrawDebugPoint( vehicle, x,y+2,z	, 1, 1, 1, 1 )

					local a = -AutoSteeringEngine.getToolAngle( vehicle )					
					local l = tp.b1 + tp.b2
				--print(tostring(tp.b1).." "..tostring(tp.b2).." "..tostring(math.deg(a)))
					
					x,_,z = localToWorld( vehicle.aiveChain.refNode, math.sin(a) * l, 0, math.cos(a) * l )
					y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
					AIVEDrawDebugLine( vehicle,  x,y,z, 1,0.2,0.2, x,y+2,z, 1,0.2,0.2 )
					AIVEDrawDebugPoint( vehicle, x,y+2,z	, 1, 1, 1, 1 )
					
					if tp.b3 ~= nil and math.abs( tp.b3 ) > 0.1 then
						local x3,_,z3 = localDirectionToWorld( vehicle.aiveChain.refNode, math.sin(a+a) * tp.b3, 0, math.cos(a+a) * tp.b3 )
						x = x + x3
						z = z + z3
						y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
						AIVEDrawDebugLine( vehicle,  x,y,z, 1,1,0, x,y+2,z, 1,1,0 )
						AIVEDrawDebugPoint( vehicle, x,y+2,z	, 1, 1, 0, 1 )
					end
				end
				
				x,_,z = localToWorld( vehicle.aiveChain.refNode, tp.x, 0, tp.z )
				y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)
				AIVEDrawDebugLine( vehicle,  x,y,z, 1,0,0, x,y+2,z, 1,0,0 )
				AIVEDrawDebugPoint( vehicle, x,y+2,z	, 1, 1, 1, 1 )
				
				if vehicle.acIamDetecting or vehicle.aiveChain.staticRoot then
					local px,py,pz
					for i=1,indexMax+1 do
						local wx,wy,wz = AutoSteeringEngine.getChainPoint( vehicle, i, tp )
						
						if      i > 1
								and vehicle.aiveChain.nodes[i-1].tool[tp.i]   ~= nil 
								and vehicle.aiveChain.nodes[i-1].tool[tp.i].t ~= nil then
								
							AIVEDrawDebugLine( vehicle,px,py+0.5,pz,1,1,1,wx,wy+0.5,wz,1,1,1)
							local wx1,xy1,wz1,wx2,wy2,wz2 = AutoSteeringEngine.getChainSegment( vehicle, i-1, tp )

							local lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( wx1, wz1, wx2, wz2, off )
							local ly1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx1, 1, lz1) + 0.5
							local ly2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx2, 1, lz2) + 0.5
							local ly3 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx3, 1, lz3) + 0.5

							local c1, c2, c3 = 0, 0, 0
							
							if      vehicle.aiveChain.lastIndexMax ~= nil
									and i-1 > vehicle.aiveChain.lastIndexMax then
								c1 = 0.25
								c2 = 0.25
								c3 = 0.25
							elseif vehicle.aiveChain.nodes[i-1].tool[tp.i].t < 0 then
								c1 = 0.5
								c2 = 0.5
								c3 = 0.5
							elseif vehicle.aiveChain.nodes[i-1].tool[tp.i].b > 0 then
								c1 = 1
							elseif vehicle.aiveChain.nodes[i-1].tool[tp.i].t > 0 then
								c2 = 1
							else
								c1 = 1
								c2 = 1
							end
							
							AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c1,c2,c3,lx3,ly3,lz3,c1,c2,c3)

							if vehicle.aiveChain.nodes[i-1].tool[tp.i].t < 0 then
								AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,0.3,0.3,0.3,lx2,ly2,lz2,0.3,0.3,0.3)
							else
								AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,0,0,1,lx2,ly2,lz2,0,0,1)
							end
						end
						
						px = wx 
						py = wy
						pz = wz
					end		
				end
			end

			y = y + 1
		end
	end
			
	if vehicle.aiveFruitAreas ~= nil then
		for i,fas in pairs( vehicle.aiveFruitAreas ) do
			for _,fa in pairs( fas ) do
				if table.getn( fa ) == 9 then
					local lx1,lz1,lx2,lz2,lx3,lz3,lx4,lz4,g = unpack( fa )
					local c = {1,0,0}
					if g then
						c = {0,1,0}
					end
					
					local y1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx1, 1, lz1) + 0.25
					local y2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx2, 1, lz2) + 0.25
					local y3 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx3, 1, lz3) + 0.25
					local y4 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx4, 1, lz4) + 0.25
					
					AIVEDrawDebugLine( vehicle,lx1,y1,lz1,c[1],c[2],c[3],lx3,y3,lz3,c[1],c[2],c[3])
					AIVEDrawDebugLine( vehicle,lx1,y1,lz1,c[1],c[2],c[3],lx2,y2,lz2,c[1],c[2],c[3])
					AIVEDrawDebugLine( vehicle,lx4,y4,lz4,c[1],c[2],c[3],lx2,y2,lz2,c[1],c[2],c[3])
					AIVEDrawDebugLine( vehicle,lx4,y4,lz4,c[1],c[2],c[3],lx3,y3,lz3,c[1],c[2],c[3])
				end
			end
		end
	end


	local c1,c2,c3 = 0,0,1
	for i=1,indexMax+1 do
		local wx,wy,wz = getWorldTranslation( vehicle.aiveChain.nodes[i].index )
		wy = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, wx,wy,wz)+0.25
		if i > 1 then
			
			AIVEDrawDebugLine( vehicle,px,py,pz,c1,c2,c3,wx,wy,wz,c1,c2,c3)
		end
		
		px = wx 
		py = wy 
		pz = wz
		
		local cx,cy,cz = getWorldTranslation( vehicle.aiveChain.nodes[i].index3 )
		cy = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, cx,cy,cz)+0.25
		AIVEDrawDebugLine( vehicle,wx,wy,wz,1,1,1,cx,cy,cz,1,1,1)
		local tx,ty,tz = getWorldTranslation( vehicle.aiveChain.nodes[i].index4 )
		ty = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tx,ty,tz)+0.25
		AIVEDrawDebugLine( vehicle,cx,cy,cz,0.5,0.5,0.5,tx,ty,tz,0.5,0.5,0.5)
		
		cx,cy,cz = localToWorld( vehicle.aiveChain.nodes[i].index4, vehicle.aiveChain.activeX, 0, 0 )
		tx,ty,tz = localToWorld( vehicle.aiveChain.nodes[i].index4, vehicle.aiveChain.otherX, 0, 0 )
		AIVEDrawDebugLine( vehicle,cx,cy,cz,1,1,1,tx,ty,tz,1,1,1)		
	end		


	if vehicle.aiveChain.trace ~= nil and vehicle.aiveChain.trace.foundNext then
		local lx1,lz1,lx2,lz2,lx3,lz3,b,t,wu = unpack( vehicle.aiveChain.trace.fn )
		local lx4 = lx2 + lx3 - lx1
		local lz4 = lz2 + lz3 - lz1
		local ly1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx1, 1, lz1) + 0.25
		local ly2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx2, 1, lz2) + 0.25
		local ly3 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx3, 1, lz3) + 0.25
		local ly4 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx4, 1, lz4) + 0.25
		local c = { 0.2, 0.2, 0.2 }
				
		if b <= 0 then
			c = { 0, 1, 0 }
		elseif b >= t then
			c = { 1, 0.5, 0.5 }
		else
			c = { 1, b/(t+t), b/(t+t) }
		end
		
		AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c[1],c[2],c[3],lx3,ly3,lz3,c[1],c[2],c[3])
		AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c[1],c[2],c[3],lx2,ly2,lz2,c[1],c[2],c[3])
		AIVEDrawDebugLine( vehicle,lx4,ly4,lz4,c[1],c[2],c[3],lx3,ly3,lz3,c[1],c[2],c[3])
		AIVEDrawDebugLine( vehicle,lx4,ly4,lz4,c[1],c[2],c[3],lx2,ly2,lz2,c[1],c[2],c[3])

		local tx = 0.25*( lx1 + lx2 + lx3 + lx4 )
		local tz = 0.25*( lz1 + lz2 + lz3 + lz4 )	
		local ty = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tx, 1, tz)
		local tt = string.format("(%d, %d)",b,t)

		local sx,sy,sz = project(tx,ty,tz)
		setTextColor(c[1],c[2],c[3],1) 
		if 1 > sz and sz > 0 then 
			renderText(sx, sy, getCorrectTextSize(0.02) * sz, tt )
		end 
	end

	
	if vehicle.aiveChain.cbr ~= nil then
		for _,cbr in pairs( vehicle.aiveChain.cbr ) do
			local lx1,lz1,lx2,lz2,lx3,lz3,b,t,wu = unpack( cbr )
			local lx4 = lx2 + lx3 - lx1
			local lz4 = lz2 + lz3 - lz1
			local ly1 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx1, 1, lz1) + 0.25
			local ly2 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx2, 1, lz2) + 0.25
			local ly3 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx3, 1, lz3) + 0.25
			local ly4 = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, lx4, 1, lz4) + 0.25
			local c = { 0.2, 0.2, 0.2 }
			local d = true
			
			
			
			if b <= 0 then
				c = { 0, 1, 0 }
			elseif b >= t then
				c = { 1, 0.5, 0.5 }
			else
				c = { 1, b/(t+t), b/(t+t) }
			end

			if wu == nil then
				d = true
			elseif wu == 1 then				
				d = b>0
			elseif wu == 2 then
				b = c[3]
				c[3] = c[1]
				c[1] = b
				d = b>0
			elseif wu == 3 then
				d = b<=0
			end
			
			if d then
				AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c[1],c[2],c[3],lx3,ly3,lz3,c[1],c[2],c[3])
				AIVEDrawDebugLine( vehicle,lx1,ly1,lz1,c[1],c[2],c[3],lx2,ly2,lz2,c[1],c[2],c[3])
				AIVEDrawDebugLine( vehicle,lx4,ly4,lz4,c[1],c[2],c[3],lx3,ly3,lz3,c[1],c[2],c[3])
				AIVEDrawDebugLine( vehicle,lx4,ly4,lz4,c[1],c[2],c[3],lx2,ly2,lz2,c[1],c[2],c[3])

				local tx = 0.25*( lx1 + lx2 + lx3 + lx4 )
				local tz = 0.25*( lz1 + lz2 + lz3 + lz4 )	
				local ty = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tx, 1, tz)
				local tt = string.format("(%d, %d)",b,t)

				local sx,sy,sz = project(tx,ty,tz)
				setTextColor(c[1],c[2],c[3],1) 
				if 1 > sz and sz > 0 then 
					renderText(sx, sy, getCorrectTextSize(0.02) * sz, tt )
				end 
			end
		end
	end
	
	if AIVEGlobals.showChannels > 0 then
		if vehicle.aiveTestMap == nil and vehicle.aiveCurrentField ~= nil then
			vehicle.aiveTestMap = vehicle.aiveCurrentField.getPoints()
			if vehicle.aiveTestMap ~= nil then
				print(string.format("points: %i",table.getn(vehicle.aiveTestMap)))
			end
		end
		
		if vehicle.aiveTestMap ~= nil then
			for _,p in pairs( vehicle.aiveTestMap ) do
				x,z = unpack( p )
				local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z) + 2.2
				AIVEDrawDebugPoint( vehicle, x, y, z, 1,1,1, 1 )
			end
		end
	end
	
	if      vehicle.aiveChain.trace             ~= nil 
			and vehicle.aiveChain.trace.targetTrace ~= nil then
		local cr = 1
		if vehicle.aiveChain.trace.targetTraceMode > 0 then
			cr = 0
		end
		for i,p in pairs( vehicle.aiveChain.trace.targetTrace ) do
			local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p.x, 1, p.z)
			
		
			AIVEDrawDebugLine( vehicle, p.x, y, p.z,cr,1,0, p.x, y+4, p.z,cr,1,0)
			AIVEDrawDebugPoint(vehicle, p.x, y+4, p.z	, 1, 1, 1, 1 )
			AIVEDrawDebugLine( vehicle, p.x, y+2, p.z,cr,1,0, p.x+p.dx, y+2, p.z+p.dz,cr,0,1)
		end
	end
	
end

------------------------------------------------------------------------
-- displayDebugInfo
------------------------------------------------------------------------
function AutoSteeringEngine.displayDebugInfo( vehicle )

	if vehicle.isControlled then
		setTextBold(false)
		setTextColor(1, 1, 1, 1)
		setTextAlignment(RenderText.ALIGN_LEFT)
		
		local fullText = ""
		
		fullText = fullText .. string.format("AIVehicleExtension:") .. "\n"
		
		renderText(0.51, 0.97, 0.02, fullText)		
	end
	
end

------------------------------------------------------------------------
-- getFruitArea
------------------------------------------------------------------------
function AutoSteeringEngine.getFruitArea( vehicle, x1,z1,x2,z2,d,toolIndex,bypassBuffer )
	local lx1,lz1,lx2,lz2,lx3,lz3 = AutoSteeringEngine.getParallelogram( x1, z1, x2, z2, d, true )
	return AutoSteeringEngine.getAIAreaOfVehicle( vehicle, toolIndex, lx1,lz1,lx2,lz2,lx3,lz3, bypassBuffer )
end

------------------------------------------------------------------------
-- initWorldToDensity
------------------------------------------------------------------------
function AutoSteeringEngine.initWorldToDensity( vehicle )
	if vehicle.aiveChain.worldToDensity == nil then
		vehicle.aiveChain.worldToDensityM = 4 * g_currentMission.terrainDetailMapSize
		vehicle.aiveChain.worldToDensity  = vehicle.aiveChain.worldToDensityM / g_currentMission.terrainSize
		vehicle.aiveChain.worldToDensityI = g_currentMission.terrainSize / vehicle.aiveChain.worldToDensityM
	end
end

------------------------------------------------------------------------
-- floatToInteger
------------------------------------------------------------------------
function AutoSteeringEngine.floatToInteger( vehicle, f, m )
	if f < m then -- mean
		return math.floor( f * vehicle.aiveChain.worldToDensity )
	end
	return math.ceil( f * vehicle.aiveChain.worldToDensity )
end

------------------------------------------------------------------------
-- getAIAreaOfVehicle
------------------------------------------------------------------------
function AutoSteeringEngine.getAIAreaOfVehicle1( vehicle, toolIndex, lx1,lz1,lx2,lz2,lx3,lz3, bypassBuffer )

	local a, t = AutoSteeringEngine.getAIAreaOfVehicle2( vehicle, toolIndex, lx1,lz1,lx2,lz2,lx3,lz3, bypassBuffer )

--if a <= 0 then 
--	return a, t 
--end 
--
--local tool = vehicle.aiveChain.tools[toolIndex]
--if tool == nil then 
--	return 0, 0
--end 
--
--if     ( vehicle.aiveHas.cultivator and vehicle.aiveHas.sowingMachine ) 
--		or ( vehicle.aiveHas.plow       and vehicle.aiveHas.cultivator    ) then 
--	local ao, to = 0, t 
--
--	for i,t in pairs( vehicle.aiveChain.tools ) do 
--		if      not t.skip 
--				and ( ( t.isCultivator    and not tool.isCultivator )
--					 or ( t.isPlow          and not tool.isPlow )
--					 or ( t.isSowingMachine and not tool.isSowingMachine ) ) then 
--			local a2, t2 = AutoSteeringEngine.getAIAreaOfVehicle2( vehicle, i, lx1,lz1,lx2,lz2,lx3,lz3, false )
--			ao = math.max( ao, a2 )
--			to = math.max( to, t2 ) 
--		end 
--		if ao >= a then 
--			break 
--		end 
--	end 
--	
--	a = math.max( 0, a - ao )
--end 
	

	return a, t
end 

------------------------------------------------------------------------
-- getAIAreaOfVehicle1
------------------------------------------------------------------------
function AutoSteeringEngine.getAIAreaOfVehicle( vehicle, toolIndex, lx1,lz1,lx2,lz2,lx3,lz3, bypassBuffer )

	if AIVEGlobals.fruitBuffer > 0 and not ( bypassBuffer ) then 
		AutoSteeringEngine.initWorldToDensity( vehicle ) 
		
		local lxm = 0.5 * ( lx2 + lx3 )
		local lzm = 0.5 * ( lz2 + lz3 )
		local ni1 = AutoSteeringEngine.floatToInteger( vehicle, lx1, lxm )
		local ni2 = AutoSteeringEngine.floatToInteger( vehicle, lx2, lxm )
		local ni3 = AutoSteeringEngine.floatToInteger( vehicle, lx3, lxm )
		local nj1 = AutoSteeringEngine.floatToInteger( vehicle, lz1, lzm )
		local nj2 = AutoSteeringEngine.floatToInteger( vehicle, lz2, lzm )
		local nj3 = AutoSteeringEngine.floatToInteger( vehicle, lz3, lzm )
		
		if AIVEGlobals.fruitBuffer <= 1 then
			return AutoSteeringEngine.getAIAreaOfVehicle1( vehicle, toolIndex,
																											ni1 * vehicle.aiveChain.worldToDensityI,
																											nj1 * vehicle.aiveChain.worldToDensityI,
																											ni2 * vehicle.aiveChain.worldToDensityI, 
																											nj2 * vehicle.aiveChain.worldToDensityI, 
																											ni3 * vehicle.aiveChain.worldToDensityI,
																											nj3 * vehicle.aiveChain.worldToDensityI )
		end	
		
		if vehicle.aiveChain.fruitBuffer == nil then
			vehicle.aiveChain.fruitBuffer = {}
		end

		local id = string.format("%d,%d,%d,%d,%d,%d,%d",toolIndex,ni1,ni2,ni3,nj1,nj2,nj3)
		
		if vehicle.aiveChain.fruitBuffer[id] ~= nil then
			vehicle.aiveChain.fruitBufferHit = AIVEUtils.getNoNil( vehicle.aiveChain.fruitBufferHit, 0 ) + 1
			return unpack( vehicle.aiveChain.fruitBuffer[id] )
		end
		
		local a, t = AutoSteeringEngine.getAIAreaOfVehicle1( vehicle, toolIndex,
																										ni1 * vehicle.aiveChain.worldToDensityI,
																										nj1 * vehicle.aiveChain.worldToDensityI,
																										ni2 * vehicle.aiveChain.worldToDensityI, 
																										nj2 * vehicle.aiveChain.worldToDensityI, 
																										ni3 * vehicle.aiveChain.worldToDensityI,
																										nj3 * vehicle.aiveChain.worldToDensityI )
		
		vehicle.aiveChain.fruitBuffer[id] = { a, t }	
		vehicle.aiveChain.fruitBufferSize = AIVEUtils.getNoNil( vehicle.aiveChain.fruitBufferSize, 0 ) + 1
		vehicle.aiveChain.fruitBufferMis  = AIVEUtils.getNoNil( vehicle.aiveChain.fruitBufferMis, 0 ) + 1
		
		return a, t
	end 

	return AutoSteeringEngine.getAIAreaOfVehicle1( vehicle, toolIndex, lx1,lz1,lx2,lz2,lx3,lz3 )
end 

------------------------------------------------------------------------
-- getAIAreaOfVehicle2
------------------------------------------------------------------------
function AutoSteeringEngine.getAIAreaOfVehicle2( vehicle, toolIndex, lx1,lz1,lx2,lz2,lx3,lz3 )
	local tool = vehicle.aiveChain.tools[toolIndex]
	if tool == nil then 
		return 0, 0
	end 
	
	if     AIImplement.getFieldCropsQuery == nil 
			or AIVEGlobals.oldAIArea >= 2
			or ( AIVEGlobals.oldAIArea >= 1 and tool.isTerrainDetailRequiredModified ) then 
	--1.3
		local terrainDetailRequiredValueRanges  = tool.terrainDetailRequiredValueRanges
		local terrainDetailProhibitValueRanges  = tool.obj:getAITerrainDetailProhibitedRange()
		local fruitRequirements = tool.obj:getAIFruitRequirements()
		local useDensityHeightMap, useWindrowFruitType = tool.obj:getAIFruitExtraRequirements()
		local fruitProhibitions = tool.fruitProhibitions
		
		if not useDensityHeightMap then
			if vehicle.aiveAIAreaLog == nil or vehicle.aiveAIAreaLog ~= 11 then 
				vehicle.aiveAIAreaLog = 11
				AIVehicleExtension.debugPrint( vehicle, "AutoSteeringEngine.getAIAreaOfVehicle v1.3 I" ) 
			end 
			return AutoSteeringEngine.getAIFruitAreaOldSchool(lx1,lz1,lx2,lz2,lx3,lz3, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, fruitRequirements, fruitProhibitions, useWindrowFruitType)
		else
			if vehicle.aiveAIAreaLog == nil or vehicle.aiveAIAreaLog ~= 12 then 
				vehicle.aiveAIAreaLog = 12
				AIVehicleExtension.debugPrint( vehicle, "AutoSteeringEngine.getAIAreaOfVehicle v1.3 II" ) 
			end 
			return AIVehicleUtil.getAIDensityHeightArea(lx1,lz1,lx2,lz2,lx3,lz3, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, fruitRequirements, fruitProhibitions, useWindrowFruitType)
		end
	else
	-- 1.4
		local useDensityHeightMap, useWindrowFruitType =  tool.obj:getAIFruitExtraRequirements()
	
		if not useDensityHeightMap then
			if vehicle.aiveAIAreaLog == nil or vehicle.aiveAIAreaLog ~= 1 then 
				vehicle.aiveAIAreaLog = 1
				AIVehicleExtension.debugPrint( vehicle, "AutoSteeringEngine.getAIAreaOfVehicle v1.4 I" ) 
			end 
				
			local query =  tool.obj:getFieldCropsQuery()
			return AIVehicleUtil.getAIFruitArea(lx1,lz1,lx2,lz2,lx3,lz3, query)
		else
			if vehicle.aiveAIAreaLog == nil or vehicle.aiveAIAreaLog ~= 2 then 
				vehicle.aiveAIAreaLog = 2
				AIVehicleExtension.debugPrint( vehicle, "AutoSteeringEngine.getAIAreaOfVehicle v1.4 II" ) 
			end 
	
			local fruitRequirements =  tool.obj:getAIFruitRequirements()
			return AIVehicleUtil.getAIDensityHeightArea(lx1,lz1,lx2,lz2,lx3,lz3, fruitRequirements, useWindrowFruitType)
		end 
	end 
end


function AutoSteeringEngine.getAIFruitAreaOldSchool(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, fruitRequirements, fruitProhibitions, useWindrowed)
	local query = g_currentMission.fieldCropsQuery
	if type( fruitRequirements ) == "table" then 
		for _, fruitRequirement in pairs( fruitRequirements ) do
			if fruitRequirement.fruitType ~= FruitType.UNKNOWN then
				local ids = g_currentMission.fruits[fruitRequirement.fruitType]
				if ids ~= nil and ids.id ~= 0 then
					if useWindrowed then
						return 0, 1
					end
					local desc = g_fruitTypeManager:getFruitTypeByIndex(fruitRequirement.fruitType)
					query:addRequiredCropType(ids.id, fruitRequirement.minGrowthState+1, fruitRequirement.maxGrowthState+1, desc.startStateChannel, desc.numStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)
				end
			end
		end
	end
	if type( fruitProhibitions ) == "table" then 
		for _, fruitProhibition in pairs( fruitProhibitions ) do
			if fruitProhibition.fruitType ~= FruitType.UNKNOWN then
				local ids = g_currentMission.fruits[fruitProhibition.fruitType]
				if ids ~= nil and ids.id ~= 0 then
					local desc = g_fruitTypeManager:getFruitTypeByIndex(fruitProhibition.fruitType)
					query:addProhibitedCropType(ids.id, fruitProhibition.minGrowthState+1, fruitProhibition.maxGrowthState+1, desc.startStateChannel, desc.numStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)
				end
			end
		end
	end
	if type( terrainDetailRequiredValueRanges ) == "table" then 
		for _,valueRange in pairs(terrainDetailRequiredValueRanges) do
			query:addRequiredGroundValue(valueRange[1], valueRange[2], valueRange[3], valueRange[4])
		end
	end
	if type( terrainDetailProhibitValueRanges ) == "table" then 
		for _,valueRange in pairs(terrainDetailProhibitValueRanges) do
			query:addProhibitedGroundValue(valueRange[1], valueRange[2], valueRange[3], valueRange[4])
		end
	end
	local x,z, widthX,widthZ, heightX,heightZ = MathUtil.getXZWidthAndHeight(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
	return query:getParallelogram(x,z, widthX,widthZ, heightX,heightZ, true)
end

------------------------------------------------------------------------
-- steering2ChainAngle
------------------------------------------------------------------------
function AutoSteeringEngine.steering2ChainAngle( vehicle, steering )
	if math.abs( steering ) < 1e-4 then
		return 0
	end
	
	local a = 0
	if steering > 0 then
		a =  AIVEUtils.clamp( steering / vehicle.aiveChain.maxAngle, 0, 1 )
	else
		a = -AIVEUtils.clamp( steering / vehicle.aiveChain.minAngle, 0, 1 )
	end
	if vehicle.aiveChain.leftActive then
		return a
	end
	return -a
end

------------------------------------------------------------------------
-- chainAngle2Steering
------------------------------------------------------------------------
function AutoSteeringEngine.chainAngle2Steering( vehicle, angle )
	if -1E-4 < angle and angle <  1E-4 then
		return 0
	elseif vehicle.aiveChain.leftActive	then
		if     angle >= 1 then
			return  vehicle.aiveChain.maxAngle
		elseif angle <=-1 then
			return  vehicle.aiveChain.minAngle
		elseif angle >= 0 then
			-- outside 
			return  vehicle.aiveChain.maxAngle * angle 
		else
			-- inside
			return -vehicle.aiveChain.minAngle * angle 
		end
	else
		if     angle >= 1 then
			return  vehicle.aiveChain.minAngle
		elseif angle <=-1 then
			return  vehicle.aiveChain.maxAngle
		elseif angle >= 0 then
			-- outside 
			return  vehicle.aiveChain.minAngle * angle 
		else
			-- inside
			return -vehicle.aiveChain.maxAngle * angle 
		end
	end
end

------------------------------------------------------------------------
-- applySteering
------------------------------------------------------------------------
function AutoSteeringEngine.applySteering( vehicle, toIndex )

	if vehicle.aiveChain.minAngle == nil or vehicle.aiveChain.maxAngle == nil then
		vehicle.aiveChain.minAngle = -vehicle.aiveChain.maxSteering
		vehicle.aiveChain.maxAngle = vehicle.aiveChain.maxSteering
	end

	local j0 = vehicle.aiveChain.chainMax+2
	
	local jMax = vehicle.aiveChain.chainMax+1
	if toIndex ~= nil and toIndex < vehicle.aiveChain.chainMax then 
		jMax = toIndex 
		AutoSteeringEngine.setChainStatus( vehicle, jMax + 1, AIVEStatus.initial )
	end
		
	for j=1,vehicle.aiveChain.chainMax+1 do 
		local a = AutoSteeringEngine.chainAngle2Steering( vehicle, vehicle.aiveChain.nodes[j].angle )
						
		if j0 > j and vehicle.aiveChain.nodes[j].status < AIVEStatus.steering then
			j0 = j
		end
		if j >= j0 then
			if j > jMax then
				vehicle.aiveChain.nodes[j].status      = math.min( vehicle.aiveChain.nodes[j].status, AIVEStatus.steering-1 )
			else
				vehicle.aiveChain.nodes[j].steering    = a
				if math.abs(a) > 1E-5 then
					local t = math.tan( a )
					vehicle.aiveChain.nodes[j].radius    = vehicle.aiveChain.wheelBase / t
					vehicle.aiveChain.nodes[j].invRadius = vehicle.aiveChain.invWheelBase * t
				else
					vehicle.aiveChain.nodes[j].radius    = 1E+6
					vehicle.aiveChain.nodes[j].invRadius = 0
				end
				vehicle.aiveChain.nodes[j].status      = AIVEStatus.steering
			end
		end
	end 
end

------------------------------------------------------------------------
-- applyRotation
------------------------------------------------------------------------
function AutoSteeringEngine.applyRotation( vehicle, toIndex )

	local limited = false

	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return end
	
	local cumulRot= 0
	if vehicle.aiveChain.inField then
		local f = 1
		local t = AutoSteeringEngine.getTraceLength( vehicle )
		if t < AIVEGlobals.maxRotationL then
			f = t / AIVEGlobals.maxRotationL
		end
		local rMin, rMax = -AIVEGlobals.maxRotation * f, AIVEGlobals.maxRotation * f
		if vehicle.aiveChain.leftActive	then
			rMin = 0
		else
			rMax = 0
		end
		cumulRot = AIVEUtils.clamp( AutoSteeringEngine.getTurnAngle( vehicle ), rMin, rMax )
	end 

	AutoSteeringEngine.applySteering( vehicle, toIndex )
	
	if      AutoSteeringEngine.hasArticulatedAxis( vehicle )
			and vehicle.aiveChain.noReverseIndex <= 0 then 
	else 
		
	end 

	local j0   = vehicle.aiveChain.chainMax+2
	local jMax = vehicle.aiveChain.chainMax+1
	if toIndex ~= nil and toIndex < vehicle.aiveChain.chainMax then 
		jMax = toIndex 
	end
	for j=1,vehicle.aiveChain.chainMax+1 do 
		if j0 > j and vehicle.aiveChain.nodes[j].status < AIVEStatus.rotation then
			j0 = j
		end		
		if j >= j0 then
			if j > jMax then
				vehicle.aiveChain.nodes[j].status = math.min( vehicle.aiveChain.nodes[j].status, AIVEStatus.rotation-1 )
			else
				vehicle.aiveChain.nodes[j].tool = {}		
			
				--vehicle.aiveChain.nodes[j].rotation = math.tan( vehicle.aiveChain.nodes[j].steering ) * vehicle.aiveChain.invWheelBase
				local length = vehicle.aiveChain.nodes[j].length		
				local updateSteering

				if toIndex ~= nil and j > toIndex then
					vehicle.aiveChain.nodes[j].rotation = 0
					updateSteering = true
				elseif math.abs( vehicle.aiveChain.nodes[j].invRadius ) < 1e-6 then
					vehicle.aiveChain.nodes[j].rotation = 0
					updateSteering = false
				else
					vehicle.aiveChain.nodes[j].rotation = 2 * math.asin( AIVEUtils.clamp( length * 0.5 * vehicle.aiveChain.nodes[j].invRadius, -1, 1 ) )
					updateSteering = false
				end
				
				local oldCumulRot = cumulRot
				cumulRot = cumulRot + vehicle.aiveChain.nodes[j].rotation
				
				if     cumulRot >  vehicle.aiveChain.maxRotation then
					vehicle.aiveChain.nodes[j].rotation = vehicle.aiveChain.nodes[j].rotation + vehicle.aiveChain.maxRotation - cumulRot
					updateSteering                     = true
				elseif cumulRot < vehicle.aiveChain.minRotation then
					vehicle.aiveChain.nodes[j].rotation = vehicle.aiveChain.nodes[j].rotation + vehicle.aiveChain.minRotation - cumulRot
					updateSteering                     = true
				end
				
				if updateSteering then
					limited  = true
					cumulRot = oldCumulRot + vehicle.aiveChain.nodes[j].rotation
					vehicle.aiveChain.nodes[j].invRadius  = math.sin( 0.5 * vehicle.aiveChain.nodes[j].rotation ) * 2 / vehicle.aiveChain.nodes[j].length
					if math.abs( vehicle.aiveChain.nodes[j].invRadius ) > 1E-6 then
						vehicle.aiveChain.nodes[j].radius   = 1 / vehicle.aiveChain.nodes[j].invRadius
						vehicle.aiveChain.nodes[j].steering = math.atan2( vehicle.aiveChain.wheelBase, vehicle.aiveChain.nodes[j].radius )
					else
						vehicle.aiveChain.nodes[j].radius   = 1E+6
						vehicle.aiveChain.nodes[j].steering = 0
					end
					vehicle.aiveChain.nodes[j].tool     = {}
				end

				vehicle.aiveChain.nodes[j].cumulRot = cumulRot
				
				setRotation( vehicle.aiveChain.nodes[j].index2, 0, vehicle.aiveChain.nodes[j].rotation, 0 )
				vehicle.aiveChain.nodes[j].status   = AIVEStatus.rotation
			end
		else
			cumulRot = cumulRot + vehicle.aiveChain.nodes[j].rotation
		end	
	end

	return limited
end

------------------------------------------------------------------------
-- invalidateField
------------------------------------------------------------------------
function AutoSteeringEngine.invalidateField( vehicle, force )
	--if not ( vehicle.aiveFieldIsInvalid ) then print("invalidating field") end
	vehicle.aiveFieldIsInvalid = true
	if force then
		vehicle.aiveCurrentField = nil		
	end
	if vehicle.aiveChain ~= nil then
		vehicle.aiveChain.lastBestAngle  = nil
		vehicle.aiveChain.savedAngles    = nil
	end
end

------------------------------------------------------------------------
-- checkFieldNoBuffer
------------------------------------------------------------------------
 function AutoSteeringEngine.checkFieldNoBuffer( x, z, checkFunction ) 
 
	if x == nil or z == nil or checkFunction == nil then
		--AIVehicleExtension.printCallstack()
		return false
	end 
	
	FieldBitmap.prepareIsField( )
	local startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ = FieldBitmap.getParallelogram( x, z, 0.5, 0.25 )
	local ret = checkFunction( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
	FieldBitmap.cleanupAfterIsField( )
	
	return ret
end

------------------------------------------------------------------------
-- getCheckFunction
------------------------------------------------------------------------
function AutoSteeringEngine.getCheckFunction( vehicle )

	local checkFct, areaTotalFct
	
	if vehicle.aiveChain.useAIFieldFct then
		areaTotalFct = function( lx1,lz1,lx2,lz2,lx3,lz3 )
			local a, t = 0, 0
			for i,tp in pairs(vehicle.aiveChain.toolParams) do
				if not tp.skip then
					local ta, tt = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, tp.i, lx1,lz1,lx2,lz2,lx3,lz3, true )
					a = a + ta
					t = t + tt
				end
			end
			return a, t
		end
		checkFct     = function( lx1,lz1,lx2,lz2,lx3,lz3 )
			return areaTotalFct( lx1,lz1,lx2,lz2,lx3,lz3 ) > 0
		end
	else
		areaTotalFct = FieldBitmap.getAreaTotal
		checkFct     = FieldBitmap.isFieldFast
	end
	
	return checkFct, areaTotalFct
end

------------------------------------------------------------------------
-- checkFieldNear
------------------------------------------------------------------------
function AutoSteeringEngine.checkFieldNear( vehicle, x, z, d )
	local dist = d
	if d == nil then
		dist = 0.5
	end
	
	return AutoSteeringEngine.checkField( vehicle, x, z )
			or AutoSteeringEngine.checkField( vehicle, x+dist, z )
			or AutoSteeringEngine.checkField( vehicle, x-dist, z )
			or AutoSteeringEngine.checkField( vehicle, x, z+dist )
			or AutoSteeringEngine.checkField( vehicle, x, z-dist )
end

------------------------------------------------------------------------
-- checkFieldIsValid
------------------------------------------------------------------------
function AutoSteeringEngine.checkFieldIsValid( vehicle )

	local stepLog2 = AIVEGlobals.stepLog2
	local checkFunction, areaTotalFunction
	local x1,_,z1 = localToWorld( vehicle.aiveChain.refNode, 0.5 * ( vehicle.aiveChain.activeX + vehicle.aiveChain.otherX ), 0, 
																													 math.max( 0, vehicle.aiveChain.maxZ + AIVEGlobals.lowerAdvance ) )
	
	if vehicle.aiveFieldIsInvalid then
		vehicle.aiveChain.lastX = nil
		vehicle.aiveChain.lastZ = nil 
		vehicle.aiveCurrentFieldCo = nil
		vehicle.aiveCurrentFieldCS = 'dead'
	
		if vehicle.aiveCurrentField ~= nil then
			if vehicle.aiveCurrentField.getBit( x1, z1 ) then
				vehicle.aiveFieldIsInvalid = false			
			else
				checkFunction, areaTotalFunction = AutoSteeringEngine.getCheckFunction( vehicle )
				if AutoSteeringEngine.checkFieldNoBuffer( x1, z1, checkFunction ) then
					vehicle.aiveCurrentField = nil	
				end
			end
		end
	end
	
	if vehicle.aiveCurrentField == nil then
		vehicle.aiveFieldIsInvalid = false
		
		local status, message, hektar = false, "", 0
		
		if vehicle.aiveCurrentFieldCo == nil then
			vehicle.aiveCurrentFieldCt = 0
			if checkFunction == nil then
				checkFunction, areaTotalFunction = AutoSteeringEngine.getCheckFunction( vehicle )
			end
			
			if vehicle.aiveChain.lastX ~= nil and vehicle.aiveChain.lastZ ~= nil then
				if AIVEUtils.vector2LengthSq( vehicle.aiveChain.lastX - x1, vehicle.aiveChain.lastZ - z1 ) < 1 then
					return true
				else
					vehicle.aiveChain.lastX = x1
					vehicle.aiveChain.lastZ = z1 
				end
			end
		
			local found = AutoSteeringEngine.checkFieldNoBuffer( x1, z1, checkFunction )
			
			if      found 
					and ( not AutoSteeringEngine.checkFieldNoBuffer( x1-1, z1, checkFunction )
						 or not AutoSteeringEngine.checkFieldNoBuffer( x1+1, z1, checkFunction )
						 or not AutoSteeringEngine.checkFieldNoBuffer( x1, z1-1, checkFunction )
						 or not AutoSteeringEngine.checkFieldNoBuffer( x1, z1+1, checkFunction ) ) then
				found = false
			end
			
			if found then
				stepLog2 = math.log( 2 * g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize ) / math.log( 2 )
	
				if AIVEGlobals.yieldCount < 1 then
					if areaTotalFunction and areaTotalFunction ~= FieldBitmap.getAreaTotal then
						vehicle.aiveCurrentField, hektar = FieldBitmap.createForFieldAtWorldPosition( x1, z1, stepLog2, 1, areaTotalFunction, nil, nil, 0 )
					else
						vehicle.aiveCurrentField, hektar = FieldBitmap.createForFieldAtWorldPositionSimple( x1, z1, stepLog2, 1, checkFunction )
					end
					vehicle.aiveCurrentFieldCo = nil
					vehicle.aiveCurrentFieldCS = 'dead'
				else
					if areaTotalFunction and areaTotalFunction ~= FieldBitmap.getAreaTotal then
						vehicle.aiveCurrentFieldCo = coroutine.create( FieldBitmap.createForFieldAtWorldPosition )
						status, vehicle.aiveCurrentField, hektar = coroutine.resume( vehicle.aiveCurrentFieldCo, x1, z1, stepLog2, 1, areaTotalFunction, nil, nil, AIVEGlobals.yieldCount )
					else
						vehicle.aiveCurrentFieldCo = coroutine.create( FieldBitmap.createForFieldAtWorldPositionSimple )
						status, vehicle.aiveCurrentField, hektar = coroutine.resume( vehicle.aiveCurrentFieldCo, x1, z1, stepLog2, 1, checkFunction, AIVEGlobals.yieldCount )
					end
					if status then
						vehicle.aiveCurrentFieldCS = coroutine.status( vehicle.aiveCurrentFieldCo )
					else
						message = tostring(vehicle.aiveCurrentField)
print("Error in fieldBitmap.lua: "..tostring(message))						
						vehicle.aiveCurrentField   = nil
						vehicle.aiveCurrentFieldCo = nil
						vehicle.aiveCurrentFieldCS = 'dead'
					end
				end
			end
		elseif  vehicle.aiveCurrentFieldCS ~= 'dead' 
				and vehicle.aiveCurrentFieldCt < g_currentMission.time then
			vehicle.aiveCurrentFieldCt = g_currentMission.time
			status, vehicle.aiveCurrentField, hektar = coroutine.resume( vehicle.aiveCurrentFieldCo )				
			if status then
				vehicle.aiveCurrentFieldCS = coroutine.status( vehicle.aiveCurrentFieldCo )
			else
				message = tostring(vehicle.aiveCurrentField)
print("Error in fieldBitmap.lua: "..tostring(message))						
				vehicle.aiveCurrentField   = nil
				vehicle.aiveCurrentFieldCo = nil
				vehicle.aiveCurrentFieldCS = 'dead'
			end
		end
		
		if     status then
		-- still running 
			AIVehicleExtension.showWarning( vehicle, AIVehicleExtension.getText( "AIVE_FIELD_W", "Field detection is running" )..string.format(" (%0.3f ha)", hektar), 500 )
		elseif vehicle.aiveCurrentField == nil then
		-- failed 
			AIVehicleExtension.showWarning( vehicle, AIVehicleExtension.getText( "AIVE_FIELD_E", "Field detection failed" ).." ("..message..")", 500 )
		end 
		
		if vehicle.aiveCurrentFieldCo ~= nil then
			if vehicle.aiveCurrentFieldCS == 'dead' then
				vehicle.aiveCurrentFieldCo = nil
			elseif vehicle.aiveCurrentField ~= nil then
				print("ups")
				vehicle.aiveCurrentField = nil
			end
		end
	end
end

------------------------------------------------------------------------
-- checkField
------------------------------------------------------------------------
function AutoSteeringEngine.checkField( vehicle, x, z )
	if vehicle.aiveCurrentField == nil then 
		if vehicle.aiveChain.useAIFieldFct then 
			return true
		else 
			return AutoSteeringEngine.checkFieldNoBuffer( x, z, FieldBitmap.isFieldFast ) 
		end 
	else
		return vehicle.aiveCurrentField.getBit( x, z )
	end
end

------------------------------------------------------------------------
-- isFieldAhead
------------------------------------------------------------------------
function AutoSteeringEngine.isFieldAhead( vehicle, distance, node )
	if node == nil then
		node = vehicle.aiveChain.refNode
	end
	
	local w = math.max( 1, 0.25 * vehicle.aiveChain.width )--+ 0.13 * vehicle.aiveChain.headland )
	
	for j=-2,2 do
		local x,y,z = localToWorld( node, j * w, 0, distance )
		if AutoSteeringEngine.checkField( vehicle, x, z ) then return true end
	end
	return false
	
end

------------------------------------------------------------------------
-- initHeadlandVector
------------------------------------------------------------------------
function AutoSteeringEngine.initHeadlandVector( vehicle )

--if vehicle.aiveChain.isTurnMode7 then
--	vehicle.aiveChain.headland = vehicle.aiveChain.width 
--end

	if      vehicle.aiveChain         ~= nil
	    and vehicle.aiveChain.refNode ~= nil then
		local x,_,z = AutoSteeringEngine.getAiWorldPosition( vehicle )
		if     vehicle.aiveChain.collisionDists == nil
				or vehicle.aiveChain.collisionDistX == nil
				or vehicle.aiveChain.collisionDistZ == nil
				or AIVEUtils.vector2LengthSq( vehicle.aiveChain.collisionDistX - x, vehicle.aiveChain.collisionDistZ - z ) > 2 then
			vehicle.aiveChain.collisionDists      = {}
			vehicle.aiveChain.collisionDistX      = x
			vehicle.aiveChain.collisionDistZ      = z
			vehicle.aiveChain.collisionDistPoints = nil
		end
	end
	
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return end
	
	AutoSteeringEngine.rotateHeadlandNode( vehicle )
	local w = vehicle.aiveChain.width
	local w = math.max( 1, 0.25 * w )--+ 0.13 * vehicle.aiveChain.headland )	
	local d = 0
	if      AIVEGlobals.ignoreDist > 0 
			and vehicle.aiveChain.turnMode  ~= "C"
			and vehicle.aiveChain.turnMode  ~= "L"
			and vehicle.aiveChain.turnMode  ~= "K" 
			and vehicle.aiveChain.turnMode  ~= "7" then
		if d < AIVEGlobals.ignoreDist then
			d = AIVEGlobals.ignoreDist
		end
		if ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
			for i=1,table.getn(vehicle.aiveChain.toolParams) do
				local d2 = math.abs( vehicle.aiveChain.toolParams[i].zReal - vehicle.aiveChain.toolParams[i].zBack )
				if d < d2 and vehicle.aiveChain.tools[vehicle.aiveChain.toolParams[i].i].isSowingMachine then 
					d = d2
				end
			end
		end
	end
	d = d + vehicle.aiveChain.headland
	
	vehicle.aiveChain.headlandVector       = {}
	vehicle.aiveChain.headlandVector.front = {}
	vehicle.aiveChain.headlandVector.back  = {}
	for j=1,5 do
		local front = {}
		front.x,_,front.z   = localDirectionToWorld( vehicle.aiveChain.headlandNode, (j-3)*w, 0, d )
		--front.x1,_,front.z1 = localDirectionToWorld( vehicle.aiveChain.headlandNode, (j-3)*w, 0, 1 )
		vehicle.aiveChain.headlandVector.front[j] = front
		
		local back  = {}
		back.x,_,back.z   = localDirectionToWorld( vehicle.aiveChain.headlandNode, (j-3)*w, 0,-d )
		--back.x1,_,back.z1 = localDirectionToWorld( vehicle.aiveChain.headlandNode, (j-3)*w, 0, 1 )
		vehicle.aiveChain.headlandVector.back[j]  = back
	end
end

------------------------------------------------------------------------
-- isChainPointOnField
------------------------------------------------------------------------
function AutoSteeringEngine.isChainPointOnField( vehicle, xw, zw )
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return true end
	
	local front = false
	local back  = false

	for j=1,5 do
		if AutoSteeringEngine.checkField( vehicle, xw + vehicle.aiveChain.headlandVector.front[j].x, zw + vehicle.aiveChain.headlandVector.front[j].z ) then
			front = true
		end
		if not ( vehicle.aiveChain.respectStartNode ) then
			back = true
		elseif AutoSteeringEngine.checkField( vehicle, xw + vehicle.aiveChain.headlandVector.back[j].x, zw + vehicle.aiveChain.headlandVector.back[j].z ) then
			back = true
		end
	end
	
	return front 
end

------------------------------------------------------------------------
-- isNotHeadland
------------------------------------------------------------------------
function AutoSteeringEngine.isNotHeadland( vehicle, distance )
	local x,y,z
	local fRes  = true
	local angle = AutoSteeringEngine.getTurnAngle( vehicle )
	local dist  = distance
	
	if vehicle.aiveChain.headland < 1E-3 then return true end
	
	if math.abs(angle)> 0.5*math.pi then
		dist = -dist
	end
	
	--if vehicle.aiveChain.headland > 0 then		
		setRotation( vehicle.aiveChain.headlandNode, 0, -angle, 0 )
		
		local d = dist + ( vehicle.aiveChain.headland + 1 )
		for i=0,d do
			if not AutoSteeringEngine.isFieldAhead( vehicle, d, vehicle.aiveChain.headlandNode ) then
				fRes = false
				break
			end
		end
		
		if fRes then
			d = dist - ( vehicle.aiveChain.headland + 1 )
			for i=0,d do
				if not AutoSteeringEngine.isFieldAhead( vehicle, d, vehicle.aiveChain.headlandNode ) then
					fRes = false
					break
				end
			end
		end
	--end
	
	return fRes
end

------------------------------------------------------------------------
-- getChainPoint
------------------------------------------------------------------------
function AutoSteeringEngine.getChainPoint( vehicle, i, tp )

	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return 0,0 end
	
	local tpx = tp.x
	
	if      AutoSteeringEngine.hasArticulatedAxis( vehicle )
			and vehicle.aiveChain.currentSteeringAngle ~= nil
			and not ( vehicle.aiveChain.tools[tp.i].aiForceTurnNoBackward ) then
		local t0 = 0.5 * vehicle.aiveChain.currentSteeringAngle / vehicle.aiveChain.maxSteering 
		local t1 = 0.5 * vehicle.aiveChain.nodes[i].steering    / vehicle.aiveChain.maxSteering 
		tpx = tpx + t0 - t1
	end
	
	if not ( vehicle.aiveChain.nodes[i].status       >= AIVEStatus.position
       and vehicle.aiveChain.nodes[i].tool[tp.i]   ~= nil 
			 and vehicle.aiveChain.nodes[i].tool[tp.i].x ~= nil 
			 and vehicle.aiveChain.nodes[i].tool[tp.i].z ~= nil ) then
				
		vehicle.aiveChain.nodes[i].tool[tp.i] = {}
		vehicle.aiveChain.nodes[i].tool[tp.i].a = tp.angle 

		local x,y,z
		
		local r = 0
		if i == 1 and ( tp.attacherRotFactor < 0.01 or tp.attacherRotFactor > 0.01 ) then 
			r = tp.attacherRotFactor * vehicle.aiveChain.nodes[i].steering 
		end 
		x,y,z = getRotation( vehicle.aiveChain.nodes[i].index )
		if math.max( math.abs( x ) , math.abs( y - r ), math.abs( z ) ) > 1e-5 then		
			setRotation( vehicle.aiveChain.nodes[i].index, 0, r, 0 )
		end		

		x,y,z = getTranslation( vehicle.aiveChain.nodes[i].index3 )
		if math.max( math.abs( x ) , math.abs( y ), math.abs( tp.b1 - z ) ) > 1e-4 then
			setTranslation( vehicle.aiveChain.nodes[i].index3, 0, 0, tp.b1 )
		end
		x,y,z = getTranslation( vehicle.aiveChain.nodes[i].index4 )
		if math.max( math.abs( x ) , math.abs( y ), math.abs( tp.z - tp.b1 - z ) ) > 1e-4 then
			setTranslation( vehicle.aiveChain.nodes[i].index4, 0, 0, tp.z - tp.b1 )
		end
		
		if math.abs( tp.b2 + tp.b3 ) > 1E-3 and AIVEGlobals.offTracking ~= 0 then
			if AIVEGlobals.offTracking > 0 then
				if i > vehicle.aiveChain.chainStart then
					local dx, dy, dz = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.nodes[i].index, vehicle.aiveChain.nodes[i-1].index4 )
					dz = dz - tp.b1
					local oldAngle   = AIVEUtils.getNoNil( vehicle.aiveChain.nodes[i-1].tool[tp.i].a, tp.angle )
					local newAngle   = math.atan2( dx, -dz )
					vehicle.aiveChain.nodes[i].tool[tp.i].a = AIVEGlobals.offTracking * newAngle + ( 1 - AIVEGlobals.offTracking ) * oldAngle			
				end
			else
				if i <= vehicle.aiveChain.chainMax then
					x,y,z = getTranslation( vehicle.aiveChain.nodes[i+1].index3 )
					if math.max( math.abs( x ) , math.abs( y ), math.abs( tp.b1 - z ) ) > 1e-4 then
						setTranslation( vehicle.aiveChain.nodes[i+1].index3, 0, 0, tp.b1 )
					end 
					local dx, dy, dz = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.nodes[i+1].index, vehicle.aiveChain.nodes[i].index4 )
					dz = dz - tp.b1
					local oldAngle   = tp.angle
					if i > 1 then 
						oldAngle = vehicle.aiveChain.nodes[i-1].tool[tp.i].a
					end
					local newAngle   = math.atan2( dx, -dz )
					vehicle.aiveChain.nodes[i].tool[tp.i].a = -AIVEGlobals.offTracking * newAngle + ( 1 + AIVEGlobals.offTracking ) * oldAngle			
				else
					vehicle.aiveChain.nodes[i].tool[tp.i].a = vehicle.aiveChain.nodes[i-1].tool[tp.i].a
				end 
			end
		end
			
		x,y,z = getRotation( vehicle.aiveChain.nodes[i].index3 )
		if math.max( math.abs( x ) , math.abs( y + vehicle.aiveChain.nodes[i].tool[tp.i].a ), math.abs( z ) ) > 1e-5 then		
			setRotation( vehicle.aiveChain.nodes[i].index3, 0, -vehicle.aiveChain.nodes[i].tool[tp.i].a, 0 )
		end
			
		local idx = vehicle.aiveChain.nodes[i].index4
		local ofs = tpx
		
		vehicle.aiveChain.nodes[i].tool[tp.i].x, vehicle.aiveChain.nodes[i].tool[tp.i].y, vehicle.aiveChain.nodes[i].tool[tp.i].z = localToWorld( idx, ofs, 0, 0 )
		vehicle.aiveChain.nodes[i].status = AIVEStatus.position
	end

	return vehicle.aiveChain.nodes[i].tool[tp.i].x, vehicle.aiveChain.nodes[i].tool[tp.i].y, vehicle.aiveChain.nodes[i].tool[tp.i].z
end

------------------------------------------------------------------------
-- getChainSegment
------------------------------------------------------------------------
function AutoSteeringEngine.getChainSegment( vehicle, i, tp )
	local x1,y1,z1 = AutoSteeringEngine.getChainPoint( vehicle, i, tp )
	local x2,y2,z2 = AutoSteeringEngine.getChainPoint( vehicle, i+1, tp )
	
	if not ( vehicle.aiveChain.tools[tp.i].aiForceTurnNoBackward ) then
		local x0,y0,z0
		if i == 1 then
			x0,y0,z0 = localToWorld( vehicle.aiveChain.nodes[1].index4, tp.x, 0, -vehicle.aiveChain.nodes[1].length )
		else
			x0,y0,z0 = AutoSteeringEngine.getChainPoint( vehicle, i-1, tp )
		end
			
		local x4 = 0.25 * ( x0 + x1 + x1 + x2 )
		local z4 = 0.25 * ( z0 + z1 + z1 + z2 )
		local dx = x1 - x4
		local dz = z1 - z4
		
		local lx,_,lz = worldDirectionToLocal( vehicle.aiveChain.nodes[i].index4, dx, 0, dz )
		
		if vehicle.aiveChain.leftActive	then
			if lx < 0 then				
				return x1+dx,y1,z1+dz, x2+dx,y2,z2+dz
			end
		else
			if lx > 0 then
				return x1+dx,y1,z1+dz, x2+dx,y2,z2+dz
			end
		end
	end
	
	return x1,y1,z1, x2,y2,z2
end

------------------------------------------------------------------------
-- normalizePosition
------------------------------------------------------------------------
function AutoSteeringEngine.normalizePosition( vehicle, x, z )
	AutoSteeringEngine.initWorldToDensity( vehicle )
	
	local nx = math.floor(x*vehicle.aiveChain.worldToDensity+0.5) * vehicle.aiveChain.worldToDensityI
	local nz = math.floor(z*vehicle.aiveChain.worldToDensity+0.5) * vehicle.aiveChain.worldToDensityI
		
	return nx, nz
end

------------------------------------------------------------------------
-- getChainBorder
------------------------------------------------------------------------
function AutoSteeringEngine.getChainBorder( vehicle, i1, i2, toolParam, detectWidth, offsetInsideFactor )
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return 0,0 end
	
	local b,t    = 0,0
	local bo,to  = 0,0
	local bw,tw  = 0,0
	local d      = false
	local i      = math.max( 1, i1 )
	local count  = 0
	local ll     = 0
	local lo     = math.huge
	local offsetOutside = -1
	
	if vehicle.aiveChain.leftActive	then
		offsetOutside = 1
	end
	
	local fcOffset = -offsetOutside * toolParam.width
	local lastDetectedDist = math.huge
	if detectWidth then
		lastDetectedDist = 0
	end
	local dx, _, dz = localDirectionToWorld( vehicle.aiveChain.refNode, -offsetOutside, 0, 0 )
	
	if i <= vehicle.aiveChain.chainMax then
		local xp,yp,zp = AutoSteeringEngine.getChainPoint( vehicle, i, toolParam )
		local fp       = AutoSteeringEngine.isChainPointOnField( vehicle, xp, zp )
		local ncp      = not AutoSteeringEngine.hasCollision( vehicle, vehicle.aiveChain.nodes[i].index )
		
		while i<=i2 and i<=vehicle.aiveChain.chainMax do		
			local x2,y2,z2 -- = AutoSteeringEngine.getChainPoint( vehicle, i+1, toolParam )
			xp,yp,zp, x2,y2,z2 = AutoSteeringEngine.getChainSegment( vehicle, i, toolParam )
			local xc       = x2
			local yc       = y2
			local zc       = z2
			local f2       = AutoSteeringEngine.isChainPointOnField( vehicle, xc, zc )
			local fc       = f2
			local ncc      = not AutoSteeringEngine.hasCollision( vehicle, vehicle.aiveChain.nodes[i+1].index )
			
			if vehicle.aiveChain.nodes[i].tool[toolParam.i] == nil then
				AIVehicleExtension.printCallstack()
				AITractor.stopAITractor(vehicle)
			end
			
			local bi, ti = 0, 0
			local bj, tj = 0, 0
			local bk, tk = 0, -1
			local fi     = false
			
			if  		AIVEGlobals.borderBuffer > 0
					and vehicle.aiveChain.nodes[i].status >= AIVEStatus.border
					and vehicle.aiveChain.nodes[i].tool[toolParam.i].b ~= nil
					and vehicle.aiveChain.nodes[i].tool[toolParam.i].t ~= nil then
					
				if vehicle.aiveChain.nodes[i].tool[toolParam.i].t >= 0 then
					fi = true
					bi = vehicle.aiveChain.nodes[i].tool[toolParam.i].b
					ti = vehicle.aiveChain.nodes[i].tool[toolParam.i].t
					bj = vehicle.aiveChain.nodes[i].tool[toolParam.i].bo
					tj = vehicle.aiveChain.nodes[i].tool[toolParam.i].to
				end
				
			else			
				vehicle.aiveChain.nodes[i].status = AIVEStatus.border
				vehicle.aiveChain.nodes[i].tool[toolParam.i].t  = -1
				vehicle.aiveChain.nodes[i].tool[toolParam.i].b  = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].bo = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].to = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].bw = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].tw = -1
				
				if ncp and ncc and fp then
						
					local f = 1
					while f > 0.01 do
						xc = xp + f*(x2-xp)
						yc = yp + f*(y2-yp)
						zc = zp + f*(z2-zp) 
						
						if f == 1 then
							fc = f2
						else
							fc = AutoSteeringEngine.isChainPointOnField( vehicle, xc, zc )
						end
						if fc then
							fi = true
							break
						end
						f = f - 0.334
					end
					
					if      fi
							and vehicle.aiveChain.respectStartNode 
							and ( AutoSteeringEngine.getRelativeZTranslation( vehicle.aiveChain.startNode, vehicle.aiveChain.nodes[i].index )   < 0
								 or AutoSteeringEngine.getRelativeZTranslation( vehicle.aiveChain.startNode, vehicle.aiveChain.nodes[i+1].index ) < 0 ) then
					--print("respecting start node "..tostring(i))
						fi = false
					end
					
					if      fi
							and vehicle.aiveChain.toolCount > 1
							and vehicle.aiveChain.nodes[i].distance < 5
							and ( ( vehicle.aiveChain.tools[toolParam.i].isSowingMachine and ( vehicle.aiveHas.cultivator or vehicle.aiveHas.plow ) )
								 or ( vehicle.aiveChain.tools[toolParam.i].isCultivator and vehicle.aiveHas.plow ) )
							then 
						fi = false 
					end 
					
					if      fi 
							and AIVEGlobals.shiftFixZ > 0
							and not vehicle.aiveChain.tools[toolParam.i].aiForceTurnNoBackward
							and vehicle.aiveChain.nodes[i].distance < - toolParam.zReal 
							then 
						fi = false 
					end 
					
					if fi then	
						vehicle.aiveChain.nodes[i].tool[toolParam.i].t  = 0
						
						bi, ti  = AutoSteeringEngine.getFruitArea( vehicle, xp, zp, xc, zc, offsetOutside, toolParam.i )		

						if vehicle.aiveChain.collectCbr then
							local cbr = { AutoSteeringEngine.getParallelogram( xp, zp, xc, zc, offsetOutside ) }
							cbr[7]    = bi
							cbr[8]    = ti
							cbr[9]    = 1
							if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
							table.insert( vehicle.aiveChain.cbr, cbr )
						end
						
						local offsetInside = toolParam.offsetStd
						
						if     AIVEGlobals.widthDec < 0 then
						elseif i == 1 or vehicle.aiveChain.nodes[i].distance + vehicle.aiveChain.minZ <= 0 then
							offsetInside = 0
						elseif AIVEGlobals.widthDec > 0 then
							if vehicle.aiveChain.widthDecFactor ~= nil then
								local w = toolParam.width
								if 0 < AIVEGlobals.widthMaxDec and AIVEGlobals.widthMaxDec < w then
									w = AIVEGlobals.widthMaxDec
								end
								w = w * vehicle.aiveChain.widthDecFactor
								if offsetInsideFactor ~= nil then
									w = w * offsetInsideFactor
								end
								offsetInside = offsetInside + w * AIVEGlobals.widthDec * ( vehicle.aiveChain.nodes[i].distance + vehicle.aiveChain.minZ )
							--if AIVEGlobals.fruitBuffer > 0 then
									offsetInside = math.max( vehicle.aiveChain.worldToDensityI, offsetInside )
							--end
							end
						end
						
						if math.abs( offsetInside ) < 0.01 or bi > AIVEGlobals.ignoreBorder then
							bj = bi
							tj = ti
						else
							local xpj = xp + offsetInside * dx
							local zpj = zp + offsetInside * dz
							local xcj = xc + offsetInside * dx
							local zcj = zc + offsetInside * dz
							bj, tj = AutoSteeringEngine.getFruitArea( vehicle, xpj, zpj, xcj, zcj, offsetOutside, toolParam.i )			

							if vehicle.aiveChain.collectCbr then
								local cbr = { AutoSteeringEngine.getParallelogram( xpj, zpj, xcj, zcj, offsetOutside ) }
								cbr[7]    = bj
								cbr[8]    = tj
								cbr[9]    = 2
								if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
								table.insert( vehicle.aiveChain.cbr, cbr )
							end						
						end
						
						vehicle.aiveChain.nodes[i].tool[toolParam.i].b  = bi
						vehicle.aiveChain.nodes[i].tool[toolParam.i].t  = ti
						vehicle.aiveChain.nodes[i].tool[toolParam.i].bo = bj
						vehicle.aiveChain.nodes[i].tool[toolParam.i].to = tj
					end
				end
			end
			
			if     bi > AIVEGlobals.ignoreBorder then		
				bk = 0
				tk = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].bw = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].tw = 0
			elseif vehicle.aiveChain.nodes[i].distance > 10 then
				bk = 0
				tk = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].bw = 0
				vehicle.aiveChain.nodes[i].tool[toolParam.i].tw = 0
			elseif bj > AIVEGlobals.ignoreBorder then
				bk = bj
				tk = tj
			elseif tk < 0 and fi then
				local xs, zs, xw, zw, xl, zw
				local l = toolParam.width / AIVEUtils.vector2Length( xp-xc, zp-zc )
				
				local w = math.max( AIVEGlobals.testOutside, toolParam.width * 0.25 )
				
				xs = xp + toolParam.offsetStd * dx
				zs = zp + toolParam.offsetStd * dz
				if l <= 1 then
					xl = xc
					zl = zc 
				end
				
				local xm = xp + w * dx
				local zm = zp + w * dz
				if AutoSteeringEngine.isChainPointOnField( vehicle, xm, zm ) then					
					xw = xm
					zw = zm
				end
				
				if xw == nil then
					for m=10,0,-1 do
						local xm = xp + 0.1 * m * w * dx
						local zm = zp + 0.1 * m * w * dz
						
						if AutoSteeringEngine.isChainPointOnField( vehicle, xm, zm ) then					
							if xw == nil then
								xw = xm
								zw = zm
								if xs ~= nil then
									break
								end
							else
								xs = xm
								zs = zm
							end
						end
					end
				end
				
				if xl == nil and xs ~= nil and xw ~= nil then
					for n=7,1,-1 do
						local xn = xs + ( xc - xp ) * l * 0.1 * n
						local zn = zs + ( zc - zp ) * l * 0.1 * n

						if AutoSteeringEngine.isChainPointOnField( vehicle, xn, zn ) then
							xl = xn
							zl = zn
							break
						end
					end
				end
				
				if xs ~= nil and xw ~= nil and xl ~= nil then
					bk, tk = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, toolParam.i, xs, zs ,xw, zw, xl, zl )
					if vehicle.aiveChain.collectCbr then
						if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
						table.insert( vehicle.aiveChain.cbr, { xs, zs ,xw, zw, xl, zl, bk, tk, 3 } )
					end
				else
					bk = 0
					tk = 1 
				end
		
				vehicle.aiveChain.nodes[i].tool[toolParam.i].bw = bk
				vehicle.aiveChain.nodes[i].tool[toolParam.i].tw = tk
			else
				bk = vehicle.aiveChain.nodes[i].tool[toolParam.i].bw
				tk = vehicle.aiveChain.nodes[i].tool[toolParam.i].tw
			end

			if b <= 0 then
				ll = vehicle.aiveChain.nodes[i+1].distance
			end
			
			if AIVEGlobals.ignoreFactor > 0 then 
				local f = AIVEGlobals.ignoreFactor
				local d = AIVEGlobals.ignoreFactor * AIVEGlobals.ignoreFactor
				local l = vehicle.aiveChain.nodes[i].distance
			--if toolParam.z < 0 then 
			--	l = l - toolParam.z
			--end 
				if 10 * l < d then 
					f = f * 0.1
				elseif l < d then 
					f = f * l / d
				end 
				bi = bi * f 
				ti = ti * f 
			end 
			
			if fi then
				b  = b  + bi
				t  = t  + ti
				bo = bo + bj
				to = to + tj
				
				if tk >= 0 then
					bw = bw + bk
					tw = tw + tk
				end
								
				vehicle.aiveChain.nodes[i].isField = true
				if bi > 0 then
					vehicle.aiveChain.nodes[i].hasBorder = true
				end
				
				if bi > 0 or bj > 0 and vehicle.aiveChain.nodes[i].distance < lo then
					lo = vehicle.aiveChain.nodes[i].distance
				end
			end
			
			if b > AIVEGlobals.ignoreBorder or ( b > 0 and ll > 10 ) then
				return b, t, bo, to, bw, tw, ll, lo
			end
			
			i = i + 1
			xp = x2
			yp = yc
			zp = z2
			fp = f2
			ncp = ncc
		end
	end
	
	return b, t, bo, to, bw, tw, ll, lo
end

------------------------------------------------------------------------
-- getAllChainBorders
------------------------------------------------------------------------
function AutoSteeringEngine.getAllChainBorders( vehicle, i1, i2, detectWidth, offsetInsideFactor )
	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return 0,0,0,0,0 end
	
	local b1,t1 = 0,0
	local b2,t2 = 0,0
	local b3,t3 = 0,0
	local ll    = 0
	local lo    = math.huge
	
	if i1 == nil then i1 = 1 end
	if i2 == nil then i2 = vehicle.aiveChain.chainMax end
	
	local i      = i1
	if 1 <= i and i <= vehicle.aiveChain.chainMax then
		while i<=i2 and i<=vehicle.aiveChain.chainMax do				
			vehicle.aiveChain.nodes[i].hasBorder = false
			i = i + 1
		end
	end
		
	for _,tp in pairs(vehicle.aiveChain.toolParams) do	
		if not ( tp.skip ) then
			local bi,ti,bj,tj,bk,tk,l,lj = AutoSteeringEngine.getChainBorder( vehicle, i1, i2, tp, detectWidth, offsetInsideFactor )				
			if bi > 0 then
				if b1 > 0 then
					ll = math.min( ll, l )
				else
					ll = l
				end
			elseif b1 <= 0 then
				ll = math.max( ll, l )
			end
			lo = math.min( lo, lj )
			b1 = math.max( b1, bi )
			t1 = math.max( t1, ti )
			b2 = math.max( b2, bj )
			t2 = math.max( t2, tj )
			b3 = math.max( b3, bk )
			t3 = math.max( t3, tk )
		end
	end
	
	return b1,t1,b2,t2,b3,t3,ll,lo
end

------------------------------------------------------------------------
-- getSteeringParameterOfTool
------------------------------------------------------------------------
function AutoSteeringEngine.getSteeringParameterOfTool( vehicle, toolIndex, maxLooking, widthOffset, widthFactor )
	
	local toolParam = {}
	toolParam.i       = toolIndex
	
	local tool = vehicle.aiveChain.tools[toolIndex]
	local maxAngle, minAngle
	local xl = -999
	local xr = 999
	local zb = 999
	local il, ir, ib, i1, zl, zr	
	
	toolParam.attacherRotFactor = 0
	toolParam.limitOutside = false
	toolParam.limitInside  = false
	if AIVEGlobals.limitOutside > 0 then --and tool.hasFruits then
		toolParam.limitOutside = true
	end
	if AIVEGlobals.limitInside  > 0 then
		toolParam.limitInside  = true
	end
	
	if tool.aiForceTurnNoBackward then
		local x1, z1, i1
	
--  no reverse allowed	
		local xOffset,_,zOffset = AutoSteeringEngine.getRelativeTranslation( tool.steeringAxleNode, tool.refNode )
		if xOffset == nil or zOffset == nil then
			xOffset = 0 
			zOffset = 0 
		end
		
		if tool.backMarker ~= nil then
			_,_,zb = AutoSteeringEngine.getRelativeTranslation( tool.steeringAxleNode, tool.backMarker )
			if zb == nil then zb = 0 end			
			zb = zb - zOffset
		end
		
		for i=1,table.getn(tool.marker) do
			local xxx,_,zzz = AutoSteeringEngine.getRelativeTranslation( tool.steeringAxleNode, tool.marker[i] )
			xxx = xxx - xOffset
			zzz = zzz - zOffset
			if tool.invert then xxx = -xxx zzz = -zzz end
			if xl < xxx then xl = xxx zl = zzz il = i end
			if xr > xxx then xr = xxx zr = zzz ir = i end
			-- back marker!
			if zb > zzz then zb = zzz ib = i end
		end
		
		local width  = xl - xr		
		local offset = AutoSteeringEngine.getWidthOffset( vehicle, width, widthOffset, widthFactor )
		toolParam.offsetStd = AutoSteeringEngine.getWidthOffsetStd( vehicle, width )
		
		if offset > 0 then
			toolParam.offsetStd = toolParam.offsetStd + offset * 0.5
			offset = offset * 0.5
		end
		
		width = width - offset - offset

		if vehicle.aiveChain.leftActive	then
	-- left	
			x1 = xl - offset 
			z1 = zl
			i1 = il
		else
	-- right	
			x1 = xr + offset
			z1 = zr
			i1 = ir
		end
		
		if not ( tool.isPlow ) then
			z1 = 0.5 * ( z1 + zb )
		end
		
		local x0,_,z0 = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, tool.refNode )
		
		zb = zb + z0
		x1 = x1 + x0
		z1 = z1 + z0
		toolParam.zReal = z1
		
	--if vehicle.aiveDebugTimer == nil or vehicle.aiveDebugTimer < g_currentMission.time then
	--	vehicle.aiveDebugTimer = g_currentMission.time + 1000		
	--	print(string.format("l: %1.2f r: %1.2f o: %1.2f xo: %1.2f zo: %1.2f x1: %1.2f z1: %1.2f", xl, xr, offset, xOffset, zOffset, x1, z1 ) )
	--end
		
		local b1,b2,b3 = z1, 0, 0

	--local r1 = math.sqrt( x1*x1 + b1*b1 )		
	--r1       = ( 1 + AIVEGlobals.minMidDist ) * ( r1 + math.max( 0, -b1 ) )
	--local a1 = math.atan( vehicle.aiveChain.wheelBase / r1 )
		local r1 = vehicle.aiveChain.radius 
		local a1 = maxLooking
		
		local toolAngle = 0
	
		if b1 < 0 then
			local tr   = 0
			tr, b1, b2 = AutoSteeringEngine.getToolRadius( vehicle, tool.refNode, tool.obj, true )
			
			if tool.b3 ~= nil then
				b3 = tool.b3
			end
			
			toolAngle = AutoSteeringEngine.getRelativeYRotation( vehicle.aiveChain.refNode, tool.steeringAxleNode )
			if tool.invert then
				if toolAngle < 0 then
					toolAngle = toolAngle + math.pi
				else
					toolAngle = toolAngle - math.pi
				end
			end
			
			if tool.doubleJoint then
				toolAngle = toolAngle + toolAngle
			end

		--z1 = 0.5 * ( b1 + z1 )
		end

		toolParam.x        = x1
		toolParam.z        = z1
		toolParam.zBack    = zb
		toolParam.nodeBack = tool.marker[ib]
		toolParam.nodeLeft = tool.marker[il]
		toolParam.nodeRight= tool.marker[ir]
		toolParam.b1       = b1
		toolParam.b2       = b2
		toolParam.b3       = b3
		toolParam.offset   = offset
		toolParam.width    = width
		toolParam.angle    = toolAngle
		toolParam.minRaduis= r1
		toolParam.refAngle = AIVEUtils.clamp( a1, vehicle.aiveChain.minLooking, maxLooking )
		toolParam.refAngle2= maxLooking

	else
		toolParam.attacherRotFactor = tool.attacherRotFactor
	
	
		local x1
		local z1 = -999
	
--  normal tool, can be lifted and reverse is possible
		if tool.backMarker ~= nil then
			_,_,zb = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, tool.backMarker )
		end
		
		for i=1,table.getn(tool.marker) do
			local xxx,_,zzz = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, tool.marker[i] )			
			if xl < xxx then xl = xxx zl = zzz il = i end
			if xr > xxx then xr = xxx zr = zzz ir = i end
			-- back marker!
			if zb > zzz then zb = zzz ib = i end
		end

		local width  = xl - xr
		local offset = AutoSteeringEngine.getWidthOffset( vehicle, width, widthOffset, widthFactor )
		toolParam.offsetStd = AutoSteeringEngine.getWidthOffsetStd( vehicle, width )

		if offset > 0 then
			toolParam.offsetStd = toolParam.offsetStd + offset * 0.5
			offset = offset * 0.5
		end
		
		width = width - offset - offset

		if vehicle.aiveChain.leftActive	then
	-- left	
			x1 = xl - offset
			z1 = zl
			i1 = il
		else
	-- right		
			x1 = xr + offset
			z1 = zr
			i1 = ir
		end

		toolParam.zReal = z1
				
		local dx 
		if vehicle.aiveChain.leftActive	then
			dx = x1
		else
			dx = -x1
		end

		local r0 = vehicle.aiveChain.radius 
		local r1 = math.max( r0, AIVEGlobals.minMidDist + dx )
		local r2 = vehicle.aiveChain.wheelBase / math.tan( maxLooking ) 
		
		if z1 < 0 and toolParam.offsetStd > 0 and ( toolParam.limitOutside or toolParam.limitInside ) then
			local of = 0.5 * toolParam.offsetStd			
		--print(AutoSteeringEngine.posToString(r1).." "..AutoSteeringEngine.posToString(z1).." "..AutoSteeringEngine.posToString(of).." "..AutoSteeringEngine.posToString(dx))			
			if toolParam.limitOutside then
				local rn = dx + ( of*of + z1*z1 ) / ( of+of )
			--print(AutoSteeringEngine.posToString(rn))
				r1 = math.max( r1, rn )
			end
			
			if toolParam.limitInside then
				local rn = dx + ( of*of + zb*zb ) / ( of+of )
			--print(AutoSteeringEngine.posToString(rn))
				r2 = math.max( r2, rn )
			end			
		end
		
		local a1 = math.max( vehicle.aiveChain.minLooking, math.atan( vehicle.aiveChain.wheelBase / r1 ) )
		local a2 = math.max( vehicle.aiveChain.minLooking, math.atan( vehicle.aiveChain.wheelBase / r2 ) )
		
	--if AIVEGlobals.shiftFixZ > 0 and z1 < 0 and not tool.isPlow then
	--	z1 = math.max( z1-2, zb )
	--end

	--if AIVEGlobals.shiftFixZ > 0 then
	--	z1 = math.abs( z1 )
	--end
		
	--local r1 = math.sqrt( x1*x1 + z1*z1 )		
	--r1       = ( 1 + AIVEGlobals.minMidDist ) * ( r1 + math.max( 0, -z1 ) )
	--local a1 = math.atan( vehicle.aiveChain.wheelBase / r1 )
	--local a2 = maxLooking 
	--
	--if z1 < 0 and toolParam.offsetStd > 0 and ( toolParam.limitOutside or toolParam.limitInside ) then
	--	local of = toolParam.offsetStd
	--	local zf = z1 + 0.1 * ( zb-z1 )
	--	local r2 = ( zf*zf - of*of ) / ( of+of )
	--	if vehicle.aiveChain.leftActive then
	--		r2 = r2 + xl
	--	else
	--		r2 = r2 - xr
	--	end
	--	print(tostring(r1).." "..tostring(r2).." "..tostring(z1).." "..tostring(of).." "..tostring(x1))
	--	if r2 < r1 then
	--		r2 = r1
	--	end
	--	
	--	if     toolParam.limitOutside and toolParam.limitInside then
	--		a2 = AIVEUtils.clamp(  math.atan( vehicle.aiveChain.wheelBase / r2 ), vehicle.aiveChain.minLooking, a2 )
	--		a1 = math.min( a1, a2 )
	--	elseif toolParam.limitOutside then
	--		a1 = AIVEUtils.clamp(  math.atan( vehicle.aiveChain.wheelBase / r2 ), vehicle.aiveChain.minLooking, a1 )
	--	end
	--end
		
		
		toolParam.x        = x1
		toolParam.z        = z1
		toolParam.zBack    = zb
		toolParam.nodeBack = tool.marker[ib]
		toolParam.nodeLeft = tool.marker[il]
		toolParam.nodeRight= tool.marker[ir]
		toolParam.b1       = z1
		toolParam.b2       = 0
		toolParam.b3       = 0
		toolParam.offset   = offset
		toolParam.width    = width
		toolParam.angle    = 0
		toolParam.minRaduis= r1
		toolParam.refAngle = a1
		toolParam.refAngle2= a2
	
	end

	if vehicle.aiveChain.leftActive then
		toolParam.minAngle = -math.min(toolParam.refAngle2, maxLooking )
		toolParam.maxAngle = math.min( toolParam.refAngle,  maxLooking )
	else
		toolParam.minAngle = -math.min(toolParam.refAngle,  maxLooking )
		toolParam.maxAngle = math.min( toolParam.refAngle2, maxLooking )
	end
	
	local wx,wy,wz = worldDirectionToLocal(vehicle.aiveChain.refNode, 0, 1, 0)
	local cf = math.abs( wy ) 
	toolParam.x        = toolParam.x      * cf
	toolParam.offset   = toolParam.offset * cf
	toolParam.width    = toolParam.width  * cf

	-- width is always left - right 
	if vehicle.aiveChain.leftActive then
	-- toolParam.x is left marker (the biggest one) => l - ( l - r ) = l - l + r = r
		toolParam.xOther = toolParam.x - toolParam.width
	else
	-- toolParam.x is right marker => r + l - r = l
		toolParam.xOther = toolParam.x + toolParam.width
	end
	
	return toolParam
end

------------------------------------------------------------------------
-- setChainStatus
------------------------------------------------------------------------
function AutoSteeringEngine.setChainStatus( vehicle, startIndex, newStatus )
	if newStatus > AIVEStatus.initial and AutoSteeringEngine.skipIfNotServer( vehicle ) then 
		return
	end
	
	if vehicle.aiveChain ~= nil and vehicle.aiveChain.nodes ~= nil then
		local i = math.max(startIndex,1)
		while i <= vehicle.aiveChain.chainMax + 1 do
			if vehicle.aiveChain.nodes[i].status > newStatus then
				vehicle.aiveChain.nodes[i].status = newStatus
				vehicle.aiveChain.nodes[i].tool   = {}
			end
			i = i + 1
		end
	end
end

------------------------------------------------------------------------
-- initSteering
------------------------------------------------------------------------
function AutoSteeringEngine.initSteering( vehicle )

	if AutoSteeringEngine.skipIfNotServer( vehicle ) then return end

	local mi = vehicle.aiveChain.minAngle 
	local ma = vehicle.aiveChain.maxAngle

	local check = { vehicle.aiveChain.fixAttacher,
									vehicle.aiveChain.chainMax,
									vehicle.aiveChain.minZ,
									vehicle.aiveChain.minAngle,
									vehicle.aiveChain.maxAngle }

	if vehicle.aiveChain.toolParams == nil or table.getn( vehicle.aiveChain.toolParams ) < 1 then
		vehicle.aiveChain.minAngle  = -vehicle.aiveChain.maxSteering
		vehicle.aiveChain.maxAngle  = vehicle.aiveChain.maxSteering
		vehicle.aiveChain.width     = 0
		vehicle.aiveChain.maxZ      = 0
		vehicle.aiveChain.minZ      = 0
		vehicle.aiveChain.activeX   = 0
		vehicle.aiveChain.otherX    = 0
		vehicle.aiveChain.offsetZ   = 0
		vehicle.aiveChain.backZ     = 0
		vehicle.aiveChain.offsetStd = 0
  else
		vehicle.aiveChain.minAngle  = nil
		vehicle.aiveChain.maxAngle  = nil
		vehicle.aiveChain.activeX   = nil
		vehicle.aiveChain.otherX    = nil
		
		vehicle.aiveChain.width     = 0
		vehicle.aiveChain.maxZ      = nil
		vehicle.aiveChain.minZ      = nil
		vehicle.aiveChain.offsetZ   = nil
		vehicle.aiveChain.backZ     = nil 
		vehicle.aiveChain.offsetStd = 0
		
		for _,tp in pairs(vehicle.aiveChain.toolParams) do							
			if vehicle.aiveChain.maxZ  == nil or vehicle.aiveChain.maxZ < tp.zReal then
				vehicle.aiveChain.maxZ  = tp.zReal
			end
			if vehicle.aiveChain.minZ  == nil or vehicle.aiveChain.minZ > tp.zReal then
				vehicle.aiveChain.minZ  = tp.zReal
			end
			if vehicle.aiveChain.offsetZ == nil then
				vehicle.aiveChain.offsetZ = tp.offset
			end
			local z = math.min( tp.zReal, tp.zBack ) - tp.z
			if vehicle.aiveChain.backZ == nil or vehicle.aiveChain.backZ > z then
				vehicle.aiveChain.backZ = z
			end
			
			local noSkipA = not ( tp.skip )
			local noSkipO = not ( tp.skipOther )
			
			if noSkipA then
				if vehicle.aiveChain.minAngle == nil or vehicle.aiveChain.minAngle < tp.minAngle then
					vehicle.aiveChain.minAngle = tp.minAngle
				end
				if vehicle.aiveChain.maxAngle == nil or vehicle.aiveChain.maxAngle > tp.maxAngle then
					vehicle.aiveChain.maxAngle = tp.maxAngle
				end
				if vehicle.aiveChain.offsetStd < tp.offsetStd then
					vehicle.aiveChain.offsetStd  = tp.offsetStd
				end
			end
			
			if vehicle.aiveChain.leftActive then
				if noSkipA and ( vehicle.aiveChain.activeX  == nil or vehicle.aiveChain.activeX > tp.x ) then
					vehicle.aiveChain.activeX = tp.x
					vehicle.aiveChain.offsetZ  = tp.offset
				end
				if noSkipO and ( vehicle.aiveChain.otherX  == nil or vehicle.aiveChain.otherX   < tp.xOther ) then
					vehicle.aiveChain.otherX  = tp.xOther 
				end
			else
				if noSkipA and ( vehicle.aiveChain.activeX  == nil or vehicle.aiveChain.activeX < tp.x ) then
					vehicle.aiveChain.activeX = tp.x
					vehicle.aiveChain.offsetZ  = tp.offset 
				end
				if noSkipO and ( vehicle.aiveChain.otherX  == nil or vehicle.aiveChain.otherX   > tp.xOther ) then
					vehicle.aiveChain.otherX  = tp.xOther
				end
			end
		end
  end
	
	if     vehicle.aiveChain.activeX == nil 
			or vehicle.aiveChain.otherX  == nil then
		vehicle.aiveChain.width   = 0
		vehicle.aiveChain.activeX = 0
		vehicle.aiveChain.otherX  = 0
	elseif vehicle.aiveChain.leftActive	then
		vehicle.aiveChain.width = vehicle.aiveChain.activeX - vehicle.aiveChain.otherX
	else
		vehicle.aiveChain.width = vehicle.aiveChain.otherX - vehicle.aiveChain.activeX
	end
	
	local fixAttacher = false
	for _,tp in pairs(vehicle.aiveChain.toolParams) do	
		if      vehicle.aiveChain.radius ~= nil
				and not ( tp.skip ) 				
				and not ( vehicle.aiveChain.tools[tp.i].aiForceTurnNoBackward )
				and not ( vehicle.aiveChain.tools[tp.i].ignoreAI )
				and math.abs( tp.x ) < vehicle.aiveChain.radius then
			fixAttacher = true
			break
		end
	end
	
	if not vehicle.aiveChain.leftActive then vehicle.aiveChain.offsetZ = -vehicle.aiveChain.offsetZ end
	
	if vehicle.aiveChain.minAngle == nil then
		vehicle.aiveChain.minAngle = -vehicle.aiveChain.maxSteering
	end
	if vehicle.aiveChain.maxAngle == nil then
		vehicle.aiveChain.maxAngle =  vehicle.aiveChain.maxSteering
	end	
	vehicle.aiveChain.angleFactor = AutoSteeringEngine.getAngleFactor( math.max( math.abs( vehicle.aiveChain.minAngle ), math.abs( vehicle.aiveChain.maxAngle ) ) )
	if not vehicle.aiveChain.leftActive	then
		vehicle.aiveChain.angleFactor = -vehicle.aiveChain.angleFactor
	end 
	
	vehicle.aiveChain.fixAttacher = fixAttacher
	
	vehicle.aiveChain.nodes      = vehicle.aiveChain.nodesLow
	vehicle.aiveChain.chainStep0 = AIVEGlobals.chain2Step0
	vehicle.aiveChain.chainStep1 = AIVEGlobals.chain2Step1
	vehicle.aiveChain.chainStep2 = AIVEGlobals.chain2Step2
	if fixAttacher then
		if vehicle.aiveChain.minZ < 0 then
			vehicle.aiveChain.nodes      = vehicle.aiveChain.nodesFix
			vehicle.aiveChain.chainStep0 = AIVEGlobals.chainStep0
			vehicle.aiveChain.chainStep1 = AIVEGlobals.chainStep1
			vehicle.aiveChain.chainStep2 = AIVEGlobals.chainStep2
		else
			vehicle.aiveChain.nodes      = vehicle.aiveChain.nodesCom
			vehicle.aiveChain.chainStep0 = AIVEGlobals.chain3Step0
			vehicle.aiveChain.chainStep1 = AIVEGlobals.chain3Step1
			vehicle.aiveChain.chainStep2 = AIVEGlobals.chain3Step2
		end
	end
	vehicle.aiveChain.chainMax = table.getn( vehicle.aiveChain.nodes ) - 1
	
	if      vehicle.aiveChain.angleBuffer ~= nil 
			and ( check[1] == nil or check[1] ~= vehicle.aiveChain.fixAttacher )
			and ( check[2] == nil or check[2] ~= vehicle.aiveChain.chainMax    )
			and ( check[3] == nil or math.abs( check[3] - vehicle.aiveChain.minZ     ) > 1e-3 ) 
			and ( check[4] == nil or math.abs( check[4] - vehicle.aiveChain.minAngle ) > 1e-3 )
			and ( check[5] == nil or math.abs( check[5] - vehicle.aiveChain.maxAngle ) > 1e-3 ) 
			then 
		vehicle.aiveChain.angleBuffer = nil
	end 
	
	AutoSteeringEngine.checkFieldIsValid( vehicle )	
	
	if mi == nil or ma == nil or math.abs( vehicle.aiveChain.minAngle - mi ) > 1E-4 or math.abs( vehicle.aiveChain.maxAngle - ma ) > 1E-4 then
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.initial )	
		AutoSteeringEngine.applyRotation( vehicle )		
	end

	AutoSteeringEngine.initHeadlandVector( vehicle )	

	if vehicle.aiveChain ~= nil and vehicle.aiveChain.nodes ~= nil then
		for i=1,vehicle.aiveChain.chainMax do	
			vehicle.aiveChain.nodes[i].isField = false
		end	
	end	
end

------------------------------------------------------------------------
-- getChainAngles
------------------------------------------------------------------------
function AutoSteeringEngine.getToolDistance( vehicle )
	if vehicle.aiveChain.maxZ == nil then
		return 0
	end
	return vehicle.aiveChain.maxZ
end

------------------------------------------------------------------------
-- getChainAngles
------------------------------------------------------------------------
function AutoSteeringEngine.getChainAngles( vehicle )
	local chainAngles = {}
	
	for j=1,vehicle.aiveChain.chainMax+1 do 
		chainAngles[j] = vehicle.aiveChain.nodes[j].angle
	end
	
	return chainAngles
end

------------------------------------------------------------------------
-- setChainAngles
------------------------------------------------------------------------
function AutoSteeringEngine.setChainAngles( vehicle, chainAngles, startIndex, mergeFactor )
	AutoSteeringEngine.setChainInt( vehicle, startIndex, "angles", nil, mergeFactor, chainAngles )
end

------------------------------------------------------------------------
-- setChainStraight
------------------------------------------------------------------------
function AutoSteeringEngine.setChainStraight( vehicle, startIndex, startAngle )	
	AutoSteeringEngine.setChainInt( vehicle, startIndex, "straight", startAngle )
end

------------------------------------------------------------------------
-- setChainOutside
------------------------------------------------------------------------
function AutoSteeringEngine.setChainOutside( vehicle, startIndex, angleSafety )
	AutoSteeringEngine.setChainInt( vehicle, startIndex, "outside", angleSafety )
end

------------------------------------------------------------------------
-- setChainContinued
------------------------------------------------------------------------
function AutoSteeringEngine.setChainContinued( vehicle, startIndex )
	AutoSteeringEngine.setChainInt( vehicle, startIndex, "continued" )
end

------------------------------------------------------------------------
-- setChainInside
------------------------------------------------------------------------
function AutoSteeringEngine.setChainInside( vehicle, startIndex )
	AutoSteeringEngine.setChainInt( vehicle, startIndex, "inside" )	
end

------------------------------------------------------------------------
-- setChainInt
------------------------------------------------------------------------
function AutoSteeringEngine.setChainInt( vehicle, startIndex, mode, angle, factor, chainAngles )
	if vehicle.aiveChain == nil or vehicle.aiveChain.chainMax == nil then
		return
	end
	
	local j0=1
	if startIndex ~= nil then
		j0 = math.max( startIndex, 1 )
	end

	local a 
	if AutoSteeringEngine.isSetAngleZero( vehicle ) then 
	  a = 0 
	else 
	  a = AIVEUtils.getNoNil( vehicle.aiveChain.currentSteeringAngle, 0 )
	end 
	local af = AIVEUtils.getNoNil( vehicle.aiveChain.angleFactor, AutoSteeringEngine.getAngleFactor( ) )
	
	local angleSafety = AIVEUtils.getNoNil( angle, AIVEGlobals.angleSafety )
	
	for j=j0,vehicle.aiveChain.chainMax+1 do 
		local old = vehicle.aiveChain.nodes[j].angle

		if     	mode  == "straight" 
				and angle ~= nil
				and j     == j0 then
			vehicle.aiveChain.nodes[j].angle = angle
		elseif  mode ~= "straight" 
				and AutoSteeringEngine.isNotHeadland( vehicle, vehicle.aiveChain.nodes[j].distance ) then
		
			if     mode == "outside" then
			-- setChainOutside
				vehicle.aiveChain.nodes[j].angle = angleSafety 
			elseif mode == "inside" then
			-- setChainInside
				vehicle.aiveChain.nodes[j].angle = -AIVEGlobals.angleSafety 
			elseif mode == "continued" then
			-- setChainContinued
				vehicle.aiveChain.nodes[j].angle = 0
			elseif mode == "angles" then
			-- setChainAngles
				if chainAngles == nil then
					print("Error: AutoSteeringEngine.setChainInt mode angles with empty chainAngles")				
				else
					vehicle.aiveChain.nodes[j].angle = AIVEUtils.getNoNil( chainAngles[j], 0 )
				end
			else
				print("Error: AutoSteeringEngine.setChainInt wrong mode: "..tostring(mode))				
			end
			
			if factor ~= nil then
				if     mode == "outside" then
					if j <= vehicle.aiveChain.chainMax then
						old = 0.8 * old + 0.2 * vehicle.aiveChain.nodes[j+1].angle
					end
					vehicle.aiveChain.nodes[j].angle = vehicle.aiveChain.nodes[j].angle + factor * ( old - vehicle.aiveChain.nodes[j].angle )
					if vehicle.aiveChain.nodes[j].angle < 0 then
						vehicle.aiveChain.nodes[j].angle = 0
					end
				else
					vehicle.aiveChain.nodes[j].angle = vehicle.aiveChain.nodes[j].angle + factor * ( old - vehicle.aiveChain.nodes[j].angle )
				end			
			end
		elseif j <= 1 then
			vehicle.aiveChain.nodes[j].angle = 0
	--elseif vehicle.aiveChain.nodes[j].length > 1E-3 then 
	--	AutoSteeringEngine.applyRotation( vehicle, j-1 )	
	--	
	--	local r = nil
	--	for i=1,j-1 do
	--		local q = math.abs( vehicle.aiveChain.nodes[i].rotation )
	--		if r == nil or r < q then
	--			r = q
	--		end
	--	end
	--	if vehicle.aiveChain.nodes[j-1].cumulRot == nil then
	--		vehicle.aiveChain.nodes[j-1].cumulRot = 0
	--	end			
	--	if r == nil then
	--		r = -0.5 * vehicle.aiveChain.nodes[j-1].cumulRot
	--	elseif vehicle.aiveChain.nodes[j-1].cumulRot > 0 then
	--		r = math.min(  r, vehicle.aiveChain.nodes[j-1].cumulRot )
	--	else
	--		r = math.max( -r, vehicle.aiveChain.nodes[j-1].cumulRot )
	--	end
	--	
	--	vehicle.aiveChain.nodes[j].rotation = -r
	--	vehicle.aiveChain.nodes[j].cumulRot = vehicle.aiveChain.nodes[j-1].cumulRot + r
	--	vehicle.aiveChain.nodes[j].invRadius  = math.sin( 0.5 * vehicle.aiveChain.nodes[j].rotation ) * 2 / vehicle.aiveChain.nodes[j].length
	--	if vehicle.aiveChain.nodes[j].invRadius > 1E-6 then
	--		vehicle.aiveChain.nodes[j].radius   = 1 / vehicle.aiveChain.nodes[j].invRadius
	--		vehicle.aiveChain.nodes[j].steering = math.atan2( vehicle.aiveChain.wheelBase, vehicle.aiveChain.nodes[j].radius )
	--	else
	--		vehicle.aiveChain.nodes[j].radius   = 1E+6
	--		vehicle.aiveChain.nodes[j].steering = 0
	--	end
	--	vehicle.aiveChain.nodes[j].tool     = {}
	--	
	--	setRotation( vehicle.aiveChain.nodes[j].index2, 0, vehicle.aiveChain.nodes[j].rotation, 0 )
	--	vehicle.aiveChain.nodes[j].status   = AIVEStatus.rotation
	--	
	--	if math.abs( vehicle.aiveChain.nodes[j].rotation ) < 1E-5 then
	--		vehicle.aiveChain.nodes[j].angle = 0
	--	else
	--		local r = vehicle.aiveChain.nodes[j].length / ( math.sin( -0.5 * vehicle.aiveChain.nodes[j].cumulRot ) * 2 )
	--		local b = math.atan( vehicle.aiveChain.wheelBase * vehicle.aiveChain.nodes[j].invRadius )
	--		vehicle.aiveChain.nodes[j].angle = AutoSteeringEngine.steering2ChainAngle( vehicle, b )				
	--	end
	--	old = vehicle.aiveChain.nodes[j].angle
	--
	--else
	--	vehicle.aiveChain.nodes[j].angle = 0
		else
			local r = nil
			for i=1,j-1 do
				local q = math.abs( vehicle.aiveChain.nodes[i].rotation )
				if r == nil or r < q then
					r = q
				end
			end
			if r == nil then r = 1 end
			
			vehicle.aiveChain.nodes[j].angle = 0
			AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
			AutoSteeringEngine.applyRotation( vehicle, j )
			if math.abs( vehicle.aiveChain.nodes[j].cumulRot ) > 1e-6 then
				local aMin, aMax = -r, r
				vehicle.aiveChain.nodes[j].angle = aMin
				AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
				AutoSteeringEngine.applyRotation( vehicle, j )
				local cMin = vehicle.aiveChain.nodes[j].cumulRot
				vehicle.aiveChain.nodes[j].angle = aMax
				AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
				AutoSteeringEngine.applyRotation( vehicle, j )
				local cMax = vehicle.aiveChain.nodes[j].cumulRot
				if     cMin > 0 and cMax > 0 then
					if     cMin < cMax then
						vehicle.aiveChain.nodes[j].angle = aMin
					else						vehicle.aiveChain.nodes[j].angle = aMax
					end
				elseif cMin < 0 and cMax < 0 then
					if     cMin > cMax then
						vehicle.aiveChain.nodes[j].angle = aMin
					else
						vehicle.aiveChain.nodes[j].angle = aMax
					end
				else
					local aLast = nil
					for i=1,5 do
						local aMid = ( aMin * cMax - aMax * cMin ) / ( cMax - cMin )
						vehicle.aiveChain.nodes[j].angle = aMid
						AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
						AutoSteeringEngine.applyRotation( vehicle, j )
						local cMid = vehicle.aiveChain.nodes[j].cumulRot
						if     cMid >  1e-6 then
							if cMax > 0 then
								aMax = aMid
								cMax = cMid
							else
								aMin = aMid
								cMin = cMid
							end
						elseif cMid < -1e-6 then
							if cMax < 0 then
								aMax = aMid
								cMax = cMid
							else
								aMin = aMid
								cMin = cMid
							end
						else
							break 
						end
						if math.abs( cMin - cMax ) < 1e-6 then
							vehicle.aiveChain.nodes[j].angle = 0.5 * ( aMin + aMax )
							break
						elseif aLast == nil then
							aLast = aMid
						elseif math.abs( aLast - aMid ) < 1e-6 then
							vehicle.aiveChain.nodes[j].angle = aMid
							break
						end
					end
				end
			end
			AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
		end
		
		if math.abs( vehicle.aiveChain.nodes[j].angle - old ) > 1E-5 then
			AutoSteeringEngine.setChainStatus( vehicle, j, AIVEStatus.initial )
		end
	end 
	AutoSteeringEngine.applyRotation( vehicle )			
	
--if mode  == "straight" and startIndex > 2 and startIndex + 2 < vehicle.aiveChain.chainMax then
--	local i = AIVEUtils.clamp( startIndex-1, 1, vehicle.aiveChain.chainMax )
--	local j = vehicle.aiveChain.chainMax
--	print(				tostring(startIndex)
--				..", "..tostring(vehicle.aiveChain.chainMax)
--				..", "..AutoSteeringEngine.radToString(vehicle.aiveChain.nodes[1].cumulRot)
--				..", "..AutoSteeringEngine.radToString(vehicle.aiveChain.nodes[i].cumulRot)
--				..", "..AutoSteeringEngine.radToString(vehicle.aiveChain.nodes[j].cumulRot)
--				..", "..AutoSteeringEngine.radToString(AutoSteeringEngine.getTurnAngle( vehicle )))
--end
	
end

------------------------------------------------------------------------
-- getParallelogram
------------------------------------------------------------------------
function AutoSteeringEngine.getParallelogram( xs, zs, xh, zh, diff, noMinLength )
	local xw, zw, xd, zd
	
	xd = zh - zs
	zd = xs - xh
	
	local l = math.sqrt( xd*xd + zd*zd )
	
	if l < 1E-3 then
		xw = xs
		zw = zs
	elseif noMinLength then
	end
	
	if 0.999 < l and l < 1.001 then
		xw = xs + diff * xd
		zw = zs + diff * zd
	elseif l > 1E-3 then
		xw = xs + diff * xd / l
		zw = zs + diff * zd / l
	else
		xw = xs
		zw = zs
	end
	
	return xs, zs, xw, zw, xh, zh
end

function AutoSteeringEngine.clearTrace( vehicle )
	vehicle.aiveChain.trace = {}
end

------------------------------------------------------------------------
-- invertsMarkerOnTurn
------------------------------------------------------------------------
function AutoSteeringEngine.invertsMarkerOnTurn( vehicle, tool, turnLeft )
	local res = false		
	if tool ~= nil and tool.obj ~= nil and type( tool.obj.getAIInvertMarkersOnTurn ) == "function" then
		res = res or tool.obj:getAIInvertMarkersOnTurn( not turnLeft )
	end		
	return res		
end		

------------------------------------------------------------------------
-- saveDirection
------------------------------------------------------------------------
function AutoSteeringEngine.saveDirection( vehicle, cumulate, isOutside, detected )

	if vehicle.aiveChain == nil then
		return 
	end

	if vehicle.aiveChain.respectStartNode then
		vehicle.aiveChain.respectStartNode = false
		AutoSteeringEngine.initFruitBuffer( vehicle )
		AutoSteeringEngine.setChainStatus( vehicle, 1, AIVEStatus.initial )
	end

	if vehicle.aiveChain.trace == nil then
		vehicle.aiveChain.trace = {}
	end

	vehicle.aiveChain.trace.a           = nil
	vehicle.aiveChain.trace.l           = nil
	vehicle.aiveChain.trace.isUTurn     = nil
	vehicle.aiveChain.trace.targetTrace = nil
	
	if not ( cumulate ) or vehicle.aiveChain.trace.traceIndex == nil or vehicle.aiveChain.trace.trace == nil then
		vehicle.aiveChain.trace.trace       = {}
		vehicle.aiveChain.trace.traceIndex  = 0
		vehicle.aiveChain.trace.uTrace      = {}
		vehicle.aiveChain.trace.uTraceIndex = 0
		vehicle.aiveChain.trace.sx, _, vehicle.aiveChain.trace.sz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		vehicle.aiveChain.trace.ux          = nil
		vehicle.aiveChain.trace.uz          = nil
		vehicle.aiveChain.trace.cx          = nil
		vehicle.aiveChain.trace.cz          = nil
		vehicle.aiveChain.trace.ox          = nil
		vehicle.aiveChain.trace.oz          = nil
		vehicle.aiveChain.trace.ax          = nil
		vehicle.aiveChain.trace.az          = nil
		vehicle.aiveChain.trace.rx          = nil
		vehicle.aiveChain.trace.rz          = nil
		vehicle.aiveChain.trace.tpBuffer    = {}
		vehicle.aiveChain.trace.foundNext   = nil
	end
	
	if not ( cumulate ) or vehicle.aiveChain.toolParams == nil then
		return 
	end

	local wx,_,wz = localToWorld( vehicle.aiveChain.refNode, vehicle.aiveChain.otherX, 0 , vehicle.aiveChain.backZ )
	
	local saveTurnPoint = nil
	if vehicle.aiveChain.trace.ux == nil then
		saveTurnPoint = true
--elseif cumulate and not ( vehicle.aiveChain.isAtEnd ) then
--	saveTurnPoint = true
	elseif isOutside then
		saveTurnPoint = false
	elseif AIVEUtils.vector2LengthSq( vehicle.aiveChain.trace.x - wx, vehicle.aiveChain.trace.z - wz ) < 0.0625 then
		saveTurnPoint = false
	end
		
	if vehicle.aiveChain.leftActive then
		vehicle.aiveChain.trace.dx,_,vehicle.aiveChain.trace.dz = localDirectionToWorld( vehicle.aiveChain.refNode, 1, 0, 0 )
	else
		vehicle.aiveChain.trace.dx,_,vehicle.aiveChain.trace.dz = localDirectionToWorld( vehicle.aiveChain.refNode,-1, 0, 0 )
	end	
	
	local turnXu, turnZc
	local turnZu = vehicle.aiveChain.minZ
	local turnXc = vehicle.aiveChain.otherX
		
	for i,tp in pairs(vehicle.aiveChain.toolParams) do
		if not ( tp.skip and tp.skipOther ) then 
			local tpb
			if vehicle.aiveChain.trace.tpBuffer[i] == nil then
				vehicle.aiveChain.trace.tpBuffer[i] = { xA = tp.x, 
																								xO = tp.xOther, 
																								zR = tp.zReal }
				tpb = vehicle.aiveChain.trace.tpBuffer[i]
			else
				tpb = vehicle.aiveChain.trace.tpBuffer[i]
				tpb.xA = tpb.xA + 0.05 * ( tp.x      - tpb.xA )
				tpb.xO = tpb.xO + 0.05 * ( tp.xOther - tpb.xO )
				tpb.zR = tpb.zR + 0.05 * ( tp.zReal  - tpb.zR )
			end
			
			local oxr,_,ozr = localToWorld( vehicle.aiveChain.refNode, tpb.xO, 0 , tpb.zR )
			
			local ofs, idx, dir
			ofs = tp.offset + tp.offsetStd + 0.25
			dir = math.max( 0.5, math.min( 3, 0.5 * tp.width ) )
			if vehicle.aiveChain.leftActive	then
				idx = tp.nodeRight
				dir = -dir
			else
				ofs = -ofs
				idx = tp.nodeLeft 
			end
			
			local ox,_,oz = AutoSteeringEngine.toolLocalToWorld( vehicle, tp.i, idx, ofs, 2 )
			
			if      ( saveTurnPoint == nil or saveTurnPoint == true )
					and ( ( ( vehicle.aiveChain.headland >= 1
							and AutoSteeringEngine.isChainPointOnField( vehicle, ox, oz ) )
						 or ( vehicle.aiveChain.headland < 1
							and AutoSteeringEngine.checkField( vehicle, ox, oz ) ) ) ) then
							
				local stp = false
				if saveTurnPoint then
					stp = true
				elseif AutoSteeringEngine.checkField( vehicle, ox,oz ) then
					local refNode = vehicle.aiveChain.refNode
					local ex,_,ez = localDirectionToWorld( refNode, 0, 0, -2 )
					local bx = ox + ex
					local bz = oz + ez
					ex,_,ez = localDirectionToWorld( refNode, dir, 0, 0 )
					local dx = bx + ex
					local dz = bz + ez
					local a,t = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, tp.i, bx,bz,dx,dz,ox,oz, true )
					if a > 0 then
						if vehicle.aiveChain.collectCbr then
							if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
							table.insert( vehicle.aiveChain.cbr, { bx,bz,dx,dz,ox,oz, a, t } )
						end

						stp = true
						
						
						if  not ( vehicle.aiveChain.trace.foundNext ) 
								and vehicle.aiveChain.inField 
								and AutoSteeringEngine.hasFruits( vehicle ) then 

							local ox,_,oz = AutoSteeringEngine.toolLocalToWorld( vehicle, tp.i, idx, -ofs-ofs, -1 )
							
							local ex,_,ez = localDirectionToWorld( refNode, 0, 0, -1 )
							local bx = ox + ex
							local bz = oz + ez
							ex,_,ez = localDirectionToWorld( refNode, dir, 0, 0 )
							local dx = bx + ex
							local dz = bz + ez
							if      AutoSteeringEngine.checkField( vehicle, ox,oz ) 
									and AutoSteeringEngine.checkField( vehicle, bx,bz ) 
									and AutoSteeringEngine.checkField( vehicle, dx,dz ) then 
								local a,t = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, tp.i, bx,bz,dx,dz,ox,oz, true )
								if a > AIVEGlobals.ignoreBorder then
									vehicle.aiveChain.trace.fn ={ bx,bz,dx,dz,ox,oz, a, t }
									vehicle.aiveChain.trace.foundNext = true 
								end 
							end 
						end				
					end				
				end
				
				if stp then			
					saveTurnPoint = true

					vehicle.aiveChain.trace.ox = ox
					vehicle.aiveChain.trace.oz = oz
					local mx,_,mz = worldDirectionToLocal( vehicle.aiveChain.refNode, ox - oxr, 0, oz - ozr )

					if not ( tp.skipOther ) then
						local txu = tpb.xO 				
						if AutoSteeringEngine.invertsMarkerOnTurn( vehicle, vehicle.aiveChain.tools[tp.i], not vehicle.aiveChain.leftActive ) then
							txu = -tpb.xA
						end
						txu = tpb.xO + txu + mx
						
						if     turnXu == nil then
							turnXu = txu 
							turnZu = vehicle.aiveChain.minZ + mz
						elseif vehicle.aiveChain.leftActive then
							if turnXu > txu then
								turnXu = txu 
								turnZu = vehicle.aiveChain.minZ + mz
							end
						else
							if turnXu < txu then
								turnXu = txu 
								turnZu = vehicle.aiveChain.minZ + mz
							end
						end
					end
					
					if not ( tp.skip ) then
						local tzc = tpb.xA
						if vehicle.aiveChain.leftActive then
							tzc = -tzc
						end						
						tzc = tzc + tpb.zR + mz -- + 0.5
						
						if     turnZc == nil then
							turnZc = tzc
							turnXc = vehicle.aiveChain.otherX + mx
						elseif turnZc > tzc then
							turnZc = tzc
							turnXc = vehicle.aiveChain.otherX + mx
						end
					end
				end
			end
		end 
	end
	
	if saveTurnPoint then
		vehicle.aiveChain.trace.x = wx
		vehicle.aiveChain.trace.z = wz
		
		if turnXu == nil and vehicle.aiveChain.trace.ux == nil then
			turnXu = vehicle.aiveChain.otherX
		--if AIVehicleUtil.invertsMarkerOnTurn( vehicle, not vehicle.aiveChain.leftActive ) then
		--	turnXu = -vehicle.aiveChain.activeX
		--end
			turnXu = turnXu + vehicle.aiveChain.otherX
		end
		if turnZc == nil and vehicle.aiveChain.trace.cx == nil then
			turnZc = vehicle.aiveChain.activeX
			if vehicle.aiveChain.leftActive then
				turnZc = -turnZc 
			end
			turnZc = turnZc + vehicle.aiveChain.minZ
		end
		
		if turnXu ~= nil then
		--vehicle.aiveChain.trace.ux, _, vehicle.aiveChain.trace.uz = localToWorld( vehicle.aiveChain.refNode, turnXu, 0, turnZu )
			vehicle.aiveChain.trace.ux, _, vehicle.aiveChain.trace.uz = localToWorld( vehicle.aiveChain.headlandNode, turnXu, 0, turnZu )
		end
		if turnZc ~= nil then
		--vehicle.aiveChain.trace.cx, _, vehicle.aiveChain.trace.cz = localToWorld( vehicle.aiveChain.refNode, turnXc, 0, turnZc )
			vehicle.aiveChain.trace.cx, _, vehicle.aiveChain.trace.cz = localToWorld( vehicle.aiveChain.headlandNode, turnXc, 0, turnZc )
		end
	end
	
	if cumulate then
		local vector = {}	
		vector.dx,_,vector.dz = localDirectionToWorld( vehicle.aiveChain.refNode, 0,0,1 )
		vector.px,_,vector.pz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		
		local count = table.getn(vehicle.aiveChain.trace.trace)
		if count > 100 and vehicle.aiveChain.trace.traceIndex == count then
			local x = vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].px - vehicle.aiveChain.trace.trace[1].px
			local z = vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].pz - vehicle.aiveChain.trace.trace[1].pz		
		
		--if x*x + z*z > 10000 then 
			if x*x + z*z > 900 then
				vehicle.aiveChain.trace.traceIndex = 0
			end
		end
		vehicle.aiveChain.trace.traceIndex = vehicle.aiveChain.trace.traceIndex + 1
		
		vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex] = vector
		
		AutoSteeringEngine.navigateToSavePoint( vehicle, 0 )

		if vehicle.aiveChain.trace.ax == nil or not ( isOutside ) then
			vehicle.aiveChain.trace.ax, _, vehicle.aiveChain.trace.az = localToWorld( vehicle.aiveChain.refNode, vehicle.aiveChain.activeX, 0 , vehicle.aiveChain.backZ - 2 )
			vehicle.aiveChain.trace.rx, _, vehicle.aiveChain.trace.rz = localToWorld( vehicle.aiveChain.refNode, 0, 0 , vehicle.aiveChain.backZ - 2 )
		end
	end
end

------------------------------------------------------------------------
-- hasFoundNext
------------------------------------------------------------------------
function AutoSteeringEngine.hasFoundNext( vehicle )
	if vehicle.aiveChain == nil or vehicle.aiveChain.trace == nil then 
		return false
	end
	if vehicle.aiveChain.trace.foundNext then 
		return true
	end
	return false
end

------------------------------------------------------------------------
-- shiftTurnVector
------------------------------------------------------------------------
function AutoSteeringEngine.shiftTurnVector( vehicle, distance )

	if vehicle.aiveChain.trace.dx == nil then
		return 
	end
		
	vehicle.aiveChain.trace.ux = vehicle.aiveChain.trace.ux + vehicle.aiveChain.trace.dx * distance
	vehicle.aiveChain.trace.uz = vehicle.aiveChain.trace.uz + vehicle.aiveChain.trace.dz * distance
	vehicle.aiveChain.trace.rx = vehicle.aiveChain.trace.rx + vehicle.aiveChain.trace.dz * distance
	vehicle.aiveChain.trace.rz = vehicle.aiveChain.trace.rz + vehicle.aiveChain.trace.dx * distance
	
	if vehicle.aiveChain.leftActive then
		vehicle.aiveChain.trace.cx = vehicle.aiveChain.trace.cx - vehicle.aiveChain.trace.dz * distance
		vehicle.aiveChain.trace.cz = vehicle.aiveChain.trace.cz + vehicle.aiveChain.trace.dx * distance
	else
		vehicle.aiveChain.trace.cx = vehicle.aiveChain.trace.cx + vehicle.aiveChain.trace.dz * distance
		vehicle.aiveChain.trace.cz = vehicle.aiveChain.trace.cz - vehicle.aiveChain.trace.dx * distance
	end
	
	AutoSteeringEngine.navigateToSavePoint( vehicle, 0 )
end

------------------------------------------------------------------------
-- getFirstTraceIndex
------------------------------------------------------------------------
function AutoSteeringEngine.getFirstTraceIndex( vehicle )
	if     vehicle.aiveChain.trace.trace      == nil 
			or vehicle.aiveChain.trace.traceIndex == nil 
			or vehicle.aiveChain.trace.traceIndex < 1 then
		return nil
	end
	local l = table.getn(vehicle.aiveChain.trace.trace)
	if l < 1 then
		return nil
	end
	local i = vehicle.aiveChain.trace.traceIndex + 1
	if i > l then i = 1 end
	return i
end

------------------------------------------------------------------------
-- getTurnVector
------------------------------------------------------------------------
function AutoSteeringEngine.getTurnVector( vehicle, uTurn, turn2Outside )
	if     vehicle.aiveChain.refNode         == nil
			or vehicle.aiveChain.trace   == nil
			or vehicle.aiveChain.trace.x == nil
			or vehicle.aiveChain.trace.z == nil then
		return 0,0
	end

	if uTurn == nil then
		if vehicle.aiveChain.trace.isUTurn == nil then
			return 0,0
		end
		uTurn = vehicle.aiveChain.trace.isUTurn
	end
	
	setRotation( vehicle.aiveChain.headlandNode, 0, -AutoSteeringEngine.getTurnAngle( vehicle ), 0 )
	
	local _,wy,_ = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local wx, wz

	if turn2Outside then
		wx = vehicle.aiveChain.trace.rx
		wz = vehicle.aiveChain.trace.rz 
	elseif uTurn then
		wx = vehicle.aiveChain.trace.ux
		wz = vehicle.aiveChain.trace.uz 
	else
		wx = vehicle.aiveChain.trace.cx
		wz = vehicle.aiveChain.trace.cz 
	end
	
	local x,y,z = worldToLocal( vehicle.aiveChain.headlandNode, wx , wy, wz )
	
	-- change view point...
	x = -x
	
	z = -z
	
	return x,z
end

------------------------------------------------------------------------
-- getToolTurnVector
------------------------------------------------------------------------
function AutoSteeringEngine.getToolTurnVector( vehicle, toolParam )
	if     vehicle.aiveChain.refNode          == nil
			or vehicle.aiveChain.trace    == nil
			or vehicle.aiveChain.trace.ox == nil
			or vehicle.aiveChain.trace.oz == nil then
		print("direction not saved")
		return 0,0
	end
	
	setRotation( vehicle.aiveChain.headlandNode, 0, -AutoSteeringEngine.getTurnAngle( vehicle ), 0 )

	local node, ofs    
	if vehicle.aiveChain.leftActive then
		node = toolParam.nodeLeft
		ofs  = -toolParam.offset
	else
		node = toolParam.nodeRight
		ofs  = toolParam.offset
	end
	local _,wy,_   = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local wx       = vehicle.aiveChain.trace.ox
	local wz       = vehicle.aiveChain.trace.oz
	local ox,_,oz  = worldToLocal( vehicle.aiveChain.headlandNode, wx , wy, wz )
	local tx,_,tz  = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.headlandNode, node )
	local dx,dy,dz = localDirectionToWorld( vehicle.aiveChain.tools[toolParam.i].steeringAxleNode, ofs, 0, 0 )
	dx,dy,dz       = worldDirectionToLocal( vehicle.aiveChain.headlandNode, dx, dy, dz )
	
	return ox-(tx+dx), oz-(tz+dz)
end

------------------------------------------------------------------------
-- getToolsTurnVector
------------------------------------------------------------------------
function AutoSteeringEngine.getToolsTurnVector( vehicle )
	local xMin, xMax, zMin, zMax
	
	if vehicle.aiveChain.toolParams == nil then
		return 0, 0, 0, 0
	end
	
	for _,tp in pairs( vehicle.aiveChain.toolParams ) do
		if not ( tp.skip ) then
			local tx,tz = AutoSteeringEngine.getToolTurnVector( vehicle, tp )
			
			if xMin == nil or xMin > tx then xMin = tx end
			if xMax == nil or xMax < tx then xMax = tx end
			if zMin == nil or zMin > tz then zMin = tz end
			if zMax == nil or zMax < tz then zMax = tz end
		end
	end
	
	if xMin == nil then xMin = 0 end
	if xMax == nil then xMax = 0 end
	if zMin == nil then zMin = 0 end
	if zMax == nil then zMax = 0 end
	
	return xMin, xMax, zMin, zMax
end

------------------------------------------------------------------------
-- rotateHeadlandNode
------------------------------------------------------------------------
function AutoSteeringEngine.rotateHeadlandNode( vehicle )

	setRotation( vehicle.aiveChain.headlandNode, 0, -AutoSteeringEngine.getTurnAngle( vehicle ), 0 )
	
end

------------------------------------------------------------------------
-- initTurnVector
------------------------------------------------------------------------
function AutoSteeringEngine.initTurnVector( vehicle, uTurn, turn2Outside )
	
	if     vehicle.aiveChain.refNode  == nil
			or vehicle.aiveChain.trace    == nil
			or vehicle.aiveChain.trace.x  == nil
			or vehicle.aiveChain.trace.z  == nil
			or vehicle.aiveChain.trace.ox == nil
			or vehicle.aiveChain.trace.oz == nil
			then
		return
	end
	
	if vehicle.aiveChain.trace.isUTurn ~= nil then
		return
	end
	
	vehicle.aiveChain.inField         = false
	vehicle.aiveChain.trace.isUTurn   = uTurn
	vehicle.aiveChain.trace.isOutside = turn2Outside
	AutoSteeringEngine.rotateHeadlandNode( vehicle )	
	AutoSteeringEngine.initFruitBuffer( vehicle, true )
	
	if      vehicle.aiveChain.trace.a ~= nil 
			and vehicle.aiveChain.tools                 ~= nil 
			and vehicle.aiveChain.toolCount             > 0 then	
			
		if turn2Outside then
		-- outside
		-- keep the current direction !!!
			AutoSteeringEngine.shiftTurnVector( vehicle, 2 )
		
			local offsetOutside = -1	
			if vehicle.aiveChain.leftActive then
				offsetOutside = -offsetOutside
			end

			local a = -AutoSteeringEngine.getTurnAngle( vehicle )
			local t = {}
			local offset = 4
			local factor = 1
			if vehicle.aiveChain.leftActive then
				factor = -1
			end
			
			local lStart = 0
			local lEnd   = 10
			local lWidth = 1
			
			
			for f=-0.5,1.0,0.1 do
				local d = 30 * f
				if f > 0 then d = -d end
					
				t[d]   = {}
				t[d].r = factor * math.rad( d )
				
				setRotation( vehicle.aiveChain.headlandNode, 0, a + t[d].r, 0 )
				
				-- drive direction 
				local ddx,_,ddz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )
				-- width 
				local dwx,_,dwz = localDirectionToWorld( vehicle.aiveChain.headlandNode, offsetOutside, 0, 0 )
				
				local xs = vehicle.aiveChain.trace.ax + lStart * ddx
				local zs = vehicle.aiveChain.trace.az + lStart * ddz
				local xw = xs + lWidth * dwx
				local zw = zs + lWidth * dwz
				
				local xh = xs + ddx
				local zh = zs + ddz
				
				for x=1,lEnd do
					local dx, dz
					dx = xs + x * ddx
					dz = zs + x * ddz
					if not AutoSteeringEngine.checkFieldNear( vehicle, dx, dz ) then
						break
					end
					xh = dx
					zh = dz
				end
				
				
				t[d].a = 0
				t[d].t = 0
				for _,tp in pairs( vehicle.aiveChain.toolParams ) do
					if not tp.skip then
						local ta, tt = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, tp.i, xs, zs, xw, zw, xh, zh, true )
						t[d].a = t[d].a + ta
						t[d].t = t[d].t + tt

						if vehicle.aiveChain.collectCbr then
							if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
							table.insert( vehicle.aiveChain.cbr, { xs, zs, xw, zw, xh, zh, ta, tt } )
						end
					end
				end
				
				if t[d].a <= 0 or t[d].t <= 0 then
					t[d].q = 0
				else
					t[d].q = t[d].a -- / t[d].t 
				end
			end			
			
			local bestQ, bestR, bestD, worstQ
			
			for d,result in pairs( t ) do
				if     bestQ == nil 
						or bestQ > result.q 
						or ( bestQ == result.q and bestD < d ) then
					bestQ = result.q
					bestR = result.r 
					bestD = d
				end
				if     worstQ == nil
						or worstQ < result.q then
					worstQ = result.q
				end
			end
			
			vehicle.aiveChain.trace.a = vehicle.aiveChain.trace.a + bestR			
			
			if      vehicle.aiveChain.refNode          ~= nil
					and vehicle.aiveChain.trace            ~= nil
					and vehicle.aiveChain.trace.trace      ~= nil 
					and vehicle.aiveChain.trace.traceIndex >= 1 then			
				AutoSteeringEngine.rotateHeadlandNode( vehicle )
				
				local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, vehicle.aiveChain.nodes[2].distance + AIVEGlobals.ignoreDist )
				
				if      AutoSteeringEngine.isChainPointOnField( vehicle, vehicle.aiveChain.trace.rx, vehicle.aiveChain.trace.rz )
						and AutoSteeringEngine.isChainPointOnField( vehicle, vehicle.aiveChain.trace.rx + dx, vehicle.aiveChain.trace.rz + dz ) then				
					vehicle.aiveChain.respectStartNode = true
					local wx, wy, wz
					wx, wy, wz = getWorldRotation( vehicle.aiveChain.headlandNode )
					setRotation( vehicle.aiveChain.startNode, wx, wy, wz )
					wx = vehicle.aiveChain.trace.rx
					wz = vehicle.aiveChain.trace.rz
					wy = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, wx, 0, wz)
					setTranslation( vehicle.aiveChain.startNode, wx, wy, wz )
				end
			end
			
		elseif uTurn then
		-- U-turn: shift (ux,uz)
			local offsetOutside = -1	
			if vehicle.aiveChain.leftActive then
				offsetOutside = -offsetOutside
			end
		
			local dxz, _,dzz  = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )
			local dxx, _,dzx  = localDirectionToWorld( vehicle.aiveChain.headlandNode, 1, 0, 0 )			
			local xw0,zw0,xw1,zw1,xw2,zw2 
			local dist = AIVEUtils.clamp( AutoSteeringEngine.getTraceLength( vehicle ), AIVEGlobals.ignoreDist + 3, AIVEGlobals.maxTurnCheck )
			local f = offsetOutside * 0.025 * math.abs( vehicle.aiveChain.width )
			local found = false  

			for i = -40,40 do
				xw0 = vehicle.aiveChain.trace.ox + f * i * dxx
				zw0 = vehicle.aiveChain.trace.oz + f * i * dzx
				
				xw1 = xw0 - dist * dxz
				zw1 = zw0 - dist * dzz
				xw2 = xw0
				zw2 = zw0
				if vehicle.aiveChain.headland > 0 then
					xw2 = xw2 - AIVEGlobals.ignoreDist * dxz
					zw2 = zw2 - AIVEGlobals.ignoreDist * dzz
				else
					xw2 = xw2 + dxz
					zw2 = zw2 + dzz
				end

				if AIVEGlobals.showTrace > 0 and vehicle.isEntered and i == 1 then
					vehicle.aiveChain.trace.itv1 = { AutoSteeringEngine.getParallelogram( xw1, zw1, xw2, zw2, offsetOutside ) }
				end
				
				found = false 
				for _,tp in pairs( vehicle.aiveChain.toolParams ) do
					if not tp.skip and AutoSteeringEngine.getFruitArea( vehicle, xw1,zw1,xw2,zw2, offsetOutside, tp.i, true ) > 0 then
						found = true  
					end 
				end 
				if not found then 
					break
				end
			end	
			
			if found then 
				if AIVEGlobals.showTrace > 0 and vehicle.isEntered then
					vehicle.aiveChain.trace.itv2 = { AutoSteeringEngine.getParallelogram( xw1, zw1, xw2, zw2, offsetOutside ) }
				end
				
				f = offsetOutside * vehicle.aiveChain.offsetStd
				xw0 = xw0 + f * dxx
				zw0 = zw0 + f * dzx
				
				local dx1,_,dz1 = localDirectionToWorld( vehicle.aiveChain.headlandNode, vehicle.aiveChain.trace.ux - xw0, 0, vehicle.aiveChain.trace.uz - zw0 )
				local dx2,_,dz2 = localDirectionToWorld( vehicle.aiveChain.headlandNode, xw0 - vehicle.aiveChain.trace.ox, 0, zw0 - vehicle.aiveChain.trace.oz )
				
				AIVehicleExtension.debugPrint(string.format("%3.2fm %3.2fm / %3.2fm %3.2fm => %3.2fm %3.2fm (%d)", 
							vehicle.aiveChain.trace.ox,
							vehicle.aiveChain.trace.oz,
							dx1,
							dz1,
							dx2,
							dz2,
							offsetOutside ) )
							
				vehicle.aiveChain.trace.ux = vehicle.aiveChain.trace.ux + xw0 - vehicle.aiveChain.trace.ox
				vehicle.aiveChain.trace.uz = vehicle.aiveChain.trace.uz + zw0 - vehicle.aiveChain.trace.oz
			end 
			
			if vehicle.aiveChain.headland >= 1 then
				vehicle.aiveChain.respectStartNode = true
				local wx, wy, wz
				setRotation( vehicle.aiveChain.headlandNode, 0, math.pi-AutoSteeringEngine.getTurnAngle( vehicle ), 0 )
				wx, wy, wz = getWorldRotation( vehicle.aiveChain.headlandNode )
				local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, AIVEGlobals.ignoreDist - vehicle.aiveChain.minZ )
				setRotation( vehicle.aiveChain.startNode, wx, wy, wz )
				wx = vehicle.aiveChain.trace.ux + dx
				wz = vehicle.aiveChain.trace.uz + dz
				wy = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, wx, 0, wz)
				setTranslation( vehicle.aiveChain.startNode, wx, wy, wz )
				AutoSteeringEngine.rotateHeadlandNode( vehicle )
			end
		
		else
		-- 90°: rotate (cx,cz)
			AutoSteeringEngine.rotateHeadlandNode( vehicle )	
			
			local a = -AutoSteeringEngine.getTurnAngle( vehicle )
			local t = {}
			local offset = 1
			local factor = 1
			local width  = 1
			if vehicle.aiveChain.leftActive then
				factor = -factor
			end
			
			do --if false then
				local w = math.max( 2, 0.5 * math.floor( 2 * vehicle.aiveChain.width + 0.5 ) )
				local minShiftZ = -w
				local maxShiftZ = w+w
				local shiftZ, area, total = 0, 0, 0
				local dzx,_,dzz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )				
			--local dxx,_,dxz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor * math.cos( math.rad( 15 )), 0, math.sin( math.rad( 15 )) )			
				local dxx,_,dxz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor * math.cos( math.rad( 4.5 )), 0, math.sin( math.rad( 4.5 )) )			
			--local dxx,_,dxz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor, 0, 0 )			
				
				while minShiftZ <= shiftZ and shiftZ <= maxShiftZ do
					area  = 0
					total = 0
					
					for _,tp in pairs( vehicle.aiveChain.toolParams ) do
						local x0 = vehicle.aiveChain.trace.ox + dzx * shiftZ
						local z0 = vehicle.aiveChain.trace.oz + dzz * shiftZ
						if AutoSteeringEngine.checkFieldNear( vehicle, x0, z0 ) then	
							local xs = x0 - dxx
							local zs = z0 - dxz
							local xh = xs + dzx
							local zh = zs + dzz
							local xw = x0 + dxx
							local zw = z0 + dxz
							for x=1,w,0.5 do
								vx = x0 + x * dxx
								vz = z0 + x * dxz
								local isOnField = AutoSteeringEngine.checkFieldNear( vehicle, vx, vz )
								if isOnField then
									xw = x0 + x * dxx
									zw = z0 + x * dxz
								end
								if not isOnField then
									break
								end
							end
							if not tp.skip then
								local ta, tt = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, tp.i, xs, zs, xw, zw, xh, zh, true )
								area = area + ta
								total = total + tt
								
								if AIVEGlobals.collectCbr > 0 then
									if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
									table.insert( vehicle.aiveChain.cbr, { xs, zs, xw, zw, xh, zh, ta, tt } )
								end
								
							end
						end
					end
					
					if     shiftZ > 0 then
						if area <= 0 then
							doShiftZ = shiftZ
							break
						end
						shiftZ = shiftZ + 0.25
					elseif shiftZ < 0 then
						if area > 0 then
							doShiftZ = shiftZ + 0.25
							break
						else
							shiftZ = shiftZ - 0.25 
						end
					else
						if area > 0 then
							shiftZ = shiftZ + 0.25
						else
							shiftZ = shiftZ - 0.25 
						end
					end
				end
				
				if doShiftZ ~= nil then
					doShiftZ = doShiftZ + 0.5 -- math.max( vehicle.aiveChain.worldToDensityI, vehicle.aiveChain.offsetStd )
					vehicle.aiveChain.trace.cx = vehicle.aiveChain.trace.cx + dzx * doShiftZ
					vehicle.aiveChain.trace.ox = vehicle.aiveChain.trace.ox + dzx * doShiftZ
					vehicle.aiveChain.trace.cz = vehicle.aiveChain.trace.cz + dzz * doShiftZ
					vehicle.aiveChain.trace.oz = vehicle.aiveChain.trace.oz + dzz * doShiftZ
					
					if AIVEGlobals.showTrace > 0 and vehicle.isEntered then			
						print(string.format("shiftZ: %1.2fm => area: %d / total: %d",doShiftZ,area,total))
						local x0 = vehicle.aiveChain.trace.cx + dzx * math.abs( vehicle.aiveChain.activeX )
						local z0 = vehicle.aiveChain.trace.cz + dzz * math.abs( vehicle.aiveChain.activeX )
						local xs = x0 - dxx
						local zs = z0 - dxz
						local xh = xs + dzx
						local zh = zs + dzz
						local xw = x0 + dxx
						local zw = z0 + dxz
						
					--print(string.format("xs: %1.2f, zs: %1.2f, xw: %1.2f, zw: %1.2f, xh: %1.2f, zh: %1.2f",xs, zs, xw, zw, xh, zh))
						vehicle.aiveChain.trace.itv2 = { xs, zs, xw, zw, xh, zh }			
					end
				end
			end

			for f=-1.4,1.4,0.1 do
				local d = 45 * f * f
				if f < 0 then d = -d end
					
				t[d]   = {}
				t[d].r = factor * math.rad( d )
				
				setRotation( vehicle.aiveChain.headlandNode, 0, a + t[d].r, 0 )

				t[d].ox,_,t[d].oz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, width )				
				t[d].sx,_,t[d].sz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor, 0, 0 )
				
				local xb = 0 				
				local xs = vehicle.aiveChain.trace.ox + xb * t[d].sx
				local zs = vehicle.aiveChain.trace.oz + xb * t[d].sz				
				local xw = xs + t[d].ox
				local zw = zs + t[d].oz

				local xe = 1
				local xh = xs + xe * t[d].sx
				local zh = zs + xe * t[d].sz
				
				for x=3,10 do
					vx = xs + x * t[d].sx
					vz = zs + x * t[d].sz
					if AutoSteeringEngine.checkFieldNear( vehicle, vx, vz ) then
						xh = vx
						zh = vz
						xe = x
					else
						break
					end
				end
				
				while true do					
					t[d].a = 0
					t[d].t = 0
					for _,tp in pairs( vehicle.aiveChain.toolParams ) do
						if not tp.skip then
							local ta, tt = AutoSteeringEngine.getAIAreaOfVehicle( vehicle, tp.i, xs, zs, xw, zw, xh, zh, true )
							t[d].a = t[d].a + ta
							t[d].t = t[d].t + tt
							
							if AIVEGlobals.collectCbr > 0 then
								if vehicle.aiveChain.cbr == nil then vehicle.aiveChain.cbr = {} end
								table.insert( vehicle.aiveChain.cbr, { xs, zs, xw, zw, xh, zh, ta, tt, ta>0 } )
							end
							
						end
					end
					
					if t[d].a <= 0 then
						break
				--elseif xe > 1 then
				--	xb = xb + 1
				--	xe = xe - 1
				--	xs = vehicle.aiveChain.trace.ox + xb * t[d].sx
				--	zs = vehicle.aiveChain.trace.oz + xb * t[d].sz
				--	xw = xs + t[d].ox
				--	zw = zs + t[d].oz
					else
						break
					end
				end
				
				t[d].xb = xb
				t[d].xe = xe
				
				if t[d].a <= 0 or t[d].t <= 0 then
					t[d].q = -xb
				else
					t[d].q = t[d].a / t[d].t 
				end
			end			
			
			local bestQ, bestR, bestD, worstQ
			
			for d,result in pairs( t ) do
				if     bestQ == nil 
						or bestQ > result.q 
						or ( bestQ == result.q and bestD < d ) then
					bestQ = result.q
					bestR = result.r 
					bestD = d
				end
				if     worstQ == nil
						or worstQ < result.q then
					worstQ = result.q
				end
			end
			
			if     bestQ > 0 then
				vehicle.aiveChain.trace.a = vehicle.aiveChain.trace.a + factor * math.rad( 90 )
			elseif bestQ < worstQ then			
				vehicle.aiveChain.trace.a = vehicle.aiveChain.trace.a + bestR
			end

			if AIVEGlobals.showTrace > 0 and vehicle.isEntered then			
				print(string.format( "%3d %3d° %s %0.3f %0.3f %3d %3d", bestD, math.deg(bestR), tostring(vehicle.aiveChain.leftActive), bestQ, worstQ, t[bestD].a, t[bestD].t))
				local xs = vehicle.aiveChain.trace.ox + t[bestD].xb * t[bestD].sx
				local zs = vehicle.aiveChain.trace.oz + t[bestD].xb * t[bestD].sz				
				local xh = xs + t[bestD].xe * t[bestD].sx
				local zh = zs + t[bestD].xe * t[bestD].sz
				local xw = xs + t[bestD].ox
				local zw = zs + t[bestD].oz
				
				vehicle.aiveChain.trace.itv1 = { xs, zs, xw, zw, xh, zh }			
			end
			
			AutoSteeringEngine.rotateHeadlandNode( vehicle )	
		end		
	end
end	

------------------------------------------------------------------------
-- getTurnDistance
------------------------------------------------------------------------
function AutoSteeringEngine.getTurnDistance( vehicle )
	if     vehicle.aiveChain.refNode             == nil
			or vehicle.aiveChain.trace       == nil
			or vehicle.aiveChain.trace.trace == nil 
			or vehicle.aiveChain.trace.traceIndex < 1 then
		return 0
	end
	local _,y,_ = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local x,_,z = worldToLocal( vehicle.aiveChain.refNode, vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].px, y, vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].pz )
	return math.sqrt( x*x + z*z )
end

------------------------------------------------------------------------
-- getTurnDistance
------------------------------------------------------------------------
function AutoSteeringEngine.getTurnDistanceSq( vehicle )
	if     vehicle.aiveChain.refNode             == nil
			or vehicle.aiveChain.trace       == nil
			or vehicle.aiveChain.trace.trace == nil 
			or vehicle.aiveChain.trace.traceIndex < 1 then
		return 0
	end
	local _,y,_ = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local x,_,z = worldToLocal( vehicle.aiveChain.refNode, vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].px, y, vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].pz )
	return x*x + z*z
end

------------------------------------------------------------------------
-- getTraceLength
------------------------------------------------------------------------
function AutoSteeringEngine.getTraceLength( vehicle )
	if     vehicle.aiveChain.refNode         == nil
			or vehicle.aiveChain.trace   == nil then
		return 0
	end
	if     vehicle.aiveChain.trace.sx    == nil
			or vehicle.aiveChain.trace.sz    == nil
			or vehicle.aiveChain.trace.trace == nil then
		return 0
	end
	
	if table.getn(vehicle.aiveChain.trace.trace) < 2 then
		return 0
	end
		
	local i = AutoSteeringEngine.getFirstTraceIndex( vehicle )
	if i == nil then
		return 0
	end
	
	if vehicle.aiveChain.trace.l == nil then
		local x = vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].px - vehicle.aiveChain.trace.sx
		local z = vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].pz - vehicle.aiveChain.trace.sz
		vehicle.aiveChain.trace.l = math.sqrt( x*x + z*z )
	end
	
	return vehicle.aiveChain.trace.l
end

------------------------------------------------------------------------
-- getTurnAngle
------------------------------------------------------------------------
function AutoSteeringEngine.getTurnAngle( vehicle )
	local refNode = vehicle:getAIVehicleDirectionNode() -- vehicle.aiveChain.refNode

	if refNode == nil or vehicle.aiveChain.trace   == nil then
		return 0
	end
	if vehicle.aiveChain.trace.a == nil then
		local i = AutoSteeringEngine.getFirstTraceIndex( vehicle )
		if i == nil then
			return 0
		end
		if i == vehicle.aiveChain.trace.traceIndex then
			return 0
		end
		local l = AutoSteeringEngine.getTraceLength( vehicle )
		if l < 2 then
			return 0
		end

		local vx = vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].px - vehicle.aiveChain.trace.trace[i].px
		local vz = vehicle.aiveChain.trace.trace[vehicle.aiveChain.trace.traceIndex].pz - vehicle.aiveChain.trace.trace[i].pz		
		vehicle.aiveChain.trace.a = AIVEUtils.getYRotationFromDirection(vx,vz)
		
		if vehicle.aiveChain.trace.a == nil then
			print("NIL!!!!")
		end
	end

	local x,y,z = localDirectionToWorld( vehicle.aiveChain.refNode, 0,0,1 )
	
	local angle = AutoSteeringEngine.normalizeAngle( AIVEUtils.getYRotationFromDirection(x,z) - vehicle.aiveChain.trace.a )	

	return angle
end	

------------------------------------------------------------------------
-- getRelativeTranslation
------------------------------------------------------------------------
function AutoSteeringEngine.getRelativeTranslation(root,node)
	if root == nil or node == nil then
		if AIVEGlobals.devFeatures > 0 then AIVehicleExtension.printCallstack() end
		return 0,0,0
	end
	local x,y,z
	local state,result = pcall( getParent, node )
	if not ( state ) then
		if AIVEGlobals.devFeatures > 0 then AIVehicleExtension.printCallstack() end
		return 0,0,0
	elseif result==root then
		x,y,z = getTranslation(node)
	else
		x,y,z = worldToLocal(root,getWorldTranslation(node))
	end
	return x,y,z
end

------------------------------------------------------------------------
-- getRelativeYRotation
------------------------------------------------------------------------
function AutoSteeringEngine.getRelativeYRotation(root,node)
	if root == nil or node == nil then
		AIVehicleExtension.printCallstack()
		return 0
	end
	local x, y, z = worldDirectionToLocal(node, localDirectionToWorld(root, 0, 0, 1))
	local dot = z
	dot = dot / AIVEUtils.vector2Length(x, z)
	local angle = math.acos(dot)
	if x < 0 then
		angle = -angle
	end
	return angle
end

------------------------------------------------------------------------
-- getRelativeYRotation
------------------------------------------------------------------------
function AutoSteeringEngine.getRelativeZRotation(root,node)
	if root == nil or node == nil then
		AIVehicleExtension.printCallstack()
		return 0
	end
	local x, y, z = worldDirectionToLocal(node, localDirectionToWorld(root, 0, 1, 0))
	local dot = y
	dot = dot / AIVEUtils.vector2Length(x, y)
	local angle = math.acos(dot)
	if x < 0 then
		angle = -angle
	end
	return angle
end

------------------------------------------------------------------------
-- getRelativeYRotation
------------------------------------------------------------------------
function AutoSteeringEngine.getAbsoulteZRotation(node)
	if node == nil then
		AIVehicleExtension.printCallstack()
		return 0
	end
	local x, y, z = worldDirectionToLocal(node, 0, 1, 0)
	local dot = y
	dot = dot / AIVEUtils.vector2Length(x, y)
	local angle = math.acos(dot)
	if x < 0 then
		angle = -angle
	end
	return angle
end

------------------------------------------------------------------------
-- initChain
------------------------------------------------------------------------
function AutoSteeringEngine.initChain( vehicle, iRefNode, wheelBase, maxSteering, widthOffset, turnOffset )
	
	vehicle.aiveChain = {}
	vehicle.aiveChain.resetCounter = AutoSteeringEngine.resetCounter
	
	vehicle.aiveChain.wheelBase    = wheelBase
	vehicle.aiveChain.invWheelBase = 1 / wheelBase
	vehicle.aiveChain.maxSteering  = maxSteering
	vehicle.aiveChain.refNode      = iRefNode
	vehicle.aiveChain.chainStart   = AIVEGlobals.chainStart 
	
--if AutoSteeringEngine.skipIfNotServer( vehicle ) then return end
	if not vehicle.isServer then return end
	
	vehicle.aiveChain.headlandNode = createTransformGroup( "acHeadland" )
	link( vehicle.aiveChain.refNode, vehicle.aiveChain.headlandNode )

	if not AutoSteeringEngine.hasArticulatedAxis( vehicle ) and AIVEGlobals.staticRoot > 0 then
--if AIVEGlobals.staticRoot > 0 then
		vehicle.aiveChain.staticRoot = true 
		vehicle.aiveChain.rootNode   = createTransformGroup( "acChainRoot" )
		link( g_currentMission.terrainRootNode, vehicle.aiveChain.rootNode )
	else
		vehicle.aiveChain.staticRoot = false 
		vehicle.aiveChain.rootNode   = vehicle.aiveChain.refNode 
	end
	--vehicle.aiveChain.otherINode   = createTransformGroup( "acOtherI" )
	--link( vehicle.aiveChain.refNode, vehicle.aiveChain.otherINode )
	vehicle.aiveChain.startNode = createTransformGroup( "acChainStart" )
	link( g_currentMission.terrainRootNode, vehicle.aiveChain.startNode )
	vehicle.aiveChain.respectStartNode = false
	
	for chainType=1,3 do
		local cl0, pre, atr
		
		if     chainType == 1 then
			cl0 = AIVEGlobals.chainLen
			pre = "acChainA"
			atr = "nodesFix"
		elseif chainType == 2 then
			cl0 = AIVEGlobals.chain2Len
			pre = "acChainB"
			atr = "nodesLow"
		else
			cl0 = AIVEGlobals.chain3Len
			pre = "acChainC"
			atr = "nodesCom"
		end
	
		local node    = {}
		node.index    = createTransformGroup( pre.."0_lnk" )
		node.index2   = createTransformGroup( pre.."0_rot" )
		node.index3   = createTransformGroup( pre.."0_b1" )
		node.index4   = createTransformGroup( pre.."0_b2" )
		node.status   = 0
		node.angle    = 0
		node.steering = 0
		node.rotation = 0
		node.isField  = false
		node.distance = 0
		node.length   = 0
		node.tool     = {}
		link( vehicle.aiveChain.rootNode, node.index )
		link( node.index, node.index2 )
		link( node.index, node.index3 )
		link( node.index3, node.index4 )

		local distance = 0
		local nodes = {}
		nodes[1] = node
		
		for i,add in pairs( cl0 ) do
			local parent   = nodes[i]
			local text     = string.format("%s%i",pre,i)
			local node2    = {}
			distance       = distance + add
			node2.index    = createTransformGroup( text.."_lnk" )
			node2.index2   = createTransformGroup( text.."_rot" )
			node2.index3   = createTransformGroup( text.."_b1" )
			node2.index4   = createTransformGroup( text.."_b2" )
			node2.status   = 0
			node2.angle    = 0
			node2.steering = 0
			node2.rotation = 0
			node2.isField  = false
			node2.distance = distance
			node2.length   = 0
			node2.tool     = {}
			
			link( parent.index2, node2.index )
			link( node2.index, node2.index2 )
			link( node2.index, node2.index3 )
			link( node2.index3, node2.index4 )
			setTranslation( node2.index, 0,0,add )
			
			nodes[#nodes].length = add
			
			nodes[#nodes+1] = node2
		end
		
		vehicle.aiveChain[atr] = nodes
	end	
end

------------------------------------------------------------------------
-- deleteNode
------------------------------------------------------------------------
function AutoSteeringEngine.deleteNode( index, noUnlink )
	return pcall(AutoSteeringEngine.deleteNode1, index, noUnlink )
end

function AutoSteeringEngine.deleteNode1( index, noUnlink )
	if index == nil then return end
	if noUnlink then
	else
		unlink( index )
	end
	delete( index )
end

------------------------------------------------------------------------
-- deleteChain
------------------------------------------------------------------------
function AutoSteeringEngine.deleteChain( vehicle )

	AutoSteeringEngine.deleteTools( vehicle )

	if vehicle.aiveChain == nil then return end

	local i
	if vehicle.aiveChain.nodes ~= nil then
		local n = vehicle.aiveChain.nodes
		vehicle.aiveChain.nodes = nil
		for j=-1,vehicle.aiveChain.chainMax-1 do
			i = vehicle.aiveChain.chainMax - j
			AutoSteeringEngine.deleteNode( n[i].index4 )
			AutoSteeringEngine.deleteNode( n[i].index3 )
			AutoSteeringEngine.deleteNode( n[i].index2 )
			AutoSteeringEngine.deleteNode( n[i].index  )
		end
	end

	if vehicle.aiveChain.headlandNode ~= nil then
		AutoSteeringEngine.deleteNode( vehicle.aiveChain.headlandNode )
		vehicle.aiveChain.headlandNode = nil
	end
	
	if vehicle.aiveChain.staticRoot then
		AutoSteeringEngine.deleteNode( vehicle.aiveChain.rootNode )
		vehicle.aiveChain.rootNode = nil
	end

	if vehicle.aiveChain.startNode ~= nil then
		AutoSteeringEngine.deleteNode( vehicle.aiveChain.startNode )
		vehicle.aiveChain.startNode = nil
	end
	
	vehicle.aiveChain = nil
	vehicle.aiveCurrentField = nil	
	
end

------------------------------------------------------------------------
-- getSpecialToolSettings
------------------------------------------------------------------------
function AutoSteeringEngine.getSpecialToolSettings( vehicle )
	local settings = {}
	
	settings.leftOnly  = false
	settings.rightOnly = false
	
	if not ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		return settings
	end
	
	for _,tool in pairs(vehicle.aiveChain.tools) do
		if      tool.isPlow then
		--	if     tool.obj.rotationPart               == nil
		--			or tool.obj.rotationPart.turnAnimation == nil then
		--		settings.rightOnly = true
		--	end
		end
		if tool.isCombine then
		--	if tool.xl+tool.xl+tool.xl < -tool.xr then
		--		settings.rightOnly = true
		--	end
		--	if tool.xl > -tool.xr-tool.xr-tool.xr then
		--		settings.leftOnly  = true
		--	end	
		end
	end

	return settings
end

------------------------------------------------------------------------
-- addTool
------------------------------------------------------------------------
function AutoSteeringEngine.addTool( vehicle, implement, ignore )

	local tool       = {}
	local marker     = {}
	local extraNodes = {}
	local object     = vehicle
	local reference  = vehicle.aiveChain.refNode
	
	tool.attacherRotFactor = 0
	
	if implement == nil or implement.object == nil then
		return 
	elseif implement.object ~= vehicle then
		object    = implement.object
		reference = implement.object.spec_attachable.attacherJoint.node

		if      vehicle == implement.object.spec_attachable.attacherVehicle
				and AutoSteeringEngine.hasArticulatedAxis( vehicle )
				and vehicle.spec_attacherJoints           ~= nil then 
			local attacherJoint = vehicle:getAttacherJointDescFromObject( object )
			local spec = vehicle.spec_articulatedAxis
			
			if attacherJoint ~= nil then 
				local f = 0.5 
				for i=1,2 do 
					if spec.componentJoint.componentIndices[i] ~= nil then 
						c = vehicle.components[spec.componentJoint.componentIndices[i]] 
						if c ~= nil then  
							if c.node == attacherJoint.rootNode then 
								tool.attacherRotFactor = f 
							end 
						end 
					end 
					f = -f 
				end 
			end 
		end 
	end
	
	local spec = object.spec_aiImplement
	if spec == nil then 
		return 
	end 
	
	tool.steeringAxleNode   = object.steeringAxleNode
	if tool.steeringAxleNode == nil then
		tool.steeringAxleNode = object.components[1].node
	end
	
	tool.aiForceTurnNoBackward   = spec.blockTurnBackward or not ( spec.allowTurnBackward ) 
	tool.checkZRotation          = false
	tool.isCombine               = object.spec_combine ~= nil 
	tool.hasWorkAreas            = object.spec_workArea ~= nil
	tool.isTurnOnVehicle         = object.spec_turnOnVehicle ~= nil
	tool.isFoldable              = object.spec_foldable ~= nil
	tool.isAIImplement           = object.spec_aiImplement ~= nil
	
	if tool.hasWorkAreas then 
		tool.isPlow                = false 
		tool.isCultivator          = false 
		tool.isSowingMachine       = false 
		tool.isSprayer             = false 
		for _,w in pairs( object.spec_workArea.workAreas ) do
			if     w.functionName == nil then 
			elseif w.functionName == "processPlowArea"          then tool.isPlow          = true 
			elseif w.functionName == "processCultivatorArea"    then tool.isCultivator    = true 
			elseif w.functionName == "processSowingMachineArea" then tool.isSowingMachine = true 
			elseif w.functionName == "processSprayerArea"       then tool.isSprayer       = true 
			elseif w.functionName == "processMowerArea"         then tool.isMower         = true 
			end 
		end 
		if tool.isCultivator then 
			tool.isSprayer     = false 
		end 
		if tool.isSowingMachine then 
			tool.isCultivator = false
			tool.isSprayer     = false 
		end 
	else 
		tool.isPlow                = object.spec_plow ~= nil
		tool.isCultivator          = object.spec_cultivator ~= nil
		tool.isSowingMachine       = object.spec_sowingMachine ~= nil
		tool.isSprayer             = object.spec_sprayer ~= nil
		tool.isMower               = object.spec_mower ~= nil
	end 
	
	tool.configFileName          = object.configFileName
	tool.obj                     = object
	tool.isAITool                = false
	tool.specialType             = ""
	tool.b1                      = 0
	tool.b2                      = 0
	tool.b3                      = 0
	tool.invert                  = false
	tool.outTerrainDetailChannel = -1	
	tool.useAIMarker             = false
	tool.doubleJoint             = false
	tool.noRevStraight           = spec.blockTurnBackward
	tool.ignoreAI                = ignore 
	
	
	if      tool.isSprayer 
			and ( tool.isPlow or tool.isCultivator or tool.isSowingMachine ) then 
		tool.isSprayer = false 
	end 
	if      tool.isSprayer 
			and not ( object.spec_sprayer.allowsSpraying ) 
			and spec.leftMarker == nil and spec.rightMarker == nil then
		return 0
	end
	
	if tool.isPlow and tool.aiForceTurnNoBackward then
		local specP = object.spec_plow 
    if specP.ai ~= nil and specP.ai.rotateToCenterHeadlandPos < 0.4 and  specP.ai.rotateCompletelyHeadlandPos > 0.6 then
			tool.ploughTransport = true
		end
		local wheel = nil
		if spec.turningRadiusLimitation.wheels ~= nil then
			wheel = spec.turningRadiusLimitation.wheels[1]
		end
		if wheel == nil and object.spec_wheels ~= nil then
			wheel = object.spec_wheels.wheels[1]
		end
		if wheel ~= nil then
			tool.checkZRotation = true
			local parent = getParent(wheel.repr)
			tool.steeringAxleNode = createTransformGroup( "AIVESteeringAxle" )
			extraNodes[#extraNodes+1] = tool.steeringAxleNode
			link( parent, tool.steeringAxleNode )
		end
	end
	
	local xo,yo,zo = AutoSteeringEngine.getRelativeTranslation( tool.steeringAxleNode, reference )
	
	tool.xOffset = xo
	tool.zOffset = zo
	
	local b1, trailer = AutoSteeringEngine.findComponentJointDistance( vehicle, object )

	if     ( spec.leftMarker  == nil and spec.rightMarker == nil )
			or object.spec_windrower   ~= nil
			or object.spec_forageWagon ~= nil
			or object.spec_tedder      ~= nil
			or object.spec_baler       ~= nil
			or object.spec_baleWrapper ~= nil
			or object.spec_baleLoader  ~= nil
			then
		tool.ignoreAI = true
	end
	
	if tool.ignoreAI then
		if spec.leftMarker ~= nil and spec.rightMarker ~= nil then
			marker[#marker+1] = spec.leftMarker
			marker[#marker+1] = spec.rightMarker
		elseif ( object.spec_wheels.wheels ~= nil and trailer )
				or tool.isTurnOnVehicle 
				or tool.hasWorkAreas then
			marker[1] = reference
			marker[2] = reference
			tool.aiForceTurnNoBackward = trailer 
		else
			return 0
		end
	else
-- tool with AI support		
		tool.isAITool    = true
		tool.useAIMarker = true
		if AtResetCounter == nil or AtResetCounter < 1 then
			--print("object has AI support")
		end
		
		if spec.leftMarker ~= nil then
			marker[#marker+1] = spec.leftMarker
		end
		
		if spec.rightMarker ~= nil then
			marker[#marker+1] = spec.rightMarker
		end
		
		tool.backMarker = spec.backMarker		

		if     tool.isSowingMachine then
			tool.outTerrainDetailChannel = g_currentMission.sowingValue
		elseif tool.isCultivator then
			tool.outTerrainDetailChannel = g_currentMission.cultivatorValue
		elseif tool.isPlow then
			tool.outTerrainDetailChannel = g_currentMission.plowValue
		end
	end

	if #marker < 1 then 
		--if AtResetCounter == nil or AtResetCounter < 1 then
		--	print("no marker found") 
		--end
		return 0
	end

	if spec.backMarker == nil then
		tool.backMarker = marker[1]
	end
	
	tool.refNode = reference		
	tool.marker  = marker
	
	tool.refNodeRot = createTransformGroup( "toolRefNodeRot" )
	setTranslation( tool.refNodeRot, 0, 0, 0 )
	setRotation( tool.refNodeRot, 0, 0, 0 )
	extraNodes[#extraNodes+1] = tool.refNodeRot 
	
  --------------------------------------------------------
	if      implement                         ~= nil
			and type( object.getAttacherVehicle ) == "function" then 
		local oav = object:getAttacherVehicle()
		if oav ~= nil and oav == vehicle and AutoSteeringEngine.tableGetN( AutoSteeringEngine.getTaJoints2( vehicle, implement, vehicle.aiveChain.refNode, 0 ) ) > 1 then
			tool.doubleJoint = true
		end
		
		--------------------------------------------------------
		-- tool attached to tool
		if vehicle ~= oav then
			if vehicle.aiveChain.tools == nil then
				return 0
			else
				for i,t in pairs( vehicle.aiveChain.tools ) do
					if t.obj == oav then
						if t.aiForceTurnNoBackward then
							if tool.aiForceTurnNoBackward then
								tool.doubleJoint = true						
							else
								tool.aiForceTurnNoBackward = true
							end
						end
						if t.doubleJoint then
							tool.doubleJoint = true
						end				
					--if ( t.isCultivator or t.isSowingMachine ) and tool.isSprayer then
					--	tool.ignoreAI = true
					--end
						
						break
					end
				end
			end
		end
	end
  --------------------------------------------------------
	if     tool.doubleJoint 
			or ( tool.isPlow 
			 and tool.aiForceTurnNoBackward 
			 and not ( tool.ploughTransport ) ) then
		tool.noRevStraight = true
	end
	
	if table.getn( extraNodes ) > 0 then
		tool.extraNodes = extraNodes
	end
	
		--if object.lengthOffset ~= nil and object.lengthOffset < 0 then			
	if math.abs( AutoSteeringEngine.getRelativeYRotation( vehicle.aiveChain.refNode, tool.steeringAxleNode ) ) > 0.6 * math.pi then
	-- wrong rotation ???
		--print("wrong rotation")
		tool.invert = not tool.invert
	end	
	--local _,_,rsz = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, tool.steeringAxleNode )
	--if rsz > 1 then
	--	tool.invert = not tool.invert
	--end		
	
	local xl, xr, zz, zb = AutoSteeringEngine.getToolMarkerRange( vehicle, tool )
	
	tool.xl = xl - tool.xOffset
	tool.xr = xr - tool.xOffset
	tool.z  = zz - tool.zOffset
	tool.zb = zb - tool.zOffset
	
	if tool.doubleJoint then
	-- do nothing
	elseif tool.aiForceTurnNoBackward then
	--tool.b1 = b1
	--
	--if object.spec_wheels.wheels ~= nil then
	--	local wna,wza=0,0
	--	for i,wheel in pairs(object.spec_wheels.wheels) do
	--		local f = AutoSteeringEngine.getToolWheelFactor( vehicle, tool, object, i )
	--		if f > 1E-3 then
	--			local _,_,wz = AutoSteeringEngine.getRelativeTranslation(tool.steeringAxleNode,wheel.driveNode)
	--			wza = wza + f * wz
	--			wna = wna + f		
	--		end
	--	end
	--	if wna > 0 then
	--		tool.b2 = math.min( math.max( tool.zb, wza / wna - tool.zOffset ) - tool.b1, 0 )
	--	--if tool.invert then tool.b2 = -tool.b2 end
	--		print(string.format("wna=%i wza=%f b2=%f b2=%f ofs=%f zb=%f/%f",wna,wza,tool.b1,tool.b2,tool.zOffset,zb,tool.zb))
	--	end
	--end
		local r
		tool.r, tool.b1, tool.b2 = AutoSteeringEngine.getToolRadius( vehicle, tool.refNode, object )
		AIVehicleExtension.debugPrint(string.format("r: %6f, b1: %6f, b2: %6f",
																								tool.r, tool.b1, tool.b2 ) )
	else
		tool.b1 = tool.z
	end
	
	local i = 0
	
	if vehicle.aiveChain.tools == nil then
		vehicle.aiveChain.tools ={}
		i = 1
	else
		i = table.getn(vehicle.aiveChain.tools) + 1
	end
	
	if vehicle.spec_combine ~= nil then
		vehicle.aiveHas.combine = true 
		vehicle.aiveHas.combineVehicle = true
	end	
	
	if not ( tool.ignoreAI ) then
		tool.useDensityHeightMap, tool.useWindrowFruitType =  tool.obj:getAIFruitExtraRequirements()	
		
		if not tool.useDensityHeightMap then vehicle.aiveHas.noDHM = true end 
		
		if tool.isCombine       then vehicle.aiveHas.combine       = true end
		if tool.isPlow          then vehicle.aiveHas.plow          = true end
		if tool.isCultivator    then vehicle.aiveHas.cultivator    = true end
		if tool.isSowingMachine then vehicle.aiveHas.sowingMachine = true end
		if tool.isSprayer       then vehicle.aiveHas.sprayer       = true end
		if tool.isMower         then vehicle.aiveHas.mower         = true end
		if tool.isAIImplement   then vehicle.aiveHas.aiImplement   = true end
	end
	
  if tool.isFoldable      then vehicle.aiveHas.foldable      = true end                                                       
  if tool.doubleJoint     then vehicle.aiveHas.doubleJoint   = true end
  if tool.hasWorkAreas    then vehicle.aiveHas.workAreas     = true end
  if tool.isTurnOnVehicle then vehicle.aiveHas.turnOnVehicle = true end
		
	if tool.aiForceTurnNoBackward and ( vehicle.aiveChain.noReverseIndex == nil or vehicle.aiveChain.noReverseIndex < 1 ) then 
		vehicle.aiveChain.noReverseIndex = i 
	end 
	
	vehicle.aiveChain.toolCount = i
	vehicle.aiveChain.tools[i]  = tool
	return i	
end

------------------------------------------------------------------------
-- isToolWheelRelevant
------------------------------------------------------------------------
function AutoSteeringEngine.getToolWheelFactor( vehicle, tool, object, i )
	return AIVEUtils.getNoNil( object.spec_wheels.wheels[i].lateralStiffness, 1 )
end

------------------------------------------------------------------------
-- getToolRadius
------------------------------------------------------------------------
function AutoSteeringEngine.getToolRadius( vehicle, dirNode, object, groundContact )

	local radius, b1, b2 = vehicle.aiveChain.radius, 0, 0
	local spec = object.spec_aiImplement

	if spec == nil then
		AIVehicleExtension.debugPrint("spec is nil")
		spec = {}
	elseif spec.turningRadiusLimitation == nil then
		AIVehicleExtension.debugPrint("spec.turningRadiusLimitation is nil")
	elseif spec.turningRadiusLimitation.rotationJoint == nil then
		AIVehicleExtension.debugPrint("spec.turningRadiusLimitation.rotationJoint is nil")
	end
	
	local implement 
	local oav = nil
	if type( object.getAttacherVehicle ) == "function" then 
		oav = object:getAttacherVehicle()
	end 
	if oav ~= nil and oav.spec_attacherJoints ~= nil and oav.spec_attacherJoints.attachedImplements ~= nil then
		for _,impl in pairs( oav.spec_attacherJoints.attachedImplements ) do
			if impl.object == object then
				implement = impl
			end
		end
	end
	
	local refNode = dirNode
	if implement ~= nil and spec.turningRadiusLimitation ~= nil and spec.turningRadiusLimitation.rotationJoint ~= nil then
		refNode = spec.turningRadiusLimitation.rotationJoint
	end
	
	do
		local rx,_,rz = localToLocal(refNode, vehicle.aiveChain.refNode, 0,0,0)

	--b1  = AIVEUtils.vector2Length( rx, rz )
		b1 = math.abs( rz )
		
		if AutoSteeringEngine.hasArticulatedAxis( vehicle ) and b1 > 0 then
			b1 = b1 * math.cos( 0.5 * vehicle.spec_articulatedAxis.rotMax )
		end
		
		local b2x, b2z, b2i = 0, 0, 0
		
		if type( object.getWheels ) == "function" then 
			local wheels = nil		
			
			if spec.turningRadiusLimitation ~= nil and spec.turningRadiusLimitation.wheels ~= nil then
				wheels = spec.turningRadiusLimitation.wheels
			elseif groundContact then
				wheels = {}
				for _, wheel in pairs(object:getWheels()) do
					if wheel.hasGroundContact then
						table.insert( wheels, wheel )
					end
				end
			else 
				wheels = object:getWheels()
			end

			if wheels ~= nil then 
				for _,wheel in pairs(wheels) do
					local x,_,z = localToLocal(wheel.repr, refNode, 0,0,0)
					
					b2x = b2x + x
					b2z = b2z + z
					b2i = b2i + 1
				end
			end
		end
		
		if b2i > 1 then
			b2x = b2x / b2i
			b2z = b2z / b2i
		end
		
		if math.abs( b2x ) < 0.1 then
			b2 = b2z
		elseif b2i > 0 then
			b2 = AIVEUtils.vector2Length( b2x, b2z )
		end
		
		-- get max rotation
		local rotMax = nil
		if      object.spec_attachable                     ~= nil
				and object.spec_attachable.attacherJoint      ~= nil
				and object.spec_attachable.attacherJoint.node ~= nil
				and refNode == object.spec_attachable.attacherJoint.node 
				and implement ~= nil then
			local jointDesc = object:getAttacherVehicle().spec_attacherJoints.attachedImplements[implement.jointDescIndex]
			if jointDesc ~= nil then 
				rotMax = math.max(jointDesc.upperRotLimit[2], jointDesc.lowerRotLimit[2]) * object.spec_attachable.attacherJoint.lowerRotLimitScale[2]
			end 
		end 
		if rotMax == nil then 
			for _,compJoint in pairs(object.componentJoints) do
				if refNode == compJoint.jointNode and type( compJoint.rotLimit ) == "table" and compJoint.rotLimit[2] ~= nil then 
					rotMax = compJoint.rotLimit[2]
					break
				end
			end
		end
		
		if rotMax == nil or rotMax > vehicle.aiveChain.maxToolAngle then
			rotMax = vehicle.aiveChain.maxToolAngle
		end
		
	--if b2 > 1e-3 then
	--	rotMax = math.min( rotMax, 0.5*math.pi-math.atan( 1.5 / b2 ) )
	--end		

		if rotMax > 0 then
			radius = math.max( radius, ( b1 * math.cos( rotMax ) + b2 ) / math.sin( rotMax ) )
		end
		
		if spec.turningRadiusLimitation ~= nil and spec.turningRadiusLimitation.radius ~= nil then
			rt = math.sqrt( math.max( radius*radius + b1*b1 - b2*b2, 0 ) )	
			if rt < spec.turningRadiusLimitation.radius then
				rt = spec.turningRadiusLimitation.radius
				radius = math.max( radius, math.sqrt( math.max( rt*rt - b1*b1 + b2*b2 ) ) )
			end
		end
	end

	local dummy = radius 
	radius = math.max( radius, b2 )
	
	if AutoSteeringEngine.hasArticulatedAxis( vehicle ) and b1 > 0 then
		radius = radius + b1 * math.tan( 0.5 * vehicle.spec_articulatedAxis.rotMax )
	end
	
	return radius, -b1, -b2

end

------------------------------------------------------------------------
-- deleteTools
------------------------------------------------------------------------
function AutoSteeringEngine.deleteTools( vehicle )

	if vehicle ~= nil and vehicle.aiveChain ~= nil then
		if vehicle.aiveChain.tools ~= nil and vehicle.aiveChain.toolCount > 0 then
			for _,tool in pairs( vehicle.aiveChain.tools ) do
				if tool.extraNodes ~= nil and table.getn( tool.extraNodes ) > 0 then
					for _,n in pairs( tool.extraNodes ) do
						AutoSteeringEngine.deleteNode( n )
					end
				end
			end
		end
		vehicle.aiveChain.toolCount      = 0
		vehicle.aiveChain.tools          = nil
		vehicle.aiveChain.toolParams     = nil
		vehicle.aiveChain.noReverseIndex = 0
	end
	
	vehicle.aiveHas = {}
end

function AutoSteeringEngine.getIsAIReadyForWork( vehicle )
	return true
--local allowedToDrive = Vehicle.getIsAIReadyForWork( vehicle )
--for i,tool in pairs(vehicle.aiveChain.tools) do
--	if not Vehicle.getIsAIReadyForWork( tool.obj ) then
--		allowedToDrive = false
--	end
--end
--
--return allowedToDrive
end

------------------------------------------------------------------------
-- checkAllowedToDrive
------------------------------------------------------------------------
function AutoSteeringEngine.checkAllowedToDrive( vehicle, checkFillLevel, checkField )

	if checkField and vehicle.aiveCurrentFieldCo == nil then
		AutoSteeringEngine.invalidateField( vehicle )
		local x,_,z = AutoSteeringEngine.getAiWorldPosition( vehicle )
		AutoSteeringEngine.checkField( vehicle, x, z )
	end
				
	if vehicle.aiveCurrentFieldCo ~= nil then
		local x,_,z = AutoSteeringEngine.getAiWorldPosition( vehicle )
		AutoSteeringEngine.checkField( vehicle, x, z )
		if vehicle.aiveCurrentFieldCo ~= nil then
			if AIVEGlobals.devFeatures > 0 then print("not allowed to drive I") end
			return false
		end
	end
	
--if     not ( vehicle.isMotorStarted ) 
--		or ( vehicle.motorStartTime ~= nil and g_currentMission.time <= vehicle.motorStartTime ) then
--	if AIVEGlobals.devFeatures > 0 then print("not allowed to drive IV") end
--	return false
--end

	if vehicle.aiveChain.tools == nil or table.getn(vehicle.aiveChain.tools) < 1 then
		if AIVEGlobals.devFeatures > 0 then print("not allowed to drive III") end
		return false
	end
	
	local allowedToDrive = true
	
	if vehicle.aiveMaxCollisionSpeed ~= nil and vehicle.aiveMaxCollisionSpeed < 2 then
		allowedToDrive = false 
	end 
	
--for i,tool in pairs(vehicle.aiveChain.tools) do
--	local self = tool.obj
--	local curCapa, maxCapa = 0, 0
--	
--	if useAIMarker then
--		if tool.marker[1] ~= nil then
--			tool.marker[1] = tool.obj.spec_aiImplement.leftMarker
--		end
--		if tool.marker[2] ~= nil then
--			tool.marker[2] = tool.obj.spec_aiImplement.rightMarker
--		end
--		tool.backMarker = AIVEUtils.getNoNil( tool.obj.spec_aiImplement.backMarker, tool.marker[1] )
--	end
--	
--	if self.fillUnits ~= nil then
--		for u,f in pairs( self.fillUnits ) do
--			maxCapa = maxCapa + self:getUnitCapacity( u )
--			curCapa = curCapa + self:getUnitFillLevel( u )
--		end
--	end
--	
--	if  not ( tool.isCombine )
--			and checkFillLevel
--			and self.capacity  ~= nil
--			and self.capacity  > 0 
--			and self.fillLevel ~= nil
--			and self.fillLevel <= 0 then
--		if AIVEGlobals.devFeatures > 0 then print("emtpy") end
--		allowedToDrive = false
--	end
--end
		
	if not allowedToDrive then
		vehicle.lastNotAllowedToDrive = true
	elseif vehicle.lastNotAllowedToDrive then
		vehicle.lastNotAllowedToDrive = false
		AutoSteeringEngine.setToolsAreLowered( vehicle, true, false )		
	end
	
	return allowedToDrive
end

------------------------------------------------------------------------
-- checkToolIsReadyForWork
------------------------------------------------------------------------
function AutoSteeringEngine.checkToolIsReadyForWork( self, noLower )
	if type( self.getCanAIImplementContinueWork ) == "function" then 
		if self.spec_attachable ~= nil and self.spec_attachable.attacherVehicle == nil then 
			return false 
		end 
		return self:getCanAIImplementContinueWork() 
	end 
	return true
end

------------------------------------------------------------------------
-- checkIsAnimPlaying
------------------------------------------------------------------------
function AutoSteeringEngine.checkIsAnimPlaying( vehicle, moveDown )
	
	local isPlaying = false

	if vehicle.aiveChain.tools == nil or table.getn(vehicle.aiveChain.tools) < 1 then
		if AIVEGlobals.devFeatures > 0 then print("no tools") end
		return false, false
	end
	
	return isPlaying, false
end

------------------------------------------------------------------------
-- checkToolIsReady
------------------------------------------------------------------------
function AutoSteeringEngine.checkToolIsReady( tool )
	local result   = nil
	local noSneak  = false
	
	if not ( AutoSteeringEngine.checkToolIsReadyForWork( tool.obj, true ) ) then
		return false, true
	end
	
	return true 
end

------------------------------------------------------------------------
-- normalizeAngle
------------------------------------------------------------------------
function AutoSteeringEngine.normalizeAngle( b )
	local a = b
	while a >  math.pi do a = a - math.pi - math.pi end
	while a < -math.pi do a = a + math.pi + math.pi end
	return a
end

------------------------------------------------------------------------
-- getMinToolRadius
------------------------------------------------------------------------
function AutoSteeringEngine.getMinToolRadius( vehicle, radius )
	local radiusT = radius
	
	for _,tool in pairs( vehicle.aiveChain.tools ) do
		if tool.aiForceTurnNoBackward then
			local _,b1,b2 = AutoSteeringEngine.getToolRadius( vehicle, tool.refNode, tool.obj )
			b1 = math.max( 0, -b1 )
			b2 = math.max( 0, -b2 )
			local b3 = 0
			if tool.doubleJoint and tool.b3 ~= nil then
				b3 = tool.b3
			end
			if b1 < 0 and b2 < -1 then
				b2 = b2 + 0.5
				b1 = b1 - 0.5
			end
			
			radiusT = math.min( radiusT, math.sqrt( math.max( radius*radius + b1*b1 - b2*b2 - b3*b3, 0 ) ) )
		end
	end
	
	return radiusT 
end

------------------------------------------------------------------------
-- getToolMarkerRange
------------------------------------------------------------------------
function AutoSteeringEngine.getToolMarkerRange( vehicle, tool )
	local xl, xr, zz, zb
	
	local x,_,z = AutoSteeringEngine.getRelativeTranslation(tool.steeringAxleNode,tool.backMarker)
	zz = z
	zb = z
	for i,m in pairs( tool.marker ) do
		x,_,z = AutoSteeringEngine.getRelativeTranslation(tool.steeringAxleNode,m)
		if tool.invert then x = -x end
		if xl == nil or xl < x then xl = x end
		if xr == nil or xr > x then xr = x end
		if zz == nil or zz < z then zz = z end
		if zb == nil or zb > z then zb = z end
	end
	return xl, xr, zz, zb
end

------------------------------------------------------------------------
-- getMaxSteeringAngle75
------------------------------------------------------------------------
function AutoSteeringEngine.getMaxSteeringAngle75( vehicle, invert )

	if vehicle.aiveChain.trace == nil then
		vehicle.aiveChain.trace = {}
	end
	
	if     vehicle.aiveChain.trace.turn75 == nil then
		vehicle.aiveChain.trace.turn75 = {}
		
		local index   = AutoSteeringEngine.getNoReverseIndex( vehicle )
		local radius  = vehicle.aiveChain.radius
		local radiusT = vehicle.aiveChain.radius
		local alpha   = vehicle.aiveChain.maxSteering
		local radiusE = vehicle.aiveChain.radius
		local maxB2   = 0
		local diffE   = 0
		local gammaE  = 0
		local deltaW  = 1.25
		if vehicle.maxTurningRadius ~= nil and vehicle.maxTurningRadius > vehicle.aiveChain.radius then
			deltaW = vehicle.maxTurningRadius - vehicle.aiveChain.radius 
		end
		
		if index > 0 then
			local r = vehicle.aiveChain.radius
			radiusT = nil
			
			for _,tool in pairs(vehicle.aiveChain.tools) do
				if tool.aiForceTurnNoBackward then
					local tr, b1, b2 = AutoSteeringEngine.getToolRadius( vehicle, tool.refNode, tool.obj, true )
					local b3 = 0
					if tool.b3 ~= nil then
						b3 = tool.b3
					end
					maxB2 = math.max( maxB2, -b2 )
					
					radius  = math.max( radius, tr )
					local t = math.sqrt( math.max( radius*radius + b1*b1 - b2*b2 - b3*b3, 0 ) )				
					if t+t < vehicle.aiveChain.width then
						t  = 0.5 * vehicle.aiveChain.width
						tr = math.sqrt( math.max( t*t - b1*b1 + b2*b2 + b3*b3 ) )
					--print("tool radius less than width => "..tostring(tr).." ("..tostring(radius)..")")
						radius = math.max( radius, tr )
					end
					if radiusT == nil then
						radiusT = t
					else
						radiusT = math.min( radiusT, t )
					end
				end
			end 
			
			if radiusT == nil then
				radiusT = vehicle.aiveChain.radius
			end
			
			alpha    = math.min( vehicle.aiveChain.maxSteering, math.atan( vehicle.aiveChain.wheelBase / radius ) )
			radiusE  = r
			diffE    = math.max( 0, radiusE - radiusT )
			gammaE   = math.acos( math.min(math.max( 1 - diffE / radius, 0), 1 ) )
		end
						
		local diffT = vehicle.aiveChain.otherX
		
	--if     ( invert == nil and AIVehicleUtil.invertsMarkerOnTurn( vehicle, vehicle.aiveChain.leftActive ) )
	--		or invert then
	--	diffT = vehicle.aiveChain.activeX
	--end
		
		if diffT < 0 and ( vehicle.aiveChain.activeX > 0 or vehicle.aiveChain.otherX > 0 ) then -- vehicle.aiveChain.leftActive then
			diffT = -diffT
		end
		
		vehicle.aiveChain.trace.turn75.index   = index 
		vehicle.aiveChain.trace.turn75.radius  = radius
		vehicle.aiveChain.trace.turn75.radiusT = radiusT
		vehicle.aiveChain.trace.turn75.alpha   = alpha
		vehicle.aiveChain.trace.turn75.diffE   = diffE  
		vehicle.aiveChain.trace.turn75.gammaE  = gammaE
		vehicle.aiveChain.trace.turn75.diffT   = diffT
		vehicle.aiveChain.trace.turn75.b2      = maxB2
	end
	
	return vehicle.aiveChain.trace.turn75
end

------------------------------------------------------------------------
-- navigateToSavePoint
------------------------------------------------------------------------
function AutoSteeringEngine.navigateToSavePoint( vehicle, turnMode, fallback, Turn75 )

	if turnMode == nil or turnMode <= 0 then
		vehicle.aiveChain.trace.targetTrace = nil
		return 0, false
	end

  -------------------------------------------------------
	local debugOutput = false 
	debugOutput = debugOutput and ( AIVEGlobals.devFeatures > 0 )
  -------------------------------------------------------  

	if     vehicle.aiveChain               == nil
			or vehicle.aiveChain.maxSteering   == nil 
			or vehicle.aiveChain.trace == nil then
		return 0, false
	end
	
	local uTurn        = true
	local turn2Outside = false
	if turnMode == 2 or turnMode == 4 then
		uTurn = false
	end
	if turnMode == 5 then
		turn2Outside = true
	end

	local tvx, tvz = AutoSteeringEngine.getTurnVector( vehicle, uTurn, turn2Outside )
	local wx,wy,wz = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local angle    = nil
	local d1       = nil
	local onTrack  = true
	local radius   = AIVEUtils.getNoNil( vehicle.aiveChain.radius, 5 ) * 1.1
--radius = radius + math.max( 0.1 * radius, 0.5 )
	
	local turn75 
	if     vehicle.aiveChain.trace.targetTrace     == nil
			or vehicle.aiveChain.trace.targetTraceMode ~= turnMode then
		--or math.abs( vehicle.aiveChain.activeX - vehicle.aiveChain.trace.aiveChain.activeX ) > 0.2 then
		
		AutoSteeringEngine.rotateHeadlandNode( vehicle )
		
		vehicle.aiveChain.trace.targetTrace       = {}			
		vehicle.aiveChain.trace.targetTraceMode   = turnMode	
		
		local shiftT = 0
		local rV     = radius
		local rT     = rV
		local mta    = 0.5 * math.pi - vehicle.aiveChain.maxToolAngle

		if      type( Turn75 ) == "table"
				and Turn75.radius  ~= nil 
				and Turn75.radiusT ~= nil then 
			turn75 = Turn75
		else
			vehicle.aiveChain.trace.turn75 = nil
			turn75 = AutoSteeringEngine.getMaxSteeringAngle75( vehicle )
		end
	
		if      mta            > 0
				and turn75.radius  > turn75.radiusT then				
			rT     = turn75.radius
			shiftT = turn75.radius - turn75.radiusT
			
			if turnMode == 3 and shiftT < turn75.b2 then
				shiftT = turn75.b2
			end				
			
			local delta = vehicle.aiveChain.otherX + vehicle.aiveChain.activeX
			if vehicle.aiveChain.leftActive then
				delta = -delta 
			end
			if delta > 0 then
				if     tvx >  1 then
					if not vehicle.aiveChain.leftActive then
						delta = -delta
					end
				elseif tvx < -1 then
					if vehicle.aiveChain.leftActive then
						delta = -delta 
					end
				end
				
				if delta >= shiftT then
					shiftT = 0
				else
					shiftT = shiftT - delta 
				end
			end
		--print(tostring(shiftT).." "..
		--			tostring(delta).." "..
		--			tostring(turn75.radius).." "..
		--			tostring(turn75.radiusT).." "..
		--			tostring(vehicle.aiveChain.otherX).." "..
		--			tostring(vehicle.aiveChain.activeX).." "..
		--			tostring(vehicle.aiveChain.leftActive))
		--			
		--local tool = vehicle.aiveChain.tools[1]
		--local tr,b1,b2 = AutoSteeringEngine.getToolRadius( vehicle, tool.refNode, tool.obj )
		--local mr = AutoSteeringEngine.getMinToolRadius( vehicle, turn75.radius )
		--print(tostring(tr).." "..
		--			tostring(b1).." "..
		--			tostring(b2).." "..
		--			tostring(mr))
		end
		
		vehicle.aiveChain.trace.targetTraceMinZ = math.min( 0, vehicle.aiveChain.maxZ ) - 20
		
	--print(tostring(vehicle.aiveChain.radius).." "..tostring(rV).." "..tostring(rT).." "..tostring(turn75.radius).." "..tostring(turn75.radiusT))
		
		local p = {}
		if turnMode == 1 or turnMode == 3 then
			local ta      = AutoSteeringEngine.normalizeAngle( math.pi - AutoSteeringEngine.getTurnAngle( vehicle )	)
			local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, -1 )
					
			local zz  = 0

			if turnMode == 1 then
				if math.abs( tvx ) > 1 then
					zz = tvz - 0.5 * ( rV + rT )
				else
					zz = tvz
				end
						
				if shiftT <= 0 or math.abs( tvx ) < 0.5 then
					shiftT = 0
				elseif ( tvx > 0 and not vehicle.aiveChain.leftActive )
						or ( tvx < 0 and     vehicle.aiveChain.leftActive ) then
					shiftT = math.max( 0, shiftT - 0.5 )
				else
					shiftT = math.max( 0, shiftT - 1 )
				end
			end
			
			if shiftT <= 0 then
				shiftT = 0
				mta    = 0
			end
			
			local shiftZ = zz
			local toa = 0
			if shiftT > 0 and rT > 0 then
				toa = -math.asin( AIVEUtils.clamp( 1 - shiftT / rT, 0, 0.5 ) )
				zz  = zz + rT * math.sin( toa )
				if AIVEGlobals.devFeatures > 0 then
					print("***********************************************************")
					print(string.format("%1.3fm %1.3fm => %3d° %1.3fm", shiftT, rT, math.deg( toa ), zz ))
				end
			end			
			
			local zl = zz + 1		
			while zl > vehicle.aiveChain.trace.targetTraceMinZ do
				zl = zl - 1						
				local x,_,z = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, zl )
				x = vehicle.aiveChain.trace.ux + x
				z = vehicle.aiveChain.trace.uz + z
				table.insert( vehicle.aiveChain.trace.targetTrace, 1, { x=x, z=z, dx=dx, dz=dz, a=0, ir=0 } )
			end			
			
			vehicle.aiveChain.trace.targetTraceIOfs = table.getn( vehicle.aiveChain.trace.targetTrace )
			
			if turnMode == 1 and math.abs( tvx ) > 1 then
				for i=1,50 do
					local a = ( 0.5 * math.pi - toa ) * i * 0.02 + toa
					local s = math.sin( a )
					local c = math.cos( a )
					
					local ir, lx, lz					
					if a > mta and rT > rV then
						ir = 1 / rV
						lx = c * rV + math.cos( mta ) * ( rT - rV ) 
						lz = s * rV + math.sin( mta ) * ( rT - rV )
					else
						ir = 1 / rT
						lx = c * rT
						lz = s * rT 
					end
					
					lx = lx - rT + shiftT
					if tvx > 0 then
					-- negative because getTurnVector inverts the sign
						lx = -lx
					end
					lz = lz + shiftZ
										
					x,_,z = localDirectionToWorld( vehicle.aiveChain.headlandNode, lx, 0, lz )
					x = x + vehicle.aiveChain.trace.ux
					z = z + vehicle.aiveChain.trace.uz

					local j = table.getn( vehicle.aiveChain.trace.targetTrace )
					dx = vehicle.aiveChain.trace.targetTrace[j].x - x
					dz = vehicle.aiveChain.trace.targetTrace[j].z - z
					if dx*dx+dz*dz > 0.04 then
						table.insert( vehicle.aiveChain.trace.targetTrace, { x=x, z=z, dx=dx, dz=dz, a=a, ir=ir } )
					end
				end			
			elseif  false -- turnMode       >  1
					and tvz            >= 1 
					and math.abs(tvx)  >= 0.1
					and math.abs( ta ) <= 0.75 * math.pi 
					and ( math.abs( ta ) > 1E-3 or math.abs( tvx ) < 0.1 ) 
					and ( ( ta >= 0 and tvx <= 0 ) or ( ta <= 0 and tvx >= 0 ) ) then
				local r  = radius
				local c  = math.cos( ta ) 
				local s  = math.sin( ta )
				local zo = 0
				local xo = 0
				
				if tvz * ( 1 - c) < math.abs( tvx * s ) then
					r  = tvz / math.abs( s )
					if tvx < 0 then r = -r end
				--xo = xo + tvx - r * ( 1 - c )
				else
					r  = tvx / ( 1 - c )
					zo = tvz - math.abs( r * s )
				end
				
				local iMax = math.max( 2, math.floor( math.abs( ta * r ) + 0.5 ) )
				
				for i=1,iMax do
					local a = ta * i / iMax
			
					x,_,z = localDirectionToWorld( vehicle.aiveChain.headlandNode, xo + r * (1-math.cos( a )), 0, zo + math.abs( r * math.sin( a ) ) )
					x = x + vehicle.aiveChain.trace.ux
					z = z + vehicle.aiveChain.trace.uz
				
					local j = table.getn( vehicle.aiveChain.trace.targetTrace )
					dx = vehicle.aiveChain.trace.targetTrace[j].x - x
					dz = vehicle.aiveChain.trace.targetTrace[j].z - z
					if dx*dx+dz*dz > 0.04 then
						table.insert( vehicle.aiveChain.trace.targetTrace, { x=x, z=z, dx=dx, dz=dz, a=a, ir=1/r } )
					end
				end		
			end
			
		elseif turnMode == 5 then
			-- continue in previous direction 
			local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )
			local zl = 1		
			
			local lx = vehicle.aiveChain.trace.rx
			local lz = vehicle.aiveChain.trace.rz
			
			while zl > vehicle.aiveChain.trace.targetTraceMinZ do
				zl = zl - 1						
				local x,_,z = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, -zl )
				x = lx + x
				z = lz + z
				table.insert( vehicle.aiveChain.trace.targetTrace, 1, { x=x, z=z, dx=dx, dz=dz, a=0, ir=0 } )
			end			
			
			vehicle.aiveChain.trace.targetTraceIOfs = table.getn( vehicle.aiveChain.trace.targetTrace )
		
		elseif turnMode == 2 or turnMode == 4 then
			-- negative Z is beyond turn point in old direction
			-- negative X is beyond turn point in new direction 
			
			local dx, dz
			if vehicle.aiveChain.leftActive then
				dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, -1, 0, 0 )				
			else
				dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode,  1, 0, 0 )				
			end			
			
			local shiftX = tvx
			if not vehicle.aiveChain.leftActive then
				shiftX = -shiftX 
			end
			
			if shiftT <= 0 then
				shiftT = 0
				mta    = 0
			end
				
			if turnMode == 2 then
				if mta > 0 then
					shiftX = shiftX - rV - math.sin( mta ) * ( rT - rV )
				else
					shiftX = shiftX - rV 
				end
			end
			
			local zz  = shiftX - 2
			local toa = 0
			if shiftT > 0 and rT > 0 then
				toa = -math.asin( AIVEUtils.clamp( 1 - shiftT / rT, 0, 0.5 ) )
				zz  = zz + rT * math.sin( toa )
				if AIVEGlobals.devFeatures > 0 then
					print("***********************************************************")
					print(string.format("%1.3fm %1.3fm => %3d° %1.3fm", shiftT, rT, math.deg( toa ), zz ))
				end
			end
			
			local zl = zz + 1						
			while zl > vehicle.aiveChain.trace.targetTraceMinZ do
				zl = zl - 1
				
				local zd = math.min( 0, zl - zz )
				local zf = zl - zd
				local lx = zd + zf
				
				if not vehicle.aiveChain.leftActive then
					lx = -lx
				end
				
				x,_,z = localDirectionToWorld( vehicle.aiveChain.headlandNode, lx, 0, 0 )				
				x = x + vehicle.aiveChain.trace.cx 
				z = z + vehicle.aiveChain.trace.cz 
				table.insert( vehicle.aiveChain.trace.targetTrace, 1, { x=x, z=z, dx=dx, dz=dz, a=0, ir=0 } )
			end			
			
			vehicle.aiveChain.trace.targetTraceIOfs = table.getn( vehicle.aiveChain.trace.targetTrace )
			
			if turnMode == 2 then
				for i=1,50 do
					local a = ( 0.5 * math.pi - toa ) * i * 0.02 + toa
					local s = math.sin( a )
					local c = math.cos( a )
					
					local ir, lx, lz
					if a > mta and rT > rV then
						ir = 1 / rV
						lx = shiftX + s * rV + math.sin( mta ) * ( rT - rV )
						lz = shiftT + c * rV + math.cos( mta ) * ( rT - rV ) 
					else
						ir = 1 / rT
						lx = shiftX + s * rT
						lz = shiftT + c * rT
					end
					
					lz = lz - rT
					if not vehicle.aiveChain.leftActive then
						lx = -lx
					end
					
					if tvz > 1 then
						lz = -lz
					end
					
					x,_,z = localDirectionToWorld( vehicle.aiveChain.headlandNode, lx, 0, lz )
					x = x + vehicle.aiveChain.trace.cx
					z = z + vehicle.aiveChain.trace.cz

					local j = table.getn( vehicle.aiveChain.trace.targetTrace )
					if vehicle.aiveChain.trace.targetTrace[j] ~= nil then
						dx = vehicle.aiveChain.trace.targetTrace[j].x - x
						dz = vehicle.aiveChain.trace.targetTrace[j].z - z
						if dx*dx+dz*dz > 0.04 then
							table.insert( vehicle.aiveChain.trace.targetTrace, { x=x, z=z, dx=dx, dz=dz, a=a, ir=ir } )
						end
					end
				end			
			end
		else
			print("ERROR in AutoSterringEngine.navigateToSavePoint: invalid turn mode: "..tostring(turnMode))
		end

		if table.getn( vehicle.aiveChain.trace.targetTrace ) > vehicle.aiveChain.trace.targetTraceIOfs then
			local p = vehicle.aiveChain.trace.targetTrace[vehicle.aiveChain.trace.targetTraceIOfs]
			local q = vehicle.aiveChain.trace.targetTrace[vehicle.aiveChain.trace.targetTraceIOfs+1]
			local d = math.floor( math.sqrt( (p.x-q.x)^2 + (p.z-q.z)^2 ) ) - 1
			
			for i=1,d do
				x  = p.x + i/(d+1)*(q.x-p.x)
				z  = p.z + i/(d+1)*(q.z-p.z)
				dx = q.x - p.x
				dz = q.z - p.z
				local j = vehicle.aiveChain.trace.targetTraceIOfs + i
				table.insert( vehicle.aiveChain.trace.targetTrace, j, { x=x, z=z, dx=dx, dz=dz, a=0, ir=0 } )
			end			
		end
		
		vehicle.aiveChain.trace.targetTraceMinZ = nil
		if AIVEGlobals.devFeatures > 0 then
			print("***********************************************************")
			for i,p in pairs( vehicle.aiveChain.trace.targetTrace ) do
				local lx,_,lz = worldToLocal( vehicle.aiveChain.refNode, p.x, wy, p.z )
				local kx,_,kz = worldDirectionToLocal( vehicle.aiveChain.refNode, p.dx, 0, p.dz )
				if p.a == nil then
					print(string.format("nil° %1.3fm %1.3fm / %1.3fm %1.3fm",lx,lz,kx,kz ))
				else
					print(string.format("%3d° %1.3fm %1.3fm / %1.3fm %1.3fm",math.deg(p.a),lx,lz,kx,kz ))
				end
			end
			print("***********************************************************")
		end	
	end
	
	if      vehicle.aiveChain.trace.targetTrace       ~= nil 
			and vehicle.aiveChain.trace.targetTraceMode   >  0
			and ( vehicle.aiveChain.trace.targetTraceMinZ == nil
			   or tvz > vehicle.aiveChain.trace.targetTraceMinZ ) then				
		
		if debugOutput then
			print("=========================================================")
			local x,_,z = getWorldTranslation( vehicle.aiveChain.refNode )
			print(tostring(x).." "..tostring(z).." / "..tostring(wx).." "..tostring(wz))
		end
		
		local score = {}
		for i=1,5 do
			score[i] = { score = math.huge }
		end
		
		for i,p in pairs(vehicle.aiveChain.trace.targetTrace) do
		--local x,_,z   = worldToLocal( vehicle.aiveChain.refNode, p.x, wy, p.z )
			local x,_,z   = worldDirectionToLocal( vehicle.aiveChain.refNode, p.x-wx, 0, p.z-wz )
			local dx,_,dz = worldDirectionToLocal( vehicle.aiveChain.refNode, p.dx, 0, p.dz )
			
		--if i > 1 then
		--	local q = vehicle.aiveChain.trace.targetTrace[i-1]
		--  dx,_,dz = worldDirectionToLocal( vehicle.aiveChain.refNode, q.x-p.x, 0, q.z-p.z )
		--end
			
			if z > 1 then					
				if debugOutput then
					print(tostring(x).." "..tostring(z).." / "..tostring(dx).." "..tostring(dz))
				end
				
				if math.abs( x ) <= 22.9 * math.abs( z ) then
					local alpha = AIVEUtils.quot2Rad( x/z )					
					local beta  = math.atan2( dx, dz )
										
					if math.abs(x) < math.abs(z) then
						a = math.atan2( vehicle.aiveChain.wheelBase * math.sin( alpha ), z )					
					else
						a = math.atan2( vehicle.aiveChain.wheelBase * (1-math.cos( alpha )), math.abs(x) )					
						if x < 0 then
							a = -a
						end
					end
					
					a = a + 0.5 * ( alpha - beta )
					
				--if math.abs( a ) <= 1.25 * vehicle.aiveChain.maxSteering then
				--if math.abs( a ) <= 2 * vehicle.aiveChain.maxSteering then
					if math.abs( a ) <= 0.5 * math.pi then
						local d = x*x+z*z 						
					--local s = 1000 * math.abs( p.ir - math.tan( a ) / vehicle.aiveChain.wheelBase )
						local s = math.abs( 9 - d )
						local b = math.abs( alpha - beta ) 
						
						if debugOutput then
							print("=> "..tostring(math.deg(alpha)).."° "..tostring(math.deg(beta)).."° ===> "..tostring(math.deg(a)).."°")
						end
						
						for j=1,table.getn( score ) do
							if s <= score[j].score then
								for k=table.getn( score )-1, j,-1 do
									if score[k].angle ~= nil then
										score[k+1].score = score[k].score
										score[k+1].angle = score[k].angle
										score[k+1].dist  = score[k].dist 
										score[k+1].beta  = score[k].beta 
										score[k+1].tX    = score[k].tX   
										score[k+1].tZ    = score[k].tZ
									end
								end
								score[j].score = s
								score[j].angle = a
								score[j].dist  = d
								score[j].beta  = b
								score[j].tX    = p.x
								score[j].tZ    = p.z
								break
							end
						end
					end			
				end				
			end
		end
		
		n     = 0
		angle = nil
		bestD = nil
		bestB = nil
		bestX = nil
		bestZ = nil
		
	--for k=1,2 do
		for k=2,2 do
			for j=1,table.getn( score ) do
				if score[j].angle == nil then
					break
				elseif k == 2 or score[j].score < 10 then
					if n > 0 then
						n     = n + 1
						angle = angle + score[j].angle
						bestD = bestD + score[j].dist 
						bestB = bestB + score[j].beta 
						bestX = bestX + score[j].tX
						bestZ = bestZ + score[j].tZ
					else
						n     = 1
						angle = score[j].angle
						bestD = score[j].dist 
						bestB = score[j].beta 						
						bestX = score[j].tX
						bestZ = score[j].tZ
					--if k == 1 then break end
					end
				end
			end
			if n > 0 then
				break
			end
		end
		
		if n > 1 then
			angle = angle / n
			bestD = bestD / n
			bestB = bestB / n
			bestX = bestX / n
			bestZ = bestZ / n
		end
		
		if debugOutput then
			print("---------------------------------")
			for j=1,table.getn( score ) do
				if score[j].angle == nil then
					break
				else
					print(string.format("%2d: s: %2.3f a: %2.1f° d: %2.3fm b: %2.1f°", j, score[j].score, math.deg( score[j].angle ), math.sqrt( score[j].dist ), math.deg( score[j].beta ) ) )
				end
			end
		end
		
		if      angle ~= nil 
				and AIVEGlobals.devFeatures > 0 then
			print(tostring(math.deg(angle)).."° "..tostring(n).." "..tostring(bestD).." "..tostring(bestB))
		end
	end
	
	if angle == nil then
		onTrack = false
		bestX   = nil
		bestZ   = nil
		
		if vehicle.aiveChain.trace.targetTraceMode == 1 then
			vehicle.aiveChain.trace.targetTraceMode = 0
		end
		
		if fallback ~= nil then
			angle = fallback( vehicle, uTurn )
			if AIVEGlobals.devFeatures > 0 then
				print("Fallback angle: "..math.floor( 0.5 + math.deg( angle )))
			end
		else
			angle = nil
			if AIVEGlobals.devFeatures > 0 then
				print("No angle found")
			end
		end
	end
	
	if angle ~= nil then
		angle = math.min( math.max( angle, -vehicle.aiveChain.maxSteering  ), vehicle.aiveChain.maxSteering  )
	end
	
	return angle, onTrack, bestX, bestZ
end

------------------------------------------------------------------------
-- setToolsAreTurnedOn
------------------------------------------------------------------------
function AutoSteeringEngine.setToolsAreTurnedOn( vehicle, isTurnedOn, immediate, objectFilter )
	if isTurnedOn then 
		vehicle:raiseAIEvent("onAIStartTurn", "onAIImplementStartTurn")
	else 
		vehicle:raiseAIEvent("onAIEndTurn", "onAIImplementEndTurn")
	end 
end

------------------------------------------------------------------------
-- areToolsLowered
------------------------------------------------------------------------
function AutoSteeringEngine.areToolsLowered( vehicle )
	if     vehicle.aiveChain           == nil 
			or vehicle.aiveChain.tools     == nil
			or vehicle.aiveChain.toolCount == nil 
			or vehicle.aiveChain.toolCount <= 0 then
		return nil 
	end
	for _,tool in pairs( vehicle.aiveChain.tools ) do
		if not tool.ignoreAI then
			local atl = AutoSteeringEngine.checkToolIsReadyForWork( tool.obj ) 
			if atl == nil then
				return nil
			elseif not atl then
				return false
			end
		end
	end
	return true
end

------------------------------------------------------------------------
-- setToolIsLowered
------------------------------------------------------------------------
function AutoSteeringEngine.setToolIsLowered( vehicle, tool, isLowered )	
	tool.currentLowerState  = isLowered
	tool.changeLowerTime    = g_currentMission.time
	if tool.targetLowerState == nil then
		tool.targetLowerState = isLowered 
	end
	
	if isLowered then
		SpecializationUtil.raiseEvent(tool.obj, "onAIImplementStartLine")
		vehicle:raiseStateChange(Vehicle.STATE_CHANGE_AI_START_LINE)
	else
		SpecializationUtil.raiseEvent(tool.obj, "onAIImplementEndLine")
		vehicle:raiseStateChange(Vehicle.STATE_CHANGE_AI_END_LINE)
	end
end

------------------------------------------------------------------------
-- setToolsAreLowered
------------------------------------------------------------------------
function AutoSteeringEngine.setToolsAreLowered( vehicle, isLowered, immediate, objectFilter )
	if not ( vehicle.aiveChain ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		return
	end

	local doItNow = false
	if immediate then 
		doItNow = true
	end
	
	for i=1,vehicle.aiveChain.toolCount do		
		if immediate then
			vehicle.aiveChain.tools[i].currentLowerState = nil
		elseif vehicle.aiveChain.tools[i].currentLowerState == nil then
			doItNow = true			
		end

		vehicle.aiveChain.tools[i].targetLowerState = isLowered		
	end	
	
	if doItNow or objectFilter ~= nil then
		for i=1,table.getn( vehicle.aiveChain.toolParams ) do
			if immediate or vehicle.aiveChain.tools[vehicle.aiveChain.toolParams[i].i].obj == objectFilter then
				AutoSteeringEngine.ensureToolIsLowered( vehicle, isLowered, i )
			end
		end
	end
end


------------------------------------------------------------------------
-- raiseToolNoFruits
------------------------------------------------------------------------
function AutoSteeringEngine.raiseToolNoFruits( vehicle, objectFilter )
	if not ( vehicle.aiveChain ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		return
	end
	
	for i=1,table.getn( vehicle.aiveChain.toolParams ) do
		if vehicle.aiveChain.tools[vehicle.aiveChain.toolParams[i].i].obj == objectFilter then
			vehicle.aiveChain.tools[vehicle.aiveChain.toolParams[i].i].targetLowerState = false
			AutoSteeringEngine.ensureToolIsLowered( vehicle, false, i )
			vehicle.aiveChain.tools[vehicle.aiveChain.toolParams[i].i].targetLowerState = true
		end
	end
end

------------------------------------------------------------------------
-- setToolsAreLowered
------------------------------------------------------------------------
function AutoSteeringEngine.setPloughTransport( vehicle, isTransport, excludePackomat )
--if not ( vehicle.aiveChain ~= nil and vehicle.aiveChain.leftActive ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
--	return
--end
--for i=1,vehicle.aiveChain.toolCount do
--	if vehicle.aiveChain.tools[i].ploughTransport then
--		if     isTransport then
--			AutoSteeringEngine.ensureToolIsLowered( vehicle, false )
--			vehicle.aiveChain.tools[i].obj:aiRotateCenter(true)			
--		else
--			vehicle:aiTurnProgress( 0.5, not vehicle.aiveChain.leftActive )
--		end
--	end
--end	
end

------------------------------------------------------------------------
-- ensureToolsLowered
------------------------------------------------------------------------
function AutoSteeringEngine.ensureToolIsLowered( vehicle, isLowered, indexFilter )
	if not ( vehicle.aiveChain ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 ) then
		return
	end
		
	for i=1,table.getn( vehicle.aiveChain.toolParams ) do
		local doit = false
		local tool = vehicle.aiveChain.tools[vehicle.aiveChain.toolParams[i].i]
		
		if indexFilter == nil or indexFilter <= 0 or i == indexFilter then
			if tool.targetLowerState == nil then
				if AIVEGlobals.devFeatures > 0 then print(tool.obj.configFileName..", "..tostring(isLowered)..": no target lowered state") end
				doit = true
			elseif tool.targetLowerState == isLowered and tool.currentLowerState == nil then
			--if AIVEGlobals.devFeatures > 0 then print(tool.obj.configFileName..", "..tostring(isLowered)..": no current lowered state") end
				doit = true
			elseif tool.targetLowerState == isLowered then
				if     ( tool.targetLowerState and not ( tool.currentLowerState ) ) 
						or ( not ( tool.targetLowerState ) and tool.currentLowerState ) then
					if AIVEGlobals.devFeatures > 0 then print(tool.obj.configFileName..", "..tostring(tool.currentLowerState).." -> "..tostring(tool.targetLowerState)) end
					doit = true
				end
			end
		end
		
		if doit then
			AutoSteeringEngine.setToolIsLowered( vehicle, tool, isLowered )			
		end
	end
end

------------------------------------------------------------------------
-- ensureToolsLowered
------------------------------------------------------------------------
function AutoSteeringEngine.findComponentJointDistance( vehicle, object )
	
	if      object.spec_attachable                            ~= nil
			and object.spec_attachable.attacherJoint              ~= nil
			and object.spec_attachable.attacherJoint.jointType    ~= nil
			and ( object.spec_attachable.attacherJoint.jointType  == Vehicle.JOINTTYPE_TRAILERLOW
			   or object.spec_attachable.attacherJoint.jointType  == Vehicle.JOINTTYPE_TRAILER ) then
		return 0, true
	end
	
	return -0.7, false
end

------------------------------------------------------------------------
-- greenDirectCut
------------------------------------------------------------------------
function AutoSteeringEngine.greenDirectCut( vehicle, resetShift )
	if     not ( vehicle.aiveChain ~= nil and vehicle.aiveChain.toolCount ~= nil and vehicle.aiveChain.toolCount >= 1 )
			or ZZZ_greenDirectCut                                    == nil 
			or ZZZ_greenDirectCut.greenDirectCut                     == nil
			or ZZZ_greenDirectCut.greenDirectCut.shiftMinGrowthState == nil
			or ZZZ_greenDirectCut.greenDirectCut.forceGreenForage    == nil then
		return
	end
	
	local shiftDone  = false
	local shiftValue = -1
	
	if resetShift then
		shiftValue = 1
	end
	
	for i=1,vehicle.aiveChain.toolCount do
		local object = vehicle.aiveChain.tools[i].obj
		if object ~= nil and object.convertedFruits ~= nil then
			shiftDone = true
			ZZZ_greenDirectCut.greenDirectCut:shiftMinGrowthState(object,shiftValue)
			if g_currentMission.missionStats.difficulty == 3 then
				ZZZ_greenDirectCut.greenDirectCut:forceGreenForage(object,resetShift)
			end
		end
	end
	
	return shiftDone
end

--***************************************************************
-- getRelativeZTranslation
--***************************************************************
function AutoSteeringEngine.getRelativeZTranslation(root,node)
	local x,y,z = AutoSteeringEngine.getRelativeTranslation(root,node)
	return z
end

--***************************************************************
-- getWorldYRotation
--***************************************************************
function AutoSteeringEngine.getWorldYRotation(node)
	local x, _, z = localDirectionToWorld(node, 0, 0, 1)
	if math.abs(x) < 1e-3 and math.abs(z) < 1e-3 then
		return 0
	end
	return AutoSteeringEngine.normalizeAngle( math.atan2(z,x) + 1.5707963268 )
end

--***************************************************************
-- tableGetN
--***************************************************************
function AutoSteeringEngine.tableGetN( tab )
	if type( tab ) == "table" then
		return table.getn( tab )
	end
	return 0
end	

--***************************************************************
-- countWheelsWithGroundContact
--***************************************************************
function AutoSteeringEngine.countWheelsWithGroundContact( vehicle )
	
	if vehicle == nil or vehicle.spec_wheels or type( vehicle.spec_wheels.wheels ~= "table" ) then 
		return 0 
	end 

	local i = 0
	for _,wheel in pairs( vehicle.spec_wheels.wheels ) do 
		if wheel.hasGroundContact then 
			i = i + 1 
		end 
	end 
	return i 
end 

--***************************************************************
-- getTaJoints1
--***************************************************************
function AutoSteeringEngine.getTaJoints1( vehicle, refNode, zOffset )
	
	if vehicle.spec_attacherJoints == nil or AutoSteeringEngine.tableGetN( vehicle.spec_attacherJoints.attachedImplements ) < 1 then
		return
	end
	
--if vehicle.aiveChain ~= nil and vehicle.aiveChain.noReverseIndex ~= nil and vehicle.aiveChain.noReverseIndex == 0 then
--	return
--end

	local taJoints
	
	for _,implement in pairs( vehicle.spec_attacherJoints.attachedImplements ) do
		if      implement.object ~= nil 
				and implement.object.steeringAxleNode ~= nil 
				and ( implement.object.spec_aiImplement == nil 
					 or implement.object.spec_aiImplement.blockTurnBackward 
					 or not ( implement.object.spec_aiImplement.allowTurnBackward ) )
				and ( AutoSteeringEngine.tableGetN( implement.object.spec_wheels.wheels ) > 0
					 or AutoSteeringEngine.tableGetN( implement.object.spec_attacherJoints.attachedImplements ) > 0 ) 
				and AutoSteeringEngine.getRelativeZTranslation( refNode, implement.object.steeringAxleNode ) < zOffset then

			local taJoints2 = AutoSteeringEngine.getTaJoints2( vehicle, implement, refNode, zOffset )
			local iLast     = AutoSteeringEngine.tableGetN( taJoints2 )
			if iLast > 0 then
				if taJoints == nil then
					taJoints = {}
				end
				for i,joint in pairs( taJoints2 ) do
					table.insert( taJoints, joint )
				end
				break
			end
		end
	end
	
	return taJoints 
end

--***************************************************************
-- getComponentOfNode
--***************************************************************
function AutoSteeringEngine.getComponentOfNode( vehicle, node )

	if node == nil then
		return 0
  end
	
	for i,c in pairs(vehicle.components) do
		if c.node == node then
			return i
		end
	end
	
	local state, result = pcall( getParent, node )
	
	if state and result ~= nil then
		return AutoSteeringEngine.getComponentOfNode( vehicle, getParent( node ) )
	else
		return 0
	end
end
	
--***************************************************************
-- getTaJoints2
--***************************************************************
function AutoSteeringEngine.getTaJoints2( vehicle, implement, refNode, zOffset )

	if     type( implement )                 ~= "table"
			or type( implement.object)           ~= "table"
			or refNode                           == nil
			or implement.object.steeringAxleNode == nil
			or vehicle.spec_attacherJoints      == nil
			or AutoSteeringEngine.tableGetN( vehicle.spec_attacherJoints.attachedImplements ) < 1 then
		return 
	end
		
	local taJoints
	local trailer  = implement.object

	if trailer.spec_attacherJoints ~= nil and AutoSteeringEngine.tableGetN( trailer.spec_attacherJoints.attachedImplements ) > 0 then
		taJoints = AutoSteeringEngine.getTaJoints1( trailer, trailer.steeringAxleNode, 0 )
	end
	
	if taJoints == nil then 
		taJoints = {}
	end
	
  local index = AutoSteeringEngine.tableGetN( taJoints ) + 1
	

	if      implement.jointRotLimit    ~= nil
			and implement.jointRotLimit[2] ~= nil
			and implement.jointRotLimit[2] >  math.rad( 0.1 ) then
		local n = vehicle.spec_attacherJoints.attacherJoints[implement.jointDescIndex].rootNode
		local v = AIVEUtils.getNoNil( vehicle.steeringAxleNode, vehicle.components[1].node )
		if vehicle.aiveChain ~= nil and vehicle.aiveChain.refNode ~= nil then 
			v = vehicle.aiveChain.refNode
		end 
		local a = AutoSteeringEngine.getRelativeYRotation( v, n )
		table.insert( taJoints, index,
									{ nodeVehicle    = n,
										otherDirection = ( math.abs( a ) > 0.75 * math.pi ),
										nodeTrailer    = AIVEUtils.getNoNil( trailer.steeringAxleNode, trailer.components[1].node ),
										targetFactor   = 1 } )
	end
	
	if      AutoSteeringEngine.tableGetN( trailer.spec_wheels.wheels )          > 0
			and AutoSteeringEngine.tableGetN( trailer.components )      > 1
			and AutoSteeringEngine.tableGetN( trailer.componentJoints ) > 0 then
		
		local na = AutoSteeringEngine.getComponentOfNode( trailer, trailer.spec_attachable.attacherJoint.rootNode )
		
		if na > 0 then		
			local wcn = {}
			
			for _,wheel in pairs( trailer.spec_wheels.wheels ) do
				local n = AutoSteeringEngine.getComponentOfNode( trailer, wheel.node )
				if n > 0 then
					wcn[n] = true
				end
			end			
			
			local nextN = { na }
			local allN  = {}
			
			while AutoSteeringEngine.tableGetN( nextN ) > 0 do				
				local thisN = {}
				for _,n in pairs( nextN ) do
					if not ( allN[n] ) then
						thisN[n] = true
						allN[n]  = true
					end
				end
				nextN = {}
				
				for _,cj in pairs( trailer.componentJoints ) do
					if thisN[cj.componentIndices[1]] and not ( allN[cj.componentIndices[2]] ) then
						table.insert( nextN, cj.componentIndices[2] )
						if cj.rotLimit ~= nil and cj.rotLimit[2] ~= nil and cj.rotLimit[2] > math.rad( 0.1 ) then
							table.insert( taJoints, index,
														{ nodeVehicle  = trailer.components[cj.componentIndices[1]].node,
															nodeTrailer  = trailer.components[cj.componentIndices[2]].node, 
															targetFactor = 1 } )
						end
					end
					if thisN[cj.componentIndices[2]] and not ( allN[cj.componentIndices[1]] ) then
						table.insert( nextN, cj.componentIndices[1] )
						if cj.rotLimit ~= nil and cj.rotLimit[2] ~= nil and cj.rotLimit[2] > math.rad( 0.1 ) then
							table.insert( taJoints, index,
														{ nodeVehicle  = trailer.components[cj.componentIndices[2]].node,
															nodeTrailer  = trailer.components[cj.componentIndices[1]].node, 
															targetFactor = 1 } )
						end
					end
				end
			end
		end
	end	

	return taJoints 
end



function AutoSteeringEngine.degToString( d )
	if type(d) ~= "number" then
		return tostring(d)
	end
	return string.format("%6.2f°",d)
end
function AutoSteeringEngine.radToString( r )
	if r == nil then
		return "nil"
	end
	return AutoSteeringEngine.degToString( math.deg( r ))
end
function AutoSteeringEngine.posToString( p )
	if type(p) ~= "number" then
		return tostring(p)
	end
	return string.format("%6.3f",p)
end

function AutoSteeringEngine.SowingMachineProcessSowingMachineArea(self, superFunc, workArea, dt)
	local vehicle = self:getRootVehicle()
	local spec    = self.spec_sowingMachine

	if      spec == nil or ( spec.useDirectPlanting and not ( spec.useDirectPlanting  )) then 
	-- do nothing
	elseif  vehicle              ~= nil
			and vehicle.acParameters ~= nil
			and vehicle.acParameters.enabled
			and vehicle.aiveHas      ~= nil
			and vehicle.aiveHas.cultivator then 
		if not ( spec.useDirectPlanting ) then 
			spec.aiveDirectPlanting = true 
			spec.useDirectPlanting  = true 
		end 
	elseif spec.aiveDirectPlanting then 
		spec.useDirectPlanting  = false 
	end 
	
	return superFunc( self, workArea, dt)
end
SowingMachine.processSowingMachineArea = Utils.overwrittenFunction( SowingMachine.processSowingMachineArea, AutoSteeringEngine.SowingMachineProcessSowingMachineArea )

function AutoSteeringEngine.SowingMachineUpdateAiParameters(self, superFunc)
	local vehicle = self:getRootVehicle()
	local spec    = self.spec_sowingMachine

	if      spec == nil or ( spec.useDirectPlanting and not ( spec.useDirectPlanting  )) then 
	-- do nothing
	elseif  vehicle              ~= nil
			and vehicle.aiveIsStarted
			and vehicle.aiveHas      ~= nil
			and vehicle.aiveHas.cultivator then 
		if not ( spec.useDirectPlanting ) then 
			spec.aiveDirectPlanting = true 
			spec.useDirectPlanting  = true 
		end 
	elseif spec.aiveDirectPlanting then 
		spec.useDirectPlanting  = false 
	end 
	
	return superFunc( self )
end 
SowingMachine.updateAiParameters = Utils.overwrittenFunction( SowingMachine.updateAiParameters, AutoSteeringEngine.SowingMachineUpdateAiParameters )

function AutoSteeringEngine.CultivatorProcessCultivatorArea(self, superFunc, workArea, dt)
	local vehicle = self:getRootVehicle()
	local spec = self.spec_cultivator

	if      vehicle              ~= nil
			and vehicle.aiveIsStarted
			and vehicle.aiveHas      ~= nil
			and vehicle.aiveHas.sowingMachine then 
		
		local xs,_,zs = getWorldTranslation(workArea.start)
		local xw,_,zw = getWorldTranslation(workArea.width)
		local xh,_,zh = getWorldTranslation(workArea.height)
		
		if spec.isSubsoiler then
			FSDensityMapUtil.updateSubsoilerArea(xs,zs, xw,zw, xh,zh)
		end
		FSDensityMapUtil.eraseTireTrack(xs,zs, xw,zw, xh,zh)
		spec.isWorking = self:getLastSpeed() > 0.5
		
		return 0, 0
	end 
	
	return superFunc( self, workArea, dt)
end 
Cultivator.processCultivatorArea = Utils.overwrittenFunction( Cultivator.processCultivatorArea, AutoSteeringEngine.CultivatorProcessCultivatorArea )