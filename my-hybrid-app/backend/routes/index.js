const express = require('express');
const router = express.Router();

// Import route modules
const aiRoutes = require('./ai.routes');

// Mount routes
router.use('/ai', aiRoutes);

// You can add more route modules here later, like:
// router.use('/users', userRoutes);
// router.use('/auth', authRoutes);

module.exports = router;
