local plugin_handlers = {}

SetHttpHandler(function(req, res)
    local path = req.path
    local method = req.method
    if method == "POST" and path == '/event' then
        req.setDataHandler(function(data)
            if not data then
                res.send(json.encode({
                    ["error"] = "bad request"
                }))
                return
            end
            local body = json.decode(data)
            if not body then
                res.send(json.encode({
                    ["error"] = "bad request"
                }))
                return
            end
            if body.key and body.key:upper() == Config.apiKey:upper() then
                TriggerClientEvent(plugin_handlers[body.type], body)
                res.send('ok')
            end
        end)
    end
end)

RegisterNetEvent('sonorancms::RegisterPushEvent', function(type, event)
    plugin_handlers[type] = event
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(100)
        SetConvar("sonorancms_api_key", Config.APIKey)
        SetConvar("sonorancms_comm_id", Config.CommID)
    end
end)
