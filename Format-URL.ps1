<#
.DESCRIPTION
    Grabs the title for the provided URL then formats it in <TITLE> (URL) and copies to the clipboard.

.PARAMETER URL
    Target URL

.PARAMETER Loop
    Will cause the URL prompt to loop until a blank URL is entered.

.PARAMETER Type
    Report (default), Markdown

.EXAMPLE
    PS C:\> Format-URL.ps1 -URL http://www.google.com
    Will retrieve the title for the parameter, format it, copy it to the clipboard with the URL, and output it.

.NOTES
    Heavy lifting by:
     - http://www.powershellmagazine.com/2013/01/29/pstip-retrieve-a-redirected-url/
     - https://gallery.technet.microsoft.com/scriptcenter/e76a4213-cd05-4735-bf80-d5903171ae11
#>

[CmdletBinding()]
Param(
    [string]$URL,
    [switch]$Loop,
    [string]$Type = 'Report'
)

function Get-RedirectedURL ($URL) {
    # Define supported SSL/TLS versions
    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12", "Tls11", "tls", "ssl3")
    $Request = [System.Net.WebRequest]::Create($URL)
    # Need a user agent to avoid 403 forbiddens
    $Request.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)"
    try {
        Write-Verbose -Message 'Getting real URL'
        $Response = $Request.GetResponse()
        if ($Response.StatusCode -eq "OK") {
            $URL = $Response.ResponseUri.OriginalString
        }
    }
    catch {
        Write-Warning "$($error[0])"
        $URL = $null
    }
    finally {
        Write-Verbose -Message 'Closing response'
        $Response.Close()
        $URL
    }
}

function Get-Title ($URL) {
    $TitleRegex = [regex] '(?<=<title>)([\S\s]*?)(?=</title>)'
    $UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)"
    Write-Verbose -Message 'Creating web client'
    $WebClient = New-Object System.Net.WebClient
    $WebClient.Headers.Add("User-Agent", $UserAgent)
    Write-Verbose -Message 'Downloading raw data'
    # Use a stream reader so we don't have to wait for the entire page
    $Stream = $WebClient.OpenRead($URL)
    $Reader = New-Object System.IO.StreamReader($Stream)
    $Line = ''
    while ($Line -notmatch "title") {
        $Line = $Reader.ReadLine()
    }
    Write-Verbose -Message "Title tag found: $Line"
    Write-Verbose -Message 'Parsing data'
    $ParsedData = [System.Net.WebUtility]::HtmlDecode($Line)
    Write-Verbose -Message 'Finding title'
    $Title = $TitleRegex.Match($ParsedData).Value.Trim()
    if ($Title) {
        Write-Host "[*] Title: $Title"
    }
    else {
        $UrlArray = $URL.Split('/')
        # Grab the page from the URL
        $Page = $UrlArray[-1]
        $PageName = $Page.Split('.')
        # Drop the extension
        if ($PageName.Count -gt 1) {
            $PageName = $PageName[1]
        }
        $PageName = $PageName.Replace('-', ' ')
        $Title = (Get-Culture).TextInfo.ToTitleCase($PageName.ToLower())
        Write-Host "[-] No title found. Made a guess: $Title"
    }
    Write-Verbose -Message 'Closing webclient'
    $WebClient.Dispose()
    Write-Verbose -Message 'Closing stream'
    $Stream.Close()
    Write-Verbose -Message 'Creating output'
    switch ($Type) {
        Report {$Output = $Title + " ($URL)"}
        Markdown {$Output = "[$Title]($URL)"}
    }
    $Output
}

function Get-Input ($URL) {
    $URL = $URL.trim()
    $URL = [System.Net.WebUtility]::HtmlEncode($URL)
    $RURL = Get-RedirectedUrl $URL
    if ($RURL -ne $null) {
        $Title = Get-Title $RURL
        Write-Host "[*] Original URL: $URL"
        Write-Host "[*] Redirected URL: $RURL"
        $Title | clip.exe
        Write-Host "[+] Results copied to clipboard!"
    }
    else {
        "[-] Invalid URL."
    }
}

if ($Loop -eq $true) {
    Write-Verbose -Message 'Looping'
    Get-Input $URL
    while ($URL) {
        $URL = Read-Host "URL"
        if ($URL) {
            Get-Input $URL
        }
        else {
            Write-Verbose -Message 'Exiting'
            Exit
        }
    }
}
else {
    Get-Input $URL
}
