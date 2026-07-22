param([Parameter(Mandatory=$true)][string]$Requirement)

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   JARVIS PHASE 2 - Complete D365 Builder   ║" -ForegroundColor Cyan
Write-Host "║   Tables | Relationships | Rules | Flows   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# STEP 1: Analyze Requirement
Write-Host "STEP 1: Analyzing Requirement..." -ForegroundColor Yellow
$specPath = & .\prompt-analyzer.ps1 -Requirement $Requirement
if (-not $specPath) { Write-Host "FAILED"; exit 1 }
$spec = Get-Content -Path $specPath | ConvertFrom-Json
$systemName = $spec.plugin_name
Write-Host "✅ Analysis Complete: $systemName" -ForegroundColor Green
Write-Host ""

# STEP 2: Generate Tables
Write-Host "STEP 2: Generating Tables..." -ForegroundColor Yellow
& .\table-generator.ps1 -Spec $spec
Write-Host "✅ Tables Generated" -ForegroundColor Green
Write-Host ""

# STEP 3: Generate Relationships
Write-Host "STEP 3: Generating Relationships..." -ForegroundColor Yellow
& .\relationship-generator.ps1 -Spec $spec
Write-Host "✅ Relationships Generated" -ForegroundColor Green
Write-Host ""

# STEP 4: Generate Business Rules
Write-Host "STEP 4: Generating Business Rules..." -ForegroundColor Yellow
& .\business-rules-generator.ps1 -Spec $spec
Write-Host "✅ Business Rules Generated" -ForegroundColor Green
Write-Host ""

# STEP 5: Generate JavaScript
Write-Host "STEP 5: Generating JavaScript..." -ForegroundColor Yellow
& .\javascript-generator.ps1 -Spec $spec
Write-Host "✅ JavaScript Generated" -ForegroundColor Green
Write-Host ""

# STEP 6: Generate Flows
Write-Host "STEP 6: Generating Power Automate Flows..." -ForegroundColor Yellow
& .\flow-generator.ps1 -Spec $spec
Write-Host "✅ Flows Generated" -ForegroundColor Green
Write-Host ""

# STEP 7: Generate Plugin
Write-Host "STEP 7: Generating and Compiling Plugin..." -ForegroundColor Yellow
& .\code-generator.ps1 -SpecPath $specPath | Out-Null
& .\auto-compiler.ps1 -PluginName $systemName | Out-Null
Write-Host "✅ Plugin Compiled" -ForegroundColor Green
Write-Host ""

# STEP 8: Package Solution
Write-Host "STEP 8: Packaging Solution..." -ForegroundColor Yellow
$solutionPath = & .\solution-packager.ps1 -SystemName $systemName -Version "1.0.0.0"
Write-Host "✅ Solution Packaged" -ForegroundColor Green
Write-Host ""

# STEP 9: Deploy
Write-Host "STEP 9: Deploying to D365..." -ForegroundColor Yellow
$dllPath = "C:\CRM-Jarvis\generated\plugins\$systemName.dll"
& .\auto-deployer.ps1 -DllPath $dllPath -PluginName $systemName -D365Url "https://orgfdc28268.crm8.dynamics.com" -Username "jahangeershaik@EVOMAX689.onmicrosoft.com" | Out-Null
Write-Host "✅ Deployment Complete" -ForegroundColor Green
Write-Host ""

# STEP 10: Build Solution ZIP
Write-Host "STEP 10: Building Solution ZIP Package..." -ForegroundColor Yellow
$solutionZip = & .\solution-builder.ps1 -Spec $spec -SolutionName $systemName
Write-Host "✅ Solution ZIP created: $solutionZip" -ForegroundColor Green
Write-Host ""

# STEP 11: Import Solution to D365
Write-Host "STEP 11: Importing Solution to D365..." -ForegroundColor Yellow
& .\solution-importer.ps1 -SolutionZipPath $solutionZip -D365Url "https://orgfdc28268.crm8.dynamics.com"
Write-Host "✅ Solution imported" -ForegroundColor Green
Write-Host ""

# Summary
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   🎉 PHASE 2 COMPLETE - SYSTEM LIVE 🎉     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "System Name: $systemName" -ForegroundColor Cyan
Write-Host "Tables: $($spec.tables.Count)" -ForegroundColor Cyan
Write-Host "Business Rules: $($spec.business_rules.Count)" -ForegroundColor Cyan
Write-Host "Flows: $($spec.flows.Count)" -ForegroundColor Cyan
Write-Host "Total Time: $([Math]::Round($duration, 2)) seconds" -ForegroundColor Cyan
Write-Host ""
Write-Host "Generated Files:" -ForegroundColor Yellow
Write-Host "  Spec    : C:\CRM-Jarvis\generated\configs\$systemName-spec.json" -ForegroundColor Yellow
Write-Host "  Code    : C:\CRM-Jarvis\generated\plugins\$systemName.cs" -ForegroundColor Yellow
Write-Host "  DLL     : C:\CRM-Jarvis\generated\plugins\$systemName.dll" -ForegroundColor Yellow
Write-Host "  ZIP     : $solutionZip" -ForegroundColor Yellow
Write-Host ""
Write-Host "Status: ✅ LIVE IN D365 - TABLES CREATED AUTOMATICALLY" -ForegroundColor Green
Write-Host ""