$apiKey = $env:GCP_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw "GCP_API_KEY environment variable is not set."
}

$headers = @{
    "Content-Type" = "application/json"
    "X-Goog-Api-Key" = $apiKey
    "Accept" = "application/json"
}

$toolsBody = @{
    jsonrpc = "2.0"
    method = "tools/list"
    id = 2
    params = @{}
} | ConvertTo-Json -Depth 5

try {
    $toolsResponse = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $toolsBody
    $listScreensTool = $toolsResponse.result.tools | Where-Object { $_.name -eq "list_screens" }
    Write-Host "Input Schema for list_screens:"
    Write-Host ($listScreensTool.inputSchema | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
