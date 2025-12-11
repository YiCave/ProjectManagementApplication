const aiService = require('../services/ai.service');
const fs = require('fs');

/**
 * POST /api/ai/analyze-food
 * 
 * Upload a food image and get back info about what it is.
 * Useful for the "what is this food?" feature.
 */
async function analyzeFood(req, res) {
    console.log('[Controller] analyzeFood called');
    console.log('[Controller] req.file:', req.file);
    console.log('[Controller] req.body:', req.body);
    console.log('[Controller] Content-Type:', req.headers['content-type']);
    
    try {
        if (!req.file) {
            console.log('[Controller] No file received!');
            return res.status(400).json({
                success: false,
                error: 'No image file uploaded. Send image as multipart form data with field name "image".'
            });
        }
        
        const imagePath = req.file.path;
        console.log(`[Controller] Analyzing food image: ${imagePath}`);
        
        const result = await aiService.analyzeFood(imagePath);
        
        // Clean up - delete the uploaded file after processing
        // We don't need to keep it around
        fs.unlink(imagePath, (err) => {
            if (err) console.log(`[Controller] Warning: could not delete temp file ${imagePath}`);
        });
        
        return res.json(result);
        
    } catch (error) {
        console.error('[Controller] analyzeFood error:', error);
        return res.status(500).json({
            success: false,
            error: error.message
        });
    }
}

/**
 * POST /api/ai/detect-ingredients
 * 
 * Upload an image (like fridge contents) and detect what ingredients are visible.
 * Returns a list of ingredient names that can be used for recipe search.
 */
async function detectIngredients(req, res) {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'No image file uploaded. Send image as multipart form data with field name "image".'
            });
        }
        
        const imagePath = req.file.path;
        console.log(`[Controller] Detecting ingredients from: ${imagePath}`);
        
        const result = await aiService.detectIngredients(imagePath);
        
        // Clean up temp file
        fs.unlink(imagePath, (err) => {
            if (err) console.log(`[Controller] Warning: could not delete temp file ${imagePath}`);
        });
        
        return res.json(result);
        
    } catch (error) {
        console.error('[Controller] detectIngredients error:', error);
        return res.status(500).json({
            success: false,
            error: error.message
        });
    }
}

/**
 * POST /api/ai/recommend-recipes
 * 
 * Given a list of ingredients and optional filters, recommend recipes.
 * This doesn't need an image - just send JSON body.
 * 
 * Expected body:
 * {
 *   "ingredients": ["chicken", "rice", "garlic"],
 *   "maxMinutes": 30,
 *   "cuisines": ["asian", "chinese"],
 *   "vegetarian": false,
 *   "vegan": false,
 *   "halal": true,
 *   "maxMissingIngredients": 3,
 *   "topK": 10
 * }
 */
async function recommendRecipes(req, res) {
    try {
        const { ingredients } = req.body;
        
        if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Missing or invalid "ingredients" array in request body.'
            });
        }
        
        // Build params object from request body
        const params = {
            ingredients: ingredients,
            maxMinutes: req.body.maxMinutes || null,
            cuisines: req.body.cuisines || null,
            vegetarian: req.body.vegetarian || false,
            vegan: req.body.vegan || false,
            halal: req.body.halal || false,
            maxMissingIngredients: req.body.maxMissingIngredients || 5,
            topK: req.body.topK || 10
        };
        
        console.log(`[Controller] Recommending recipes for ${ingredients.length} ingredients`);
        
        const result = await aiService.recommendRecipes(params);
        
        return res.json(result);
        
    } catch (error) {
        console.error('[Controller] recommendRecipes error:', error);
        return res.status(500).json({
            success: false,
            error: error.message
        });
    }
}

/**
 * GET /api/ai/health
 * 
 * Simple health check for the AI service.
 * Doesn't actually call Python - just confirms the routes are working.
 */
function healthCheck(req, res) {
    return res.json({
        success: true,
        service: 'AI Service',
        status: 'running',
        endpoints: [
            'POST /api/ai/analyze-food',
            'POST /api/ai/detect-ingredients',
            'POST /api/ai/recommend-recipes'
        ]
    });
}

module.exports = {
    analyzeFood,
    detectIngredients,
    recommendRecipes,
    healthCheck
};
