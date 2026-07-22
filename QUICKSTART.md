# 🚀 JARVIS Quick Start Guide

**Build your first automated D365/Dataverse system in 60 minutes**

---

## **Pre-Requirements (5 minutes)**

### **1. Install Tools**

```bash
# Power Platform CLI
npm install -g @microsoft/powerplatform-cli

# .NET SDK (for plugin compilation)
# Download from: https://dotnet.microsoft.com/download

# Git
# Download from: https://git-scm.com/download

# Verify installations
pac --version
dotnet --version
git --version
```

### **2. Clone JARVIS Repository**

```bash
git clone https://github.com/yourorg/jarvis-crm-autopilot.git
cd jarvis-crm-autopilot
npm install
```

### **3. Configure Power Platform**

```bash
# Create .env file
cp config/.env.example config/.env

# Edit with your details
nano config/.env
```

**Required in .env:**
```env
POWER_PLATFORM_URL=https://yourorg.crm.dynamics.com
POWER_PLATFORM_USERNAME=you@company.com
POWER_PLATFORM_PASSWORD=your-password
GITHUB_TOKEN=your-github-token
```

### **4. Authenticate**

```bash
pac auth create \
  --url https://yourorg.crm.dynamics.com \
  --username you@company.com

# Enter password when prompted
```

---

## **Your First System: Sales Order Management (30-45 minutes)**

### **Step 1: Give Your Requirement (2 minutes)**

Open terminal and run:

```bash
node scripts/jarvis-prompt.js
```

**Copy-paste this requirement:**

```
Build a Sales Order Management system with:

TABLES:
1. Customer (name, email, phone, credit_limit, status)
2. Product (SKU, price, category, inventory)
3. Order (order_number, customer lookup, order_date, status, total_amount)
4. OrderLineItem (order lookup, product lookup, quantity, unit_price, line_total)

AUTOMATION:
1. Auto-calculate OrderLineItem.line_total (unit_price × quantity)
2. Auto-calculate Order.total_amount (sum of all line items)
3. Auto-approve order if total < $5,000
4. For orders > $5,000, require manager approval (send email notification)
5. When order approved, create invoice record
6. Send confirmation email to customer

BUSINESS RULES:
- Cannot create order without customer
- Cannot exceed customer credit limit
- Cannot submit order without line items
- Automatically update inventory when order shipped

WORKFLOWS:
- Order submission flow:
  1. Submit → Auto-validation → Auto-approve OR Pending approval
  2. Approved → Create invoice → Send confirmation
  3. Ready to ship → Create shipment record
```

---

### **Step 2: JARVIS Analyzes (5 minutes)**

JARVIS will:

✅ Parse your requirements
✅ Design database schema
✅ Plan plugin architecture
✅ Generate C# code
✅ Design flows
✅ Create test cases
✅ Generate deployment scripts

**Watch the console output:**

```
📊 Analyzing requirement...
✅ Identified 4 tables
✅ Identified 7 business rules
✅ Planned 5 plugins
✅ Planned 3 flows

🔧 Generating code...
✅ Schema generated
✅ Plugins generated (5 files)
✅ Flows generated
✅ Tests generated

📝 Generating documentation...
✅ API reference created
✅ Deployment guide created
✅ Troubleshooting guide created
```

---

### **Step 3: Validation (5 minutes)**

JARVIS automatically validates everything:

```bash
✅ Checking schema for errors...
✅ Validating plugin syntax...
✅ Checking for Microsoft known issues...
✅ Verifying dependencies...
✅ Running security checks...

All checks passed! ✅
```

---

### **Step 4: Execute Deployment (15-20 minutes)**

JARVIS deploys to your environment:

