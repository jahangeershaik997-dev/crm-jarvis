# JARVIS Architecture & Design

**Complete technical specification for the CRM Autopilot Platform**

---

## **System Overview**

JARVIS is a multi-layered AI-powered automation platform that converts natural language requirements into production-ready Power Platform solutions.

```
┌──────────────────────────────────────────────────────────┐
│                 USER INPUT LAYER                         │
│  "Build Sales Order system with auto-totals"            │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│              AI ANALYSIS LAYER (Claude API)              │
│  • Parse requirements                                    │
│  • Extract entities & relationships                      │
│  • Identify business rules                              │
│  • Design database schema                               │
│  • Plan plugin architecture                             │
│  • Suggest flow workflows                               │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│           SPECIFICATION GENERATION LAYER                 │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ schema-generator.js    → table definitions      │ │
│  │ plugin-generator.js    → C# plugin code         │ │
│  │ flow-generator.js      → Power Automate flows   │ │
│  │ page-generator.js      → Power Pages            │ │
│  │ test-generator.js      → test suites            │ │
│  └─────────────────────────────────────────────────────┘ │
│           ↓                                               │
│  Output: JSON specs + code files                         │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│         VALIDATION & QUALITY ASSURANCE LAYER            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ schema-validator.js      → Table validity       │ │
│  │ plugin-validator.js      → Code quality         │ │
│  │ dependency-checker.js    → Relationship check   │ │
│  │ security-analyzer.js     → Security review      │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│        EXECUTION LAYER (Power Platform Integration)      │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ power-platform-client.js → CLI wrapper         │ │
│  │ table-creator.js         → Create tables       │ │
│  │ plugin-compiler.js       → Compile C#          │ │
│  │ plugin-registrar.js      → Register plugins    │ │
│  │ flow-deployer.js         → Deploy flows        │ │
│  │ solution-packager.js     → Create .zip files   │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│         TESTING & VERIFICATION LAYER                     │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ unit-tests.js            → Plugin logic         │ │
│  │ integration-tests.js     → End-to-end flows     │ │
│  │ smoke-tests.js           → Basic functionality  │ │
│  │ performance-tests.js     → Load & speed         │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│      DEPLOYMENT & CI/CD LAYER (GitHub Actions)          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ Dev Environment      → Deploy & Test           │ │
│  │ Test Environment     → Run full test suite     │ │
│  │ Production Environment → Final deployment      │ │
│  │ Monitoring           → Alerts & logging        │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────┐
│                 OUTPUT                                    │
│  ✅ Live Dataverse system                               │
│  ✅ GitHub repository with version history              │
│  ✅ Automated documentation                             │
│  ✅ Deployment logs & monitoring                        │
│  ✅ Error reports & fixes                               │
└──────────────────────────────────────────────────────────┘
```

---

## **Core Components**

### **1. AI Analysis Engine**

**File:** `src/ai-engine/claude-integration.js`

**Responsibility:** Parse natural language and generate specifications

**Process:**

```javascript
class AIAnalysisEngine {
  async analyzeRequirement(userPrompt) {
    // Step 1: Send prompt to Claude API
    const analysis = await claudeAPI.analyze(userPrompt);
    
    // Step 2: Extract entities
    const entities = extractEntities(analysis);
    // Example: ["Customer", "Order", "Product"]
    
    // Step 3: Identify relationships
    const relationships = identifyRelationships(entities);
    // Example: Order has many Products, Order has one Customer
    
    // Step 4: Extract business rules
    const businessRules = extractBusinessRules(analysis);
    // Example: "Auto-approve if total < $5000"
    
    // Step 5: Design schema
    const schema = designDatabaseSchema(entities, relationships);
    
    // Step 6: Plan plugins
    const plugins = planPlugins(businessRules);
    
    // Step 7: Design flows
    const flows = designFlows(businessRules);
    
    // Return complete spec
    return {
      entities,
      relationships,
      businessRules,
      schema,
      plugins,
      flows
    };
  }
}
```

**Output:** JSON specification file

---

### **2. Code Generators**

**Directory:** `src/generators/`

#### **2.1 Schema Generator**

**File:** `schema-generator.js`

Generates Dataverse table definitions

```javascript
class SchemaGenerator {
  generateTableDefinitions(schema) {
    const tables = schema.entities.map(entity => ({
      logicalName: camelCase(entity.name),
      displayName: entity.name,
      pluralName: pluralize(entity.name),
      columns: entity.attributes.map(attr => ({
        logicalName: camelCase(attr.name),
        displayName: attr.name,
        type: attr.type, // Text, Number, DateTime, Lookup, etc.
        required: attr.required,
        maxLength: attr.maxLength,
        format: attr.format
      })),
      keys: entity.keys,
      descriptions: entity.description
    }));
    
    return generateXML(tables); // output: solution.xml
  }
}
```

#### **2.2 Plugin Generator**

