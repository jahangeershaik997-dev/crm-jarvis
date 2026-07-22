param([Parameter(Mandatory=$true)][string]$SpecPath)

$LogPath = "C:\CRM-Jarvis\generated\logs\code-generator.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

function Generate-PluginCode {
    param($Spec)
    Write-Log "Generating C# plugin code..."
    $pluginName = $Spec.plugin_name
    $description = $Spec.description
    $code = @"
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;

namespace JARVIS.Plugins
{
    public class $pluginName : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            try
            {
                var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
                var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                var service = factory.CreateOrganizationService(context.UserId);
                var trace = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

                trace.Trace("$pluginName plugin started");
                var target = (Entity)context.InputParameterCollection["Target"];
                trace.Trace("$pluginName plugin completed");
            }
            catch (Exception ex)
            {
                throw new InvalidPluginExecutionException("Error in plugin: " + ex.Message, ex);
            }
        }
    }
}
"@
    return $code
}

function Save-PluginCode {
    param([string]$Code, [string]$PluginName)
    $codePath = "C:\CRM-Jarvis\generated\plugins\$PluginName.cs"
    $Code | Set-Content -Path $codePath
    Write-Log "Plugin code saved: $codePath"
    return $codePath
}

Write-Host "" 
Write-Host "========== JARVIS - Code Generator ==========" -ForegroundColor Cyan

Write-Log "Loading spec: $SpecPath"

$spec = Get-Content -Path $SpecPath | ConvertFrom-Json
Write-Log "Spec loaded successfully"

$pluginCode = Generate-PluginCode -Spec $spec
$codePath = Save-PluginCode -Code $pluginCode -PluginName $spec.plugin_name

Write-Host ""
Write-Host "========== CODE GENERATION COMPLETE ==========" -ForegroundColor Green
Write-Host ""
Write-Host "Plugin Name  : $($spec.plugin_name)" -ForegroundColor Yellow
Write-Host "Saved to     : $codePath" -ForegroundColor Cyan
Write-Host ""
