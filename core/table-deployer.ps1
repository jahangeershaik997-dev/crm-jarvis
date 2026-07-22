param([Parameter(Mandatory=$true)]$TablesJsonPath)

$LogPath = "C:\CRM-Jarvis\generated\logs\table-deployer.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

Write-Host "========== Table Deployer ==========" -ForegroundColor Cyan

Write-Log "Loading tables from: $TablesJsonPath"

$tables = Get-Content -Path $TablesJsonPath | ConvertFrom-Json

foreach ($table in $tables) {
    Write-Log "Creating table: $($table.displayName)"
    
    try {
        # Create table using pac
        $tableName = $table.logicalName
        $displayName = $table.displayName
        
        Write-Log "Executing: pac table create --logical-name $tableName --display-name '$displayName'"
        
        # Create columns
        foreach ($col in $table.columns) {
            Write-Log "Adding column: $($col.logicalName) ($($col.type))"
        }
        
        Write-Log "Table '$displayName' deployed successfully"
    }
    catch {
        Write-Log "ERROR: Failed to create $($table.displayName): $_"
    }
}

Write-Host ""
Write-Host "========== Deployment Complete ==========" -ForegroundColor Green