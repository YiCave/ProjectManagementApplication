const { spawn } = require('child_process');
const path = require('path');

// Path to our Python CLI script
const AI_CLI_PATH = path.join(__dirname, '..', 'ai', 'ai_cli.py');

// Path to Python executable in venv - adjust if your setup is different
const PYTHON_PATH = path.join(__dirname, '..', '.venv', 'Scripts', 'python.exe');

/**
 * Runs the Python AI CLI with given command and arguments.
 * Returns a promise that resolves with the JSON result.
 * 
 * This is the core function that bridges Node.js and Python.
 * We spawn a Python process, capture stdout, and parse it as JSON.
 */
function runPythonAI(command, args = []) {
    return new Promise((resolve, reject) => {
        const fullArgs = [AI_CLI_PATH, command, ...args];
        
        console.log(`[AI Service] Running: python ${command} ${args.join(' ')}`);
        
        const python = spawn(PYTHON_PATH, fullArgs, {
            cwd: path.join(__dirname, '..', 'ai') // Run from ai directory
        });
        
        let stdout = '';
        let stderr = '';
        
        python.stdout.on('data', (data) => {
            stdout += data.toString();
        });
        
        python.stderr.on('data', (data) => {
            // Stderr might have debug info from the AI, we log it but don't fail
            stderr += data.toString();
            console.log(`[AI Service] stderr: ${data}`);
        });
        
        python.on('close', (code) => {
            console.log(`[AI Service] Process exited with code ${code}`);
            console.log(`[AI Service] Raw stdout: ${stdout}`);
            
            // Clean up the output - remove trailing whitespace and newlines
            const cleanOutput = stdout.trim();
            
            // Try to find the LAST complete JSON object in stdout
            // The AI scripts print debug info, then the JSON result at the end
            // We need to find the outermost JSON that starts with {"success" or {"data"
            let jsonStart = cleanOutput.lastIndexOf('{"success"');
            if (jsonStart === -1) {
                jsonStart = cleanOutput.lastIndexOf('{"data"');
            }
            if (jsonStart === -1) {
                // Fallback: find last { and try to parse from there
                jsonStart = cleanOutput.lastIndexOf('{');
            }
            
            if (jsonStart !== -1) {
                const jsonStr = cleanOutput.substring(jsonStart);
                console.log(`[AI Service] Attempting to parse JSON: ${jsonStr.substring(0, 200)}...`);
                try {
                    const result = JSON.parse(jsonStr);
                    resolve(result);
                } catch (parseError) {
                    // Try the original regex as fallback
                    const jsonMatch = cleanOutput.match(/\{"success"[\s\S]*?\}$/);
                    if (jsonMatch) {
                        try {
                            const result = JSON.parse(jsonMatch[0]);
                            resolve(result);
                        } catch (e) {
                            reject(new Error(`Failed to parse AI response: ${parseError.message}. Raw: ${jsonStr.substring(0, 500)}`));
                        }
                    } else {
                        reject(new Error(`Failed to parse AI response: ${parseError.message}. Raw: ${jsonStr.substring(0, 500)}`));
                    }
                }
            } else {
                reject(new Error(`No valid JSON in AI response. stdout: ${stdout}, stderr: ${stderr}`));
            }
        });
        
        python.on('error', (error) => {
            reject(new Error(`Failed to start Python process: ${error.message}`));
        });
    });
}

/**
 * Analyze a food image to identify what food it is.
 * Returns food name, category, ingredients, halal status, etc.
 */
async function analyzeFood(imagePath) {
    return runPythonAI('analyze-food', [imagePath]);
}

/**
 * Detect ingredients from an image (like a photo of fridge contents).
 * Returns a list of ingredient names.
 */
async function detectIngredients(imagePath) {
    return runPythonAI('detect-ingredients', [imagePath]);
}

/**
 * Recommend recipes based on available ingredients and preferences.
 * 
 * @param {Object} params - Recipe search parameters
 * @param {string[]} params.ingredients - List of available ingredients
 * @param {number} params.maxMinutes - Maximum cooking time
 * @param {string[]} params.cuisines - Preferred cuisines
 * @param {boolean} params.vegetarian - Vegetarian only
 * @param {boolean} params.vegan - Vegan only
 * @param {boolean} params.halal - Halal only
 * @param {number} params.maxMissingIngredients - How many missing ingredients to allow
 * @param {number} params.topK - Number of recipes to return
 */
async function recommendRecipes(params) {
    // Pass params as JSON string to Python
    const paramsJson = JSON.stringify(params);
    return runPythonAI('recommend-recipes', [paramsJson]);
}

module.exports = {
    analyzeFood,
    detectIngredients,
    recommendRecipes
};
