const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const axios = require('axios');

const CONFIG_DIR = path.join(__dirname, 'config');
const CREDENTIALS_FILE = path.join(CONFIG_DIR, 'credentials.json');
const CACHE_FILE = path.join(CONFIG_DIR, 'token-cache.json');

// Ensure directory exists
if (!fs.existsSync(CONFIG_DIR)) {
  fs.mkdirSync(CONFIG_DIR, { recursive: true });
}

// Encryption settings
const ALGORITHM = 'aes-256-cbc';
// Use process.env.JARVIS_SECRET_KEY or fallback to a standard static key for local security
const SECRET_KEY = crypto.scryptSync(process.env.JARVIS_SECRET_KEY || 'JarvisDataverseDefaultKeySalt321', 'salt', 32);
const IV_LENGTH = 16;

/**
 * Encrypts a string.
 */
function encrypt(text) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, SECRET_KEY, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return `${iv.toString('hex')}:${encrypted}`;
}

/**
 * Decrypts a string.
 */
function decrypt(text) {
  const parts = text.split(':');
  const iv = Buffer.from(parts.shift(), 'hex');
  const encryptedText = Buffer.from(parts.join(':'), 'hex');
  const decipher = crypto.createDecipheriv(ALGORITHM, SECRET_KEY, iv);
  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}

/**
 * Saves configuration credentials in an encrypted JSON file.
 */
function saveConfig(clientId, clientSecret, tenantId, d365Url) {
  const configData = {
    clientId,
    clientSecret,
    tenantId,
    d365Url: d365Url.replace(/\/+$/, '')
  };

  const encryptedString = encrypt(JSON.stringify(configData));
  fs.writeFileSync(CREDENTIALS_FILE, JSON.stringify({ data: encryptedString }, null, 2), 'utf8');
}

/**
 * Loads configuration credentials.
 */
function loadConfig() {
  if (!fs.existsSync(CREDENTIALS_FILE)) {
    throw new Error(`Credentials file not found at ${CREDENTIALS_FILE}. Please run the setup script first.`);
  }

  const raw = JSON.parse(fs.readFileSync(CREDENTIALS_FILE, 'utf8'));
  if (!raw.data) {
    throw new Error('Invalid credentials file format.');
  }

  const decryptedString = decrypt(raw.data);
  return JSON.parse(decryptedString);
}

/**
 * Gets the token from local cache if it is still valid, or requests a new one.
 */
async function getToken() {
  // Check cache first
  if (fs.existsSync(CACHE_FILE)) {
    try {
      const cache = JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
      if (cache.token && cache.expiresAt && Date.now() < cache.expiresAt) {
        console.log('[Token Cache] Using cached Dataverse authentication token.');
        return cache.token;
      }
    } catch (e) {
      // Ignore cache read errors and proceed to fetch new token
    }
  }

  // Load config to fetch new token
  const config = loadConfig();
  const scope = `${config.d365Url}/.default`;
  const tokenUrl = `https://login.microsoftonline.com/${config.tenantId}/oauth2/v2.0/token`;

  const params = new URLSearchParams();
  params.append('grant_type', 'client_credentials');
  params.append('client_id', config.clientId);
  params.append('client_secret', config.clientSecret);
  params.append('scope', scope);

  try {
    const response = await axios.post(tokenUrl, params.toString(), {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    });

    const { access_token, expires_in } = response.data;
    if (!access_token) {
      throw new Error('Access token was not returned by the auth server.');
    }

    // Cache the token (expires_in is in seconds, subtract 60s safety buffer)
    const expiresAt = Date.now() + (expires_in - 60) * 1000;
    fs.writeFileSync(CACHE_FILE, JSON.stringify({ token: access_token, expiresAt }, null, 2), 'utf8');

    console.log(`[Token Cache] Retrieved and cached new Dataverse token. Valid until ${new Date(expiresAt).toISOString()}`);
    return access_token;
  } catch (error) {
    if (error.response) {
      throw new Error(`Authentication failure: ${error.response.data.error_description || error.response.data.error || error.message}`);
    }
    throw error;
  }
}

module.exports = {
  saveConfig,
  loadConfig,
  getToken
};
