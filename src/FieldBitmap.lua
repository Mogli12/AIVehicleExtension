------------------------------------------------------------------------
-- FieldBitmapTile
------------------------------------------------------------------------
local FieldBitmapTile = {}

------------------------------------------------------------------------
-- getNewTile
------------------------------------------------------------------------
function FieldBitmapTile.getNewTile( iX, iZ, iStepLog2, iRelX, iRelZ, iInvert )

	local relX, relZ, self;
	
	self = {};
	
	if iRelX == nil then
		relX = 0
	else
		relX = math.min( math.max( iRelX, 0 ), 1 )
	end
	
	if iRelZ == nil then
		relZ = 0
	else
		relZ = math.min( math.max( iRelZ, 0 ), 1 )
	end
	
	if iInvert then
		self.invert = true
	else
		self.invert = false
	end
	
	self.sizeLog2 = 5	
	self.sizeInt  = 32
	
	if iStepLog2 == nil then
		self.stepLog2 = 2
	else 
		self.stepLog2 = math.min( math.max( math.floor( iStepLog2 + 0.5 ), 0 ), 4 )
	end
	
	self.size    = 2 ^ ( self.sizeLog2 - self.stepLog2 )
	
	self.step    = 2 ^ self.stepLog2;
	self.stepInv = 2 ^ (-self.stepLog2);
	
	self.startX  = iX + relX * self.size
	self.startZ  = iZ + relZ * self.size
	self.endX    = self.startX + self.size
	self.endZ    = self.startZ + self.size

	self.bitmap  = { 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0 }--, 0,0,0,0,0,0,0,0 }	
	return self
end

------------------------------------------------------------------------
-- clone
------------------------------------------------------------------------
function FieldBitmapTile.clone( template )

	self = {};
	
	self.invert   = template.invert
	self.sizeLog2 = template.sizeLog2 
	self.sizeInt  = template.sizeInt  	
	self.size     = template.size   
	self.step     = template.step   
	self.stepInv  = template.stepInv
	self.startX   = template.startX 
	self.startZ   = template.startZ 
	self.endX     = template.endX   
	self.endZ     = template.endZ   

	self.bitmap   = {}
	for i,b in pairs(template.bitmap) do
		self.bitmap[i] = b
	end
	
	return self
end

------------------------------------------------------------------------
-- getIndex
------------------------------------------------------------------------
function FieldBitmapTile:getIndex( x, z )
	local i =     math.floor( self.step * ( x - self.startX ) )
	local j = 1 + math.floor( self.step * ( z - self.startZ ) )
	return i,j
end

------------------------------------------------------------------------
-- checkIndex
------------------------------------------------------------------------
function FieldBitmapTile:checkIndex( i, j )
	if i < 0 or i >= self.sizeInt then return false end	
	if j < 1 or j >  self.sizeInt then return false end
	return true
end
	
------------------------------------------------------------------------
-- getBitHelper
------------------------------------------------------------------------	

function FieldBitmapTile.getBitHelper( bitmap, i )	
	if bitmap <= 0 then
		return 0
	elseif bit32 ~= nil then
		return bit32.extract( bitmap, i, 1 ) > 0
	else
		if FieldBitmapTile.getBitHelperConstants == nil then
			FieldBitmapTile.getBitHelperConstants = {}
			for b=31,0,-1 do
				table.insert( FieldBitmapTile.getBitHelperConstants, { bit=b, value=2^b } )
			end
		end
		local v = bitmap
		for _,h in pairs(FieldBitmapTile.getBitHelperConstants) do
			if v >= h.value then
				if i > h.bit then
					return 0
				elseif i == h.bit then
					return 1
				end
				v = v - h.value 
			end
		end
		return 0
	end
	
	return math.floor( bitmap / 2^i ) % 2 > 0
end

