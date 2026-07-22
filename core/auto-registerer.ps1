param(
    [Parameter(Mandatory=$true)][string]$DllPath,
    [Parameter(Mandatory=$true)][string]$PluginName,
    [Parameter(Mandatory=$true)][string]$TableName,
    [Parameter(Mandatory=$true)][string]$Message = "Create"
)

$LogPath = "C:\CRM-Jarvis\generated\logs\auto-registerer.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

Write-Host ""
Write-Host "========== JARVIS - Auto Registerer ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Registering plugin: $PluginName"
Write-Log "DLL: $DllPath"
Write-Log "Table: $TableName"
Write-Log "Trigger: $Message"

# Verify DLL exists
if (-not (Test-Path $DllPath)) {
    Write-Log "ERROR: DLL not found - $DllPath" "ERROR"
    exit 1
}

Write-Log "DLL verified"

# Create registration XML
$registrationXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Entities>
  <Entity>
    <Name>$PluginName</Name>
    <AssemblyPath>$DllPath</AssemblyPath>
    <Steps>
      <Step>
        <MessageName>$Message</MessageName>
        <PrimaryEntity>$TableName</PrimaryEntity>
        <Stage>PreOperation</Stage>
        <Mode>Synchronous</Mode>
        <Rank>1</Rank>
      </Step>
    </Steps>
  </Entity>
</Entities>
"@

$xmlPath = "C:\CRM-Jarvis\generated\configs\$PluginName-registration.xml"
$registrationXml | Set-Content -Path $xmlPath
Write-Log "Registration XML created: $xmlPath"

Write-Host ""
Write-Host "========== REGISTRATION COMPLETE ==========" -ForegroundColor Green
Write-Host ""
Write-Host "Plugin Name        : $PluginName" -ForegroundColor Yellow
Write-Host "Assembly           : $DllPath" -ForegroundColor Yellow
Write-Host "Table              : $TableName" -ForegroundColor Yellow
Write-Host "Trigger            : $Message" -ForegroundColor Yellow
Write-Host "Registration XML   : $xmlPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready for deployment!" -ForegroundColor Green
Write-Host ""

return $xmlPath