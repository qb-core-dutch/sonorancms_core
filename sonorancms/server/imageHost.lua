--- Image host for SonoranCMS
--- This is a simple image host for SonoranCMS. It is not required to run the CMS, but is required for the item image feature.
SetHttpHandler(function(req, res)
	local path = req.path:gsub('/proxy.*', '')
	local method = req.method
	if method == 'GET' then
		local imagePath = GetResourcePath('qb-inventory') .. '/html/' .. path .. '.png'
		if not path or not imagePath then
			res.send(json.encode({error = 'Invalid path'}))
			return
		end
		local file = io.open(imagePath, 'rb')
		if not file then
			res.send(json.encode({error = 'Image not found'}))
			return
		else
			local content = file:read('*all')
			file:close()
			res.send(content)
		end
	end
	if method == 'POST' then
		local data = req.body
		local decoded = json.decode(data)
		if decoded.data.key ~= Config.APIKey then
			res.send(json.encode({error = 'Invalid API key'}))
			return
		end
		if not path or path ~= '/upload' then
			res.send(json.encode({error = 'Invalid path'}))
			return
		end
		if not data then
			res.send(json.encode({error = 'Invalid data'}))
			return
		end
		if not decoded or not decoded.data.raw then
			res.send(json.encode({error = 'Invalid data'}))
			return
		end
		exports[GetCurrentResourceName()]:SaveBase64ToFile(decoded.data.raw, GetResourcePath('qb-inventory') .. '/html/' .. decoded.data.name, decoded.data.name, function(success)
			if success.success then
				res.send(json.encode({success = true, filename = success.error}))
			else
				res.send(json.encode({success = false, error = 'Failed to save image. Error: ' .. success.error}))
			end
		end)
	end
end)
