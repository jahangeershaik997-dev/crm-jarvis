param([Parameter(Mandatory=$true)][string]$Requirement)

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   JARVIS - CRM Autopilot Phase 1           ║" -ForegroundColor Cyan
Write-Host "║   Full Automation Pipeline                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# Step 1: Prompt Analyzer
Write-Host "STEP 1: Analyzing Requirement..." -ForegroundColor Yellow
$specPath = & .\prompt-analyzer.ps1 -Requirement $Requirement
if (-not $specPath) { Write-Host "❌ Prompt analysis failed"; exit 1 }
Write-Host "✅ Requirement analyzed and spec created" -ForegroundColor Green
Write-Host ""

# Load spec
$spec = Get-Content -Path $specPath | ConvertFrom-Json
$pluginName = $spec.plugin_name

# Step 2: Code Generator
Write-Host "STEP 2: Generating C# Plugin Code..." -ForegroundColor Yellow
& .\code-generator.ps1 -SpecPath $specPath
if (-not (Test-Path "C:\CRM-Jarvis\generated\plugins\$pluginName.cs")) {
    Write-Host "❌ Code generation failed"; exit 1
}
Write-Host "✅ Plugin code generated" -ForegroundColor Green
Write-Host ""

# Step 3: Auto Compiler
Write-Host "STEP 3: Compiling Plugin to DLL..." -ForegroundColor Yellow
$dllPath = & .\auto-compiler.ps1 -PluginName $pluginName
if (-not (Test-Path $dllPath)) {
    Write-Host "❌ Compilation failed"; exit 1
}
Write-Host "✅ Plugin compiled successfully" -ForegroundColor Green
Write-Host ""

# Step 4: Auto Registerer
Write-Host "STEP 4: Creating Plugin Registration..." -ForegroundColor Yellow
$tableName = if ($spec.triggers.Count -gt 0) { $spec.triggers[0].table } else { "order" }
$message = if ($spec.triggers.Count -gt 0) { $spec.triggers[0].message } else { "Create" }
& .\auto-registerer.ps1 -DllPath $dllPath -PluginName $pluginName -TableName $tableName -Message $message
Write-Host "✅ Plugin registration configured" -ForegroundColor Green
Write-Host ""

# Step 5: Auto Deployer
Write-Host "STEP 5: Deploying to D365..." -ForegroundColor Yellow
& .\auto-deployer.ps1 -DllPath $dllPath -PluginName $pluginName -D365Url "https://orgfdc28268.crm8.dynamics.com" -Username "jahangeershaik@EVOMAX689.onmicrosoft.com"
Write-Host "✅ Deployment completed" -ForegroundColor Green
Write-Host ""

# Final Summary
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   🎉 JARVIS AUTOMATION COMPLETE 🎉         ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Plugin Name    : $pluginName" -ForegroundColor White
Write-Host "  Plugin Class   : $pluginName" -ForegroundColor White
Write-Host "  DLL File       : $dllPath" -ForegroundColor White
Write-Host "  D365 Org       : https://orgfdc28268.crm8.dynamics.com" -ForegroundColor White
Write-Host "  Total Time     : $([Math]::Round($duration, 2)) seconds" -ForegroundColor White
Write-Host ""
Write-Host "Generated Files:" -ForegroundColor Cyan
Write-Host "  Spec    : C:\CRM-Jarvis\generated\configs\$pluginName-spec.json" -ForegroundColor White
Write-Host "  Code    : C:\CRM-Jarvis\generated\plugins\$pluginName.cs" -ForegroundColor White
Write-Host "  DLL     : $dllPath" -ForegroundColor White
Write-Host "  Config  : C:\CRM-Jarvis\generated\configs\$pluginName-registration.xml" -ForegroundColor White
Write-Host ""
Write-Host "Status: ✅ READY FOR REGISTRATION" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Register the plugin in Power Platform using the DLL file" -ForegroundColor Yellow
Write-Host ""
