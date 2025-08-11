# TestRepo - GitHub Artifacts Configuration

This repository is configured to automatically upload files as GitHub Artifacts using GitHub Actions.

## Artifacts Configuration

The repository includes a GitHub Actions workflow that:
- Uploads `Files/Test.txt` as an individual artifact
- Uploads the entire `Files/` directory as a complete artifact
- Retains artifacts for 30 days
- Runs on push to main branch, pull requests, and can be manually triggered

## How to Access Artifacts

1. **Via GitHub Web Interface**:
   - Go to your repository on GitHub
   - Click on the "Actions" tab
   - Select a completed workflow run
   - Scroll down to the "Artifacts" section
   - Download the artifacts you need

2. **Via GitHub CLI**:
   ```bash
   # List artifacts for a specific run
   gh run list --repo subhajit331992-lgtm/TestRepo
   
   # Download artifacts from a specific run
   gh run download <run-id> --repo subhajit331992-lgtm/TestRepo
   ```

3. **Via REST API**:
   ```bash
   # List artifacts
   curl -H "Authorization: token YOUR_TOKEN" \
        https://api.github.com/repos/subhajit331992-lgtm/TestRepo/actions/artifacts
   
   # Download specific artifact
   curl -H "Authorization: token YOUR_TOKEN" \
        -L https://api.github.com/repos/subhajit331992-lgtm/TestRepo/actions/artifacts/{artifact_id}/zip \
        -o artifact.zip
   ```

## Workflow Triggers

The workflow runs automatically when:
- Code is pushed to the `main` branch
- A pull request is created targeting the `main` branch
- The workflow is manually triggered from the Actions tab

## Files Included

- `Files/Test.txt` - Contains programming exercises related to error handling

## Artifact Details

- **Artifact Name**: `test-file-artifact` (individual file) and `files-directory-artifact` (entire directory)
- **Retention Period**: 30 days
- **File Path**: `Files/Test.txt`
- **Content**: Programming exercises and examples

## Manual Workflow Trigger

You can manually trigger the workflow:
1. Go to the "Actions" tab in your repository
2. Select "Upload Artifacts" workflow
3. Click "Run workflow" button
4. Choose the branch and click "Run workflow"
