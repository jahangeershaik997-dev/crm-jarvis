const readline = require('readline');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { saveConfig, getToken } = require('./config-manager');

const LOGS_DIR = path.join(__dirname, 'logs');
const SETUP_LOG = path.join(LOGS_DIR, 'setup.log');

// Ensure logs directory exists
if (!fs.existsSync(LOGS_DIR)) {
  fs.mkdirSync(LOGS_DIR, { recursive: true });
}

function logToFile(message) {
  const timestamp = new Date().toISOString();
  const logMsg = `[${timestamp}] ${message}\n`;
  fs.appendFileSync(SETUP_LOG, logMsg, 'utf8');
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const askQuestion = (query) => new Promise((resolve) => rl.question(query, resolve));

async function runSetup() {
  console.log('================================================================');
  console.log('       JARVIS Dataverse Table Creator - Setup Wizard           ');
  console.log('================================================================\n');
  logToFile('Setup wizard started.');

  try {
    const clientId = (await askQuestion('Enter Azure AD Client ID: ')).trim();
    const clientSecret = (await askQuestion('Enter Azure AD Client Secret: ')).trim();
    const tenantId = (await askQuestion('Enter Azure Tenant ID: ')).trim();
    let d365Url = (await askQuestion('Enter Dynamics 365 URL (e.g., https://org.crm.dynamics.com): ')).trim();
    d365Url = d365Url.replace(/\/+$/, ''); // Remove trailing slashes

    if (!clientId || !clientSecret || !tenantId || !d365Url) {
      console.error('\n❌ Error: All fields are required. Setup aborted.');
      logToFile('Setup aborted: Missing input fields.');
      rl.close();
      return;
    }

    console.log('\n[Setup] Encrypting and saving credentials locally...');
    saveConfig(clientId, clientSecret, tenantId, d365Url);
    logToFile(`Credentials encrypted and saved for D365 URL: ${d365Url}`);

    console.log('[Setup] Testing credentials by requesting an Access Token...');
    logToFile('Requesting OAuth2 token for validation...');
    const token = await getToken();
    console.log('✅ Access Token acquired successfully.');
    logToFile('Token acquired successfully.');

    console.log('[Setup] Testing Dataverse endpoint connectivity (WhoAmI request)...');
    logToFile('Testing Dataverse WhoAmI endpoint...');
    const whoAmIUrl = `${d365Url}/api/data/v9.2/WhoAmI`;
    
    const response = await axios.get(whoAmIUrl, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json',
        'OData-MaxVersion': '4.0',
        'OData-Version': '4.0'
      }
    });

    if (response.status === 200) {
      console.log('\n================================================================');
      console.log('🎉 SUCCESS: Connectivity established and verified!');
      console.log(`- Connected to D365 Organization: ${d365Url}`);
      console.log(`- BusinessUnitId:                ${response.data.BusinessUnitId}`);
      console.log(`- UserId:                        ${response.data.UserId}`);
      console.log('================================================================');
      logToFile(`WhoAmI response success: UserId ${response.data.UserId}, BusinessUnitId ${response.data.BusinessUnitId}`);
    } else {
      throw new Error(`Unexpected WhoAmI status code: ${response.status}`);
    }

  } catch (error) {
    console.error('\n❌ Connection Validation Failed:');
    let detail = error.message;
    if (error.response) {
      detail = JSON.stringify(error.response.data);
      console.error(`Status: ${error.response.status}`);
      console.error('Details:', detail);
    } else {
      console.error(error.message || error);
    }
    logToFile(`Connection failure: ${detail}`);
    console.log('\n⚠️  Credentials were saved but the connection check failed. Please verify configurations.');
  } finally {
    rl.close();
  }
}

runSetup();
