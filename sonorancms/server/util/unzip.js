var extract = require("extract-zip");

exports("UnzipFile", async (file, dest) => {
	try {
		await extract(file, { dir: dest });
		exports[GetCurrentResourceName()].unzipCoreCompleted(true);
	} catch (ex) {
		exports[GetCurrentResourceName()].unzipCoreCompleted(false, error);
	}
});
