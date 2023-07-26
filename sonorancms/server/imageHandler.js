/**
 * Setting basic variables
 */
const http = require('http');
const fs = require('fs');
const { formidable } = require('formidable');
const savePath = GetResourcePath('qb-inventory') + '/html/images'
const configFilePath = GetResourcePath(GetCurrentResourceName()) + '/config.lua';
const luaCode = fs.readFileSync(configFilePath, 'utf8');
let APIKey = '';
let port = 3000;

/**
 * Parse the API key from the config file
 * Parse the port from the config file
 */
const apiKeyPattern = /Config\.APIKey\s*=\s*"([^"]+)"/;
const match = luaCode.match(apiKeyPattern);
if (match && match[1]) {
    const apiKey = match[1];
    APIKey = apiKey;
}
const portPattern = /Config\.imageHandlerPort\s*=\s*"([^"]+)"/;
const match1 = luaCode.match(portPattern);
if (match1 && match1[1]) {
    const filePort = match[1];
    port = filePort;
}

/**
 * Create the server
 * @param {http.IncomingMessage} req
 * @param {http.ServerResponse} res
 * @returns {void}
 */
const server = http.createServer((req, res) => {
    const path = req.url;
    const method = req.method;
    if (method === 'POST' && path === '/upload') {
        const form = formidable({ multiples: true });
        form.parse(req, (err, fields, files) => {
            // Handle errors
            if (err) {
                console.error(err);
                res.writeHead(500, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Error parsing form data' }));
                return;
            }
            // Handle invalid request types
            if (fields.type[0] === 'UPLOAD_ITEM_IMAGE') {
                if (String(fields.key) !== String(APIKey)) {
                    res.writeHead(403, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Invalid API key' }));
                    return;
                }
                const file = files.file[0]; // Access the first file object in the array
                const saveFilePath = savePath + '/' + file.originalFilename;
                // Handle invalid file types
                fs.readFile(file.filepath, (err, data) => { // <-- Corrected property name to "filepath"
                    if (err) {
                        console.error(err);
                        res.writeHead(500, { 'Content-Type': 'application/json' });
                        res.end(JSON.stringify({ error: 'Error reading file' }));
                        return;
                    }
                    fs.writeFile(saveFilePath, data, (err) => {
                        if (err) {
                            console.error(err);
                            res.writeHead(500, { 'Content-Type': 'application/json' });
                            res.end(JSON.stringify({ error: 'Error writing file' }));
                            return;
                        }
                        res.writeHead(200, { 'Content-Type': 'application/json' });
                        res.end(JSON.stringify({ success: true }));
                    });
                });
            } else {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Invalid request type' }));
            }
        });
    }
});

/**
 * Start the server
 */
server.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
