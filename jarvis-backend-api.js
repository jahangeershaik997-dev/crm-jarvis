// JARVIS Backend API - Phase 3
// Node.js + Express Server

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// In-memory storage (replace with MongoDB in production)
const systems = {};
const users = {};
const deployments = {};

// ============================================================
// AUTHENTICATION ROUTES
// ============================================================

app.post('/api/auth/register', (req, res) => {
    const { email, password, company } = req.body;
    
    if (users[email]) {
        return res.status(400).json({ error: 'User already exists' });
    }
    
    const userId = uuidv4();
    users[email] = {
        id: userId,
        email,
        password, // In production: hash this!
        company,
        createdAt: new Date(),
        systems: []
    };
    
    res.status(201).json({
        success: true,
        userId,
        message: 'User registered successfully'
    });
});

app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    const user = users[email];
    
    if (!user || user.password !== password) {
        return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = uuidv4();
    res.json({
        success: true,
        token,
        userId: user.id,
        email: user.email,
        company: user.company
    });
});

// ============================================================
// JARVIS CORE ROUTES
// ============================================================

app.post('/api/jarvis/build', async (req, res) => {
    const { requirement, userId } = req.body;
    
    if (!requirement || !userId) {
        return res.status(400).json({ error: 'Requirement and userId required' });
    }
    
    const systemId = uuidv4();
    const deploymentId = uuidv4();
    
    try {
        // STEP 1: Send to Ollama for analysis
        console.log('Sending requirement to Ollama...');
        
        const prompt = `Analyze this D365 requirement and return ONLY JSON:
${requirement}

Return JSON with: plugin_name, description, tables, triggers, business_rules, flows`;
        
        const ollamaResponse = await axios.post('http://localhost:11434/api/generate', {
            model: 'qwen2.5:3b',
            prompt: prompt,
            stream: false
        }, { timeout: 120000 });
        
        // Parse JSON from response
        const jsonMatch = ollamaResponse.data.response.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
            throw new Error('No JSON found in Ollama response');
        }
        
        const spec = JSON.parse(jsonMatch[0]);
        
        // STEP 2: Store system
        systems[systemId] = {
            id: systemId,
            userId,
            name: spec.plugin_name,
            description: spec.description,
            requirement,
            spec,
            status: 'building',
            createdAt: new Date(),
            deployments: [deploymentId]
        };
        
        // STEP 3: Create deployment record
        deployments[deploymentId] = {
            id: deploymentId,
            systemId,
            status: 'in_progress',
            progress: 0,
            steps: [
                { name: 'Analyzing Requirement', status: 'completed', progress: 20 },
                { name: 'Generating Tables', status: 'in_progress', progress: 40 },
                { name: 'Generating Business Rules', status: 'pending', progress: 0 },
                { name: 'Generating Flows', status: 'pending', progress: 0 },
                { name: 'Compiling Plugins', status: 'pending', progress: 0 },
                { name: 'Deploying to D365', status: 'pending', progress: 0 }
            ],
            createdAt: new Date(),
            completedAt: null
        };
        
        // Simulate build process (in production, call PowerShell scripts)
        simulateBuild(systemId, deploymentId);
        
        res.status(201).json({
            success: true,
            systemId,
            deploymentId,
            systemName: spec.plugin_name,
            message: 'Build started'
        });
        
    } catch (error) {
        console.error('Build error:', error.message);
        res.status(500).json({
            error: 'Build failed',
            details: error.message
        });
    }
});

// Simulate build process
function simulateBuild(systemId, deploymentId) {
    const steps = ['Generating Tables', 'Generating Business Rules', 'Generating Flows', 'Compiling Plugins', 'Deploying to D365'];
    let currentStep = 1;
    
    const interval = setInterval(() => {
        if (currentStep < steps.length) {
            const deployment = deployments[deploymentId];
            deployment.steps[currentStep].status = 'in_progress';
            deployment.steps[currentStep].progress = 50;
            
            // Mark previous as completed
            if (currentStep > 0) {
                deployment.steps[currentStep - 1].status = 'completed';
                deployment.steps[currentStep - 1].progress = 100;
            }
            
            deployment.progress = Math.round((currentStep / steps.length) * 100);
            currentStep++;
        } else {
            // Complete build
            const deployment = deployments[deploymentId];
            deployment.status = 'completed';
            deployment.progress = 100;
            deployment.steps[deployment.steps.length - 1].status = 'completed';
            deployment.steps[deployment.steps.length - 1].progress = 100;
            deployment.completedAt = new Date();
            
            const system = systems[systemId];
            system.status = 'live';
            
            clearInterval(interval);
        }
    }, 2000);
}

// ============================================================
// DASHBOARD ROUTES
// ============================================================

app.get('/api/dashboard/systems/:userId', (req, res) => {
    const { userId } = req.params;
    
    const userSystems = Object.values(systems).filter(s => s.userId === userId);
    
    res.json({
        success: true,
        totalSystems: userSystems.length,
        systems: userSystems.map(s => ({
            id: s.id,
            name: s.name,
            description: s.description,
            status: s.status,
            createdAt: s.createdAt,
            tables: s.spec.tables.length,
            rules: s.spec.business_rules.length,
            flows: s.spec.flows.length
        }))
    });
});

app.get('/api/deployment/:deploymentId', (req, res) => {
    const { deploymentId } = req.params;
    const deployment = deployments[deploymentId];
    
    if (!deployment) {
        return res.status(404).json({ error: 'Deployment not found' });
    }
    
    res.json({
        success: true,
        deployment
    });
});

app.get('/api/system/:systemId', (req, res) => {
    const { systemId } = req.params;
    const system = systems[systemId];
    
    if (!system) {
        return res.status(404).json({ error: 'System not found' });
    }
    
    res.json({
        success: true,
        system
    });
});

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date(),
        version: '3.0.0'
    });
});

// ============================================================
// ERROR HANDLING
// ============================================================

app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal server error',
        details: err.message
    });
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, () => {
    console.log('');
    console.log('╔════════════════════════════════════════════╗');
    console.log('║   JARVIS Backend API - Phase 3             ║');
    console.log('║   Server running on port ' + PORT + '               ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log('');
    console.log('API Endpoints:');
    console.log('  POST   /api/auth/register');
    console.log('  POST   /api/auth/login');
    console.log('  POST   /api/jarvis/build');
    console.log('  GET    /api/dashboard/systems/:userId');
    console.log('  GET    /api/deployment/:deploymentId');
    console.log('  GET    /api/system/:systemId');
    console.log('');
});

module.exports = app;