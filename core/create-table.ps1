param(
    [Parameter(Mandatory=$true)][string]$TableName,
    [Parameter(Mandatory=$false)][string]$Columns = "name,email,phone",
    [Parameter(Mandatory=$false)][string]$D365Url = "https://orgfdc28268.crm8.dynamics.com"
)

$LogPath = "C:\CRM-Jarvis\generated\logs\create-table.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

Write-Host ""
Write-Host "========== JARVIS - Table Creator ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Creating table: $TableName"
Write-Log "Columns: $Columns"
Write-Log "Environment: $D365Url"

# Parse columns
$columnList = $Columns.Split(",") | ForEach-Object { $_.Trim() }

Write-Log "Parsed columns: $($columnList -join ', ')"

# Create solution folder structure
$solutionName = "jarvis_$($TableName.ToLower())"
$solutionFolder = "C:\CRM-Jarvis\generated\solutions\$solutionName"
$otherFolder = "$solutionFolder\Other"
$entitiesFolder = "$solutionFolder\Entities\$($TableName.ToLower())"

New-Item -ItemType Directory -Path $solutionFolder -Force | Out-Null
New-Item -ItemType Directory -Path $otherFolder -Force | Out-Null
New-Item -ItemType Directory -Path $entitiesFolder -Force | Out-Null

Write-Log "Solution folder created"

# Build attributes XML for columns
$attributesXml = ""
foreach ($col in $columnList) {
    $colName = $col.Trim().ToLower()
    $colDisplay = (Get-Culture).TextInfo.ToTitleCase($col.Trim())
    
    $attributesXml += @"
        <EntityMetadata>
            <LogicalName>jarvis_$colName</LogicalName>
            <ExternalName/>
            <HasChanged/>
            <AttributeOf/>
            <AttributeType>String</AttributeType>
            <AttributeTypeName>
                <Value>StringType</Value>
            </AttributeTypeName>
            <ColumnNumber/>
            <Description>
                <UserLocalizedLabel>
                    <Label>$colDisplay</Label>
                    <LanguageCode>1033</LanguageCode>
                </UserLocalizedLabel>
            </Description>
            <DisplayName>
                <UserLocalizedLabel>
                    <Label>$colDisplay</Label>
                    <LanguageCode>1033</LanguageCode>
                </UserLocalizedLabel>
            </DisplayName>
            <RequiredLevel>
                <Value>None</Value>
                <CanBeChanged>true</CanBeChanged>
                <ManagedPropertyLogicalName>canmodifyrequirementlevelsettings</ManagedPropertyLogicalName>
            </RequiredLevel>
            <IsValidForCreate>
                <Value>true</Value>
            </IsValidForCreate>
            <IsValidForRead>
                <Value>true</Value>
            </IsValidForRead>
            <IsValidForUpdate>
                <Value>true</Value>
            </IsValidForUpdate>
            <MaxLength>100</MaxLength>
        </EntityMetadata>
"@
}

# Create entity XML
$entityXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Entity xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Name LocalizedName="$TableName" OriginalName="$TableName">jarvis_$($TableName.ToLower())</Name>
    <EntityInfo>
        <entity Name="jarvis_$($TableName.ToLower())">
            <LocalizedNames>
                <LocalizedName description="$TableName" languagecode="1033" />
            </LocalizedNames>
            <LocalizedCollectionNames>
                <LocalizedCollectionName description="${TableName}s" languagecode="1033" />
            </LocalizedCollectionNames>
            <Descriptions>
                <Description description="Auto-generated table by JARVIS" languagecode="1033" />
            </Descriptions>
            <attributes>
                <attribute PhysicalName="jarvis_$($TableName.ToLower())id">
                    <Type>primarykey</Type>
                    <Name>jarvis_$($TableName.ToLower())id</Name>
                    <LogicalName>jarvis_$($TableName.ToLower())id</LogicalName>
                    <DisplayMasks>PrimaryKey, ValidForAdvancedFind, ValidForForm, ValidForGrid</DisplayMasks>
                    <RequiredLevel>systemrequired</RequiredLevel>
                    <DisplayName>
                        <Titles>
                            <Title description="$TableName" languagecode="1033" />
                        </Titles>
                    </DisplayName>
                </attribute>
"@

# Add columns
foreach ($col in $columnList) {
    $colName = $col.Trim().ToLower()
    $colDisplay = (Get-Culture).TextInfo.ToTitleCase($col.Trim())
    
    $entityXml += @"
                <attribute PhysicalName="jarvis_$colName">
                    <Type>nvarchar</Type>
                    <Name>jarvis_$colName</Name>
                    <LogicalName>jarvis_$colName</LogicalName>
                    <RequiredLevel>none</RequiredLevel>
                    <MaxLength>100</MaxLength>
                    <DisplayName>
                        <Titles>
                            <Title description="$colDisplay" languagecode="1033" />
                        </Titles>
                    </DisplayName>
                </attribute>
"@
}

