param(
    [Parameter(Mandatory=$true)][string]$SystemName,
    [Parameter(Mandatory=$true)][string]$Version = "1.0.0.0"
)

$LogPath = "C:\CRM-Jarvis\generated\logs\solution-packager.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] [$Level] $Message"
}

Write-Host ""
Write-Host "========== Solution Packager ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Creating solution package for: $SystemName"

# Create solution folder
$solutionFolder = "C:\CRM-Jarvis\generated\solutions\$SystemName"
New-Item -ItemType Directory -Path $solutionFolder -Force | Out-Null
Write-Log "Solution folder created: $solutionFolder"

# Create solution.xml
$solutionXml = @"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2" SolutionPackageVersion="9.2" languageid="1033" generatedOn="$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')">
  <SolutionManifest>
    <UniqueName>jarvis_$($SystemName.ToLower())</UniqueName>
    <LocalizedNames>
      <LocalizedName languageid="1033" value="$SystemName" />
    </LocalizedNames>
    <Descriptions>
      <Description languageid="1033" value="Auto-generated $SystemName system by JARVIS" />
    </Descriptions>
    <Version>$Version</Version>
    <Managed>0</Managed>
    <Publisher>
      <UniqueName>jarvis</UniqueName>
      <LocalizedNames>
        <LocalizedName languageid="1033" value="JARVIS" />
      </LocalizedNames>
      <Descriptions>
        <Description languageid="1033" value="JARVIS CRM Autopilot" />
      </Descriptions>
      <EMailAddress>jarvis@crm-autopilot.com</EMailAddress>
      <SupportingWebsiteUrl>https://jarvis-crm.com</SupportingWebsiteUrl>
      <Addresses>
        <Address>
          <AddressNumber>1</AddressNumber>
          <AddressTypeCode>1</AddressTypeCode>
          <City>Global</City>
          <Country>USA</Country>
          <County>Worldwide</County>
          <Line1>JARVIS Platform</Line1>
          <PostalCode>00000</PostalCode>
          <StateOrProvince>Global</StateOrProvince>
          <Telephone1>+1-000-000-0000</Telephone1>
          <UTCOffset>0</UTCOffset>
        </Address>
      </Addresses>
    </Publisher>
    <RootComponents>
      <RootComponent type="1" schemaName="account" behavior="0" />
      <RootComponent type="1" schemaName="contact" behavior="0" />
      <RootComponent type="1" schemaName="opportunity" behavior="0" />
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
  <FieldSecurityProfiles />
  <Templates />
  <EntityMaps />
  <TransformationMappings />
  <SolutionPluginAssemblies />
  <SolutionWebResources />
  <Dependencies />
  <RibbonDiffXml />
</ImportExportXml>
"@

$xmlPath = "$solutionFolder\solution.xml"
$solutionXml | Set-Content -Path $xmlPath -Encoding UTF8
Write-Log "solution.xml created: $xmlPath"

# Copy all generated files
Copy-Item -Path "C:\CRM-Jarvis\generated\configs\tables.json" -Destination "$solutionFolder\" -Force
Copy-Item -Path "C:\CRM-Jarvis\generated\configs\business-rules.json" -Destination "$solutionFolder\" -Force
Copy-Item -Path "C:\CRM-Jarvis\generated\configs\flows.json" -Destination "$solutionFolder\" -Force
Copy-Item -Path "C:\CRM-Jarvis\generated\plugins\form-scripts.js" -Destination "$solutionFolder\" -Force
Copy-Item -Path "C:\CRM-Jarvis\generated\plugins\*.dll" -Destination "$solutionFolder\" -Force

Write-Log "All files packaged"

# Create deployment manifest
$manifest = @"
SOLUTION PACKAGE: $SystemName
Version: $Version
Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Contents:
- solution.xml (manifest)
- tables.json
- business-rules.json
- flows.json
- form-scripts.js
- Plugin DLLs

Ready for import to D365/Dataverse
"@

$manifestPath = "$solutionFolder\MANIFEST.txt"
$manifest | Set-Content -Path $manifestPath
Write-Log "Manifest created: $manifestPath"

Write-Host ""
Write-Host "========== SOLUTION PACKAGED ==========" -ForegroundColor Green
Write-Host ""
Write-Host "Solution Name: $SystemName" -ForegroundColor Yellow
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Location: $solutionFolder" -ForegroundColor Yellow
Write-Host ""
Write-Host "Contents:" -ForegroundColor Cyan
Write-Host "  - solution.xml" -ForegroundColor Cyan
Write-Host "  - tables.json" -ForegroundColor Cyan
Write-Host "  - business-rules.json" -ForegroundColor Cyan
Write-Host "  - flows.json" -ForegroundColor Cyan
Write-Host "  - form-scripts.js" -ForegroundColor Cyan
Write-Host "  - Plugin DLLs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Status: READY FOR IMPORT" -ForegroundColor Green
Write-Host ""

return $solutionFolder