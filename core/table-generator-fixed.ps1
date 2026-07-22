param([Parameter(Mandatory=$true)]$Spec)

$LogPath = "C:\CRM-Jarvis\generated\logs\table-generator.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

Write-Host ""
Write-Host "========== Table Generator - Fixed ==========" -ForegroundColor Cyan

Write-Log "Checking pac commands available..."

# List available pac commands
pac | Select-String "table"

Write-Log "Please create table manually in Power Platform for now"
Write-Log "OR use Power Automate Cloud Flow to create table via API"

Write-Host ""
Write-Host "For now, JARVIS can generate the table definitions in JSON"
Write-Host "You can import them into Power Platform using:"
Write-Host "1. Power Apps Studio → Create → Blank table"
Write-Host "2. Add columns manually"
Write-Host "3. Or use API to create programmatically"
Write-Host ""

# Save table definition as reference
$tablesPath = "C:\CRM-Jarvis\generated\configs\table-definitions.json"
$Spec.tables | ConvertTo-Json -Depth 10 | Set-Content -Path $tablesPath

Write-Log "Table definitions saved to: $tablesPath"
Write-Host "Definitions saved for manual creation"