**File:** `plugin-generator.js`

Auto-generates C# plugin code

```csharp
public class AutoCalculateOrderTotal : IPlugin
{
    // JARVIS generates ALL of this automatically
    // Based on business rule: "Sum line items → Update total"
    
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider
            .GetService(typeof(IPluginExecutionContext));
        var factory = (IOrganizationServiceFactory)serviceProvider
            .GetService(typeof(IOrganizationServiceFactory));
        var service = factory.CreateOrganizationService(context.UserId);
        var trace = (ITracingService)serviceProvider
            .GetService(typeof(ITracingService));

        try
        {
            trace.Trace("AutoCalculateOrderTotal plugin started");
            
            var order = (Entity)context.InputParameterCollection["Target"];
            var lineItems = FetchOrderLineItems(order.Id, service);
            
            decimal total = 0;
            foreach (var item in lineItems)
            {
                total += item.GetAttributeValue<decimal>("price") * 
                        item.GetAttributeValue<int>("quantity");
            }
            
            order["totalamount"] = total;
            trace.Trace($"Order total calculated: {total}");
        }
        catch (Exception ex)
        {
            trace.Trace($"Error: {ex.Message}");
            throw new InvalidPluginExecutionException(ex.Message, ex);
        }
    }
    
    private List<Entity> FetchOrderLineItems(Guid orderId, IOrganizationService service)
    {
        var query = new QueryExpression("orderdetail")
        {
            ColumnSet = new ColumnSet("price", "quantity")
        };
        query.Criteria.AddCondition("orderid", ConditionOperator.Equal, orderId);
        
        var results = service.RetrieveMultiple(query);
        return results.Entities.ToList();
    }
}
```

#### **2.3 Flow Generator**

**File:** `flow-generator.js`

Generates Power Automate flow definitions

```javascript
class FlowGenerator {
  generateFlow(businessRule) {
    // Input: "Send email when order approved"
    // Output: Power Automate flow JSON
    
    const flow = {
      name: "SendOrderApprovalEmail",
      trigger: {
        type: "When record is updated",
        entity: "order",
        condition: "status = Approved"
      },
      actions: [
        {
          type: "GetRecord",
          entity: "order"
        },
        {
          type: "SendEmail",
          to: "@{triggerOutput.customerEmail}",
          subject: "Order Approved",
          body: "Your order has been approved..."
        }
      ]
    };
    
    return flow;
  }
}
```

---

### **3. Executor Layer**

**Directory:** `src/executor/`

Manages actual deployment to Power Platform

#### **3.1 Table Creator**

```javascript
class TableCreator {
  async createTables(schema) {
    for (const table of schema.tables) {
      // 1. Create table
      await executeCLI(`pac data create-table 
        --logicalname ${table.logicalName}
        --displayname "${table.displayName}"`);
      
      // 2. Create columns
      for (const column of table.columns) {
        await executeCLI(`pac data create-column
          --tablename ${table.logicalName}
          --logicalname ${column.logicalName}
          --type ${column.type}`);
      }
      
      console.log(`✅ Table created: ${table.displayName}`);
    }
  }
}
```

#### **3.2 Plugin Compiler & Registrar**

```powershell
# scripts/Compile-Plugins.ps1
dotnet build plugins/YourProject.sln --configuration Release

# Outputs: bin/Release/YourProject.dll

# scripts/Register-Plugins.ps1
$assemblyId = pac plugin register --path bin/Release/YourProject.dll

pac plugin register-step `
  --plugin-id $assemblyId `
  --plugin-type "Namespace.ClassName" `
  --entity "tablename" `
  --message "Create" `
  --stage "PreOperation"
```

---

### **4. Validation & QA Layer**

**Directory:** `src/validator/`

Pre-deployment checks

```javascript
class PreDeploymentValidator {
  async validate(solution) {
    const checks = [
      this.validateSchema(),
      this.validatePlugins(),
      this.validateFlows(),
      this.validateDependencies(),
      this.validateSecurity(),
      this.checkMicrosoftKnownIssues()
    ];
    
    const results = await Promise.all(checks);
    
    if (results.some(r => r.failed)) {
      throw new Error("Validation failed - see issues above");
    }
    
    return true;
  }
  
