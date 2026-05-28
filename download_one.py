import urllib.request

url = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ6Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpZCiVodG1sX2FhYWQ1MGQyNDNkMTQ3NTBhYzhlZjM1OTQ3MzQxYTJjEgsSBxCkt7CbjhoYAZIBIgoKcHJvamVjdF9pZBIUQhI0NDUwMjEwMzc4MzA2NDg1NDc&filename=&opi=89354086"

try:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        content = response.read()
        print("Response Length:", len(content))
        print("Response (first 100 bytes):")
        print(content[:100])
        print("Response text decoded:")
        print(content.decode('utf-8', errors='ignore'))
except Exception as e:
    print("Error:", e)
