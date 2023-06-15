CreateThread(function()
	TriggerEvent('sonorancms::RegisterPushEvent', 'CMD_KICK_PLAYER', function(data)
		if data ~= nil then
			local targetPlayer = nil
			for i = 0, GetNumPlayerIndices() - 1 do
				local p = GetPlayerFromIndex(i)
				if p == data.data.playerSource then
					targetPlayer = p
				end
			end
			if targetPlayer ~= nil then
				local reason = 'Kicked By SonoranCMS Management Panel: ' .. data.data.reason
				local targetPlayerName = GetPlayerName(targetPlayer)
				print(targetPlayerName)
				DropPlayer(targetPlayer, reason)
				TriggerEvent('SonoranCMS::core:writeLog', 'debug', 'Received push event: ' .. data.type .. ' dropping player ' .. targetPlayerName .. ' for reason: ' .. reason)
			else
				TriggerEvent('SonoranCMS::core:writeLog', 'debug', 'Received push event: ' .. data.type .. ' but player with source ' .. data.data.playerSource .. ' was not found')
			end
		end
	end)
	TriggerEvent('sonorancms::RegisterPushEvent', 'CMD_SET_PLAYER_MONEY', function(data)
		if data ~= nil then
			local targetPlayer = nil
			for i = 0, GetNumPlayerIndices() - 1 do
				local p = GetPlayerFromIndex(i)
				if p == data.data.playerSource then
					targetPlayer = tonumber(p)
				end
			end
			if targetPlayer ~= nil then
				if Config.framework == 'qb-core' then
					QBCore = exports['qb-core']:GetCoreObject()
					local Player = QBCore.Functions.GetPlayer(targetPlayer)
					if Player == nil then
						TriggerEvent('SonoranCMS::core:writeLog', 'debug', 'Received push event: ' .. data.type .. ' but player with source ' .. data.data.playerSource .. ' was not found in qb-core')
						return
					end
					Player.Functions.SetMoney(data.data.moneyType, data.data.amount)
					TriggerEvent('SonoranCMS::core:writeLog', 'debug',
					             'Received push event: ' .. data.type .. ' setting player ' .. GetPlayerName(targetPlayer) .. '\'s ' .. data.data.moneyType .. ' money to ' .. data.data.amount)
				end
			else
				TriggerEvent('SonoranCMS::core:writeLog', 'debug', 'Received push event: ' .. data.type .. ' but player with source ' .. data.data.playerSource .. ' was not found')
			end
		end
	end)
end)

CreateThread(function()
	while true do
		local systemInfo = exports['sonorancms']:getSystemInfo()
		local activePlayers = {}
		for i = 0, GetNumPlayerIndices() - 1 do
			local player = GetPlayerFromIndex(i)
			local playerInfo = {name = GetPlayerName(player), ping = GetPlayerPing(player), source = player, identifiers = GetPlayerIdentifiers(player)}
			table.insert(activePlayers, playerInfo)
		end
		if Config.framework == 'qb-core' then
			QBCore = exports['qb-core']:GetCoreObject()
			qbRawChars = QBCore.Functions.GetQBPlayers()
			qbCharacters = {}
			for _, v in ipairs(qbRawChars) do
				local charInfo = {offline = v.Offline, name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname, id = v.PlayerData.charinfo.id, citizenid = v.PlayerData.charinfo.cid,
					license = v.PlayerData.license,
					jobInfo = {name = v.PlayerData.job.name, grade = v.PlayerData.job.grade.name, label = v.PlayerData.job.label, onDuty = v.PlayerData.job.onduty, type = v.PlayerData.job.type},
					money = {bank = v.PlayerData.money.bank, cash = v.PlayerData.money.cash, crypto = v.PlayerData.money.crypto}, source = v.PlayerData.source}
				table.insert(qbCharacters, charInfo)
			end
			apiResponse = {{uptime = GetGameTimer(), system = {cpuRaw = systemInfo.cpuRaw, cpuUsage = systemInfo.cpuUsage, memoryRaw = systemInfo.ramRaw, memoryUsage = systemInfo.ramUsage},
				players = activePlayers, characters = qbCharacters}}
			TriggerEvent('SonoranCMS::core:writeLog', 'debug', 'Sending API update for GAMESTATE, payload: ' .. json.encode(apiResponse))
		end
		-- performApiRequest(apiResponse, 'GAMESTATE', function(result, ok)
		-- 	if not ok then
		-- 		logError('API_ERROR')
		-- 		Config.critError = true
		-- 		return
		-- 	end
		-- end)
		Wait(60000)
	end
end)
