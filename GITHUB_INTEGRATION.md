# GitHub Integration for JARVIS

**Complete GitHub workflow for tracking, versioning, and continuous integration**

---

## **Overview**

JARVIS integrates with GitHub to:

✅ Store solution code & configs
✅ Track errors & issues
✅ Reference Microsoft Power Platform discussions
✅ Manage CI/CD pipelines
✅ Version control all systems
✅ Enable rollback capability
✅ Collaborate with teams

---

## **GitHub Repository Structure**

```
jarvis-crm-autopilot/
│
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml (CI/CD pipeline)
│   │   ├── test.yml (automated tests)
│   │   └── rollback.yml (emergency rollback)
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug-report.md
│   │   ├── feature-request.md
│   │   └── error-report.md
│   └── DISCUSSIONS/
│       ├── Known Issues
│       ├── Error Solutions
│       └── Feature Ideas
│
├── error-logs/
│   ├── WEBRESOURCE_ISSUES.md (WebResource error tracking)
│   ├── 2024-12-errors.json (auto-logged errors)
│   └── KNOWN_ISSUES.md (comprehensive list)
│
├── solutions/
│   ├── SalesOrderSystem/
│   │   ├── .git (version history)
│   │   ├── v1.0.0/ (release tag)
│   │   ├── v1.0.1/
│   │   └── v1.1.0/
│   └── HRLeaveSystem/
│       └── (same structure)
│
└── docs/
    ├── GITHUB_INTEGRATION.md (this file)
    ├── CI_CD_PIPELINE.md
    └── ERROR_RESOLUTION.md
```

---

## **Setting Up GitHub Integration**

### **Step 1: Create GitHub Repository**

```bash
# Create new repo on GitHub.com
# Name: jarvis-crm-autopilot
# Visibility: Private (for enterprise use)
```

### **Step 2: Initialize Locally**

```bash
cd ~/jarvis-crm-autopilot

git init
git add .
git commit -m "Initial commit: JARVIS platform setup"

git remote add origin https://github.com/yourorg/jarvis-crm-autopilot.git
git branch -M main
git push -u origin main
```

### **Step 3: Create GitHub Token**

```bash
# Go to: GitHub Settings → Developer settings → Personal access tokens

# Create token with scopes:
# ✅ repo (full control of private repositories)
# ✅ workflow (manage GitHub Actions)
# ✅ read:org (read organization)
# ✅ admin:repo_hook (manage repository hooks)

# Save token to .env
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

### **Step 4: Create GitHub Secrets**

For CI/CD to work, add repository secrets:

```
Settings → Secrets and variables → Actions → New repository secret

# Add these secrets:
POWER_PLATFORM_URL
POWER_PLATFORM_USERNAME
POWER_PLATFORM_PASSWORD
GITHUB_TOKEN
```

---

## **GitHub Issues Workflow**

### **1. Creating Issue Templates**

Create `.github/ISSUE_TEMPLATE/error-report.md`:

```markdown
---
name: Error Report
about: Report an error encountered during JARVIS execution
title: "[ERROR] "
labels: error, needs-investigation
assignees: ''
---

## Error Details

### Error Message
<!-- Paste full error text -->

### When Did It Occur?
- [ ] During table creation
- [ ] During plugin generation
- [ ] During flow creation
- [ ] During deployment
- [ ] During testing

### Steps to Reproduce
1. 
2. 
3. 

### Expected Behavior
<!-- What should have happened -->

### Actual Behavior
<!-- What actually happened -->

### Environment
- Power Platform CLI version: 
- JARVIS version: 
- Environment URL: 
- Dataverse version: 

### Solution Attempted
<!-- What did you try to fix it? -->

### Microsoft Reference
- [ ] Check: https://github.com/microsoft/powerplatform-build-tools/discussions
- Link to relevant discussion: 

### Logs
<!-- Attach error-logs file if applicable -->
```

### **2. Automatic Issue Creation from Errors**

JARVIS automatically creates GitHub issues when errors occur:

```javascript
// src/integrations/github-integration.js

async function createIssueFromError(error) {
  const issue = {
    title: `[AUTO] ${error.errorType}: ${error.message}`,
    body: `
## Automatic Error Report

**Timestamp:** ${error.timestamp}
**Severity:** ${error.severity}
**System:** ${error.system}

### Error Message
\`\`\`
${error.fullMessage}
\`\`\`

### Suggested Fix
${error.suggestedFix}

### Reference
${error.gitHubReference || 'N/A'}

### Auto-Fix Applied
${error.autoFixed ? '✅ Yes' : '❌ No'}

---
*This issue was automatically created by JARVIS*
    `,
    labels: [
      'error',
      error.severity.toLowerCase(),
      error.errorType,
      'auto-generated'
    ],
    assignees: ['@support-team']
  };
  
  const response = await octokit.rest.issues.create({
    owner: 'yourorg',
    repo: 'jarvis-crm-autopilot',
    ...issue
  });
  
  return response.data.html_url;
}
```

---

## **GitHub Actions CI/CD Pipeline**

### **1. Deployment Pipeline**

File: `.github/workflows/deploy.yml`

```yaml
name: Deploy Solution

