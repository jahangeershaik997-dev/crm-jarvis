param([Parameter(Mandatory=$true)]$Spec)

$LogPath = "C:\CRM-Jarvis\generated\logs\flow-generator.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] [$Level] $Message"
}

Write-Host ""
Write-Host "========== Flow Generator ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Generating Power Automate flows..."

$flows = @()

foreach ($flow in $Spec.flows) {
    $flowObj = @{
        name = $flow.name
        displayName = $flow.name
        description = ("Auto-generated flow: " + $flow.name)
        trigger = $flow.trigger
        actions = @($flow.action)
        enabled = $true
        type = "Cloud"
    }
    
    $flows += $flowObj
    Write-Log ("Generated flow: " + $flow.name)
}

$flowPath = "C:\CRM-Jarvis\generated\configs\flows.json"
$flows | ConvertTo-Json -Depth 10 | Set-Content -Path $flowPath
Write-Log ("Flows saved: " + $flowPath)

Write-Host ""
Write-Host "========== FLOWS GENERATED ==========" -ForegroundColor Green
Write-Host ""
Write-Host ("Total Flows: " + $flows.Count) -ForegroundColor Yellow
foreach ($flow in $flows) {
    Write-Host ("  OK " + $flow.displayName) -ForegroundColor Yellow
}
Write-Host ""
Write-Host ("Saved to: " + $flowPath) -ForegroundColor Cyan
Write-Host ""

return $flowPath