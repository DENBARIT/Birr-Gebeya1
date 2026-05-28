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
$screenIds = @(
    "19baa8d06b2443f4bab3c50ea082881a",
    "5514318d14af45e79bef9094b38f590c",
    "600fc68cc8ed4d278cfcc1db2cad41d1",
    "7d7e8c8fec2d4c77aeed1d23d8df1369",
    "972820294e7647a9b95776f0b06f4c83",
    "b83ef81e0c7a40d9a4b6aa3ed9f487e6",
    "c2a4716f9e7241589be71cbd482f3196",
    "f9f28e7249984bac9b207868c18bd995",
    "fcaf76fa4a704c73a46589120c9a9c06"
)

# Create output directory
$outDir = "stitch_screens"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

foreach ($screenId in $screenIds) {
    Write-Host "=== Fetching screen: $screenId ==="
    
    # Fetch screen HTML
    $body = @{
        jsonrpc = "2.0"
        method = "tools/call"
        id = 10
        params = @{
            name = "get_screen_html"
            arguments = @{
                project_id = $projectId
                screen_id = $screenId
            }
        }
    } | ConvertTo-Json -Depth 5
    
    try {
        $response = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $body
        $responseJson = $response | ConvertTo-Json -Depth 20 -Compress
        $responseJson | Out-File -FilePath "$outDir\screen_${screenId}.json" -Encoding UTF8
        Write-Host "  Saved HTML response for $screenId"
    } catch {
        Write-Host "  Error fetching $screenId : $($_.Exception.Message)"
    }

    # Also fetch screen image
    $imgBody = @{
        jsonrpc = "2.0"
        method = "tools/call"
        id = 11
        params = @{
            name = "get_screen_image"
            arguments = @{
                project_id = $projectId
                screen_id = $screenId
            }
        }
    } | ConvertTo-Json -Depth 5
    
    try {
        $imgResponse = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $imgBody
        $imgJson = $imgResponse | ConvertTo-Json -Depth 20 -Compress
        $imgJson | Out-File -FilePath "$outDir\image_${screenId}.json" -Encoding UTF8
        Write-Host "  Saved image response for $screenId"
    } catch {
        Write-Host "  Error fetching image for $screenId : $($_.Exception.Message)"
    }
}

Write-Host "`n=== All screens fetched ==="