  async checkMicrosoftKnownIssues() {
    // Reference: github.com/microsoft/powerplatform-build-tools/discussions
    
    const knownIssues = [
      {
        pattern: "WebResource URI must start with /",
        check: () => this.validateWebResourcePaths(),
        fix: () => this.addLeadingSlash()
      },
      {
        pattern: "Solution version format must be X.Y.Z.B",
        check: () => this.validateVersionFormat(),
        fix: () => this.correctVersionFormat()
      },
      // ... more checks
    ];
    
    for (const issue of knownIssues) {
      if (!issue.check()) {
        console.warn(`⚠️ Known issue detected: ${issue.pattern}`);
        issue.fix();
        console.log(`✅ Auto-fixed`);
      }
    }
  }
}
```

---

### **5. Testing Layer**

**Directory:** `tests/`

Automated test suites

```javascript
describe('Order Auto-Total Plugin', () => {
  
  test('should calculate total from line items', async () => {
    // Arrange
    const order = {
      id: '12345',
      lineItems: [
        { price: 100, quantity: 2 },
        { price: 50, quantity: 1 }
      ]
    };
    
    // Act
    const plugin = new AutoCalculateOrderTotal();
    const result = plugin.calculate(order);
    
    // Assert
    expect(result.total).toBe(250); // (100*2) + (50*1)
  });
  
  test('should handle zero line items', () => {
    const order = { id: '12345', lineItems: [] };
    const result = plugin.calculate(order);
    expect(result.total).toBe(0);
  });
  
  test('should throw on invalid data', () => {
    expect(() => plugin.calculate(null))
      .toThrow("Order cannot be null");
  });
});
```

---

### **6. Deployment & CI/CD Layer**

**Directory:** `.github/workflows/`

GitHub Actions automation

**Flow:**

```
Code Push
  ↓
GitHub Actions Triggered
  ↓
Validate Code
  ↓
Compile Plugins
  ↓
Run Unit Tests
  ↓
Deploy to Dev
  ↓
Run Integration Tests
  ↓
Deploy to Test
  ↓
Run Full Test Suite
  ↓
Deploy to Production
  ↓
Monitor & Alert
```

---

## **Data Flow Examples**

### **Example 1: Auto-Calculate Order Total**

**User Prompt:**
```
"Auto-calculate order total when items added"
```

**Flow:**

```
1. AI Analysis
   Input: "Auto-calculate order total when items added"
   → Identifies: Order table, calculation rule, trigger event
   → Outputs: JSON spec with plugin requirement

2. Code Generation
   Input: JSON spec with calculation rule
   → Generates: C# plugin code
   → Outputs: AutoCalculateOrderTotal.cs

3. Compilation
   Input: C# source code
   → dotnet build
   → Outputs: AutoCalculateOrderTotal.dll

4. Registration
   Input: Plugin DLL
   → Register in Dataverse
   → Set trigger: Order.Create, Order.Update
   → Outputs: Plugin ID, Step ID

5. Testing
   Input: Plugin registration
   → Create test order
   → Add line items
   → Verify total calculated
   → Outputs: Test report

6. Deployment
   Input: Verified plugin
   → Package into solution.zip
   → Deploy to environments
   → Outputs: Live system
```

---

## **Error Handling Architecture**

### **Error Tracking Flow**

```
Error Occurs
  ↓
Log with context (timestamp, component, stack trace)
  ↓
Check against known issues (Microsoft references)
  ↓
Apply auto-fix if available
  ↓
If unknown: Create GitHub issue
  ↓
Learn from error (add to KB)
  ↓
Prevent in future
```

### **Known Issues Database**

File: `error-logs/known-issues.json`

```json
{
  "issues": [
    {
      "id": "WEBRESOURCE_URI_ERROR",
      "pattern": "Part URI must start with a forward slash",
      "component": "solution-generator",
      "fix": "Add leading '/' to URI paths",
      "autoFixable": true,
      "reference": "https://github.com/microsoft/powerplatform-build-tools/discussions",
      "occurrences": 3,
      "lastSeen": "2024-12-15T10:30:00Z"
    }
  ]
}
```

---

## **Performance Considerations**

### **Timeline Estimates**

| Component | Time |
|-----------|------|
| AI Analysis | 2-5 min |
| Code Generation | 5-15 min |
| Compilation | 1-3 min |
| Deployment | 5-10 min |
| Testing | 2-5 min |
| **Total** | **15-38 min** |

### **Optimization**

```javascript
class PerformanceOptimizer {
  // Parallel execution where possible
  async optimizedDeploy(components) {
    return Promise.all([
      this.createTables(components.schema),
      this.compilePlugins(components.plugins),
      this.generateFlows(components.flows)
    ]);
  }
}
```

---

## **Security Considerations**

### **Data Protection**

- ✅ Credentials stored in GitHub Secrets (encrypted)
- ✅ API keys never logged
- ✅ Sensitive data masked in error logs
- ✅ HTTPS for all API calls
- ✅ Service Principal for automation (not personal accounts)

### **Access Control**

- ✅ GitHub branch protection (require PR reviews)
- ✅ Approval workflows for prod deployment
- ✅ Audit logs for all changes
- ✅ Role-based access in Power Platform

---

## **Scalability**

JARVIS can handle:

- ✅ Multiple simultaneous deployments
- ✅ Large solutions (100+ tables)
- ✅ Complex plugin logic
- ✅ Multi-organization management
- ✅ High-frequency updates (daily releases)

---

**Last Updated:** 2024-12-15
**Version:** 1.0.0
**Status:** Production Ready ✅
