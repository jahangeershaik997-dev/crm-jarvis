param([Parameter(Mandatory=$true)][string]$Requirement)

$OllamaUrl = "http://localhost:11434/api/generate"
$Model = "qwen2.5:3b"

Write-Host ""
Write-Host "========== Requirement Validator ==========" -ForegroundColor Cyan
Write-Host ""

# Prompt Ollama to validate requirement clarity
$validationPrompt = @"
You are a D365/Dataverse expert. Analyze this requirement for clarity and completeness.

REQUIREMENT:
$Requirement

Response ONLY with JSON (no explanation):
{
  "isComplete": true/false,
  "clarity": 0-100,
  "missingInfo": ["item1", "item2"],
  "clarifyingQuestions": ["question1", "question2"],
  "readyToBuild": true/false,
  "feedback": "Brief feedback"
}

If clarity < 70, set readyToBuild to false and provide clarifying questions.
If any required info is missing, ask for it.
"@

try {
    $body = @{
        model  = $Model
        prompt = $validationPrompt
        stream = $false
    } | ConvertTo-Json

    $response = Invoke-RestMethod `
        -Uri $OllamaUrl `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 120

    # Extract JSON
    $jsonMatch = [regex]::Match($response.response, '\{(?:[^{}]|(?:\{[^{}]*\}))*\}', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    if ($jsonMatch.Success) {
        $validation = $jsonMatch.Value | ConvertFrom-Json
        
        Write-Host "Clarity Score: $($validation.clarity)/100" -ForegroundColor Yellow
        Write-Host "Ready to Build: $($validation.readyToBuild)" -ForegroundColor Yellow
        Write-Host ""
        
        if ($validation.readyToBuild) {
            Write-Host "✅ Requirement is clear! Proceeding..." -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Requirement needs clarification:" -ForegroundColor Red
            Write-Host ""
            Write-Host "Feedback: $($validation.feedback)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Please provide more info on:" -ForegroundColor Cyan
            foreach ($q in $validation.clarifyingQuestions) {
                Write-Host "  • $q" -ForegroundColor Cyan
            }
            Write-Host ""
            Write-Host "Missing Information:" -ForegroundColor Yellow
            foreach ($m in $validation.missingInfo) {
                Write-Host "  • $m" -ForegroundColor Yellow
            }
            return $false
        }
    }
    
} catch {
    Write-Host "ERROR: Validation failed - $_" -ForegroundColor Red
    return $false
}