$apiKey = $env:GCP_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw "GCP_API_KEY environment variable is not set."
}

$headers = @{
    "Content-Type" = "application/json"
    "X-Goog-Api-Key" = $apiKey
    "Accept" = "application/json"
}

$body = @{
    jsonrpc = "2.0"
    method = "tools/call"
    id = 4
    params = @{
        name = "get_screen"
        arguments = @{
            name = "projects/445021037830648547/screens/19baa8d06b2443f4bab3c50ea082881a"
            projectId = "445021037830648547"
            screenId = "19baa8d06b2443f4bab3c50ea082881a"
        }
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $body
    Write-Host ($response | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
