
AIVehicleExtensionRegister = {}
AIVehicleExtensionRegister.modName  = "FS17_AIVehicleExtension"
AIVehicleExtensionRegister.g_currentModDirectory = g_currentModDirectory
AIVehicleExtensionRegister.isLoaded = true

if SpecializationUtil.specializations["AIVehicleExtension"] == nil then
	SpecializationUtil.registerSpecialization("AIVehicleExtension", "AIVehicleExtension", g_currentModDirectory.."AIVehicleExtension.lua")
	AIVehicleExtensionRegister.isLoaded = false
end

function AIVehicleExtensionRegister:loadMap(name)	
	if not AIVehicleExtensionRegister.isLoaded then
		AIVehicleExtensionRegister:add()
		AIVehicleExtensionRegister.isLoaded = true
	end
	
	AIVehicleExtensionRegister.AIVehicleSetDriveStrategies = AIVehicle.setDriveStrategies
	AIVehicle.setDriveStrategies = Utils.appendedFunction( AIVehicle.setDriveStrategies, AIVehicleExtension.afterSetDriveStrategies )	
end

function AIVehicleExtensionRegister:deleteMap()
	if AIVehicleExtensionRegister.AIVehicleSetDriveStrategies ~= nil then
		AIVehicle.setDriveStrategies = AIVehicleExtensionRegister.AIVehicleSetDriveStrategies
		AIVehicleExtensionRegister.AIVehicleSetDriveStrategies = nil
	end
end

function AIVehicleExtensionRegister:mouseEvent(posX, posY, isDown, isUp, button)
end

function AIVehicleExtensionRegister:keyEvent(unicode, sym, modifier, isDown)
end

function AIVehicleExtensionRegister:update(dt)
end

function AIVehicleExtensionRegister:draw()
end

function AIVehicleExtensionRegister:add()
	if AIVehicleExtensionRegister.AIVehicleSetDriveStrategies ~= nil then
		return
	end
	
	print("--- loading "..g_i18n:getText("AIVE_VERSION").." ---")
	local insertedMods = 0
	
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		for i,vs in pairs(v.specializations) do
			if vs == SpecializationUtil.getSpecialization("aiVehicle") then
				table.insert(v.specializations, SpecializationUtil.getSpecialization("AIVehicleExtension"))
				insertedMods = insertedMods + 1
			--print("  AIVehicleExtension was inserted on " .. k)
				break
			end
		end
	end
	
	print(string.format("--- "..AIVehicleExtensionRegister.modName..": inserted into %d vehicle types ---", insertedMods ))
	
	g_i18n.globalI18N.texts["AIVE_VERSION"] = g_i18n:getText("AIVE_VERSION"     )
end

addModEventListener(AIVehicleExtensionRegister)
