const axios = require('axios');

/**
 * Creates a custom table in Dynamics 365 Dataverse and adds the specified columns.
 * 
 * @param {string} tableName - The display name of the table (e.g., 'Afrin')
 * @param {string} tableLogicalName - The logical name of the table in lowercase (e.g., 'jarvis_afrin')
 * @param {Array<{name: string, displayName: string, type: string}>} columns - Array of column definitions
 * @param {string} d365Url - The D365 environment URL (e.g., 'https://orgfdc28268.crm8.dynamics.com')
 * @param {string} authToken - The Bearer token for authentication
 * @returns {Promise<{success: boolean, tableId?: string, logicalName?: string, error?: string}>}
 */
async function createTableInDataverse(tableName, tableLogicalName, columns, d365Url, authToken) {
  // Normalize the base URL (remove trailing slashes)
  const baseUrl = d365Url.replace(/\/+$/, '');
  const apiVersion = 'v9.2';
  const apiEndpoint = `${baseUrl}/api/data/${apiVersion}`;
  
  console.log(`[Dataverse] Initializing table creation for logical name: "${tableLogicalName}"`);

  // Headers required for Dynamics 365 Web API
  const headers = {
    'Authorization': `Bearer ${authToken}`,
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
    'OData-MaxVersion': '4.0',
    'OData-Version': '4.0'
  };

  try {
    // 1. Identify or create the primary attribute.
    // Dynamics 365 custom tables MUST have a primary name attribute defined during creation.
    // We look for a column in the provided list that is a String and matches a 'name' criteria.
    let primaryColumnIndex = columns.findIndex(col => 
      col.type.toLowerCase() === 'string' && 
      (col.name.toLowerCase().includes('name') || col.displayName.toLowerCase().includes('name'))
    );

    // Fallback: Use the first String column if no 'name'-like column is found
    if (primaryColumnIndex === -1) {
      primaryColumnIndex = columns.findIndex(col => col.type.toLowerCase() === 'string');
    }

    let primaryColumn;
    let otherColumns = [...columns];

    if (primaryColumnIndex !== -1) {
      // Extract the primary column so it's not created twice
      primaryColumn = columns[primaryColumnIndex];
      otherColumns.splice(primaryColumnIndex, 1);
    } else {
      // Fallback if no string column is found at all (highly recommended to have one)
      primaryColumn = {
        name: `${tableLogicalName}_name`,
        displayName: 'Name',
        type: 'String'
      };
    }

    // 2. Prepare the payload for EntityDefinitions POST request
    const entityPayload = {
      "SchemaName": tableLogicalName,
      "DisplayName": {
        "LocalizedLabels": [
          {
            "Label": tableName,
            "LanguageCode": 1033 // US English
          }
        ]
      },
      "DisplayCollectionName": {
        "LocalizedLabels": [
          {
            "Label": tableName.endsWith('s') ? tableName : `${tableName}s`,
            "LanguageCode": 1033
          }
        ]
      },
      "Attributes": [
        {
          "@odata.type": "Microsoft.Dynamics.CRM.StringAttributeMetadata",
          "AttributeType": "String",
          "AttributeTypeName": {
            "Value": "StringType"
          },
          "Description": {
            "LocalizedLabels": [
              {
                "Label": `Primary Name column for ${tableName}`,
                "LanguageCode": 1033
              }
            ]
          },
          "DisplayName": {
            "LocalizedLabels": [
              {
                "Label": primaryColumn.displayName,
                "LanguageCode": 1033
              }
            ]
          },
          "IsPrimaryName": true,
          "RequiredLevel": {
            "Value": "None"
          },
          "SchemaName": primaryColumn.name,
          "MaxLength": 100,
          "FormatName": {
            "Value": "Text"
          }
        }
      ],
      "OwnershipType": "UserOwned",
      "IsActivity": false,
      "HasNotes": false,
      "HasActivities": false
    };

    console.log(`[Dataverse] Creating entity definitions with primary attribute "${primaryColumn.name}"...`);
    
    // POST request to create the table
    const createTableResponse = await axios.post(
      `${apiEndpoint}/EntityDefinitions`,
      entityPayload,
      { headers }
    );

    // Dynamics 365 returns the entity metadata ID in the 'OData-EntityId' header
    // e.g., "https://org.crm.dynamics.com/api/data/v9.2/EntityDefinitions(7a4f91cf-...)""
    const entityIdHeader = createTableResponse.headers['odata-entityid'] || '';
    const tableIdMatch = entityIdHeader.match(/EntityDefinitions\(([^)]+)\)/);
    const tableId = tableIdMatch ? tableIdMatch[1] : null;

    console.log(`[Dataverse] Table created successfully! ID: ${tableId}`);
    
    // 3. Add the remaining columns one by one
    for (const column of otherColumns) {
      console.log(`[Dataverse] Adding column "${column.name}" (${column.type}) to table "${tableLogicalName}"...`);
      
      const columnPayload = buildColumnPayload(column);
      
      await axios.post(
        `${apiEndpoint}/EntityDefinitions(LogicalName='${tableLogicalName}')/Attributes`,
        columnPayload,
        { headers }
      );
      
      console.log(`[Dataverse] Column "${column.name}" added successfully.`);
    }

    return {
      success: true,
      tableId: tableId,
      logicalName: tableLogicalName
    };

  } catch (error) {
    // 4. Detailed Error Handling
    let errorMessage = error.message;
    let apiDetails = '';

    if (error.response) {
      const status = error.response.status;
      const data = error.response.data;
      
      console.error(`[Dataverse API Error] HTTP ${status}:`, JSON.stringify(data, null, 2));

      if (status === 401) {
        errorMessage = 'Unauthorized: Access token is invalid, expired, or has insufficient scopes.';
      } else if (status === 400) {
        const d365Error = data.error?.message || JSON.stringify(data);
        errorMessage = `Bad Request (Schema Issue): ${d365Error}`;
      } else {
        errorMessage = `Dynamics 365 API error (${status}): ${data.error?.message || error.message}`;
      }
      apiDetails = JSON.stringify(data);
    } else {
      console.error('[Dataverse Network/Client Error]:', error);
    }

    return {
      success: false,
      error: errorMessage,
      details: apiDetails
    };
  }
}

