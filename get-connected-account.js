const axios = require('axios');

async function getConnectedD365Account() {
    try {
        const clientId = process.env.CLIENT_ID;
        const clientSecret = process.env.CLIENT_SECRET;
        const tenantId = process.env.TENANT_ID;
        const d365Url = process.env.D365_URL;

        // Get token
        const tokenResponse = await axios.post(
            `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
            {
                client_id: clientId,
                client_secret: clientSecret,
                scope: `${d365Url}/.default`,
                grant_type: 'client_credentials'
            },
            {
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }
        );

        const token = tokenResponse.data.access_token;

        // Get WhoAmI info
        const whoAmIResponse = await axios.post(
            `${d365Url}/api/data/v9.2/WhoAmI`,
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
            userId: whoAmIResponse.data.UserId,
            businessUnitId: whoAmIResponse.data.BusinessUnitId,
            organizationId: whoAmIResponse.data.OrganizationId,
            environmentUrl: d365Url,
            username: 'jahangeershaik@EVOMAX689.onmicrosoft.com'
        };

    } catch (error) {
        return {
            connected: false,
            error: error.message
        };
    }
}

module.exports = { getConnectedD365Account };