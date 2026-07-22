// JARVIS Backend - Real Execution
// Connects to PowerShell Phase 2 scripts for actual D365 deployment

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');
const { exec } = require('child_process');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

// In-memory storage
const systems = {};
const users = {};
const deployments = {};

// ============================================================
// POWERSHELL EXECUTION
// ============================================================

function executePS(scriptPath, args = '') {
    return new Promise((resolve, reject) => {
        const command = `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${scriptPath}" ${args}`;
        console.log(`[EXEC] ${command}`);
        
        exec(command, { 
            shell: 'powershell.exe',
            timeout: 300000,
            maxBuffer: 10 * 1024 * 1024
        }, (error, stdout, stderr) => {
            if (error) {
                console.error(`[ERROR] ${error.message}`);
                reject(error);
            } else {
                console.log(`[OUTPUT] ${stdout}`);
                resolve(stdout);
            }
        });
    });
}

// ============================================================
// JARVIS BUILD - REAL EXECUTION
// ============================================================

app.post('/api/jarvis/build-real', async (req, res) => {
    const { requirement, userId } = req.body;
    
    if (!requirement || !userId) {
        return res.status(400).json({ error: 'Requirement and userId required' });
    }
    
    const systemId = uuidv4();
    const deploymentId = uuidv4();
    
    try {
        // STEP 1: Analyze with Ollama
        console.log('\n[STEP 1] Analyzing requirement with Ollama...');
        
        const prompt = `Analyze this D365 requirement and return ONLY valid JSON:
${requirement}

Return this JSON structure exactly:
{
  "plugin_name": "ClassName",
  "description": "Brief description",
  "tables": [{"name": "logical_name", "display_name": "Display Name", "columns": [{"name": "col_name", "type": "Text"}]}],
  "triggers": [{"table": "name", "message": "Create"}],
  "business_rules": [{"rule": "description", "type": "Validation"}],
  "flows": [{"name": "FlowName", "trigger": "When", "action": "What"}]
}`;
        
        const ollamaResponse = await axios.post('http://localhost:11434/api/generate', {
            model: 'qwen2.5:3b',
            prompt: prompt,
            stream: false
        }, { timeout: 120000 });
        
        const jsonMatch = ollamaResponse.data.response.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
            throw new Error('No JSON found in Ollama response');
        }
        
        const spec = JSON.parse(jsonMatch[0]);
        console.log('[OLLAMA] Analysis complete:', spec.plugin_name);
        
        // STEP 2: Save spec to file
        const specPath = `C:\\CRM-Jarvis\\generated\\configs\\${spec.plugin_name}-spec.json`;
        fs.writeFileSync(specPath, JSON.stringify(spec, null, 2));
        console.log(`[SAVED] Spec: ${specPath}`);
        
        // STEP 3: Create deployment record
        deployments[deploymentId] = {
            id: deploymentId,
            systemId,
            status: 'in_progress',
            progress: 10,
            steps: [
                { name: 'Analyzing Requirement', status: 'completed', progress: 100 },
                { name: 'Generating Tables', status: 'in_progress', progress: 20 },
                { name: 'Generating Business Rules', status: 'pending', progress: 0 },
                { name: 'Generating Flows', status: 'pending', progress: 0 },
                { name: 'Compiling Plugins', status: 'pending', progress: 0 },
                { name: 'Deploying to D365', status: 'pending', progress: 0 }
            ],
            createdAt: new Date(),
            completedAt: null,
            logs: ['Analysis complete']
        };
        
        // STEP 4: Run JARVIS Phase 2 (actually creates tables!)
        console.log('\n[STEP 2] Running JARVIS Phase 2...');
        
        const phase2Script = 'C:\\CRM-Jarvis\\core\\jarvis-phase2.ps1';
        const phase2Args = `-Requirement "${requirement}"`;
        
        try {
            const phase2Output = await executePS(phase2Script, phase2Args);
            console.log('[PHASE2] Execution complete');
            
            deployments[deploymentId].logs.push('Phase 2 executed successfully');
            deployments[deploymentId].progress = 100;
            deployments[deploymentId].status = 'completed';
            deployments[deploymentId].steps = [
                { name: 'Analyzing Requirement', status: 'completed', progress: 100 },
                { name: 'Generating Tables', status: 'completed', progress: 100 },
                { name: 'Generating Business Rules', status: 'completed', progress: 100 },
                { name: 'Generating Flows', status: 'completed', progress: 100 },
                { name: 'Compiling Plugins', status: 'completed', progress: 100 },
                { name: 'Deploying to D365', status: 'completed', progress: 100 }
            ];
            deployments[deploymentId].completedAt = new Date();
            
        } catch (phase2Error) {
            console.error('[PHASE2 ERROR]', phase2Error.message);
            deployments[deploymentId].status = 'failed';
            deployments[deploymentId].logs.push(`Error: ${phase2Error.message}`);
            throw phase2Error;
        }
        
        // STEP 5: Store system
        systems[systemId] = {
            id: systemId,
            userId,
            name: spec.plugin_name,
            description: spec.description,
            requirement,
            spec,
            status: 'live',
            createdAt: new Date(),
            deployments: [deploymentId],
            tablesCount: spec.tables.length,
            rulesCount: spec.business_rules.length,
            flowsCount: spec.flows.length
        };
        
        console.log(`\n[SUCCESS] System deployed: ${spec.plugin_name}`);
        
        return res.status(201).json({
            success: true,
            systemId,
            deploymentId,
            systemName: spec.plugin_name,
            message: 'System built and deployed to D365!',
            tablesCreated: spec.tables.length,
            rulesCreated: spec.business_rules.length,
            flowsCreated: spec.flows.length
        });
        
    } catch (error) {
        console.error('\n[FATAL ERROR]', error.message);
        
        deployments[deploymentId] = deployments[deploymentId] || {};
        deployments[deploymentId].status = 'failed';
        deployments[deploymentId].error = error.message;
        
        return res.status(500).json({
            success: false,
            error: 'Build failed',
            details: error.message,
            deploymentId
        });
    }
});

