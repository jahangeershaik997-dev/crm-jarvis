param([Parameter(Mandatory=$true)][string]$PluginName)

$LogPath = "C:\CRM-Jarvis\generated\logs\auto-compiler.log"
$PluginPath = "C:\CRM-Jarvis\generated\plugins\$PluginName.cs"
$OutputDll = "C:\CRM-Jarvis\generated\plugins\$PluginName.dll"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

Write-Host ""
Write-Host "========== JARVIS - Auto Compiler ==========" -ForegroundColor Cyan
Write-Host ""

Write-Log "Compiling: $PluginName"
Write-Log "Source: $PluginPath"

# Create temporary project file
$csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net462</TargetFramework>
    <AssemblyName>$PluginName</AssemblyName>
    <OutputPath>C:\CRM-Jarvis\generated\plugins\</OutputPath>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CrmSdk.CoreAssemblies" Version="9.0.2.45" />
  </ItemGroup>
</Project>
"@

$projectPath = "C:\CRM-Jarvis\generated\plugins\$PluginName.csproj"
$csprojContent | Set-Content -Path $projectPath
Write-Log "Project file created: $projectPath"

# Compile
Write-Log "Running: dotnet build"
try {
    Push-Location "C:\CRM-Jarvis\generated\plugins\"
    dotnet build $projectPath -c Release -o "C:\CRM-Jarvis\generated\plugins\"
    Pop-Location
    
    if (Test-Path $OutputDll) {
        Write-Log "Compilation successful!"
        Write-Host ""
        Write-Host "========== COMPILATION COMPLETE ==========" -ForegroundColor Green
        Write-Host ""
        Write-Host "DLL Created: $OutputDll" -ForegroundColor Yellow
        Write-Host "Size: $('{0:N0}' -f (Get-Item $OutputDll).Length) bytes" -ForegroundColor Yellow
        Write-Host ""
        return $OutputDll
    }
    else {
        Write-Log "ERROR: DLL not created" "ERROR"
        exit 1
    }
}
catch {
    Write-Log "ERROR: Compilation failed - $_" "ERROR"
    exit 1
}