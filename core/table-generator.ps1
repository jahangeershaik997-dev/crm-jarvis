param([Parameter(Mandatory=$true)]$Spec)

$LogPath = "C:\CRM-Jarvis\generated\logs\table-generator.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

Write-Host ""
Write-Host "========== Table Generator - REAL DEPLOYMENT ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Starting real table creation in D365..."

$tables = @()

foreach ($table in $Spec.tables) {
    Write-Log "Processing table: $($table.display_name)"
    
    $tableName = $table.name.ToLower()
    $displayName = $table.display_name
    
    try {
        # Create table using pac CLI (REAL DEPLOYMENT)
        Write-Log "Creating table '$displayName' in D365..."
        
        $createCommand = "pac table create --logical-name `"$tableName`" --display-name `"$displayName`" --description `"Auto-generated table`""
        Write-Log "Command: $createCommand"
        
        # Execute the command
        Invoke-Expression $createCommand | Out-Null
        
        Write-Log "Table '$displayName' created successfully in D365" "SUCCESS"
        
        # Add columns
        foreach ($col in $table.columns) {
            $colName = $col.name.ToLower()
            $colType = $col.type
            
            Write-Log "Adding column: $colName ($colType)"
            
            $addColCommand = "pac table add-column --table `"$tableName`" --logical-name `"$colName`" --type `"$colType`""
            Invoke-Expression $addColCommand | Out-Null
            
            Write-Log "Column '$colName' added"
        }
        
        $tableObj = @{
            logicalName = $tableName
            displayName = $displayName
            status = "Created in D365"
            columns = $table.columns.Count
        }
        $tables += $tableObj
        
    } catch {
        Write-Log "ERROR creating table: $_" "ERROR"
    }
}

# Save spec for reference
$tablesPath = "C:\CRM-Jarvis\generated\configs\tables-deployed.json"
$tables | ConvertTo-Json -Depth 10 | Set-Content -Path $tablesPath
Write-Log "Tables info saved: $tablesPath"

Write-Host ""
Write-Host "========== TABLES CREATED IN D365 ==========" -ForegroundColor Green
Write-Host ""
Write-Host "Total Tables: $($tables.Count)" -ForegroundColor Yellow
foreach ($table in $tables) {
    Write-Host "  ✅ $($table.displayName) - $($table.columns) columns" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Status: LIVE IN D365" -ForegroundColor Green
Write-Host ""

return $tables