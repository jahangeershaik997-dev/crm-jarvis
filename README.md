# 🤖 JARVIS - CRM Autopilot Platform

**AI-Powered D365/Dataverse Solution Generator**

Convert business requirements → Production-ready Power Platform systems in minutes.

---

> [!NOTE]
> Looking for the custom table provisioning scripts and credential configurations? Check out the [JARVIS Dataverse Table Creator Setup Guide](file:///c:/CRM-Jarvis/DATAVERSE_CREATOR_README.md).

---

## **What is JARVIS?**

JARVIS is an end-to-end automation platform that:

- ✅ Parses natural language requirements
- ✅ Generates complete data schemas
- ✅ Auto-creates C# plugins
- ✅ Builds Power Automate flows
- ✅ Packages solutions (.zip)
- ✅ Deploys to Dataverse
- ✅ Runs automated tests
- ✅ Integrates with Git
- ✅ Tracks issues & errors

**Result:** Build production systems in 30-60 minutes instead of 2-4 weeks.

---

## **Platform Architecture**

```
┌─────────────────────────────────────────────────────┐
│                 INPUT LAYER                         │
│  You: "Build Sales Order System"                    │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              AI BRAIN (Claude API)                   │
│  • Parse requirements                               │
│  • Generate JSON specs                              │
│  • Design database schema                           │
│  • Plan plugin architecture                         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│           GENERATOR LAYER                           │
│  • Create C# plugin code                            │
│  • Design Power Automate flows                      │
│  • Build Power Pages                                │
│  • Generate test cases                              │
│  • Create deployment scripts                        │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│           EXECUTOR LAYER                            │
│  • Power Platform CLI                               │
│  • Dataverse APIs                                   │
│  • Build & compile plugins                          │
│  • Create tables & columns                          │
│  • Register plugins                                 │
│  • Deploy flows                                     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│           TESTING LAYER                             │
│  • Unit tests                                       │
│  • Integration tests                                │
│  • Schema validation                                │
│  • Performance tests                                │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│           DEPLOYMENT LAYER                          │
│  • GitHub Actions CI/CD                             │
│  • Multi-environment deploy                         │
│  • Version control                                  │
│  • Automatic rollback                               │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              OUTPUT                                 │
│  ✅ Live system in Dataverse                        │
│  ✅ Git repo with full history                      │
│  ✅ Documentation auto-generated                    │
│  ✅ Monitoring & alerts configured                  │
└─────────────────────────────────────────────────────┘
```

---

## **Quick Start**

### **1. Clone Repository**
```bash
git clone https://github.com/yourname/jarvis-crm-autopilot.git
cd jarvis-crm-autopilot
```

### **2. Install Dependencies**
```bash
npm install -g @microsoft/powerplatform-cli
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

### **3. Configure Power Platform**
```bash
pac auth create --url https://yourorg.crm.dynamics.com --username you@company.com
```

### **4. Give Your First Prompt**
```bash
node scripts/jarvis-prompt.js "Build Sales Order system with:
- Customer table
- Product table
- Order table with auto-totals
- Auto-approval if < $5000
- Send confirmation email"
```

### **5. Watch Magic Happen** 🚀
- Tables created automatically
- Plugins generated & deployed
- Flows activated
- Tests run
- System live in 30-60 minutes

---

## **Directory Structure**

```
jarvis-crm-autopilot/
├── README.md (this file)
├── docs/
│   ├── ARCHITECTURE.md (complete system design)
│   ├── API_REFERENCE.md (all functions)
│   ├── ERROR_HANDLING.md (error codes & solutions)
│   ├── GITHUB_INTEGRATION.md (GitHub workflow)
│   ├── KNOWN_ISSUES.md (tracked issues)
│   └── TROUBLESHOOTING.md (common problems)
├── src/
│   ├── ai-engine/ (Claude API integration)
│   ├── generators/ (code generators)
│   ├── executor/ (Power Platform CLI wrapper)
│   ├── tester/ (test suite runner)
│   └── deployer/ (Git + CI/CD handler)
├── templates/
│   ├── plugins/ (C# templates)
│   ├── flows/ (Power Automate templates)
│   ├── solutions/ (solution.xml templates)
│   └── tests/ (test templates)
├── examples/
│   ├── sales-order-system/
│   ├── hr-leave-system/
│   ├── inventory-tracking/
│   └── customer-service/
├── config/
│   ├── .env.example
│   ├── power-platform-config.json
│   └── github-config.json
├── scripts/
│   ├── jarvis-prompt.js (main entry point)
│   ├── setup.sh (initial setup)
│   ├── deploy.ps1 (deployment script)
│   └── rollback.ps1 (rollback script)
├── .github/
│   └── workflows/
│       ├── deploy.yml (CI/CD pipeline)
│       ├── test.yml (test automation)
│       └── rollback.yml (emergency rollback)
├── error-logs/
│   ├── 2024-12-errors.json
│   └── WEBRESOURCE_ISSUES.md (known issues like WebResource error)
└── .gitignore

```

---

## **Key Features**

### **✅ Fully Automated**
- One prompt generates everything
- Zero manual clicking in Power Platform UI
- Completely hands-off after initial setup

### **✅ Intelligent Error Handling**
- Catches common Power Platform issues
- References GitHub issues
- Saves error logs locally
- Suggests fixes automatically

### **✅ Version Control**
- Every system tracked in Git
- Full deployment history
- Easy rollback capability
- Audit trail

### **✅ Multi-Environment**
- Dev → Test → Prod pipeline
- Automatic testing at each stage
- Zero-downtime deployments
- Environment parity maintained

### **✅ Complete Documentation**
- Auto-generated docs for each system
- API references
- Architecture diagrams
- Troubleshooting guides

---

## **Supported D365 Modules**

| Module | Status | Examples |
|--------|--------|----------|
| **Sales** | ✅ Full | Order Mgmt, Pipeline, Quotes |
| **Service** | ✅ Full | Cases, KB, SLAs |
| **Field Service** | ✅ Full | Work Orders, Scheduling |
| **Project Ops** | ✅ Full | Projects, Resources, Billing |
| **Finance** | ✅ Full | GL, AP/AR, Budgets |
| **HR** | ✅ Full | Leave, Payroll, Recruitment |
| **Marketing** | ✅ Full | Campaigns, Leads, Scoring |
| **Supply Chain** | ✅ Full | Inventory, Procurement |
| **Commerce** | ✅ Full | Orders, Catalog, Pricing |

---

## **Error Handling & GitHub Integration**

### **Known Issues Tracked**

See `error-logs/WEBRESOURCE_ISSUES.md` for:
- WebResource import failures
- Solution packaging errors
- Plugin compilation issues
- Flow deployment problems

Reference: https://github.com/microsoft/powerplatform-build-tools/discussions

### **How Errors Are Handled**

1. ❌ Error occurs during execution
2. 📝 Error logged with full context
3. 🔍 Check against known issues database
4. 💡 Suggest fix automatically
5. 🔗 Reference GitHub issue if applicable
6. 💾 Save to `error-logs/` for review
7. 📊 Generate report for troubleshooting

---

## **Configuration**

### **Copy config template**
```bash
cp config/.env.example config/.env
```

### **Edit with your details**
```env
# Power Platform
POWER_PLATFORM_URL=https://yourorg.crm.dynamics.com
POWER_PLATFORM_USERNAME=you@company.com
POWER_PLATFORM_PASSWORD=your-password

# GitHub
GITHUB_TOKEN=your-token
GITHUB_ORG=yourorg
GITHUB_REPO=jarvis-crm-autopilot

# Claude API
CLAUDE_API_KEY=your-key
```

---

## **Usage Examples**

### **Example 1: Sales Order System**
```bash
node scripts/jarvis-prompt.js "Build Sales Order system with:
- Customer, Product, Order tables
- Auto-calculate totals
- Send confirmation emails
- 3-stage approval workflow"
```

**Result:** Complete system live in 45 minutes ✅

### **Example 2: HR Leave Management**
```bash
node scripts/jarvis-prompt.js "Build employee leave system:
- Employee table with departments
- Leave Request table
- Auto-approve if < 2 days
- Notify manager if > 2 days
- Update leave balance automatically"
```

**Result:** Complete system live in 35 minutes ✅

### **Example 3: Customer Service Cases**
```bash
node scripts/jarvis-prompt.js "Build case management system:
- Case table with priority/status
- Auto-assign to available agents
- Escalate if unresolved > 24 hours
- Send SLA breach notifications
- Track resolution time"
```

**Result:** Complete system live in 60 minutes ✅

---

## **Error Reference: WebResource Issue**

**Error:** `WebResource name = trial_completeisequestionnaire_main: Part URI must start with a forward slash`

**Cause:** Web resource path doesn't start with `/`

**Solution:** See `error-logs/WEBRESOURCE_ISSUES.md`

**Fix Applied:** JARVIS automatically corrects this in solution generation

---

## **Contributing**

See `docs/CONTRIBUTING.md` for:
- How to add new templates
- How to extend generators
- How to report issues
- How to request features

---

## **Support**

- 📖 **Documentation:** See `docs/` folder
- 🐛 **Issues:** Report in GitHub Discussions
- 💬 **Questions:** Check `docs/FAQ.md`
- 📞 **Contact:** support@jarvis-crm.dev

---

## **License**

MIT License - See LICENSE file

---

## **Roadmap**

### **v1.0 (Current)**
- ✅ Table generation
- ✅ Plugin auto-code
- ✅ Flow creation
- ✅ Solution packaging
- ✅ Git integration

### **v1.1 (Q1 2025)**
- 📅 Power Pages auto-generation
- 📅 Advanced AI reasoning
- 📅 Dashboard UI
- 📅 Performance optimization

### **v2.0 (Q2 2025)**
- 📅 ML model integration
- 📅 Natural language flow design
- 📅 Multi-org management
- 📅 Self-healing automation

---

**Built with ❤️ by the JARVIS Team**

*Making Power Platform accessible to everyone, one prompt at a time.*