/**
 * Helper to build attribute metadata payload depending on the requested type.
 */
function buildColumnPayload(column) {
  const typeUpper = column.type.toUpperCase();
  
  const baseMetadata = {
    "SchemaName": column.name,
    "DisplayName": {
      "LocalizedLabels": [
        {
          "Label": column.displayName,
          "LanguageCode": 1033
        }
      ]
    },
    "RequiredLevel": {
      "Value": "None"
    }
  };

  switch (typeUpper) {
    case 'STRING':
    case 'TEXT':
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.StringAttributeMetadata",
        "AttributeType": "String",
        "AttributeTypeName": {
          "Value": "StringType"
        },
        "MaxLength": 250,
        "FormatName": {
          "Value": "Text"
        },
        ...baseMetadata
      };

    case 'INTEGER':
    case 'INT':
    case 'WHOLE NUMBER':
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.IntegerAttributeMetadata",
        "AttributeType": "Integer",
        "AttributeTypeName": {
          "Value": "IntegerType"
        },
        "Format": "None",
        "MinValue": -2147483648,
        "MaxValue": 2147483647,
        ...baseMetadata
      };

    case 'DECIMAL':
    case 'DOUBLE':
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.DecimalAttributeMetadata",
        "AttributeType": "Decimal",
        "AttributeTypeName": {
          "Value": "DecimalType"
        },
        "Precision": 2,
        "MinValue": -100000000000,
        "MaxValue": 100000000000,
        ...baseMetadata
      };

    case 'BOOLEAN':
    case 'BOOL':
    case 'TWO OPTIONS':
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.BooleanAttributeMetadata",
        "AttributeType": "Boolean",
        "AttributeTypeName": {
          "Value": "BooleanType"
        },
        "OptionSet": {
          "TrueOption": {
            "Value": 1,
            "Label": {
              "LocalizedLabels": [
                {
                  "Label": "Yes",
                  "LanguageCode": 1033
                }
              ]
            }
          },
          "FalseOption": {
            "Value": 0,
            "Label": {
              "LocalizedLabels": [
                {
                  "Label": "No",
                  "LanguageCode": 1033
                }
              ]
            }
          }
        },
        ...baseMetadata
      };

    case 'DATETIME':
    case 'DATE':
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.DateTimeAttributeMetadata",
        "AttributeType": "DateTime",
        "AttributeTypeName": {
          "Value": "DateTimeType"
        },
        "Format": "DateOnly", // Or DateAndTime
        ...baseMetadata
      };

    case 'MEMO':
    case 'MULTILINE':
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.MemoAttributeMetadata",
        "AttributeType": "Memo",
        "AttributeTypeName": {
          "Value": "MemoType"
        },
        "MaxLength": 2000,
        ...baseMetadata
      };

    default:
      // Default fallback to StringAttributeMetadata
      return {
        "@odata.type": "Microsoft.Dynamics.CRM.StringAttributeMetadata",
        "AttributeType": "String",
        "AttributeTypeName": {
          "Value": "StringType"
        },
        "MaxLength": 250,
        "FormatName": {
          "Value": "Text"
        },
        ...baseMetadata
      };
  }
}

