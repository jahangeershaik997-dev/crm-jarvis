param([Parameter(Mandatory=$true)][string]$Requirement)

$OllamaUrl = "http://localhost:11434/api/generate"
$Model = "qwen2.5:3b"
$LogPath = "C:\CRM-Jarvis\generated\logs\prompt-analyzer.log"

# ---- Logger ----
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

# ---- Send to Ollama ----
function Invoke-Ollama {
    param([string]$Prompt)
    Write-Log "Sending requirement to Ollama (qwen2.5:3b)..."

    $body = @{
        model  = $Model
        prompt = $Prompt
        stream = $false
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod `
            -Uri $OllamaUrl `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -TimeoutSec 120

        Write-Log "Ollama responded successfully"
        return $response.response
    }
    catch {
        Write-Log "ERROR: Ollama failed - $_" "ERROR"
        exit 1
    }
}

# ---- Build Prompt for Ollama ----
function Build-AnalysisPrompt {
    param([string]$UserRequirement)

    return @"
You are a Microsoft Dynamics 365 / Dataverse expert.
Analyze this requirement and return ONLY a JSON object. No explanation. No extra text. Only JSON.

REQUIREMENT:
$UserRequirement

Return JSON in this exact format:
{
  "plugin_name": "PluginClassName",
  "description": "What this plugin does",
  "tables": [
    {
      "name": "table_logical_name",
      "display_name": "Table Display Name",
      "columns": [
        { "name": "column_name", "type": "Text|Number|Currency|DateTime|Lookup|OptionSet|Boolean" }
      ]
    }
  ],
  "triggers": [
    {
      "table": "table_logical_name",
      "message": "Create|Update|Delete",
      "stage": "PreOperation|PostOperation",
      "mode": "Synchronous|Asynchronous"
    }
  ],
  "business_rules": [
    {
      "rule": "Description of business rule",
      "type": "Validation|Calculation|AutoSet|Notification"
    }
  ],
  "flows": [
    {
      "name": "FlowName",
      "trigger": "When this happens",
      "action": "Do this"
    }
  ]
}
"@
}

# ---- Parse JSON from Ollama Response ----
function Parse-JsonResponse {
    param([string]$RawResponse)

    Write-Log "Parsing JSON from Ollama response..."

    $jsonMatch = [regex]::Match($RawResponse, '\{(?:[^{}]|(?:\{[^{}]*\}))*\}', [System.Text.RegularExpressions.RegexOptions]::Singleline)

    if ($jsonMatch.Success) {
        try {
            $jsonText = $jsonMatch.Value
            Write-Log "Found JSON"
            
            $parsed = $jsonText | ConvertFrom-Json -ErrorAction Stop
            
            # If table data is flat (not in tables array), restructure it
            if ($parsed.name -and $parsed.display_name -and (-not $parsed.tables -or $parsed.tables.Count -eq 0)) {
                Write-Log "Restructuring flat table data into tables array..."
                
                $table = @{
                    name = $parsed.name
                    display_name = $parsed.display_name
                    columns = $parsed.columns
                }
                
                $parsed | Add-Member -NotePropertyName "tables" -NotePropertyValue @($table) -Force
            }
            
            # Validate required fields
            if (-not $parsed.plugin_name) {
                if ($parsed.name) {
                    $parsed | Add-Member -NotePropertyName "plugin_name" -NotePropertyValue ($parsed.name.Substring(0,1).ToUpper() + $parsed.name.Substring(1)) -Force
                } else {
                    $parsed | Add-Member -NotePropertyName "plugin_name" -NotePropertyValue "GeneratedPlugin" -Force
                }
            }
            if (-not $parsed.tables) {
                $parsed | Add-Member -NotePropertyName "tables" -NotePropertyValue @() -Force
            }
            if (-not $parsed.triggers) {
                $parsed | Add-Member -NotePropertyName "triggers" -NotePropertyValue @() -Force
            }
            if (-not $parsed.business_rules) {
                $parsed | Add-Member -NotePropertyName "business_rules" -NotePropertyValue @() -Force
            }
            if (-not $parsed.flows) {
                $parsed | Add-Member -NotePropertyName "flows" -NotePropertyValue @() -Force
            }
            
            Write-Log "JSON parsed OK. Plugin: $($parsed.plugin_name), Tables: $($parsed.tables.Count)"
            return $parsed
        }
        catch {
            Write-Log "ERROR: Failed to parse JSON - $_" "ERROR"
            exit 1
        }
    }
    else {
        Write-Log "ERROR: No JSON found in response" "ERROR"
        exit 1
    }
}

# ---- Save JSON Spec ----
function Save-Spec {
    param($Spec, [string]$PluginName)

    $specPath = "C:\CRM-Jarvis\generated\configs\$PluginName-spec.json"
    $Spec | ConvertTo-Json -Depth 10 | Set-Content -Path $specPath
    Write-Log "Spec saved to: $specPath"
    return $specPath
}

# ============================================================
# MAIN EXECUTION
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   JARVIS - Prompt Analyzer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "Starting analysis of requirement..."
Write-Log "Requirement: $Requirement"

# Step 1: Build prompt
$prompt = Build-AnalysisPrompt -UserRequirement $Requirement

# Step 2: Send to Ollama
$rawResponse = Invoke-Ollama -Prompt $prompt

# Step 3: Parse JSON
$spec = Parse-JsonResponse -RawResponse $rawResponse

# Step 4: Save spec
$specPath = Save-Spec -Spec $spec -PluginName $spec.plugin_name

# Step 5: Show result
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   ANALYSIS COMPLETE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Plugin Name  : $($spec.plugin_name)" -ForegroundColor Yellow
Write-Host "Description  : $($spec.description)" -ForegroundColor Yellow
Write-Host "Tables       : $($spec.tables.Count)" -ForegroundColor Yellow
Write-Host "Triggers     : $($spec.triggers.Count)" -ForegroundColor Yellow
Write-Host "Business Rules: $($spec.business_rules.Count)" -ForegroundColor Yellow
Write-Host "Flows        : $($spec.flows.Count)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Spec saved to: $specPath" -ForegroundColor Cyan
Write-Host ""

# Return spec path for next step (code generator)
return $specPath