```bash
🚀 Starting deployment...

[1/5] Creating tables in Dataverse...
  ✅ Customer table created
  ✅ Product table created
  ✅ Order table created
  ✅ OrderLineItem table created

[2/5] Compiling plugins...
  ✅ AutoCalculateLineTotal compiled
  ✅ AutoCalculateOrderTotal compiled
  ✅ AutoApproveSmallOrders compiled
  ✅ NotifyManagerForApproval compiled
  ✅ CreateInvoiceOnApproval compiled

[3/5] Registering plugins in Dataverse...
  ✅ AutoCalculateLineTotal registered
  ✅ AutoCalculateOrderTotal registered
  ✅ AutoApproveSmallOrders registered
  ✅ NotifyManagerForApproval registered
  ✅ CreateInvoiceOnApproval registered

[4/5] Deploying Power Automate flows...
  ✅ SendOrderConfirmation deployed
  ✅ NotifyManagerApproval deployed
  ✅ CreateShipment deployed

[5/5] Running automated tests...
  ✅ Unit tests passed (23/23)
  ✅ Integration tests passed (15/15)
  ✅ End-to-end tests passed (8/8)

✨ Deployment complete! ✨
```

---

### **Step 5: Verification (3-5 minutes)**

Test your live system:

**Option A: Manual Testing**

1. Go to: `https://make.powerapps.com`
2. Select your environment
3. Create test data:
   - Create Customer: "Acme Corp"
   - Create Product: "Widget", Price: $100
   - Create Order: Link to customer
   - Create OrderLineItem: 5 widgets at $100 = $500

4. Verify automation:
   - ✅ Line total auto-calculated: $500
   - ✅ Order total auto-calculated: $500
   - ✅ Order auto-approved (< $5k)
   - ✅ Email sent to customer

**Option B: Run JARVIS Tests**

```bash
npm run test

# Output
PASS  tests/unit/CalculateOrderTotal.test.js
PASS  tests/integration/OrderFlow.test.js
PASS  tests/e2e/CompleteSalesProcess.test.js

Test Summary: 46 passed, 0 failed
Coverage: 98%
```

---

## **System Live! 🎉**

Your Sales Order Management system is now:

```
✅ Running in Dataverse
✅ Fully automated (no manual intervention)
✅ Version controlled in Git
✅ Monitored & logged
✅ Production-ready
✅ Documented
✅ Tested
```

---

## **What Just Happened?**

```
BEFORE JARVIS:
├─ Design tables: 2-4 hours
├─ Write plugin code: 4-8 hours
├─ Create flows: 2-4 hours
├─ Manual testing: 4-8 hours
├─ Documentation: 2-3 hours
└─ TOTAL: 14-27 hours 😴

WITH JARVIS:
├─ Give prompt: 5 minutes
├─ JARVIS does everything: 45 minutes
└─ TOTAL: 50 minutes 🚀

SAVINGS: 94% time reduction ⚡
```

---

## **Next Steps**

### **Option 1: Deploy to Production**

```bash
# All testing passed, now deploy to production
git push origin main

# GitHub Actions automatically:
# 1. Runs full test suite
# 2. Deploys to Test environment
# 3. Runs production tests
# 4. Deploys to Production environment
# 5. Monitors for issues

# You get email notification when complete ✅
```

### **Option 2: Enhance Your System**

Give JARVIS another prompt:

```bash
node scripts/jarvis-prompt.js

# New prompt: "Add customer discount tiers:
# - Gold customers: 10% discount
# - Silver customers: 5% discount
# - Bronze customers: no discount
# Auto-apply discount based on customer tier"
```

**Result:** JARVIS adds:
- ✅ Customer tier column
- ✅ Discount calculation logic
- ✅ Tests for discount scenarios
- ✅ Deploys to production

**Time:** 20 minutes ⚡

### **Option 3: Build Another System**

```bash
node scripts/jarvis-prompt.js

# New prompt: "Build HR Leave Management system:
# - Employee table
# - Leave Request table
# - Leave Balance tracking
# - Auto-approve if < 2 days
# - Notify manager if > 2 days
# - Update leave balance"
```

**Result:** Complete HR system in 45 minutes ✅

---

## **Understanding What JARVIS Created**

### **File Structure**

