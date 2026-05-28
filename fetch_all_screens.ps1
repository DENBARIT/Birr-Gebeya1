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

# Step 1: List screens to get titles and IDs
$listBody = @{
    jsonrpc = "2.0"
    method = "tools/call"
    id = 5
    params = @{
        name = "list_screens"
        arguments = @{
            parent = "projects/$projectId"
        }
    }
} | ConvertTo-Json -Depth 5

$screens = @()
try {
    $response = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $listBody
    # Parse results
    $resObj = ConvertFrom-Json $response.result.content[0].text
    $screens = $resObj.screens
    Write-Host "Found $($screens.Count) screens in project."
} catch {
    Write-Host "Error listing screens: $($_.Exception.Message)"
    exit 1
}

# Create output folder for screens HTML
$htmlDir = "stitch_html"
New-Item -ItemType Directory -Path $htmlDir -Force | Out-Null

# Step 2: Download each screen
foreach ($screen in $screens) {
    $screenId = $screen.name.Split('/')[-1]
    $title = $screen.title
    Write-Host "Fetching: $title ($screenId)..."
    
    $getBody = @{
        jsonrpc = "2.0"
        method = "tools/call"
        id = 6
        params = @{
            name = "get_screen"
            arguments = @{
                name = $screen.name
                projectId = $projectId
                screenId = $screenId
            }
        }
    } | ConvertTo-Json -Depth 5

    try {
        $getResp = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $getBody
        $scrDetail = ConvertFrom-Json $getResp.result.content[0].text
        
        $downloadUrl = $scrDetail.htmlCode.downloadUrl
        if ($downloadUrl) {
            # Download the HTML code
            $htmlContent = Invoke-RestMethod -Uri $downloadUrl -Method GET
            
            # Clean filename
            $safeTitle = $title -replace '[^a-zA-Z0-9_ ]',''
            $safeTitle = $safeTitle -replace ' ','_'
            $filename = "$htmlDir\${screenId}_${safeTitle}.html"
            
            $htmlContent | Out-File -FilePath $filename -Encoding UTF8
            Write-Host "  Downloaded and saved to $filename"
        } else {
            Write-Host "  No HTML code found for $title"
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)"
    }
}

Write-Host "All downloads complete!"
