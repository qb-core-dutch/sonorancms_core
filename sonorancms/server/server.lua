local plugin_handlers = {}

SetHttpHandler(function(req, res)
	local path = req.path
	local method = req.method
	if method == 'POST' and path == '/events' then
		req.setDataHandler(function(data)
			if not data then
				res.send(json.encode({['error'] = 'bad request'}))
				return
			end
			local body = json.decode(data)
			if not body then
				res.send(json.encode({['error'] = 'bad request'}))
				return
			end
			if body.key and body.key:upper() == Config.APIKey:upper() then
				if plugin_handlers[body.type] ~= nil then
					TriggerEvent(plugin_handlers[body.type], body)
					res.send('ok')
					return
				else
					res.send('Event not registered')
				end
			else
				res.send('Bad API Key')
				return
			end
		end)
	else
		res.send('Bad endpoint')
	end
end)

RegisterNetEvent('SonoranCMS::pushevents::UnitLogin', function(accID)
	local payload = {}
	payload['id'] = Config.CommID
	payload['key'] = Config.APIKey
	payload['type'] = 'CLOCK_IN_OUT'
	payload['data'] = {{['accID'] = accID, ['forceClockIn'] = true, ['server'] = Config.serverId}}
	PerformHttpRequest(Config.apiUrl .. '/general/clock_in_out', function(code, result, _)
		if code == 201 and Config.debug_mode then
			print('logging in unit. Results: ' .. result)
		end
	end, 'POST', json.encode(payload), {['Content-Type'] = 'application/json'})
end)

RegisterNetEvent('SonoranCMS::pushevents::UnitLogout', function(accID)
	local payload = {}
	payload['id'] = Config.CommID
	payload['key'] = Config.APIKey
	payload['type'] = 'CLOCK_IN_OUT'
	payload['data'] = {{['accID'] = accID, ['server'] = Config.serverId}}
	PerformHttpRequest(Config.apiUrl .. '/general/clock_in_out', function(code, result, _)
		if code == 201 and Config.debug_mode then
			print('logging out unit. Results: ' .. result)
		end
	end, 'POST', json.encode(payload), {['Content-Type'] = 'application/json'})
end)

RegisterNetEvent('sonorancms::RegisterPushEvent', function(type, event)
	plugin_handlers[type] = event
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(100)
		SetConvar('SONORAN_CMS_API_KEY', Config.APIKey)
		SetConvar('SONORAN_CMS_COMMUNITY_ID', Config.CommID)
	end
end)

function getServerVersion()
	local s = GetConvar('version', '')
	local v = s:find('v1.0.0.')
	local i = string.gsub(s:sub(v), 'v1.0.0.', ''):sub(1, 4)
	return i
end

CreateThread(function()
	print('Starting SonoranCMS from ' .. GetResourcePath('sonorancms'))
	local versionfile = json.decode(LoadResourceFile(GetCurrentResourceName(), '/version.json'))
	local fxversion = versionfile.testedFxServerVersion
	local currentFxVersion = getServerVersion()
	if currentFxVersion ~= nil and fxversion ~= nil then
		if tonumber(currentFxVersion) < tonumber(fxversion) then
			warnLog(('SonoranCAD has been tested with FXServer version %s, but you\'re running %s. Please update ASAP.'):format(fxversion, currentFxVersion))
		end
	end
	if GetResourceState('sonorancms_updatehelper') == 'started' then
		ExecuteCommand('stop sonorancms_updatehelper')
	end
	TriggerEvent(GetCurrentResourceName() .. '::StartUpdateLoop')
	Wait(100000)
end)
