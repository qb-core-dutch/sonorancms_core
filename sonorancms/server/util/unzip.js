var unzipper = require("unzipper");
var fs = require("fs");

exports('UnzipFile', (file, dest, type) => {
	if (type === "core") {
		try {
			fs.createReadStream(file).pipe(unzipper.Extract({ path: dest }).on('close', () => {
				exports[GetCurrentResourceName()].unzipCoreCompleted(true);
			}))
		} catch (ex) {
			exports[GetCurrentResourceName()].unzipCoreCompleted(false, ex);
		}
	} else {
		try {
			fs.createReadStream(file).pipe(unzipper.Extract({ path: dest }).on('close', () => {
				exports[GetCurrentResourceName()].unzipAddonCompleted(true, 'nil', type);
			}))
		} catch (ex) {
			exports[GetCurrentResourceName()].unzipAddonCompleted(false, ex, type);
		}
	}
});

exports('makeDir', (path) => {
	fs.mkdirSync(path, { recursive: true })
})