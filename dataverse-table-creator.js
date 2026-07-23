/**
 * Standalone Script: Dataverse Table Creator
 * 
 * Coordinates OAuth2 authentication token acquisition using config-manager
 * and provisioning custom tables in Microsoft Dynamics 365.
 */

const fs = require('fs');
const path = require('path');
const { getToken, loadConfig } = require('./config-manager');
const { createTableInDataverse } = require('./dataverse-helper');

const LOGS_DIR = path.join(__dirname, 'logs');
const CREATOR_LOG = path.join(LOGS_DIR, 'table-creator.log');

// Ensure logs directory exists
if (!fs.existsSync(LOGS_DIR)) {
  fs.mkdirSync(LOGS_DIR, { recursive: true });
}

/**
 * Logs a message to stdout and appends it to table-creator.log.
 */
function logInfo(message) {
  const timestamp = new Date().toISOString();
  const formatted = `[${timestamp}] [INFO] ${message}`;
  console.log(message);
  fs.appendFileSync(CREATOR_LOG, formatted + '\n', 'utf8');
}

function logError(message, error = null) {
  const timestamp = new Date().toISOString();
  const detail = error ? ` - Details: ${error.message || JSON.stringify(error)}` : '';
  const formatted = `[${timestamp}] [ERROR] ${message}${detail}`;
  console.error(message, error || '');
  fs.appendFileSync(CREATOR_LOG, formatted + '\n', 'utf8');
}

// --- Target Table Schema ---
const targetTableName = 'Afrin';
const targetTableLogicalName = 'jarvis_afrin';
const columnsToCreate = [
  { name: 'jarvis_name', displayName: 'Name', type: 'String' },
  { name: 'jarvis_email', displayName: 'Email', type: 'String' },
  { name: 'jarvis_phone', displayName: 'Phone', type: 'String' }
];

async function main() {
  logInfo('================================================================');
  logInfo('       Dynamics 365 Dataverse - Custom Table Creation          ');
  logInfo('================================================================');

  try {
    // 0. Load Configuration to inspect environment URL
    const config = loadConfig();
    logInfo(`Loaded system credentials for URL: ${config.d365Url}`);

    // 1. Authenticate and acquire token (utilizes caching)
    logInfo('Retrieving access token (cached if valid)...');
    const token = await getToken();
    logInfo('Token successfully retrieved.');

    // 2. Create the table and attributes
    logInfo(`Provisioning custom table "${targetTableName}" ("${targetTableLogicalName}")...`);
    const result = await createTableInDataverse(
      targetTableName,
      targetTableLogicalName,
      columnsToCreate,
      config.d365Url,
      token
    );

    // 3. Log results
    logInfo('================================================================');
    if (result.success) {
      logInfo('🚀 SUCCESS: Table created successfully in Dataverse!');
      logInfo(`- Table Display Name:  ${targetTableName}`);
      logInfo(`- Table Logical Name: ${result.logicalName}`);
      logInfo(`- Table Unique ID:    ${result.tableId}`);
      logInfo(`- Total Columns:      ${columnsToCreate.length}`);
    } else {
      logError(`❌ FAILURE: Could not create custom table. Error: ${result.error}`);
      if (result.details) {
        logError(`API Response body: ${result.details}`);
      }
    }
    logInfo('================================================================\n');

  } catch (error) {
    logError('❌ CRITICAL ERROR during execution flow:', error);
    process.exit(1);
  }
}

// Execute workflow if run directly
if (require.main === module) {
  main();
}

module.exports = {
  main
};
