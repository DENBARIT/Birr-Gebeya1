$apiKey = $env:GCP_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw "GCP_API_KEY environment variable is not set."
}

$headers = @{
    "Content-Type" = "application/json"
    "X-Goog-Api-Key" = $apiKey
    "Accept" = "application/json"
}

$projectId = "445021037830648547"

$listBody = @{
    jsonrpc = "2.0"
    method = "tools/call"
    id = 5
    params = @{
        name = "list_screens"
        arguments = @{
            projectId = $projectId
        }
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $listBody
    Write-Host "Raw Response:"
    Write-Host ($response | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
