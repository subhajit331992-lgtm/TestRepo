# Direct cURL commands to download GitHub artifacts

# Set your variables
$TOKEN = "YOUR_TOKEN_HERE"
$OWNER = "subhajit331992-lgtm"
$REPO = "TestRepo"

Write-Host "=== GitHub Artifacts Download Methods ===" -ForegroundColor Cyan

Write-Host "`n1. List all workflow runs:" -ForegroundColor Green
Write-Host "curl -H `"Authorization: token $TOKEN`" https://api.github.com/repos/$OWNER/$REPO/actions/runs"

Write-Host "`n2. Get artifacts for a specific run (replace RUN_ID):" -ForegroundColor Green
Write-Host "curl -H `"Authorization: token $TOKEN`" https://api.github.com/repos/$OWNER/$REPO/actions/runs/RUN_ID/artifacts"

Write-Host "`n3. Download a specific artifact (replace ARTIFACT_ID):" -ForegroundColor Green
Write-Host "curl -H `"Authorization: token $TOKEN`" -L https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/ARTIFACT_ID/zip -o artifact.zip"

Write-Host "`n4. List all artifacts in the repository:" -ForegroundColor Green
Write-Host "curl -H `"Authorization: token $TOKEN`" https://api.github.com/repos/$OWNER/$REPO/actions/artifacts"