------------------------------------------------------------------------
-- getBit
------------------------------------------------------------------------	
function FieldBitmapTile:getBit( x, z )
	local i, j = FieldBitmapTile.getIndex( self, x, z )	
	if not FieldBitmapTile.checkIndex( self, i, j ) then return false end
	
	local v = FieldBitmapTile.getBitHelper( self.bitmap[j], i )	
	--if bit32 ~= nil then
	--	v = bit32.extract( self.bitmap[j], i, 1 )
	--else
	--	v = math.floor( self.bitmap[j] / 2^i ) % 2
	--end
	
	local ret = 0 < v
	
	if self.invert then
		if ret then ret = false else ret = true end
	end
	
	return ret
end

------------------------------------------------------------------------
-- setBit
------------------------------------------------------------------------
function FieldBitmapTile:setBit( x, z, set )
	local i, j = FieldBitmapTile.getIndex( self, x, z )
	if not FieldBitmapTile.checkIndex( self, i, j ) then return false end

	if self.invert then
		if set == nil or set == true then set = false else set = true end
	end
	
	if set == nil or set == true then 
		if bit32 ~= nil then 
			self.bitmap[j] = bit32.replace( self.bitmap[j], 1, i, 1 )
	--elseif math.floor( self.bitmap[j] / 2^i ) % 2 < 1 then
		elseif FieldBitmapTile.getBitHelper( self.bitmap[j], i ) < 1 then
			self.bitmap[j] = self.bitmap[j] + 2^i
		end
	else
		if bit32 ~= nil then 
			self.bitmap[j] = bit32.replace( self.bitmap[j], 0, i, 1 )
	--elseif math.floor( self.bitmap[j] / 2^i ) % 2 > 0 then
		elseif FieldBitmapTile.getBitHelper( self.bitmap[j], i ) > 0 then
			self.bitmap[j] = self.bitmap[j] - 2^i
		end
	end
	
	return true
end

------------------------------------------------------------------------
-- FieldBitmap
------------------------------------------------------------------------
FieldBitmap = {}

------------------------------------------------------------------------
-- create
------------------------------------------------------------------------
function FieldBitmap.create( iStepLog2, tiles )
	local s = 5 - Utils.getNoNil( iStepLog2, 2 )

	local self = { tiles    = {}, 
								 stepLog2 = s, 
								 factor1  = 2^s, 
								 factor2  = 2^(-s) }
								 
	if type( tiles ) == "table" then
		for i,t1 in pairs(tiles) do
			self.tiles[i] = {}
			for j,t2 in pairs(t1) do
				self.tiles[i][j] = FieldBitmapTile.clone( t2 )
			end
		end	
	end
------------------------------------------------------------------------
-- clone
------------------------------------------------------------------------
	local clone = function( )
		return FieldBitmap.create( 5 - self.stepLog2, self.tiles )
	end
	
------------------------------------------------------------------------
-- getTile
------------------------------------------------------------------------
	local getTile = function( x, z )
		return math.floor( self.factor2 * x ), math.floor( self.factor2 * z )
	end
	
------------------------------------------------------------------------
-- setBit
------------------------------------------------------------------------	
	local setBit = function( x, z, set )
		local i, j = getTile( x, z )
		if self.tiles[i] == nil then
			if set ~= nil and set ~= true then return end
			self.tiles[i] = {}
		end
		if self.tiles[i][j] == nil then
			if set ~= nil and set ~= true then return end
			self.tiles[i][j] = FieldBitmapTile.getNewTile( self.factor1 * i, self.factor1 * j, 5 - self.stepLog2 )
		end
		FieldBitmapTile.setBit( self.tiles[i][j], x, z, set )
	end
	
------------------------------------------------------------------------
-- getBit
------------------------------------------------------------------------
	local getBit = function( x, z )
		local i, j = getTile( x, z )
		if self.tiles[i] == nil then return false end
		if self.tiles[i][j] == nil then return false end
		return FieldBitmapTile.getBit( self.tiles[i][j], x, z )
	end
	
