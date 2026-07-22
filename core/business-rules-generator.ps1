param([Parameter(Mandatory=$true)]$Spec)

$LogPath = "C:\CRM-Jarvis\generated\logs\business-rules-generator.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] [$Level] $Message"
}

Write-Host ""
Write-Host "========== Business Rules Generator ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Generating business rules..."

$businessRules = @()

foreach ($rule in $Spec.business_rules) {
    $ruleName = ($rule.rule.Replace(" ", "_")).ToLower()
    
    $entity = "order"
    if ($rule.entity) {
        $entity = $rule.entity
    }
    
    $ruleObj = @{
        name = $ruleName
        displayName = $rule.rule
        ruleType = $rule.type
        entity = $entity
        enabled = $true
        scope = "Form"
        conditions = @($rule.condition)
        actions = @($rule.action)
    }
    
    $businessRules += $ruleObj
    Write-Log ("Generated rule: " + $rule.rule)
}

$brPath = "C:\CRM-Jarvis\generated\configs\business-rules.json"
$businessRules | ConvertTo-Json -Depth 10 | Set-Content -Path $brPath
Write-Log ("Business rules saved: " + $brPath)

Write-Host ""
Write-Host "========== BUSINESS RULES GENERATED ==========" -ForegroundColor Green
Write-Host ""
Write-Host ("Total Rules: " + $businessRules.Count) -ForegroundColor Yellow
foreach ($rule in $businessRules) {
    Write-Host ("  OK " + $rule.displayName) -ForegroundColor Yellow
}
Write-Host ""
Write-Host ("Saved to: " + $brPath) -ForegroundColor Cyan
Write-Host ""

return $brPath