const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Make sure uploads directory exists
const uploadDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure storage - we keep the original extension so Python can read it properly
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        // Generate unique filename: timestamp-randomstring.extension
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, uniqueSuffix + ext);
    }
});

// Only allow image files - we don't want people uploading random stuff
const fileFilter = (req, file, cb) => {
    const allowedTypes = [
        'image/jpeg', 
        'image/png', 
        'image/webp', 
        'image/jpg',
        'image/heic',      // iPhone format
        'image/heif',      // iPhone format
        'application/octet-stream'  // Sometimes mobile sends this for images
    ];
    
    // Also check file extension as fallback
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif'];
    const ext = path.extname(file.originalname).toLowerCase();
    
    console.log(`[Upload] File: ${file.originalname}, MIME: ${file.mimetype}, Extension: ${ext}`);
    
    if (allowedTypes.includes(file.mimetype) || allowedExtensions.includes(ext)) {
        cb(null, true);
    } else {
        cb(new Error(`Invalid file type: ${file.mimetype}. Only JPEG, PNG and WebP images are allowed.`), false);
    }
};

// Create the multer instance with our config
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB max - should be plenty for food photos
    }
});

module.exports = upload;
