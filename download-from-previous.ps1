param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [switch]$AutoExtract,
    [string]$ArtifactName = "",
    [int]$RunNumber = 1,  # Which run to get (1=latest, 2=second latest, etc.)
    [string]$WorkflowName = ""  # Optional: filter by workflow name
)

$owner = "subhajit331992-lgtm"
$repo = "TestRepo"

$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
}

Write-Host "Searching for artifacts..." -ForegroundColor Green

try {
    # Get workflow runs
    $runsUrl = "https://api.github.com/repos/$owner/$repo/actions/runs"
    $runs = Invoke-RestMethod -Uri $runsUrl -Headers $headers
    
    # Filter completed runs
    $completedRuns = $runs.workflow_runs | Where-Object { $_.status -eq "completed" }
    
    # Filter by workflow name if specified
    if ($WorkflowName) {
        $completedRuns = $completedRuns | Where-Object { $_.name -like "*$WorkflowName*" }
    }
    
    if ($completedRuns.Count -eq 0) {
        Write-Host "No completed runs found." -ForegroundColor Yellow
        return
    }
    
    # Select the specified run (1=latest, 2=second latest, etc.)
    if ($RunNumber -gt $completedRuns.Count) {
        Write-Host "Requested run number $RunNumber exceeds available runs ($($completedRuns.Count))" -ForegroundColor Red
        return
    }
    
    $selectedRun = $completedRuns[$RunNumber - 1]
    Write-Host "Selected run: #$($selectedRun.run_number) - $($selectedRun.name)" -ForegroundColor Cyan
    Write-Host "Run date: $($selectedRun.created_at)" -ForegroundColor Gray
    
    # Get artifacts for selected run
    $artifactsUrl = "https://api.github.com/repos/$owner/$repo/actions/runs/$($selectedRun.id)/artifacts"
    $artifacts = Invoke-RestMethod -Uri $artifactsUrl -Headers $headers
    
    if ($artifacts.artifacts.Count -eq 0) {
        Write-Host "No artifacts found for this run." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($artifacts.artifacts.Count) artifacts:" -ForegroundColor Green
    $artifacts.artifacts | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor Gray }
    
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
