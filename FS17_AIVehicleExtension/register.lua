
AIVehicleExtensionRegister = {};
AIVehicleExtensionRegister.isLoaded = true;
AIVehicleExtensionRegister.g_currentModDirectory = g_currentModDirectory;

source(Utils.getFilename("AIVEScreen.lua", g_currentModDirectory));

if SpecializationUtil.specializations["AIVehicleExtension"] == nil then
	SpecializationUtil.registerSpecialization("AIVehicleExtension", "AIVehicleExtension", g_currentModDirectory.."AIVehicleExtension.lua")
	SpecializationUtil.registerSpecialization("AIVEImplement", "AIVEImplement", g_currentModDirectory.."AIVEImplement.lua")
	AIVehicleExtensionRegister.isLoaded = false;
end;

function AIVehicleExtensionRegister:loadMap(name)	
  if not AIVehicleExtensionRegister.isLoaded then	
		AIVehicleExtensionRegister:add();
    AIVehicleExtensionRegister.isLoaded = true;
		if not g_currentMission.missionInfo.isTutorial then
			g_careerScreen.saveSavegame = Utils.appendedFunction(g_careerScreen.saveSavegame, AIVehicleExtensionRegister.saveSavegame);
		end
  end;	
	
	-- GUI Stuff
	g_AIVEScreen = AIVEScreen:new();
	g_gui:loadGui(AIVehicleExtensionRegister.g_currentModDirectory .. "gui/AIVEScreen.xml", "AIVEScreen", g_AIVEScreen);	
	FocusManager:setGui("MPLoadingScreen");
end;

function AIVehicleExtensionRegister:saveSavegame( savegame )
end

function AIVehicleExtensionRegister:loadSavegame()
end

function AIVehicleExtensionRegister:deleteMap()
  --AIVehicleExtensionRegister.isLoaded = false;
	g_AIVEScreen:delete()
end;

function AIVehicleExtensionRegister:mouseEvent(posX, posY, isDown, isUp, button)
end;

function AIVehicleExtensionRegister:keyEvent(unicode, sym, modifier, isDown)
end;

function AIVehicleExtensionRegister:update(dt)
	if not g_currentMission.missionInfo.isTutorial and g_currentMission.missionInfo.isValid then
		if not ( self.isSavegameLoaded ) then
			AIVehicleExtensionRegister.loadSavegame( self )
			self.isSavegameLoaded = true
		end
	end
	
	if      g_currentMission:getIsClient() 
			and not g_gui:getIsGuiVisible() 
			and InputBinding.hasEvent(InputBinding.AIVE_NEXT_WORKER)
			and not g_currentMission.isPlayerFrozen then
		AIVehicleExtensionRegister.toggleVehicle( 1 );
	end
end;

------------------------------------------------------------------------
-- AIVehicleExtensionRegister.toggleVehicle
------------------------------------------------------------------------
function AIVehicleExtensionRegister.toggleVehicle( delta )

	local self = g_currentMission

	if not self.isToggleVehicleAllowed then
		return;
	end;

	local numVehicles = table.getn(self.steerables);
	if numVehicles > 0 then

		local index = 1;
		local oldIndex = 1;

		if not self.controlPlayer and self.controlledVehicle ~= nil then

			for i=1, numVehicles do
				if self.controlledVehicle == self.steerables[i] then
					oldIndex = i;
					index = i+delta;
					if index > numVehicles then
						index = 1;
					end;
					if index < 1 then
						index = numVehicles;
					end;
					break;
				end;
			end;
		else
			if delta < 0 then
				index = numVehicles
			end
		end;
		
		local found = false;
		repeat
			if not self.steerables[index].isBroken and not self.steerables[index].isControlled and not self.steerables[index].nonTabbable and self.steerables[index].isHired then
				found = true;
			else
				index = index +delta;
				if index > numVehicles then
					index = 1;
				end;
				if index < 1 then
					index = numVehicles;
				end;
			end;
		until found or index == oldIndex;
		
		if found then
			self:requestToEnterVehicle(self.steerables[index])
		end;
	end;
end

function AIVehicleExtensionRegister:draw()
end;

function AIVehicleExtensionRegister:add()

	print("--- loading "..g_i18n:getText("AIVE_VERSION").." by mogli ---")

	local searchTable = { "Autopilot", "AutoTractor", "AutoCombine" };	
	
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		local modName         = string.match(k, "([^.]+)");
		local doNotAdd        = true;
		local correctLocation = false;
		local isImplement     = false;
		local specMask        = 0
		
		for _, search in pairs(searchTable) do
			if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
				doNotAdd = false;
				break;
			end;
		end;
		
	--for i = 1, table.maxn(v.specializations) do
	--	local vs = v.specializations[i];
	--	if      vs ~= nil 
	--			and vs == SpecializationUtil.getSpecialization("articulatedAxis") then
	--		doNotAdd = false;
	--		break;
	--	end;
	--end;
		
		for i = 1, table.maxn(v.specializations) do
			local vs = v.specializations[i];
			if      vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("aiVehicle") then
				correctLocation = true;
				specMask = specMask + 1
				break;
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("attachable") then
				isImplement = true
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("hirable") then
				specMask = specMask + 2
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("steerable") then
				specMask = specMask + 4
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("drivable") then
				specMask = specMask + 8
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("mower") then
				specMask = specMask + 16
			end;
		end;
		
		if doNotAdd and correctLocation then
			table.insert(v.specializations, SpecializationUtil.getSpecialization("AIVehicleExtension"));
		--print("  AIVehicleExtension was inserted on " .. k);
		elseif correctLocation and not doNotAdd then
		--print("  Failed to inserting AIVehicleExtension on " .. k);
		elseif isImplement then
			table.insert(v.specializations, SpecializationUtil.getSpecialization("AIVEImplement"));
		end;
	end;
	
	-- make l10n global 
	for n,t in pairs( g_i18n.texts ) do
		if string.sub( n, 1, 4 ) == "AIVE" then
			g_i18n.globalI18N.texts[n] = t
		end
	end
end;

addModEventListener(AIVehicleExtensionRegister);
