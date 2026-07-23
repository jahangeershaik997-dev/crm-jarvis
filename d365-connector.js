const axios = require('axios');

class D365Connector {
    constructor() {
        this.clientId = process.env.CLIENT_ID;
        this.clientSecret = process.env.CLIENT_SECRET;
        this.tenantId = process.env.TENANT_ID;
        this.d365Url = process.env.D365_URL;
        this.token = null;
        this.tokenExpiry = null;
    }

    async getToken() {
        // Return cached token if valid
        if (this.token && this.tokenExpiry > Date.now()) {
            return this.token;
        }

        try {
            const response = await axios.post(
                `https://login.microsoftonline.com/${this.tenantId}/oauth2/v2.0/token`,
                {
                    client_id: this.clientId,
                    client_secret: this.clientSecret,
                    scope: `${this.d365Url}/.default`,
                    grant_type: 'client_credentials'
                },
                {
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    }
                }
            );

            this.token = response.data.access_token;
            this.tokenExpiry = Date.now() + (response.data.expires_in * 1000) - 60000; // Refresh 1 min before expiry
            return this.token;
        } catch (error) {
            console.error('[D365] Token error:', error.message);
            throw error;
        }
    }

    async getWhoAmI() {
        try {
            const token = await this.getToken();
            
            const response = await axios.post(
                `${this.d365Url}/api/data/v9.2/WhoAmI`,
                {},
                {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'OData-Version': '4.0'
                    }
                }
            );

            return {
                connected: true,
                userId: response.data.UserId,
                businessUnitId: response.data.BusinessUnitId,
                organizationId: response.data.OrganizationId,
                username: 'jahangeershaik@EVOMAX689.onmicrosoft.com',
                environmentUrl: this.d365Url,
                environment: 'SALMA'
            };
        } catch (error) {
            console.error('[D365] WhoAmI error:', error.message);
            return {
                connected: false,
                error: error.message
            };
        }
    }

    async createTable(tableName, displayName, columns) {
        try {
            const token = await this.getToken();

            // Create table
            const tablePayload = {
                '@odata.type': 'Microsoft.Dynamics.CRM.EntityMetadata',
                LogicalName: tableName.toLowerCase(),
                DisplayName: {
                    LocalizedLabels: [
                        {
                            Label: displayName,
                            LanguageCode: 1033
                        }
                    ]
                },
                DisplayCollectionName: {
                    LocalizedLabels: [
                        {
                            Label: displayName + 's',
                            LanguageCode: 1033
                        }
                    ]
                },
                OwnershipType: 'UserOwned'
            };

            const tableResponse = await axios.post(
                `${this.d365Url}/api/data/v9.2/EntityDefinitions`,
                tablePayload,
                {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'OData-MaxVersion': '4.0',
                        'OData-Version': '4.0',
                        'Content-Type': 'application/json'
                    }
                }
            );

            console.log('[D365] Table created:', tableName);

            // Add columns
            for (const col of columns) {
                const colPayload = {
                    '@odata.type': 'Microsoft.Dynamics.CRM.StringAttributeMetadata',
                    LogicalName: col.name.toLowerCase(),
                    DisplayName: {
                        LocalizedLabels: [
                            {
                                Label: col.displayName || col.name,
                                LanguageCode: 1033
                            }
                        ]
                    },
                    RequiredLevel: {
                        Value: 'None'
                    },
                    MaxLength: 100
                };

                await axios.post(
                    `${this.d365Url}/api/data/v9.2/EntityDefinitions(LogicalName='${tableName.toLowerCase()}')/Attributes`,
                    colPayload,
                    {
                        headers: {
                            'Authorization': `Bearer ${token}`,
                            'OData-MaxVersion': '4.0',
                            'OData-Version': '4.0',
                            'Content-Type': 'application/json'
                        }
                    }
                );

                console.log('[D365] Column added:', col.name);
            }

            return {
                success: true,
                tableName: tableName,
                columnsAdded: columns.length
            };

        } catch (error) {
            console.error('[D365] Create table error:', error.message);
            throw error;
        }
    }
}

module.exports = D365Connector;