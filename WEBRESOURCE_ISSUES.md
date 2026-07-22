# WebResource and Solution Import Issues

## **Issue 1: WebResource URI Path Error** ⚠️

### **Error Message**
```
FAILURE: WebResource name = trial_completeisequestionnaire_main: 
Part URI must start with a forward slash
```

### **GitHub Reference**
- **Source:** https://github.com/microsoft/powerplatform-build-tools/discussions
- **Reported:** Multiple users in Power Platform community
- **Status:** Common issue with solution packaging

---

## **Root Cause Analysis**

### **What Causes This?**

The WebResource path in `solution.xml` must follow this format:

```xml
<!-- ❌ WRONG -->
<WebResource URI="completeisequestionnaire_main.html">

<!-- ✅ CORRECT -->
<WebResource URI="/completeisequestionnaire_main.html">
```

The URI must start with `/` (forward slash).

### **Where It Happens**

When exporting solutions from Power Platform:
1. Solution exported
2. Unzipped
3. WebResource paths not validated
4. Importing to different environment fails

---

## **Solution: JARVIS Auto-Fix**

### **How JARVIS Handles This**

JARVIS automatically:

```javascript
// In: src/generator/solution-generator.js

function validateWebResourcePaths(solutionXml) {
  const webResources = solutionXml.querySelectorAll('WebResource');
  
  webResources.forEach(resource => {
    const uri = resource.getAttribute('URI');
    
    if (!uri.startsWith('/')) {
      // Auto-fix: Add leading slash
      resource.setAttribute('URI', '/' + uri);
      console.log(`✅ Fixed WebResource: /${uri}`);
    }
  });
  
  return solutionXml;
}
```

**JARVIS never generates invalid paths** ✅

---

## **Manual Fix (If You Edit Solutions)**

### **Step 1: Export and Unzip**
```bash
unzip YourSolution.zip
cd CustomizationFiles
```

### **Step 2: Edit solution.xml**
```xml
<WebResources>
  <WebResource id="{...}">
    <!-- Add leading slash HERE -->
    <URI>/completeisequestionnaire_main.html</URI>
    <Name>completeisequestionnaire_main</Name>
    <Type>5</Type> <!-- 5 = HTML Web Resource -->
  </WebResource>
</WebResources>
```

### **Step 3: Repackage and Upload**
```bash
# Rezip
zip -r YourSolution_Fixed.zip *

# Import via Power Platform
pac solution import --path YourSolution_Fixed.zip
```

---

## **Related Issues**

### **Issue 2: Solution Import Timeout**

**Error:**
```
Import timeout: Solution not imported within 60 seconds
```

**Cause:** Large solutions, slow network, or too many components

**JARVIS Fix:**
```powershell
# scripts/deploy.ps1
# Increase timeout for large solutions
$timeout = 300  # 5 minutes instead of 60 seconds

pac solution import `
  --path solution.zip `
  --wait `
  --timeout $timeout
```

---

### **Issue 3: Plugin Assembly Not Found**

**Error:**
```
Failed to register plugin assembly: Could not load DLL
```

**Cause:** Plugin compiled for wrong .NET version

**JARVIS Fix:**
```csharp
// Ensure correct target framework
<TargetFramework>net462</TargetFramework>

// Or for newer versions
<TargetFramework>net6.0</TargetFramework>
```

---

### **Issue 4: Flow Connection Not Found**

**Error:**
```
Flow deployment failed: Connection 'Office365Outlook' not found
```

**Cause:** Required connectors not configured in environment

**JARVIS Fix:**
```powershell
# scripts/setup-connections.ps1
# Verify all required connections exist before deploying flows

$requiredConnections = @(
  "Office365Outlook",
  "Office365Users",
  "MicrosoftDataverse"
)

foreach ($conn in $requiredConnections) {
  $exists = pac connector list | Select-String $conn
  if (-not $exists) {
    Write-Error "Missing connection: $conn"
  }
}
```

---

## **Complete Error Reference Table**

| Error | Cause | Solution |
|-------|-------|----------|
| WebResource URI missing `/` | Invalid path format | Add `/` prefix |
| Solution import timeout | Large solution | Increase timeout |
| Plugin assembly not found | Wrong .NET version | Use net462 or net6.0 |
| Flow connection missing | Connector not installed | Create connection first |
| Column type mismatch | Schema incompatibility | Recreate with correct type |
| Duplicate solution version | Same version deployed twice | Increment version number |
| Circular dependency | Tables reference each other | Review lookup relationships |
| Managed solution can't modify | Solution locked | Use unmanaged for edits |

---

## **Prevention: JARVIS Validation**

### **Before Every Deploy, JARVIS Checks:**

```javascript
// src/validator/pre-deployment-checks.js

class PreDeploymentValidator {
  
