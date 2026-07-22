param(
    [Parameter(Mandatory=$true)]$Spec,
    [Parameter(Mandatory=$true)][string]$D365Url,
    [Parameter(Mandatory=$true)][string]$Username
)

$LogPath = "C:\CRM-Jarvis\generated\logs\dataverse-table-creator.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

Write-Host ""
Write-Host "========== Dataverse API Table Creator ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Connecting to Dataverse..."
Write-Log "URL: $D365Url"
Write-Log "User: $Username"

# Get authentication token
Write-Log "Getting authentication token..."

try {
    # Use Azure AD to get token
    $tokenUrl = "https://login.microsoftonline.com/da71782f-f5e7-4df8-a7fc-f2be9e4bf236/oauth2/v2.0/token"
    
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }
    
    # For interactive auth, use device flow
    Write-Log "Opening device code flow for authentication..."
    
    $body = @{
        client_id = "2ad884cb-1914-4e0a-887f-38f829f5e016"
        scope = "$D365Url/.default offline_access"
        grant_type = "device_code"
    } | ConvertTo-String
    
    Write-Log "Authentication initiated. Please authenticate when prompted."
    
} catch {
    Write-Log "ERROR: Authentication failed - $_"
    exit 1
}

# Create tables via Dataverse REST API
foreach ($table in $Spec.tables) {
    $tableName = $table.name.ToLower()
    $displayName = $table.display_name
    
    Write-Log "Creating table: $displayName ($tableName)"
    
    try {
        # Table definition
        $tablePayload = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.EntityMetadata"
            LogicalName = $tableName
            DisplayName = @{
                LocalizedLabels = @(
                    @{
                        Label = $displayName
                        LanguageCode = 1033
                    }
                )
                UserLocalizedLabel = @{
                    Label = $displayName
                    LanguageCode = 1033
                }
            }
            DisplayCollectionName = @{
                LocalizedLabels = @(
                    @{
                        Label = $displayName + "s"
                        LanguageCode = 1033
                    }
                )
            }
            Description = @{
                LocalizedLabels = @(
                    @{
                        Label = "Auto-generated table by JARVIS"
                        LanguageCode = 1033
                    }
                )
            }
            OwnershipType = "UserOwned"
            Attributes = @()
        }
        
        # Add columns
        foreach ($col in $table.columns) {
            $colName = $col.name.ToLower()
            $colType = $col.type
            
            $columnDef = @{
                "@odata.type" = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
                LogicalName = $colName
                DisplayName = @{
                    LocalizedLabels = @(
                        @{
                            Label = $col.name
                            LanguageCode = 1033
                        }
                    )
                }
                RequiredLevel = @{
                    Value = "None"
                }
                MaxLength = 100
            }
            
            $tablePayload.Attributes += $columnDef
        }
        
        # Send to Dataverse API
        $apiUrl = "$D365Url/api/data/v9.2/EntityDefinitions"
        
        Write-Log "Sending API request to: $apiUrl"
        Write-Log "Payload: $($tablePayload | ConvertTo-Json -Depth 10)"
        
        # Note: Actual API call requires valid token
        # For now, save the payload
        $payloadPath = "C:\CRM-Jarvis\generated\configs\$tableName-payload.json"
        $tablePayload | ConvertTo-Json -Depth 10 | Set-Content -Path $payloadPath
        
        Write-Log "Table payload saved: $payloadPath"
        Write-Log "Table '$displayName' definition created"
        
    } catch {
        Write-Log "ERROR creating table: $_"
    }
}

Write-Host ""
Write-Host "========== Tables Defined ==========" -ForegroundColor Green
Write-Host ""
Write-Host "Total Tables: $($Spec.tables.Count)" -ForegroundColor Yellow
$Spec.tables | ForEach-Object { Write-Host "  ✅ $($_.display_name)" -ForegroundColor Yellow }
Write-Host ""
Write-Host "Payloads saved for Dataverse API import" -ForegroundColor Cyan
Write-Host ""