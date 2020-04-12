FieldScanner = {}

function FieldScanner:new( isFieldFct, hasFruitFct, bitMapSize, startUpFct, cleanUpFct )
	local self = {}
	setmetatable(self, { __metatable = FieldScanner, __index = FieldScanner } )
	
	self.bitMapSize  = Utils.getNoNil( bitMapSize, 32768 )
	self.terrainSize = getTerrainSize(g_currentMission.terrainRootNode)
	self.terrainOfs  = self.terrainSize * 0.5
	self.terrainQuot = self.bitMapSize / self.terrainSize
	self.terrainMult = self.terrainSize / self.bitMapSize
	self.isFieldFct  = isFieldFct 
	self.hasFruitFct = hasFruitFct
	self.startUpFct  = startUpFct 
	self.cleanUpFct  = cleanUpFct 
	self.stepCount   = 0
	self.fieldBits   = 0
	self.fruitBits   = 0
	
	if self.isFieldFct == nil then 
		self.startUpFct = function() 
			self.fieldMod = {}
			self.fieldMod.modifier = DensityMapModifier:new(g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)
			self.fieldMod.filter   = DensityMapFilter:new(self.fieldMod.modifier)
			self.fieldMod.filter:setValueCompareParams("greater", 0)
		end
		self.isFieldFct = function( startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ ) 
			self.fieldMod.modifier:setParallelogramWorldCoords(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, "ppp")
			local _, area, totalArea = self.fieldMod.modifier:executeGet(self.fieldMod.filter)		
			return area, totalArea
		end
	end
	
	return self
end

function FieldScanner:loadFromSavegame( directory, index )
	self.fieldVector = createBitVectorMap( "field" )
	self.fruitVector = createBitVectorMap( "fruit" )
	
	loadBitVectorMapFromFile(self.fieldVector, directory..string.format("/aiveField%d.grle", index ), 1)
	loadBitVectorMapFromFile(self.fruitVector, directory..string.format("/aiveFruit%d.grle", index ), 1)
end

function FieldScanner:delete() 
end 

function FieldScanner:writeToSavegame( directory, index )
	saveBitVectorMapToFile( self.fieldVector, directory..string.format("/aiveField%d.grle", index ) )
	saveBitVectorMapToFile( self.fruitVector, directory..string.format("/aiveFruit%d.grle", index ) )
end 

function FieldScanner:startScan( startX, startZ, yieldCount )
	self.yieldCount  = yieldCount
	self.stepCount   = 0
	self.fieldBits   = 0
	self.fruitBits   = 0
	self.fieldVector = createBitVectorMap( "field" )
	self.fruitVector = createBitVectorMap( "fruit" )
	loadBitVectorMapNew(self.fieldVector, self.bitMapSize, self.bitMapSize, 1, false)
	loadBitVectorMapNew(self.fruitVector, self.bitMapSize, self.bitMapSize, 1, false)

	local xi = math.floor( ( startX + self.terrainOfs ) * self.terrainQuot )
	local zi = math.floor( ( startZ + self.terrainOfs ) * self.terrainQuot )
	local di = 1 
	
	for i=1,2 do
		self.scanPhase = {}
		
		if     i == 1 then
			self.scanPhase.chckFct   = self.isFieldFct
			self.scanPhase.bitVector = self.fieldVector
			self.scanPhase.bitCounter = "fieldBits"
			todoFct = function ( xi, zi, di ) 
				return getBitVectorMapParallelogram( self.scanPhase.todoVector, xi, zi, di, 0, 0, di, 0, 1 ) > 0
			end 
		elseif i == 2 and self.scanPhase.fruitX ~= nil then 
			xi = self.scanPhase.fruitX
			zi = self.scanPhase.fruitZ
			di = self.scanPhase.fruitD
			self.scanPhase.chckFct   = self.hasFruitFct
			self.scanPhase.bitVector = self.fruitVector
			self.scanPhase.bitCounter = "fruitBits"
			todoFct = function ( xi, zi, di ) 
				if getBitVectorMapParallelogram( self.fieldVector, xi, zi, di, 0, 0, di, 0, 1 ) <= 0 then
					return false 
				end 
				return getBitVectorMapParallelogram( self.scanPhase.todoVector, xi, zi, di, 0, 0, di, 0, 1 ) > 0
			end 		
		end
		self.scanPhase.doneFct = function ( xi, zi, di )
			setBitVectorMapParallelogram( self.scanPhase.todoVector, xi, zi, di, 0, 0, di, 0, 1, 0 )
		end 
		
		if self.scanPhase.chckFct ~= nil then 		
			if self.startUpFct ~= nil then 
				self.startUpFct()
			end 
			self.scanPhase.todoVector = createBitVectorMap( "todo" )
			loadBitVectorMapNew( self.scanPhase.todoVector, self.bitMapSize, self.bitMapSize, 1, true )
				
			local i = math.floor( xi / di )
			local j = math.floor( zi / di )
		
			self:scanTile( xi, zi, di )
			if i % 2 > 0 and j % 2 > 0 then  
				self:scanTile( xi - di, zi     , di )
				self:scanTile( xi     , zi - di, di )
				self:scanTile( xi - di, zi - di, di )
			elseif xi % 2 > 0 then 
				self:scanTile( xi - di, zi     , di )
				self:scanTile( xi     , zi + di, di )
				self:scanTile( xi - di, zi + di, di )
			elseif zi % 2 > 0 then 
				self:scanTile( xi + di, zi     , di )
				self:scanTile( xi     , zi - di, di )
				self:scanTile( xi + di, zi - di, di )
			else 
				self:scanTile( xi + di, zi     , di )
				self:scanTile( xi     , zi + di, di )
				self:scanTile( xi + di, zi + di, di )
			end 
			
			delete( self.scanPhase.todoVector )
			if self.cleanUpFct ~= nil then 
				self.cleanUpFct()
			end 
		end 
	end 
	
	self.scanPhase = nil
	
	return true, self.fieldBits, self.fruitBits