on:
  push:
    branches: [main]
    paths:
      - 'solutions/**'
      - '.github/workflows/deploy.yml'
  workflow_dispatch:

env:
  POWER_PLATFORM_URL: ${{ secrets.POWER_PLATFORM_URL }}
  POWER_PLATFORM_USERNAME: ${{ secrets.POWER_PLATFORM_USERNAME }}
  POWER_PLATFORM_PASSWORD: ${{ secrets.POWER_PLATFORM_PASSWORD }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install Power Platform CLI
        run: npm install -g @microsoft/powerplatform-cli
        
      - name: Authenticate to Power Platform
        run: |
          pac auth create \
            --url $POWER_PLATFORM_URL \
            --username $POWER_PLATFORM_USERNAME \
            --password $POWER_PLATFORM_PASSWORD
            
      - name: Validate Solutions
        run: node scripts/validate-solutions.js
        continue-on-error: true
        
      - name: Deploy to Dev
        run: |
          pac solution import \
            --path solutions/solution.zip \
            --wait \
            --timeout 300
        continue-on-error: true
        
      - name: Run Tests
        run: npm run test
        
      - name: Deploy to Test
        if: success()
        run: |
          pac auth create \
            --url ${{ secrets.TEST_ENVIRONMENT_URL }} \
            --username $POWER_PLATFORM_USERNAME \
            --password $POWER_PLATFORM_PASSWORD
          pac solution import \
            --path solutions/solution.zip
            
      - name: Deploy to Prod
        if: success()
        run: |
          pac auth create \
            --url ${{ secrets.PROD_ENVIRONMENT_URL }} \
            --username $POWER_PLATFORM_USERNAME \
            --password $POWER_PLATFORM_PASSWORD
          pac solution import \
            --path solutions/solution.zip
            
      - name: Generate Deployment Report
        if: always()
        run: node scripts/generate-deployment-report.js
        
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: deployment-report
          path: deployment-report.md
          
      - name: Create GitHub Issue if Failed
        if: failure()
        run: node scripts/create-error-issue.js
```

### **2. Test Pipeline**

File: `.github/workflows/test.yml`

```yaml
name: Test Automation

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        test-suite: [unit, integration, e2e]
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Setup test environment
        run: npm install
        
      - name: Run ${{ matrix.test-suite }} tests
        run: npm run test:${{ matrix.test-suite }}
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        
      - name: Comment PR
        if: github.event_name == 'pull_request'
        run: node scripts/post-test-summary.js
```

### **3. Rollback Pipeline**

File: `.github/workflows/rollback.yml`

```yaml
name: Emergency Rollback

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to rollback to'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          ref: v${{ github.event.inputs.version }}
          
      - name: Authenticate
        run: |
          npm install -g @microsoft/powerplatform-cli
          pac auth create \
            --url ${{ secrets.POWER_PLATFORM_URL }} \
            --username ${{ secrets.POWER_PLATFORM_USERNAME }} \
            --password ${{ secrets.POWER_PLATFORM_PASSWORD }}
            
      - name: Import Previous Version
        run: |
          pac solution import \
            --path solutions/solution-v${{ github.event.inputs.version }}.zip
            
      - name: Verify Rollback
        run: npm run test:smoke
        
      - name: Notify Team
        if: always()
        run: node scripts/notify-rollback.js
```

---

## **Error Tracking Workflow**

### **1. Error Occurs in JARVIS**

```
Error in plugin compilation
    ↓
JARVIS logs error
    ↓
Check against known issues database
    ↓
If known issue: apply auto-fix
If unknown issue: create GitHub issue
```

### **2. Error Logged Locally**

File: `error-logs/2024-12-15-errors.json`

```json
{
  "timestamp": "2024-12-15T10:30:00Z",
  "errorId": "ERR-20241215-001",
  "errorType": "WebResourceURIError",
  "severity": "HIGH",
  "component": "solution-generator",
  "message": "WebResource path missing forward slash",
  "fullStack": "...",
  "resource": "trial_completeisequestionnaire_main",
  "suggestedFix": "Add '/' prefix to URI",
  "gitHubReference": "https://github.com/microsoft/powerplatform-build-tools/discussions/...",
  "autoFixed": true,
  "fixApplied": "2024-12-15T10:30:05Z"
}
```

### **3. GitHub Issue Auto-Created**

```
Title: [AUTO] WebResourceURIError: Part URI must start with a forward slash

Body:
## Automatic Error Report

**Error ID:** ERR-20241215-001
**Timestamp:** 2024-12-15T10:30:00Z
**Severity:** HIGH

### Reference
https://github.com/microsoft/powerplatform-build-tools/discussions

### Status
✅ Auto-fixed and resolved
```

### **4. Discussion Reference**

Link to Microsoft discussions for known issues:

```markdown
## Related Discussions
- https://github.com/microsoft/powerplatform-build-tools/discussions
- Search terms: "WebResource", "Part URI", "solution import"
```

---

## **Version Management**

### **Semantic Versioning**

JARVIS uses `MAJOR.MINOR.PATCH.BUILD`:

```
1.0.0.0
├─ 1 = Major (breaking changes)
├─ 0 = Minor (new features)
├─ 0 = Patch (bug fixes)
└─ 0 = Build (sequential build number)
```

### **Tagging Releases**

```bash
# Tag a release
git tag -a v1.0.0 -m "Release 1.0.0: Initial production release"

# Push tag
git push origin v1.0.0

# Create GitHub Release with notes
# GitHub UI: Releases → Create Release
# Or via CLI: gh release create v1.0.0
```

### **Version History in Git**

```bash
# View all versions
git tag -l

# View specific version
git show v1.0.0

# Checkout specific version
git checkout v1.0.0

# Create branch from version
git checkout -b hotfix/v1.0.1 v1.0.0
```

---

## **Collaboration Workflow**

### **For Team Development**

```
1. Create Feature Branch
   git checkout -b feature/auto-invoice-plugin

2. Make Changes
   # Modify code, test locally
   
3. Commit with Clear Message
   git commit -m "feat: Add auto-invoice plugin with validation"
   
4. Push to GitHub
   git push origin feature/auto-invoice-plugin
   
5. Create Pull Request
   # GitHub UI or: gh pr create
   
6. Code Review
   # Team reviews, approves or requests changes
   
7. Merge to Main
   # Automatic CI/CD triggers
   
8. Auto-Deploy
   # GitHub Actions deploys to Dev → Test → Prod
```

---

## **Monitoring & Alerts**

### **GitHub Actions Status**

```bash
# Check workflow status
gh workflow list

# View recent runs
gh run list

# View specific run details
gh run view <run-id> --log
```

### **Email Notifications**

GitHub automatically sends emails for:
- ✅ Workflow failures
- ✅ Issue assignments
- ✅ Pull request reviews
- ✅ Discussion comments

---

## **Microsoft Power Platform Reference**

### **Linking to Microsoft Discussions**

In commits, PRs, or issues, reference:

```
Relates to: microsoft/powerplatform-build-tools#123
See also: https://github.com/microsoft/powerplatform-build-tools/discussions/...
```

### **Known Issues from Microsoft**

Track issues mentioned in:
- https://github.com/microsoft/powerplatform-build-tools/discussions
- Microsoft Power Platform documentation
- Community reports

---

## **Best Practices**

### **✅ DO**

```bash
# Clear commit messages
git commit -m "fix: Correct WebResource URI path validation"

# Descriptive branch names
git checkout -b fix/webresource-uri-error

# Link to GitHub issues
git commit -m "Fixes #123: WebResource URI path"

# Add error logs to commits
git add error-logs/
```

### **❌ DON'T**

```bash
# Vague messages
git commit -m "fix stuff"

# Secrets in commits
git commit -m "deployed with password: xyz"

# Large binary files
git add large-solution.zip  # BAD

# Force pushing to main
git push --force origin main  # NEVER
```

---

## **Troubleshooting GitHub Integration**

### **Issue: Deployment Fails in GitHub Actions**

```bash
# Check logs
gh run view <run-id> --log

# Debug locally first
npm run test

# Review error-logs
cat error-logs/2024-12-errors.json
```

### **Issue: Token Expired**

```bash
# Refresh GitHub token
# GitHub → Settings → Developer settings → Personal access tokens → Regenerate

# Update in repository secrets
# Settings → Secrets → Update GITHUB_TOKEN
```

### **Issue: Permission Denied**

```bash
# Check repository permissions
gh repo view --json nameWithOwner,visibility,isPrivate

# Ensure token has correct scopes
# Token needs: repo, workflow, admin:repo_hook
```

---

## **Integration Summary**

| Feature | Status | Benefit |
|---------|--------|---------|
| **Error Logging** | ✅ Auto | All errors tracked |
| **GitHub Issues** | ✅ Auto | Auto-created from errors |
| **CI/CD Pipeline** | ✅ Auto | Auto-deploy on git push |
| **Version Control** | ✅ Manual | Full history maintained |
| **Rollback** | ✅ Auto | One-click rollback |
| **Microsoft Reference** | ✅ Auto | Links to power-platform-build-tools |
| **Collaboration** | ✅ Manual | PR reviews enabled |
| **Monitoring** | ✅ Auto | Email + GitHub alerts |

---

**Last Updated:** 2024-12-15
**JARVIS Version:** 1.0.0
**Status:** Production Ready ✅