$entityXml += @"
            </attributes>
        </entity>
    </EntityInfo>
</Entity>
"@

# Save entity XML
$entityXmlPath = "$entitiesFolder\Entity.xml"
$entityXml | Set-Content -Path $entityXmlPath -Encoding UTF8
Write-Log "Entity XML created: $entityXmlPath"

# Create solution.xml
$solutionXml = @"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2" SolutionPackageVersion="9.2" languageid="1033" generatedOn="$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')">
  <SolutionManifest>
    <UniqueName>$solutionName</UniqueName>
    <LocalizedNames>
      <LocalizedName languageid="1033" value="JARVIS $TableName" />
    </LocalizedNames>
    <Descriptions>
      <Description languageid="1033" value="Auto-generated by JARVIS" />
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
      <EMailAddress>jarvis@crm.dev</EMailAddress>
      <SupportingWebsiteUrl>https://jarvis-crm.dev</SupportingWebsiteUrl>
      <CustomizationPrefix>jarvis</CustomizationPrefix>
      <CustomizationOptionValuePrefix>10000</CustomizationOptionValuePrefix>
      <Addresses>
        <Address>
          <AddressNumber>1</AddressNumber>
          <AddressTypeCode>1</AddressTypeCode>
          <City>Global</City>
          <Country>India</Country>
          <Line1>JARVIS Platform</Line1>
          <PostalCode>500001</PostalCode>
          <StateOrProvince>TS</StateOrProvince>
          <Telephone1>9000314625</Telephone1>
        </Address>
      </Addresses>
    </Publisher>
    <RootComponents>
      <RootComponent type="1" schemaName="jarvis_$($TableName.ToLower())" behavior="0" />
    </RootComponents>
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
"@

$solutionXmlPath = "$solutionFolder\solution.xml"
$solutionXml | Set-Content -Path $solutionXmlPath -Encoding UTF8
Write-Log "solution.xml created"

# Create [Content_Types].xml
$contentTypesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="xml" ContentType="application/xml" />
  <Default Extension="png" ContentType="image/png" />
  <Default Extension="jpg" ContentType="image/jpeg" />
  <Default Extension="jpeg" ContentType="image/jpeg" />
  <Default Extension="gif" ContentType="image/gif" />
</Types>
"@

$contentTypesPath = "$solutionFolder\[Content_Types].xml"
$contentTypesXml | Set-Content -Path $contentTypesPath -Encoding UTF8
Write-Log "[Content_Types].xml created"

# Create ZIP
$zipPath = "C:\CRM-Jarvis\generated\solutions\$solutionName.zip"

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($solutionFolder, $zipPath)

Write-Log "ZIP created: $zipPath"
Write-Log "ZIP size: $('{0:N0}' -f (Get-Item $zipPath).Length) bytes"

# Import to D365
Write-Host ""
Write-Host "========== Importing to D365 ==========" -ForegroundColor Cyan
Write-Host ""
Write-Log "Importing solution to D365..."
Write-Log "Command: pac solution import --path $zipPath --environment $D365Url"

try {
    pac solution import --path "$zipPath" --environment "$D365Url" --force-overwrite
    Write-Log "Import successful!"
    
    Write-Host ""
    Write-Host "========== TABLE CREATED IN D365! ==========" -ForegroundColor Green
    Write-Host ""
    Write-Host "Table Name    : jarvis_$($TableName.ToLower())" -ForegroundColor Yellow
    Write-Host "Display Name  : $TableName" -ForegroundColor Yellow
    Write-Host "Columns       : $($columnList.Count) columns added" -ForegroundColor Yellow
    Write-Host "Environment   : $D365Url" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Columns Created:" -ForegroundColor Cyan
    foreach ($col in $columnList) {
        Write-Host "  ✅ jarvis_$($col.Trim().ToLower()) ($col)" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "Status: ✅ LIVE IN D365" -ForegroundColor Green
    Write-Host ""
    Write-Host "Check in Power Apps:" -ForegroundColor Yellow
    Write-Host "  make.powerapps.com → Tables → Search: $TableName" -ForegroundColor Yellow
    Write-Host ""
    
} catch {
    Write-Log "ERROR: Import failed - $_" "ERROR"
    Write-Host "Import Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual import option:" -ForegroundColor Yellow
    Write-Host "  1. Go to make.powerapps.com → Solutions → Import" -ForegroundColor Yellow
    Write-Host "  2. Upload: $zipPath" -ForegroundColor Yellow
    Write-Host "  3. Click Next → Import" -ForegroundColor Yellow
}