```
jarvis-crm-autopilot/
├── solutions/SalesOrderSystem/  ← Your system
│   ├── Tables/                  ← Table definitions
│   │   ├── Customer.json
│   │   ├── Product.json
│   │   ├── Order.json
│   │   └── OrderLineItem.json
│   ├── Plugins/                 ← C# plugin code
│   │   ├── AutoCalculateLineTotal.cs
│   │   ├── AutoCalculateOrderTotal.cs
│   │   ├── AutoApproveSmallOrders.cs
│   │   ├── NotifyManagerForApproval.cs
│   │   └── CreateInvoiceOnApproval.cs
│   ├── Flows/                   ← Power Automate definitions
│   │   ├── SendOrderConfirmation.json
│   │   ├── NotifyManagerApproval.json
│   │   └── CreateShipment.json
│   ├── Tests/                   ← Test cases
│   │   ├── PluginTests.cs
│   │   ├── IntegrationTests.js
│   │   └── E2ETests.js
│   └── solution.xml             ← Solution package definition
├── error-logs/                  ← Auto-logged errors
│   └── 2024-12-deployment.json
└── docs/                        ← Auto-generated docs
    ├── SalesOrderSystem.md      ← System documentation
    ├── API_REFERENCE.md         ← API docs
    └── DEPLOYMENT_LOG.md        ← What was deployed
```

### **How It Works**

```
1️⃣  Tables (Dataverse Schema)
    ↓
2️⃣  Plugins (C# code for business logic)
    ↓
3️⃣  Flows (Power Automate for notifications)
    ↓
4️⃣  Tests (Automated quality assurance)
    ↓
5️⃣  Documentation (Auto-generated guides)
    ↓
6️⃣  Deployment (Git + CI/CD)
    ↓
7️⃣  Monitoring (Logs + alerts)
```

---

## **Troubleshooting**

### **Issue: Authentication Failed**

```bash
Error: Authentication failed: Invalid credentials

Solution:
1. Check username is correct
2. Check password is correct
3. Verify environment URL is correct
4. Use: pac auth clear
5. Try: pac auth create again
```

### **Issue: Table Already Exists**

```bash
Error: Table 'Customer' already exists

Solution:
# Option 1: Use different environment
pac auth create --url https://different-org.crm.dynamics.com

# Option 2: Delete existing table and retry
# (via Power Platform UI)

# Option 3: Update table instead of creating
# JARVIS will detect and update automatically
```

### **Issue: Plugin Compilation Failed**

```bash
Error: Build failed: CS0246 'namespace' not found

Solution:
1. Check .NET SDK version: dotnet --version
2. Restore packages: dotnet restore
3. Try compilation again: dotnet build
4. See error-logs/ for details
```

### **Issue: Deployment Timeout**

```bash
Error: Deployment timeout after 60 seconds

Solution:
# Increase timeout in deploy.ps1
$timeout = 300  # 5 minutes

# Or manually deploy:
pac solution import --path solution.zip --wait
```

---

## **Key Resources**

| Resource | URL |
|----------|-----|
| **Full Docs** | `docs/ARCHITECTURE.md` |
| **Error Reference** | `error-logs/WEBRESOURCE_ISSUES.md` |
| **GitHub Integration** | `docs/GITHUB_INTEGRATION.md` |
| **Troubleshooting** | `docs/TROUBLESHOOTING.md` |
| **API Reference** | `docs/API_REFERENCE.md` |
| **Examples** | `examples/` folder |

---

## **Support**

### **📖 Documentation**
See `docs/` folder for comprehensive guides

### **🐛 Report Issues**
GitHub Discussions: https://github.com/microsoft/powerplatform-build-tools/discussions

### **💬 FAQ**
See `docs/FAQ.md`

### **📧 Contact**
support@jarvis-crm.dev

---

## **Congratulations! 🎉**

You've successfully built your first production system with JARVIS!

**What's Next?**

1. ✅ **Celebrate** - You saved 20+ hours
2. ✅ **Enhance** - Add more features with new prompts
3. ✅ **Share** - Show your team how fast you built it
4. ✅ **Repeat** - Build more systems for other modules
5. ✅ **Scale** - Use JARVIS for all future projects

---

**Happy Building! 🚀**

*Building Power Platform solutions, one prompt at a time.*
