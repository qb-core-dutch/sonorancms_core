RegisterNetEvent('SonoranCMS::core::RequestGamePool', function()
	local returnVehicleData = {}
	for k, v in pairs(GetGamePool('CVehicle')) do
		local vehicleData = {}
		vehicleData.model = GetEntityModel(v)
		vehicleData.plate = GetVehicleNumberPlateText(v)
		vehicleData.health = GetVehicleEngineHealth(v)
		vehicleData.fuel = GetVehicleFuelLevel(v)
		vehicleData.bodyHealth = GetVehicleBodyHealth(v)
		vehicleData.displayName = GetDisplayNameFromVehicleModel(GetEntityModel(v))
        table.insert(returnVehicleData, vehicleData)
	end
    TriggerServerEvent('SonoranCMS::core::ReturnGamePool', returnVehicleData)
end)
