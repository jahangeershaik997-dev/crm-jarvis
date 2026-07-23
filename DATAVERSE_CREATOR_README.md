# JARVIS Dataverse Table Creator Setup Guide

A secure, configuration-driven setup and execution workflow for provisioning custom tables and columns in Microsoft Dynamics 365 Dataverse using the Web API.

---

## 🏗️ File Locations & Architecture

- **Configuration:** `C:\CRM-Jarvis\config\credentials.json` (Encrypted using AES-256-CBC)
- **Token Cache:** `C:\CRM-Jarvis\config\token-cache.json` (Caches token for 1 hour)
- **Execution Log:** `C:\CRM-Jarvis\logs\table-creator.log`
- **Setup Log:** `C:\CRM-Jarvis\logs\setup.log`
- **Helper Library:** `C:\CRM-Jarvis\dataverse-helper.js`
- **Setup Wizard:** `C:\CRM-Jarvis\setup.js`
- **Table Creator Script:** `C:\CRM-Jarvis\dataverse-table-creator.js`

---

## 🛠️ Step 1: Installation & Prerequisites

1. Ensure Node.js (version 18 or above) is installed.
2. Verify all npm packages are installed:
   ```bash
   npm install
   ```

---

## ⚙️ Step 2: Interactive Configuration Setup

Run the interactive setup wizard to configure and secure your Azure Active Directory credentials:

```bash
node setup.js
```

### Prompt Details:
- **Client ID**: The Application ID from your App Registration in Azure AD.
- **Client Secret**: The client secret generated under Certificates & Secrets.
- **Tenant ID**: The Directory ID of your Microsoft Entra ID Tenant.
- **D365 URL**: The base environment URL (e.g. `https://orgfdc28268.crm8.dynamics.com`).

The wizard will:
1. Encrypt and save your configurations to `config/credentials.json`.
2. Authenticate against Microsoft identity providers using the client credentials flow.
3. Attempt to fetch a token and check connectivity to the Dynamics 365 Dataverse `/WhoAmI` Web API endpoint.
4. Record events to `logs/setup.log`.

---

## 🚀 Step 3: Run the Table Creator

After configuring the wizard, run the table creator script to provision the default `Afrin` table:

```bash
node dataverse-table-creator.js
```

This script:
- Automatically loads the credentials securely.
- Uses token caching (valid for 1 hour) to reduce redundant OAuth network requests.
- Provisions the custom table and primary column payload.
- Dynamically iterates and adds all additional attributes.
- Appends log telemetry directly to `logs/table-creator.log`.

---

## 🔒 Security Best Practices

> [!CAUTION]
> **Never commit your configuration credentials file!**
> Ensure `config/credentials.json` and any custom token caches are listed in your `.gitignore` file.
> You can use `.env.example` as a template for setting environment secrets if running in an automated pipeline.

---

## ☁️ Deploying to Render

This application includes a `render.yaml` blueprint configuration, making it fully ready for immediate cloud deployment:

### Deployment Steps:
1. Push your local workspace branch to your GitHub, GitLab, or Bitbucket repository.
2. Log in to your [Render Dashboard](https://dashboard.render.com/).
3. Click **New** -> **Blueprint**.
4. Connect the repository containing this project.
5. Render will automatically parse the `render.yaml` blueprint configuration and deploy the Node.js/React web service.
6. Once deployed, Render will provide a public URL where you can view the fully responsive React SPA interface.

