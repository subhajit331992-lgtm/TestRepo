param(
    [Parameter(Mandatory=$true)]
    [string]$ItemPath,
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [Parameter(Mandatory=$true)]
    [string]$ArtifactName,
    [Parameter(Mandatory=$false)]
    [ValidateSet("file", "folder")]
    [string]$ItemType = "file",
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 90)]
    [int]$RetentionDays = 30
)

$owner = "subhajit331992-lgtm"
$repo = "TestRepo"

# Validate that the item exists
if (-not (Test-Path $ItemPath)) {
    Write-Host "Error: Path '$ItemPath' does not exist!" -ForegroundColor Red
    exit 1
}

# Auto-detect item type if not specified correctly
$actualItemType = if (Test-Path $ItemPath -PathType Container) { "folder" } else { "file" }
if ($ItemType -ne $actualItemType) {
    Write-Host "Auto-correcting item type from '$ItemType' to '$actualItemType'" -ForegroundColor Yellow
    $ItemType = $actualItemType
}

Write-Host "Triggering upload for $ItemType - $ItemPath" -ForegroundColor Green
Write-Host "Artifact name - $ArtifactName" -ForegroundColor Cyan
Write-Host "Retention - $RetentionDays days" -ForegroundColor Cyan

$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
    "Content-Type" = "application/json"
}

$body = @{
    ref = "main"
    inputs = @{
        item_path = $ItemPath
        artifact_name = $ArtifactName
        item_type = $ItemType
        retention_days = $RetentionDays.ToString()
    }
} | ConvertTo-Json

$url = "https://api.github.com/repos/$owner/$repo/actions/workflows/upload-custom-artifacts.yml/dispatches"

try {
    Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $body
    Write-Host "" 
    Write-Host "Workflow triggered successfully!" -ForegroundColor Green
    Write-Host "Check progress: https://github.com/$owner/$repo/actions" -ForegroundColor Cyan
    Write-Host "" 
    Write-Host "Summary:" -ForegroundColor White
    Write-Host "   Item: $ItemPath ($ItemType)" -ForegroundColor Gray
    Write-Host "   Artifact: $ArtifactName" -ForegroundColor Gray
    Write-Host "   Retention: $RetentionDays days" -ForegroundColor Gray
}
catch {
    Write-Host "Failed to trigger workflow: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check your token permissions and item path" -ForegroundColor Yellow
}
