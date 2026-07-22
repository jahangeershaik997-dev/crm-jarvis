param(
    [Parameter(Mandatory=$true)]$Spec,
    [Parameter(Mandatory=$true)][string]$SolutionName
)

$LogPath = "C:\CRM-Jarvis\generated\logs\solution-builder.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

Write-Host ""
Write-Host "========== Solution Builder - Create Importable ZIP ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Building solution package: $SolutionName"

# Create solution folder structure
$solutionFolder = "C:\CRM-Jarvis\generated\solutions\$SolutionName"
$entitiesFolder = "$solutionFolder\Entities"
$formsFolder = "$solutionFolder\FormXml"

New-Item -ItemType Directory -Path $entitiesFolder -Force | Out-Null
New-Item -ItemType Directory -Path $formsFolder -Force | Out-Null

Write-Log "Solution folder created: $solutionFolder"

# Create customizations.xml
$customizationsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2" SolutionPackageVersion="9.2" languageid="1033" generatedOn="$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')">
  <SolutionManifest>
    <UniqueName>jarvis_$($SolutionName.ToLower())</UniqueName>
    <LocalizedNames>
      <LocalizedName languageid="1033" value="$SolutionName" />
    </LocalizedNames>
    <Descriptions>
      <Description languageid="1033" value="Auto-generated solution by JARVIS" />
    </Descriptions>
    <Version>1.0.0.0</Version>
    <Managed>0</Managed>
    <Publisher>
      <UniqueName>jarvis</UniqueName>
      <LocalizedNames>
        <LocalizedName languageid="1033" value="JARVIS" />
      </LocalizedNames>
      <Descriptions>
        <Description languageid="1033" value="JARVIS CRM Autopilot" />
      </Descriptions>
    </Publisher>
    <RootComponents>
"@

# Add entities to solution
foreach ($table in $Spec.tables) {
    $customizationsXml += @"
      <RootComponent type="1" schemaName="$($table.name.ToLower())" behavior="0" />
"@
}

$customizationsXml += @"
    </RootComponents>
    <MissingDependencies />
  </SolutionManifest>
  <EntityMetadata />
  <EntityRelationships />
  <OrganizationSettings />
  <optionSets />
  <ClientExtensions />
  <ServerExtensions />
  <Workflows />
</ImportExportXml>
"@

$customizationsPath = "$solutionFolder\customizations.xml"
$customizationsXml | Set-Content -Path $customizationsPath -Encoding UTF8

Write-Log "customizations.xml created"

# Create [Content_Types].xml
$contentTypesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml" />
  <Default Extension="xml" ContentType="application/xml" />
  <Override PartName="/customizations.xml" ContentType="application/xml" />
</Types>
"@

$contentTypesPath = "$solutionFolder\[Content_Types].xml"
$contentTypesXml | Set-Content -Path $contentTypesPath -Encoding UTF8

Write-Log "[Content_Types].xml created"

# Create _rels/.rels
$relsFolder = "$solutionFolder\_rels"
New-Item -ItemType Directory -Path $relsFolder -Force | Out-Null

$relsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rel0" Type="http://schemas.microsoft.com/office/2007/relationships/ui/extensibility" Target="customizations.xml" />
</Relationships>
"@

$relsPath = "$relsFolder\.rels"
$relsXml | Set-Content -Path $relsPath -Encoding UTF8

Write-Log ".rels file created"

# Create ZIP file
$zipPath = "C:\CRM-Jarvis\generated\solutions\$SolutionName.zip"

Write-Log "Creating ZIP package: $zipPath"

# Remove old zip if exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Create ZIP using PowerShell
Add-Type -AssemblyName System.IO.Compression.FileSystem

[System.IO.Compression.ZipFile]::CreateFromDirectory($solutionFolder, $zipPath)

Write-Log "ZIP package created successfully"

Write-Host ""
Write-Host "========== SOLUTION PACKAGE READY ==========" -ForegroundColor Green
Write-Host ""
Write-Host "Solution Name: $SolutionName" -ForegroundColor Yellow
Write-Host "ZIP File: $zipPath" -ForegroundColor Yellow
Write-Host "Size: $('{0:N0}' -f (Get-Item $zipPath).Length) bytes" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ready to import to D365/Power Apps!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Import Instructions:" -ForegroundColor Cyan
Write-Host "1. Go to Power Apps → Solutions" -ForegroundColor Cyan
Write-Host "2. Click 'Import' → Select $SolutionName.zip" -ForegroundColor Cyan
Write-Host "3. Click 'Next' → 'Import'" -ForegroundColor Cyan
Write-Host "4. Tables will be created automatically!" -ForegroundColor Cyan
Write-Host ""

return $zipPath