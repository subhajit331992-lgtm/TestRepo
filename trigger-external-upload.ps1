param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$true)]
    [string]$Token
)

$owner = "subhajit331992-lgtm"
$repo = "TestRepo"

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "File not found: $FilePath" -ForegroundColor Red
    exit 1
}

Write-Host "Triggering workflow to upload: $FilePath" -ForegroundColor Green

$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
    "Content-Type" = "application/json"
}

# Trigger workflow_dispatch
$body = @{
    ref = "main"
    inputs = @{
        file_path = $FilePath
    }
} | ConvertTo-Json

$url = "https://api.github.com/repos/$owner/$repo/actions/workflows/upload-external-artifacts.yml/dispatches"

try {
    Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $body
    Write-Host "✓ Workflow triggered successfully!" -ForegroundColor Green
    Write-Host "Check Actions tab: https://github.com/$owner/$repo/actions" -ForegroundColor Cyan
}
catch {
    Write-Host "✗ Failed to trigger workflow: $($_.Exception.Message)" -ForegroundColor Red
}
