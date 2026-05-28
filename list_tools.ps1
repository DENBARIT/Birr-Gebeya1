$apiKey = $env:GCP_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw "GCP_API_KEY environment variable is not set."
}

$headers = @{
    "Content-Type" = "application/json"
    "X-Goog-Api-Key" = $apiKey
    "Accept" = "application/json"
}

# List available tools
$toolsBody = @{
    jsonrpc = "2.0"
    method = "tools/list"
    id = 2
    params = @{}
} | ConvertTo-Json -Depth 5

try {
    $toolsResponse = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $toolsBody
    
    # Extract tools and print names
    $tools = $toolsResponse.result.tools
    Write-Host "Available Tools:"
    foreach ($tool in $tools) {
        Write-Host " - $($tool.name): $($tool.description)"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