------------------------------------------------------------------------
-- getPoints
------------------------------------------------------------------------
	local getPoints = function( )
		points = {}
		for _,t1 in pairs(self.tiles) do
			for _,t2 in pairs(t1) do
				for j=1,32 do
					z = ( j-1 ) * t2.stepInv + t2.startZ
					i=0
					n=t2.bitmap[j]
					for i=0,31 do
						if n<=0 then 
							if t2.invert then
								x = i * t2.stepInv + t2.startX
								table.insert( points, { x, z } )
							else
								break 
							end
						else
							bit = ( n%2 > 0 )
							if bit then
								if not t2.invert then
									x = i * t2.stepInv + t2.startX
									table.insert( points, { x, z } )
								end
								n = n - 1
							elseif t2.invert then
								x = i * t2.stepInv + t2.startX
								table.insert( points, { x, z } )
							end
							n = n / 2
						end
					end
				end
			end
		end
		
		return points
	end

------------------------------------------------------------------------
-- tileExists
------------------------------------------------------------------------
	local tileExists = function( x, z )
		local i, j = getTile( x, z )
		if self.tiles[i] == nil then return false end
		if self.tiles[i][j] == nil then return false end
		return true
	end
	
------------------------------------------------------------------------
-- getTileDimensions
------------------------------------------------------------------------
	local getTileDimensions = function( x, z )
		local i, j = getTile( x, z )
		local startX = self.factor1 * i
		local startZ = self.factor1 * j
		local length = self.factor1 
		return startX, startZ, length
	end
	
------------------------------------------------------------------------
-- createOneTile
------------------------------------------------------------------------
	local createOneTile = function( x, z )
		local i, j = getTile( x, z )
		
		if self.tiles[i] == nil then
			self.tiles[i] = {}
		end
		self.tiles[i][j] = FieldBitmapTile.getNewTile( self.factor1 * i, self.factor1 * j, 5 - self.stepLog2, nil, nil, true )
	end
	
------------------------------------------------------------------------
-- getPoint
------------------------------------------------------------------------
	local getPoint = function( iX, iZ )
		f1 = 2^(self.stepLog2 - 5)
		f2 = 2^(5 - self.stepLog2)
		local x = f1 * math.floor( f2 * iX + 0.5 )
		local z = f1 * math.floor( f2 * iZ + 0.5 )
		return x, z
	end
	