end 

function FieldScanner:scanTile( xi, zi, di )
	self.stepCount = self.stepCount + 1 
	if self.yieldCount ~= nil and self.yieldCount > 0 and self.stepCount >= self.yieldCount then 
		coroutine.yield( nil, self.fieldBits, self.fruitBits )
		self.stepCount = 0
	end 
	if di < 1 or getBitVectorMapParallelogram( self.scanPhase.todoVector, xi, zi, di, 0, 0, di, 0, 1 ) <= 0 then 
		return 
	end 
	setBitVectorMapParallelogram( self.scanPhase.todoVector, xi, zi, di, 0, 0, di, 0, 1, 0 )
	local x = xi * self.terrainMult - self.terrainOfs
	local z = zi * self.terrainMult - self.terrainOfs
	local d = di * self.terrainMult
	local a1, t1 = self.scanPhase.chckFct( x, z, x + d, z, x, z + d )
	
	if self.scanPhase.fruitX == nil and self.hasFruitFct ~= nil then 
		local a2, t2 = self.hasFruitFct( x, z, x + d, z, x, z + d )
		if a2 > 0 and t2 > 0 then 
			self.scanPhase.fruitX = xi 
			self.scanPhase.fruitZ = zi 
			self.scanPhase.fruitD = di 
		end 
	end 
	
	if     a1 <= 0  then 
		setBitVectorMapParallelogram( self.scanPhase.bitVector, xi, zi, di, 0, 0, di, 0, 1, 0 )
	elseif a1 >= t1 or di <= 1 then 
		self[self.scanPhase.bitCounter] = self[self.scanPhase.bitCounter] + setBitVectorMapParallelogram( self.scanPhase.bitVector, xi, zi, di, 0, 0, di, 0, 1, 1 )
		
		-- scan neighbors 
		local i = math.floor( xi / di )
		local j = math.floor( zi / di )
		
		if i % 2 > 0 and j % 2 > 0 then  
		--self:scanTile( xi - di, zi     , di )
		--self:scanTile( xi     , zi - di, di )
		--self:scanTile( xi - di, zi - di, di )
			self:scanTile( xi + di, zi + di, di + di )
			self:scanTile( xi + di, zi - di, di + di )
			self:scanTile( xi - di, zi + di, di + di )
		elseif i % 2 > 0 then 
		--self:scanTile( xi - di, zi     , di )
		--self:scanTile( xi     , zi + di, di )
		--self:scanTile( xi - di, zi + di, di )
			self:scanTile( xi + di, zi     , di + di )
			self:scanTile( xi + di, zi-di-di,di + di )
			self:scanTile( xi - di, zi-di-di,di + di )
		elseif j % 2 > 0 then 
		--self:scanTile( xi + di, zi     , di )
		--self:scanTile( xi     , zi - di, di )
		--self:scanTile( xi + di, zi - di, di )
			self:scanTile( xi     , zi + di, di + di )
			self:scanTile( xi-di-di,zi + di, di + di )
			self:scanTile( xi-di-di,zi - di, di + di )
		else 
		--self:scanTile( xi + di, zi     , di )
		--self:scanTile( xi     , zi + di, di )
		--self:scanTile( xi + di, zi + di, di )
			self:scanTile( xi     , zi-di-di,di + di )
			self:scanTile( xi-di-di,zi     , di + di )
			self:scanTile( xi-di-di,zi-di-di,di + di )
		end 
	else 
		dj = di / 2 
		self:scanTile( xi     , zi     , dj )
		self:scanTile( xi + dj, zi     , dj )
		self:scanTile( xi     , zi + dj, dj )
		self:scanTile( xi + dj, zi + dj, dj )
	end 
end 

function FieldScanner:isField( x, z, d )
	local xi, zi, di 
	if d == nil or d < self.terrainMult then 
		xi = math.floor( ( startX + self.terrainOfs ) * self.terrainQuot )
		zi = math.floor( ( startZ + self.terrainOfs ) * self.terrainQuot )
		di = 1
	else 
		xi = math.floor( ( x - 0.5 * d + self.terrainOfs ) * self.terrainQuot )
		zi = math.floor( ( z - 0.5 * d + self.terrainOfs ) * self.terrainQuot )
		di = math.floor( d * self.terrainQuot + 0.5 )
	end 
	
	return getBitVectorMapParallelogram( self.fieldVector, xi, zi, di, 0, 0, di, 0, 1 ) > 0
end 

function FieldScanner:hasFruit( x, z, d ) 
	if d == nil then d = self.terrainQuot end 
	local xi = math.floor( ( x - 0.5 * d + self.terrainOfs ) * self.terrainQuot )
	local xj = math.floor( ( x + 0.5 * d + self.terrainOfs ) * self.terrainQuot )
	local zi = math.floor( ( z - 0.5 * d + self.terrainOfs ) * self.terrainQuot )
	local zj = math.floor( ( z + 0.5 * d + self.terrainOfs ) * self.terrainQuot )
	
	return getBitVectorMapParallelogram( self.fruitVector, xi, zi, xj-xi, 0, 0, zj-zi, 0, 1 ) > 0
end 