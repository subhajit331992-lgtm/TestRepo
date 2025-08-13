# PowerShell script to download GitHub artifacts
param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [string]$Owner = "subhajit331992-lgtm",
    [string]$Repo = "TestRepo"
)

# Headers for authentication
$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
}

Write-Host "Fetching workflow runs..." -ForegroundColor Green

# Get workflow runs
$runsUrl = "https://api.github.com/repos/$Owner/$Repo/actions/runs"
$runs = Invoke-RestMethod -Uri $runsUrl -Headers $headers

if ($runs.workflow_runs.Count -eq 0) {
    Write-Host "No workflow runs found." -ForegroundColor Yellow
    exit
}

# Get the latest completed run
$latestRun = $runs.workflow_runs | Where-Object { $_.status -eq "completed" } | Select-Object -First 1

if (-not $latestRun) {
    Write-Host "No completed runs found." -ForegroundColor Yellow
    exit
}

Write-Host "Latest run ID: $($latestRun.id)" -ForegroundColor Cyan

# Get artifacts for this run
$artifactsUrl = "https://api.github.com/repos/$Owner/$Repo/actions/runs/$($latestRun.id)/artifacts"
$artifacts = Invoke-RestMethod -Uri $artifactsUrl -Headers $headers

if ($artifacts.artifacts.Count -eq 0) {
    Write-Host "No artifacts found for this run." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($artifacts.artifacts.Count) artifacts:" -ForegroundColor Green

# Create download directory
$downloadDir = "downloaded-artifacts"
if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir
}

# Download each artifact
foreach ($artifact in $artifacts.artifacts) {
    Write-Host "Downloading: $($artifact.name)" -ForegroundColor Yellow
    
    $downloadUrl = $artifact.archive_download_url
    $outputPath = Join-Path $downloadDir "$($artifact.name).zip"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $outputPath
        Write-Host "✓ Downloaded: $outputPath" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to download $($artifact.name): $($_.Exception.Message)" -ForegroundColor Red

    }
}

Write-Host "`nAll artifacts downloaded to: $downloadDir" -ForegroundColor Cyan