------------------------------------------------------------------------
-- getAreaTotalCount
------------------------------------------------------------------------
	local getAreaTotalCount = function( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
		local area  = 0
		local total = 0
	
		local minX = startWorldX
		local maxX = startWorldX
		local minZ = startWorldZ
		local maxZ = startWorldZ
		
		minX = math.min( minX, widthWorldX )
		maxX = math.max( maxX, widthWorldX )
		minZ = math.min( minX, widthWorldZ )
		maxZ = math.max( maxX, widthWorldZ )

		minX = math.min( minX, heightWorldX )
		maxX = math.max( maxX, heightWorldX )
		minZ = math.min( minX, heightWorldZ )
		maxZ = math.max( maxX, heightWorldZ )
		
		local x = widthWorldX + heightWorldX - startWorldX
		local z = widthWorldZ + heightWorldZ - startWorldZ

		minX = math.min( minX, x )
		maxX = math.max( maxX, x )
		minZ = math.min( minX, z )
		maxZ = math.max( maxX, z )
		
		local minI, minJ = getTile( minX, minZ )
		local maxI, maxJ = getTile( maxX, maxZ )
		
		
		local stepInv = 2 ^ (self.stepLog2 - 5)

		for curI=minI,maxI do
			for curJ=minJ,maxJ do
			
				local t2
				if self.tiles[curI] ~= nil then
					t2 = self.tiles[curI][curJ]
				else
					t2 = nil
				end
				
				local startX  = self.factor1 * curI
				local startZ  = self.factor1 * curJ

				for j=1,32 do
					z = ( j-1 ) * stepInv + startZ
					for i=0,31 do
						x = i * stepInv + startX
										
						if FieldBitmap.checkPointInParallelogram( x, z, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ ) then
							total = total + 1
							if t2 ~= nil and FieldBitmapTile.getBit( t2, x, z ) then
								area = area + 1
							end
						end
					end
				end
			end
		end
		
		return area, total 
	end
		
------------------------------------------------------------------------
-- cutArea
------------------------------------------------------------------------
	local cutArea = function( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
		local minX = startWorldX
		local maxX = startWorldX
		local minZ = startWorldZ
		local maxZ = startWorldZ
		
		minX = math.min( minX, widthWorldX )
		maxX = math.max( maxX, widthWorldX )
		minZ = math.min( minX, widthWorldZ )
		maxZ = math.max( maxX, widthWorldZ )

		minX = math.min( minX, heightWorldX )
		maxX = math.max( maxX, heightWorldX )
		minZ = math.min( minX, heightWorldZ )
		maxZ = math.max( maxX, heightWorldZ )
		
		local x = widthWorldX + heightWorldX - startWorldX
		local z = widthWorldZ + heightWorldZ - startWorldZ

		minX = math.min( minX, x )
		maxX = math.max( maxX, x )
		minZ = math.min( minX, z )
		maxZ = math.max( maxX, z )
		
		local minI, minJ = getTile( minX, minZ )
		local maxI, maxJ = getTile( maxX, maxZ )
		
		
		local stepInv = 2 ^ (self.stepLog2 - 5)

		for curI=minI,maxI do
			for curJ=minJ,maxJ do
				if self.tiles[curI] ~= nil and self.tiles[curI][curJ] ~= nil then
					t2 = self.tiles[curI][curJ]
				
					local startX  = self.factor1 * curI
					local startZ  = self.factor1 * curJ

					for j=1,32 do
						z = ( j-1 ) * stepInv + startZ
						for i=0,31 do
							x = i * stepInv + startX
											
							if FieldBitmap.checkPointInParallelogram( x, z, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ ) then
								FieldBitmapTile.setBit( t2, x, z, 0 )
							end
						end
					end
				end
			end
		end
		
		return area, total 
	end
		
	return { setBit            = setBit, 
					 getBit            = getBit, 
					 getPoints         = getPoints,
					 tileExists        = tileExists, 
					 getTileDimensions = getTileDimensions,
					 createOneTile     = createOneTile,
					 getPoint          = getPoint,
					 getAreaTotalCount = getAreaTotalCount,
					 cutArea           = cutArea,
					 clone             = clone }
end

------------------------------------------------------------------------
-- prepareIsField
------------------------------------------------------------------------
function FieldBitmap.prepareIsField( )
	setDensityCompareParams(g_currentMission.terrainDetailId, "greater", 0, 0, 0, 0);
end

------------------------------------------------------------------------
-- getAreaTotal
------------------------------------------------------------------------
function FieldBitmap.getAreaTotal( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
  local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(g_currentMission.terrainDetailId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
  local _,area,totalArea = getDensityParallelogram(g_currentMission.terrainDetailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels );
	return area, totalArea
end

------------------------------------------------------------------------
-- isFieldFast
------------------------------------------------------------------------
function FieldBitmap.isFieldFast( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
  local area,totalArea = FieldBitmap.getAreaTotal( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
	return area > 0
end

------------------------------------------------------------------------
-- isField
------------------------------------------------------------------------
function FieldBitmap.isField( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )
	for channel=0,3 do
		if Utils.getDensity(g_currentMission.terrainDetailId, channel, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ ) > 0 then
			return true
		end
	end
	return false
end

------------------------------------------------------------------------
-- getParallelogram
------------------------------------------------------------------------
function FieldBitmap.getParallelogram( x, z, size, ofs )
	return x-ofs, z-ofs, x+size, z, x, z+size
end

------------------------------------------------------------------------
-- cleanupAfterIsField
------------------------------------------------------------------------
function FieldBitmap.cleanupAfterIsField( )
  setDensityCompareParams(g_currentMission.terrainDetailId, "greater", -1);
end

------------------------------------------------------------------------
-- checkPointInParallelogram
------------------------------------------------------------------------
function FieldBitmap.checkPointInParallelogram( px, pz, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ )

	local x2 = widthWorldX  - startWorldX
	local z2 = widthWorldZ  - startWorldZ
	local x3 = heightWorldX - startWorldX
	local z3 = heightWorldZ - startWorldZ
	local x1 = px           - startWorldX
	local z1 = pz           - startWorldZ
	
	local bz = z2 * x1 - x2 * z1
	local bn = z2 * x3 - x2 * z3
	
	if     bz == 0
			or ( 0 < bz and bz <= bn )
			or ( 0 > bz and bz >= bn ) then
		local az = z3 * x1 - x3 * z1
		local an = z3 * x2 - x3 * z2
		if     az == 0
				or ( 0 < az and az <= an )
				or ( 0 > az and az >= an ) then
			return true
		end
	end
	
	return false
end

------------------------------------------------------------------------
-- createForFieldAtWorldPositionSimple
------------------------------------------------------------------------
function FieldBitmap.createForFieldAtWorldPositionSimple( iX, iZ, iStepLog2, iOverlap, iCheckFunction, iYieldCount )
	if iCheckFunction == nil or iCheckFunction == FieldBitmap.isFieldFast then
		return FieldBitmap.createForFieldAtWorldPosition( iX, iZ, iStepLog2, iOverlap, FieldBitmap.getAreaTotal, FieldBitmap.prepareIsField, FieldBitmap.cleanupAfterIsField, iYieldCount )
	else
		local checkFunction = function( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ ) 
			if iCheckFunction( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ ) then
				return 1,2
			end
			return 0,2
		end
		return FieldBitmap.createForFieldAtWorldPosition( iX, iZ, iStepLog2, iOverlap, checkFunction, nil, nil, iYieldCount )
	end
end

------------------------------------------------------------------------
-- createForFieldAtWorldPosition
------------------------------------------------------------------------
function FieldBitmap.createForFieldAtWorldPosition( iX, iZ, iStepLog2, iOverlap, iAreaTotalFunction, iPrepareFunction, iCleanupFunction, iYieldCount )

	local field, done, f1, f2
	if iAreaTotalFunction == nil then
		iAreaTotalFunction = FieldBitmap.getAreaTotal
		iPrepareFunction   = FieldBitmap.prepareIsField
		iCleanupFunction   = FieldBitmap.cleanupAfterIsField
	end
	
	if iStepLog2 == nil or iStepLog2 == 2 then
		f1 = 0.25
		f2 = 4
	else
		f1 = 2^(-iStepLog2)
		f2 = 2^(iStepLog2)
	end
	local f3 = f1 * 0.5
	
	local fo1,fo3 = f1,f3
	if iOverlap ~= nil then 
		fo1 = fo1 * iOverlap
		fo3 = fo3 * iOverlap
	end

	if iPrepareFunction ~= nil then
		iPrepareFunction( )
	end
	
	if iAreaTotalFunction( FieldBitmap.getParallelogram( iX, iZ, fo1, fo3 ) ) <= 0 then 
		if iCleanupFunction ~= nil then
			iCleanupFunction( )
		end
		return nil, 0
	end

	field = FieldBitmap.create( iStepLog2 )
	done  = FieldBitmap.create( iStepLog2 )
	
	local x = f1 * math.floor( f2 * iX + 0.5 )
	local z = f1 * math.floor( f2 * iZ + 0.5 )
	local x1, z1, l1
	
	local lists = {}
	local cur, nxt = 1,2
	lists[1] = { { x, z } }
	
	done.setBit( x, z )
	
	local cycle = 0
	local count = 0
	local sqrm  = 0
	local skip  = false
	local a,t

	--print(string.format("Starting field detection with step size %0.3fm...",fo1))
	--if checkFunction == FieldBitmap.isFieldFast then
	--	print("...using built-in check function...")
	--end

	while table.getn( lists[cur] ) > 0 do
		cycle = cycle + 1
		lists[nxt] = {}
		
		for _,p in pairs( lists[cur] ) do
			count = count + 1
			
			x, z = unpack( p )
			skip = false
			if not done.getBit( x, z ) then
				print("ERROR: FieldBitmap error code 11")
			end
			
			if iYieldCount ~= nil and iYieldCount > 0 and count > iYieldCount then
			
				if iCleanupFunction ~= nil then
					iCleanupFunction( )
				end
				
				coroutine.yield( nil, sqrm*fo1*fo1*0.0001 )
				
				if iPrepareFunction ~= nil then
					iPrepareFunction( )	
				end

				if     fo1 == nil then
					print("ERROR: FieldBitmap error code 1")
				elseif fo3 == nil then
					print("ERROR: FieldBitmap error code 2")
				elseif p == nil then
					print("ERROR: FieldBitmap error code 3")
				elseif lists == nil then
					print("ERROR: FieldBitmap error code 4")
				elseif lists[cur] == nil then
					print("ERROR: FieldBitmap error code 5")
				elseif lists[nxt] == nil then
					print("ERROR: FieldBitmap error code 6")
				elseif iYieldCount == nil then
					print("ERROR: FieldBitmap error code 7")
				elseif field == nil then
					print("ERROR: FieldBitmap error code 8")
				elseif done == nil then
					print("ERROR: FieldBitmap error code 9")
				elseif not done.getBit( x, z ) then
					print("ERROR: FieldBitmap error code 10")
				end
				count = 1
			end
			
			if not field.tileExists( x, z ) then
				x1, z1, l1 = field.getTileDimensions( x, z )
				a, t = iAreaTotalFunction( FieldBitmap.getParallelogram( x1, z1, l1, fo3 ) )
				if     a == 0 then
					skip = true
					done.createOneTile( x, z )
				elseif a == t then
					skip = true
					done.createOneTile( x, z )
					field.createOneTile( x, z )
					sqrm = sqrm + 1024

					x = x1
					z = z1

					x1 = x-f1; z1 = z;    if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x+l1; z1 = z;    if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x;    z1 = z-f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x;    z1 = z+l1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x-f1; z1 = z-f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x+l1; z1 = z-f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x-f1; z1 = z+l1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
					x1 = x+l1; z1 = z+l1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				end
			end

			if not skip and iAreaTotalFunction( FieldBitmap.getParallelogram( x, z, fo1, fo3 ) ) > 0 then
				field.setBit( x, z )
				x1 = x-f1; z1 = z;    if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x+f1; z1 = z;    if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x;    z1 = z-f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x;    z1 = z+f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x-f1; z1 = z-f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x+f1; z1 = z-f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x-f1; z1 = z+f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				x1 = x+f1; z1 = z+f1; if not done.getBit( x1, z1 ) then done.setBit( x1, z1 ) table.insert( lists[nxt], { x1, z1 } ) end
				sqrm = sqrm + 1
			end
		end
		
		local tmp = cur
		cur = nxt
		nxt = tmp
	end

	--print(string.format("==> Field detection finished for %0.3f ha in %i cycles.", sqrm*fo1*fo1*0.0001, cycle ))
	
	if iCleanupFunction ~= nil then
		iCleanupFunction( )
	end
	
	return field, sqrm*fo1*fo1*0.0001
end


------------------------------------------------------------------------
-- unitTest(s)
------------------------------------------------------------------------
local function unitTest1( )
	print("------------------------------------------------------------------------")
	
	local tileTest = FieldBitmapTile.getNewTile( 10, 5, 2, nil, nil, true )
	
	print(tostring( tileTest.size ))
	print(tostring( tileTest.sizeInt ))
	print(tostring( tileTest.step ))
	print(tostring( tileTest.startX ))
	print(tostring( tileTest.startZ ))
	print(tostring( tileTest.endX ))
	print(tostring( tileTest.endZ ))
  
	FieldBitmapTile.setBit( tileTest, 17.75, 12.75, false )
	print(tostring( FieldBitmapTile.getBit( tileTest, 17.75, 12.75 ) ))
	FieldBitmapTile.setBit( tileTest, 18, 13, false )
	print(tostring( FieldBitmapTile.getBit( tileTest, 18, 13 ) ))
	
	FieldBitmapTile.setBit( tileTest, 10, 5, false )
	print(tostring( FieldBitmapTile.getBit( tileTest, 10, 5 ) ))
	FieldBitmapTile.setBit( tileTest, 9.75, 4.75, false )
	print(tostring( FieldBitmapTile.getBit( tileTest, 9.75, 4.75 ) ))
	
	print(tostring( FieldBitmapTile.getBit( tileTest, 11, 11 ) ))
	FieldBitmapTile.setBit( tileTest, 11, 11, false )
  
	print("------------------------------------------------------------------------")
	
	for i=-3,3 do for j=-3,3 do
		local x = 11 + tileTest.stepInv * i
		local z = 11 + tileTest.stepInv * j
		print(tostring(x).." "..tostring(z).." "..tostring( FieldBitmapTile.getBit( tileTest, x, z ) ))
	end end
  
	print("------------------------------------------------------------------------")
  
	FieldBitmapTile.setBit( tileTest, 11, 11, true )
	print(tostring( FieldBitmapTile.getBit( tileTest, 11, 11 ) ))
	
	print("------------------------------------------------------------------------")
end

local function unitTest2( )
	print("------------------------------------------------------------------------")
	
	local x0,z0 = -134.750, 12.750
	local map = FieldBitmap.create( )
	local stepInv = 2 ^ (-2)
	
	
	map.setBit( x0, z0 )
	for i=-3,3 do for j=-3,3 do
		local x = x0 + stepInv * i
		local z = z0 + stepInv * j
		print(tostring(x).." "..tostring(z).." "..tostring( map.getBit( x, z ) ))
	end end

	local map2 = FieldBitmap.create( )
	print(tostring( map.getBit( x0, z0 ) ))
	print(tostring( map2.getBit( x0, z0 ) ))

	map.setBit( x0, z0, false )
	print(tostring( map.getBit( x0, z0 ) ))
	print(tostring( map2.getBit( x0, z0 ) ))

	map2.setBit( x0, z0 )
	print(tostring( map.getBit( x0, z0 ) ))
	print(tostring( map2.getBit( x0, z0 ) ))

	print("------------------------------------------------------------------------")
	
	print("------------------------------------------------------------------------")
	
	local x0,z0 = -134.750, 12.750
	local map = FieldBitmap.create( 3 )
	
	map.setBit( x0, z0 )
	for i=-3,3 do for j=-3,3 do
		local x = x0 + stepInv * i
		local z = z0 + stepInv * j
		print(tostring(x).." "..tostring(z).." "..tostring( map.getBit( x, z ) ))
	end end

	local map2 = FieldBitmap.create( 3 )
	print(tostring( map.getBit( x0, z0 ) ))
	print(tostring( map2.getBit( x0, z0 ) ))

	map.setBit( x0, z0, false )
	print(tostring( map.getBit( x0, z0 ) ))
	print(tostring( map2.getBit( x0, z0 ) ))

	map2.setBit( x0, z0 )
	print(tostring( map.getBit( x0, z0 ) ))
	print(tostring( map2.getBit( x0, z0 ) ))

	print("------------------------------------------------------------------------")
end

--unitTest1( )
--unitTest2( )