/**
 * Obtains an OAuth2 Access Token for Dynamics 365 Dataverse using Client Credentials Flow.
 * 
 * @param {string} clientId - Azure AD Application (Client) ID
 * @param {string} clientSecret - Azure AD Client Secret
 * @param {string} tenantId - Azure AD Directory (Tenant) ID
 * @param {string} d365Url - Dynamics 365 Environment URL (e.g., https://orgfdc28268.crm8.dynamics.com)
 * @returns {Promise<string>} Bearer Access Token
 */
async function getDataverseToken(clientId, clientSecret, tenantId, d365Url) {
  // Normalize environment URL (remove trailing slash for scope)
  const normalizedUrl = d365Url.replace(/\/+$/, '');
  const scope = `${normalizedUrl}/.default`;
  const tokenUrl = `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`;

  console.log(`[OAuth2] Requesting access token for scope: "${scope}"`);

  // Build application/x-www-form-urlencoded parameters
  const params = new URLSearchParams();
  params.append('grant_type', 'client_credentials');
  params.append('client_id', clientId);
  params.append('client_secret', clientSecret);
  params.append('scope', scope);

  try {
    const response = await axios.post(tokenUrl, params.toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    const { access_token, expires_in } = response.data;

    if (!access_token) {
      throw new Error('Access token missing in authorization server response.');
    }

    // Log the expiration details (expires_in is in seconds)
    const expirationTime = new Date(Date.now() + expires_in * 1000);
    console.log(`[OAuth2] Token acquired successfully. Expires in ${expires_in} seconds (at ${expirationTime.toISOString()}).`);

    return access_token;

  } catch (error) {
    console.error('[OAuth2 Error] Failed to retrieve authentication token.');

    if (error.response) {
      const status = error.response.status;
      const data = error.response.data;
      console.error(`[OAuth2 API Error] HTTP ${status}:`, JSON.stringify(data, null, 2));
      throw new Error(`Authentication failed (${status}): ${data.error_description || data.error || error.message}`);
    } else {
      console.error('[OAuth2 Network/Client Error]:', error.message);
      throw error;
    }
  }
}

module.exports = {
  createTableInDataverse,
  getDataverseToken
};

