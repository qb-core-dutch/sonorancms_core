var unzipper = require("unzipper");
var fs = require("fs");

function rmdirRecursive(dirPath) {
	if (fs.existsSync(dirPath)) {
		fs.readdirSync(dirPath).forEach((file) => {
			const filePath = path.join(dirPath, file);
			if (fs.statSync(filePath).isDirectory()) {
				rmdirRecursive(filePath);
			} else {
				fs.unlinkSync(filePath);
			}
		});
		fs.rmdirSync(dirPath);
	}
}

function moveFiles(sourceDir, destDir) {
	// Create the destination directory if it doesn't exist
	if (!fs.existsSync(destDir)) {
		fs.mkdirSync(destDir);
	}

	// Get a list of all files and directories in the source directory
	const files = fs.readdirSync(sourceDir);

	// Loop through each file or directory
	files.forEach((file) => {
		const sourcePath = path.join(sourceDir, file);
		const destPath = path.join(destDir, file);

		// If it's a directory, recursively move its contents
		if (fs.statSync(sourcePath).isDirectory()) {
			moveFiles(sourcePath, destPath);
		} else {
			// Otherwise, it's a file - move it to the destination directory
			fs.copyFileSync(sourcePath, destPath);
		}
	});
}

exports('UnzipFile', (file, dest, type) => {
	if (type === "core") {
		try {
			type = '[sonorancms]'
			let tempFolder = GetResourcePath(GetCurrentResourceName()) + '/temp/' + type;
			if (fs.existsSync(tempFolder)) { rmdirRecursive(tempFolder) };
			fs.mkdirSync(tempFolder);
			fs.createReadStream(file).pipe(unzipper.Extract({ path: tempFolder }).on('close', () => {
				const configLuaPath = tempFolder + '/config.lua';
				const configNewLuaPath = tempFolder + '/config.NEW.lua';
				if (fs.existsSync(configLuaPath)) {
					fs.renameSync(configLuaPath, configNewLuaPath);
				} else {
					console.log('config.lua file not found in the folder.');
				}
				const folder = fs.readdirSync(tempFolder);
				moveFiles(tempFolder + '/' + folder, dest);
				rmdirRecursive(tempFolder);
				exports[GetCurrentResourceName()].unzipCoreCompleted(true, 'nil');
			}))
		} catch (ex) {
			exports[GetCurrentResourceName()].unzipCoreCompleted(false, ex);
		}
	} else {
		try {
			let tempFolder = GetResourcePath(GetCurrentResourceName()) + '/addonupdates/' + type
			if (fs.existsSync(tempFolder)) { rmdirRecursive(tempFolder) }
			fs.mkdirSync(tempFolder)
			fs.createReadStream(file).pipe(unzipper.Extract({ path: tempFolder }).on('close', () => {
				const folder = fs.readdirSync(tempFolder);
				if (folder[0].includes('-latest')) {
					moveFiles(tempFolder + '/' + folder, dest)
					rmdirRecursive(tempFolder);
					exports[GetCurrentResourceName()].unzipAddonCompleted(true, 'nil', type);
				}
			}))
		} catch (ex) {
			exports[GetCurrentResourceName()].unzipAddonCompleted(false, ex, type);
		}
	}
});

exports('makeDir', (path) => {
	fs.mkdirSync(path, { recursive: true })
})