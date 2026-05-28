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

$htmlDir = "stitch_html"
New-Item -ItemType Directory -Path $htmlDir -Force | Out-Null

try {
    $response = Invoke-RestMethod -Uri "https://stitch.googleapis.com/mcp" -Method POST -Headers $headers -Body $listBody
    
    # Parse results
    $text = $response.result.content[0].text
    $screensObj = ConvertFrom-Json $text
    $screens = $screensObj.screens
    
    Write-Host "Found $($screens.Count) screens. Downloading using curl.exe..."
    
    foreach ($screen in $screens) {
        $screenId = $screen.name.Split('/')[-1]
        $title = $screen.title
        $downloadUrl = $screen.htmlCode.downloadUrl
        
        # Clean filename
        $safeTitle = $title -replace '[^a-zA-Z0-9_ ]',''
        $safeTitle = $safeTitle -replace ' ','_'
        $filename = "$htmlDir\${screenId}_${safeTitle}.html"
        
        Write-Host "Downloading: $title ($screenId) -> $filename"
        
        if ($downloadUrl) {
            # Run actual curl.exe to handle redirects and user agent properly
            & curl.exe -s -L -o $filename $downloadUrl
            
            $fileInfo = Get-Item $filename
            Write-Host "  Saved size: $($fileInfo.Length) bytes"
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
