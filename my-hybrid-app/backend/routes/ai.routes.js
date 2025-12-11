const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload.middleware');
const aiController = require('../controllers/ai.controller');

// Health check - no auth needed
router.get('/health', aiController.healthCheck);

// Analyze food image - requires image upload
router.post('/analyze-food', upload.single('image'), aiController.analyzeFood);

// Detect ingredients from image - requires image upload
router.post('/detect-ingredients', upload.single('image'), aiController.detectIngredients);

// Recommend recipes - just needs JSON body, no image
router.post('/recommend-recipes', aiController.recommendRecipes);

module.exports = router;
