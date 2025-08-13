param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [switch]$AutoExtract,
    [string]$ArtifactName = "test-file-artifact"
)

$owner = "subhajit331992-lgtm"
$repo = "TestRepo"

$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
}

Write-Host "Downloading and extracting artifacts..." -ForegroundColor Green

try {
    # Get latest run and artifacts (previous code)
    $runsUrl = "https://api.github.com/repos/$owner/$repo/actions/runs"
    $runs = Invoke-RestMethod -Uri $runsUrl -Headers $headers
    $latestRun = $runs.workflow_runs | Where-Object { $_.status -eq "completed" } | Select-Object -First 1
    $artifactsUrl = "https://api.github.com/repos/$owner/$repo/actions/runs/$($latestRun.id)/artifacts"
    $artifacts = Invoke-RestMethod -Uri $artifactsUrl -Headers $headers
    
    $downloadDir = "downloaded-artifacts"
    if (-not (Test-Path $downloadDir)) {
        New-Item -ItemType Directory -Path $downloadDir | Out-Null
    }

    foreach ($artifact in $artifacts.artifacts) {
        # Filter by artifact name if specified
        if ($ArtifactName -and $artifact.name -ne $ArtifactName) {
            continue
        }
        
        Write-Host "Processing: $($artifact.name)" -ForegroundColor Yellow

        # Download ZIP to downloadDir
        $zipPath = Join-Path $downloadDir "$($artifact.name).zip"
        $downloadUrl = $artifact.archive_download_url
        Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $zipPath

        if ($AutoExtract) {
            # Extract ZIP to a subfolder in downloadDir
            $extractPath = Join-Path $downloadDir $artifact.name
            Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

            # Remove ZIP file
            Remove-Item $zipPath

            Write-Host "✓ Extracted to: $extractPath" -ForegroundColor Green
        } else {
            Write-Host "✓ Downloaded: $zipPath" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
