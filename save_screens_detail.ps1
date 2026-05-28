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
    $text = $response.result.content[0].text
    $text | Out-File -FilePath "screens_detail.json" -Encoding UTF8
    Write-Host "Saved all screens metadata to screens_detail.json"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
