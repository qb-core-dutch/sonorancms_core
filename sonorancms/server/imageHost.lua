--- Image host for SonoranCMS
--- This is a simple image host for SonoranCMS. It is not required to run the CMS, but is required for the item image feature.

SetHttpHandler(function(req, res)
    local path = req.path:gsub("/proxy.*", "")
    local method = req.method
    if method == 'GET' then
        local imagePath = GetResourcePath('qb-inventory') .. '/html/' .. path .. '.png'
        if not path or not imagePath then
            res.send(json.encode({ error = 'Invalid path' }))
            return
        end
        local file = io.open(imagePath, 'rb')
        if not file then
            res.send(json.encode({ error = 'Image not found' }))
            return
        else
            local content = file:read("*all")
            file:close()
            res.send(content)
        end
    end
end)