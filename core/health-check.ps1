Write-Host ""
Write-Host "========== JARVIS Health Check ==========" -ForegroundColor Cyan
Write-Host ""

# Check 1: Ollama
Write-Host "1. Checking Ollama..." -ForegroundColor Yellow
try {
    $ollamaResponse = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5
    Write-Host "   ✅ Ollama is RUNNING" -ForegroundColor Green
    Write-Host "   Model: qwen2.5:3b" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ollama is NOT running" -ForegroundColor Red
    Write-Host "   Start Ollama: ollama serve" -ForegroundColor Yellow
}

# Check 2: Power Platform CLI
Write-Host ""
Write-Host "2. Checking Power Platform CLI..." -ForegroundColor Yellow
try {
    $pacVersion = pac help 2>&1
    if ($pacVersion) {
        Write-Host "   ✅ Power Platform CLI installed" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Power Platform CLI NOT installed" -ForegroundColor Red
}

# Check 3: D365 Authentication
Write-Host ""
Write-Host "3. Checking D365 Authentication..." -ForegroundColor Yellow
try {
    $authList = pac auth list
    if ($authList -match "salma") {
        Write-Host "   ✅ D365 authenticated (SALMA)" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️ D365 auth status unclear" -ForegroundColor Yellow
}

# Check 4: .NET SDK
Write-Host ""
Write-Host "4. Checking .NET SDK..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "   ✅ .NET SDK installed: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ .NET SDK NOT installed" -ForegroundColor Red
}

# Check 5: Node.js
Write-Host ""
Write-Host "5. Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "   ✅ Node.js installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Node.js NOT installed" -ForegroundColor Red
}

Write-Host ""
Write-Host "========== All Systems Check ==========" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready to build? Run:" -ForegroundColor Yellow
Write-Host "  .\jarvis-phase2.ps1 -Requirement `"Your requirement`"" -ForegroundColor Cyan
Write-Host ""