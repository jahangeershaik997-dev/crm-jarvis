param([Parameter(Mandatory=$true)]$Spec)

$LogPath = "C:\CRM-Jarvis\generated\logs\relationship-generator.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] [$Level] $Message"
}

Write-Host ""
Write-Host "========== Relationship Generator ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Generating relationships..."

$relationships = @()

foreach ($rel in $Spec.relationships) {
    $relName = ($rel.parent_table + "_" + $rel.child_table + "_rel").ToLower()
    $parentAttr = ($rel.parent_table + "_id").ToLower()
    $displayName = ($rel.parent_table + " to " + $rel.child_table)
    
    $cascDel = $false
    $cascAss = $false
    
    if ($rel.cascade_delete) {
        $cascDel = $rel.cascade_delete
    }
    if ($rel.cascade_assign) {
        $cascAss = $rel.cascade_assign
    }
    
    $relObj = @{
        relationshipName = $relName
        relationshipType = $rel.type
        parentEntity = $rel.parent_table.ToLower()
        childEntity = $rel.child_table.ToLower()
        parentAttribute = "id"
        childAttribute = $parentAttr
        displayName = $displayName
        cascadeDelete = $cascDel
        cascadeAssign = $cascAss
    }
    
    $relationships += $relObj
    Write-Log ("Generated relationship: " + $rel.parent_table + " to " + $rel.child_table)
}

$relsPath = "C:\CRM-Jarvis\generated\configs\relationships.json"
$relationships | ConvertTo-Json -Depth 10 | Set-Content -Path $relsPath
Write-Log ("Relationships saved: " + $relsPath)

Write-Host ""
Write-Host "========== RELATIONSHIPS GENERATED ==========" -ForegroundColor Green
Write-Host ""
Write-Host ("Total Relationships: " + $relationships.Count) -ForegroundColor Yellow
foreach ($rel in $relationships) {
    Write-Host ("  OK " + $rel.parentEntity + " -> " + $rel.childEntity) -ForegroundColor Yellow
}
Write-Host ""
Write-Host ("Saved to: " + $relsPath) -ForegroundColor Cyan
Write-Host ""

return $relsPath