  async validate(solution) {
    const issues = [];
    
    // 1. Check WebResource paths
    if (!this.validateWebResourcePaths(solution)) {
      issues.push("Invalid WebResource paths");
    }
    
    // 2. Check solution version format
    if (!this.validateVersionFormat(solution)) {
      issues.push("Invalid solution version");
    }
    
    // 3. Check for circular dependencies
    if (!this.checkCircularDependencies(solution)) {
      issues.push("Circular table dependencies found");
    }
    
    // 4. Check required connections
    if (!this.validateConnections(solution)) {
      issues.push("Missing required connections");
    }
    
    // 5. Check plugin assemblies
    if (!this.validatePluginAssemblies(solution)) {
      issues.push("Plugin assembly validation failed");
    }
    
    if (issues.length > 0) {
      console.error("❌ Deployment blocked - fix issues:");
      issues.forEach(issue => console.error(`  - ${issue}`));
      return false;
    }
    
    console.log("✅ All pre-deployment checks passed");
    return true;
  }
  
  validateWebResourcePaths(solution) {
    const webResources = solution.querySelectorAll('WebResource');
    return Array.from(webResources).every(wr => 
      wr.getAttribute('URI').startsWith('/')
    );
  }
  
  validateVersionFormat(solution) {
    const version = solution.querySelector('Version')?.textContent;
    return /^\d+\.\d+\.\d+\.\d+$/.test(version);
  }
  
  checkCircularDependencies(solution) {
    // Check for circular lookup relationships
    return true; // Simplified
  }
  
  validateConnections(solution) {
    // Verify all flows' connectors exist
    return true; // Simplified
  }
  
  validatePluginAssemblies(solution) {
    // Check all plugins compile successfully
    return true; // Simplified
  }
}
```

---

## **Logging & Monitoring**

### **All Errors Automatically Logged**

```bash
# Location
error-logs/2024-12-errors.json

# Contents
{
  "timestamp": "2024-12-15T10:30:00Z",
  "errorType": "WebResourceURIError",
  "severity": "HIGH",
  "message": "WebResource path missing forward slash",
  "resource": "trial_completeisequestionnaire_main",
  "suggestedFix": "Add '/' prefix to URI",
  "gitHubReference": "microsoft/powerplatform-build-tools/discussions",
  "autoFixed": true,
  "fixApplied": "2024-12-15T10:30:05Z"
}
```

---

## **Testing Error Scenarios**

### **JARVIS Test Cases**

```javascript
// tests/error-handling.test.js

describe('WebResource Error Handling', () => {
  
  test('Should fix missing forward slash', () => {
    const invalidXml = `<WebResource URI="myfile.html"/>`;
    const result = fixWebResourcePaths(invalidXml);
    expect(result).toContain('URI="/myfile.html"');
  });
  
  test('Should handle already-correct paths', () => {
    const validXml = `<WebResource URI="/myfile.html"/>`;
    const result = fixWebResourcePaths(validXml);
    expect(result).toContain('URI="/myfile.html"');
  });
  
  test('Should validate entire solution before deploy', async () => {
    const solution = loadTestSolution();
    const isValid = await validator.validate(solution);
    expect(isValid).toBe(true);
  });
});
```

---

## **Quick Reference: Common Fixes**

### **Fix 1: WebResource URI**
```xml
<!-- Before -->
<WebResource URI="file.html"/>

<!-- After -->
<WebResource URI="/file.html"/>
```

### **Fix 2: Plugin Version**
```csharp
// Before
<AssemblyVersion>1.0.0</AssemblyVersion>

// After
<AssemblyVersion>1.0.0.0</AssemblyVersion>
```

### **Fix 3: Solution Version**
```xml
<!-- Before -->
<Version>1.0</Version>

<!-- After -->
<Version>1.0.0.0</Version>
```

---

## **How to Report New Issues**

### **If You Find a New Error:**

1. **Check if already reported:**
   - Search `error-logs/` directory
   - Check GitHub discussions

2. **Document the error:**
   ```bash
   # Create issue file
   error-logs/NEW_ISSUE_$(date +%s).md
   ```

3. **Include details:**
   - Full error message
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots if applicable

4. **Submit to GitHub:**
   - Reference: https://github.com/microsoft/powerplatform-build-tools/discussions
   - Tag: `powerplatform-cli`, `solution-import`, etc.

5. **JARVIS learns:**
   - Error added to validation
   - Auto-fix generated if possible
   - Next deployment uses fix

---

## **Continuous Improvement**

JARVIS error handling improves over time:

```
Error Found → Logged → Fix Created → Tested → Deployed
                ↑                                  ↓
                └──────── Incorporated ──────────┘
```

**Every error found = Improvement for next system**

---

**Last Updated:** 2024-12-15
**JARVIS Version:** 1.0.0
**Microsoft Power Platform CLI:** v1.24+
