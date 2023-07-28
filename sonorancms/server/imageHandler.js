// Import the required modules
const fs = require('fs');
const sizeOf = require('image-size');

exports('SaveBase64ToFile', function(base64String, filepath, filename) {
    // Get the base64 image data
    let base64Image = base64String.split(';base64,').pop();

    // Get the dimensions of the image
    let dimensions = sizeOf(Buffer.from(base64Image, 'base64'));

    // Check if the image is 100x100
    if (dimensions.width === 100 && dimensions.height === 100) {
        // Save the image
        fs.writeFile(filepath, base64Image, { encoding: 'base64' }, function(err) {
            if (err) {
                return {success: false, error: err}
            } else {
                return {success: true, error: filename}
            }
        });
    } else {
        // Return an error
        return {success: false, error: 'Image must be 100x100'}
    }
});