// ============================================================
// DASHBOARD ROUTES
// ============================================================

app.get('/api/dashboard/systems/:userId', (req, res) => {
    const { userId } = req.params;
    const userSystems = Object.values(systems).filter(s => s.userId === userId);
    
    res.json({
        success: true,
        totalSystems: userSystems.length,
        liveSystems: userSystems.filter(s => s.status === 'live').length,
        totalTables: userSystems.reduce((sum, s) => sum + (s.tablesCount || 0), 0),
        systems: userSystems.map(s => ({
            id: s.id,
            name: s.name,
            description: s.description,
            status: s.status,
            createdAt: s.createdAt,
            tables: s.tablesCount,
            rules: s.rulesCount,
            flows: s.flowsCount
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
        version: '3.0.0-real',
        timestamp: new Date()
    });
});

// ============================================================
// ERROR HANDLING
// ============================================================

app.use((err, req, res, next) => {
    console.error('[ERROR]', err);
    res.status(500).json({
        error: 'Internal server error',
        details: err.message
    });
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, () => {
    console.log('\n');
    console.log('╔════════════════════════════════════════════╗');
    console.log('║   JARVIS Backend - REAL Execution         ║');
    console.log('║   Server running on port ' + PORT + '               ║');
    console.log('║   Connected to Phase 2 Scripts             ║');
    console.log('║   Ready to create D365 systems!            ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log('');
    console.log('Endpoints:');
    console.log('  POST   /api/jarvis/build-real');
    console.log('  GET    /api/dashboard/systems/:userId');
    console.log('  GET    /api/deployment/:deploymentId');
    console.log('');
});

module.exports = app;
