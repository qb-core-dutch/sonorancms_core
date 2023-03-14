local function RunAddonAutoUpdater(pluginName, latestVersion)
	local f = LoadResourceFile(GetResourcePath(GetCurrentResourceName()) .. '/addonupdates/' .. pluginName .. '.zip')
	if f ~= nil then
		ExecuteCommand('stop ' .. pluginName)
		os.remove(GetResourcePath(GetCurrentResourceName()) .. '/addonupdates/' .. pluginName .. '.zip')
		os.remove(GetResourcePath(GetCurrentResourceName()) .. '/run.lock')
	end
	if FileExists(GetResourcePath(GetCurrentResourceName()) .. '/config.lock') then
		os.remove(GetResourcePath(GetCurrentResourceName()) .. '/config.lock')
	end
	local pluginRepo = GetResourceMetadata(pluginName, 'git_repo')
	local releaseUrl = (pluginRepo .. '/releases/download/v%s/latest.zip'):format(latestVersion)
	PerformHttpRequest(releaseUrl, function(code, data, _)
		if code == 200 then
			local savePath = GetResourcePath(GetCurrentResourceName()) .. '/addonupdates/' .. pluginName .. '.zip'
			local unzipPath = GetResourcePath(pluginName) .. '/../'
			local f = assert(io.open(savePath, 'wb'))
			f:write(data)
			f:close()
			Utilities.Logging.logInfo('Saved file...')
			exports[GetCurrentResourceName()]:UnzipFile(savePath, unzipPath, pluginName)
		else
			Utilities.Logging.logWarn(('Failed to download from %s: %s %s'):format(releaseUrl, code, data))
		end
	end, 'GET')
end

exports('unzipAddonCompleted', function(success, error, pluginName)
	if success then
		if GetNumPlayerIndices() > 0 then
			pendingRestart = true
			Utilities.Logging.logInfo('Delaying auto-update until server is empty.')
			return
		end
		Utilities.Logging.logWarn('Auto-restarting addon...')
		Citizen.Wait(5000)
		ExecuteCommand('ensure ' .. pluginName)
	else
		Utilities.Logging.logError('Failed to download addon update for ' .. pluginName .. ' Error: ' .. json.encode(error))
	end
end)

RegisterNetEvent('SonoranCMS::Plugins::Loaded', function(pluginName)
	local pluginVersion, pluginRepo
	local pluginPayload = {apiKey = Config.APIKey, communityId = Config.CommID, apiUrl = Config.apiUrl, apiIdType = Config.apiIdType, serverId = Config.serverId}
	TriggerEvent('SonoranCMS::Plugins::GiveInfo', pluginName, pluginPayload)
	pluginVersion = GetResourceMetadata(pluginName, 'version')
	pluginRepo = GetResourceMetadata(pluginName, 'git_repo')
	local currentVersion = string.gsub(pluginVersion, '[.]', '')
	local gitRepoSplit = {}
	for w in pluginRepo:gmatch('([^/]+)') do
		table.insert(gitRepoSplit, w)
	end
	local gitRepo = 'https://raw.githubusercontent.com/' .. gitRepoSplit[3] .. '/' .. gitRepoSplit[4]
	PerformHttpRequest(gitRepo .. '/master/fxmanifest.lua', function(code, remoteData, _)
		if code == 200 then
			local data = remoteData
			data = data:match('^%s*(.-)%s*$'):gsub('\n', '\n')
			for line in data:gmatch('[^\r\n]+') do
				if line:find('^version') then
					local versionLineSplit = {}
					for w in line:gmatch('[^\'"]+') do
						table.insert(versionLineSplit, w)
					end
					local latestVersion = versionLineSplit[2]:gsub('[.]', '')
					if currentVersion < latestVersion then
						if Config.allowAutoUpdate then
							Utilities.Logging.logInfo(pluginName .. ' is out of date, running auto update now...')
							RunAddonAutoUpdater(pluginName, versionLineSplit[2] )
						else
							Utilities.Logging.logInfo('New update available for ' .. pluginName .. '. Current version: ' .. versionLineSplit[2] .. ' | Latest Version: ' .. pluginVersion .. ' | Download new version: '
											                          .. pluginRepo .. '/releases/tag/latest')
						end
					else
						Utilities.Logging.logInfo(pluginName .. ' is already up to date! Version: ' .. versionLineSplit[2])
					end
				end
			end
		else
			Utilities.Logging.logError('An error occured while checking version... Error code: ' .. code)
		end
	end)
end)
