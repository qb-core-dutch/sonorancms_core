local warningstring = false
local scaleform = nil
local warningMessage = nil
local secondsCount = 10
local breakOff = false
local notReset = true
RegisterNetEvent('SonoranCMS::core::RequestGamePool', function()
	local returnVehicleData = {}
	for _, v in pairs(GetGamePool('CVehicle')) do
		local ped = GetPedInVehicleSeat(v, -1)
		if (DoesEntityExist(ped)) and (IsPedAPlayer(ped)) then
			local vehicleData = {}
			vehicleData.vehicleHandle = v
			vehicleData.model = GetEntityModel(v)
			vehicleData.plate = GetVehicleNumberPlateText(v)
			vehicleData.health = GetVehicleEngineHealth(v)
			vehicleData.fuel = GetVehicleFuelLevel(v)
			vehicleData.bodyHealth = GetVehicleBodyHealth(v)
			vehicleData.displayName = GetDisplayNameFromVehicleModel(GetEntityModel(v))
			vehicleData.driver = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
			vehicleData.passengers = {}
			for i = -1, GetVehicleMaxNumberOfPassengers(GetVehiclePedIsIn(ped)) + 1, 1 do
				local pedPass = GetPedInVehicleSeat(GetVehiclePedIsIn(ped), i)
				if (DoesEntityExist(pedPass)) then
					if (IsPedAPlayer(pedPass) and ped ~= pedPass) then
						local pedServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pedPass))
						table.insert(vehicleData.passengers, {seat = i, passengerId = pedServerId})
					end
				end
			end
			table.insert(returnVehicleData, vehicleData)
		end
	end
	TriggerServerEvent('SonoranCMS::core::ReturnGamePool', returnVehicleData)
end)

RegisterNetEvent('SonoranCMS::core::DeleteVehicle', function(vehHandle)
	if DoesEntityExist(vehHandle) then
		local vehDriver = GetPedInVehicleSeat(vehHandle, -1)
		if (DoesEntityExist(vehDriver)) and (IsPedAPlayer(vehDriver)) then
			local passengers = {}
			for i = -1, GetVehicleMaxNumberOfPassengers(GetVehiclePedIsIn(ped)) + 1, 1 do
				local pedPass = GetPedInVehicleSeat(GetVehiclePedIsIn(ped), i)
				if (DoesEntityExist(pedPass)) then
					if (IsPedAPlayer(pedPass) and ped ~= pedPass) then
						local pedServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pedPass))
						table.insert(passengers, pedServerId)
					end
				end
			end
			if not NetworkHasControlOfEntity() then
				if NetworkRequestControlOfEntity() then
					vehDriver = GetPlayerServerId(NetworkGetPlayerIndexFromPed(vehDriver))
					TriggerServerEvent('SonoranCMS::core::DeleteVehicleCB', vehDriver, passengers)
					SetEntityAsMissionEntity(vehHandle, true, true)
					DeleteEntity(vehHandle)
				else
					TriggerServerEvent('SonoranCMS::core:writeLog', 'debug', 'Failed to request control of entity ' .. vehHandle)
				end
			else
				vehDriver = GetPlayerServerId(NetworkGetPlayerIndexFromPed(vehDriver))
				TriggerServerEvent('SonoranCMS::core::DeleteVehicleCB', vehDriver, passengers)
				SetEntityAsMissionEntity(vehHandle, true, true)
				DeleteEntity(vehHandle)
			end
		end
	end
end)

RegisterNetEvent('SonoranCMS::core::RepairVehicle', function(vehHandle)
	if DoesEntityExist(vehHandle) then
		local vehDriver = GetPedInVehicleSeat(vehHandle, -1)
		if (DoesEntityExist(vehDriver)) and (IsPedAPlayer(vehDriver)) then
			local passengers = {}
			for i = -1, GetVehicleMaxNumberOfPassengers(GetVehiclePedIsIn(ped)) + 1, 1 do
				local pedPass = GetPedInVehicleSeat(GetVehiclePedIsIn(ped), i)
				if (DoesEntityExist(pedPass)) then
					if (IsPedAPlayer(pedPass) and ped ~= pedPass) then
						local pedServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pedPass))
						table.insert(passengers, pedServerId)
					end
				end
			end
			if not NetworkHasControlOfEntity() then
				if NetworkRequestControlOfEntity() then
					vehDriver = GetPlayerServerId(NetworkGetPlayerIndexFromPed(vehDriver))
					TriggerServerEvent('SonoranCMS::core::RepairVehicleCB', vehDriver, passengers)
					SetVehicleFixed(vehHandle)
					SetVehicleDeformationFixed(vehHandle)
				else
					TriggerServerEvent('SonoranCMS::core:writeLog', 'debug', 'Failed to request control of entity ' .. vehHandle)
				end
			else
				vehDriver = GetPlayerServerId(NetworkGetPlayerIndexFromPed(vehDriver))
				TriggerServerEvent('SonoranCMS::core::RepairVehicleCB', vehDriver, passengers)
				SetVehicleFixed(vehHandle)
				SetVehicleDeformationFixed(vehHandle)
			end
		end
	end
end)

RegisterNetEvent('SonoranCMS::core::HandleWarnedPlayer', function(message)
	warningMessage = message
	local sendMessage = message .. '\n\n\n~y~To close this message, hold [space] for ' .. secondsCount .. ' seconds'
	scaleform = Initialize('mp_big_message_freemode', sendMessage)
	Wait(500)
	warnPlayer(message)
end)

function warnPlayer(msg)
	warningstring = true
	PlaySoundFrontend(-1, 'DELETE', 'HUD_DEATHMATCH_SOUNDSET', 1)
end

function Initialize(scaleform, message)
	local scaleform = RequestScaleformMovie(scaleform)
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end
	PushScaleformMovieFunction(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	PushScaleformMovieFunctionParameterString('~r~SonoranCMS Management Panel:')
	PushScaleformMovieFunctionParameterString(message)
	PopScaleformMovieFunctionVoid()
	return scaleform
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if warningstring and not breakOff then
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
		else
			breakOff = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1)
		if warningstring then
			local countLimit = 100 -- 10 seconds
			local count = 0
			while true do
				Wait(100)
				if IsControlPressed(0, 22) then
					if (count % 10) == 0 then
						secondsCount = secondsCount - 1
						Initialize('mp_big_message_freemode', warningMessage .. '\n\n\n~y~To close this message, hold [space] for ' .. secondsCount .. ' seconds')
						breakOff = true
						notReset = true
					end
					count = count + 1
					if count >= countLimit then
						warningstring = false
						secondsCount = 10
						notReset = true
						return
					end
				else
					secondsCount = 10
					count = 0
					if notReset then
						Wait(100)
						Initialize('mp_big_message_freemode', warningMessage .. '\n\n\n~y~To close this message, hold [space] for ' .. secondsCount .. ' seconds')
						breakOff = true
						notReset = false
					end
				end
			end
		end
	end
end)
