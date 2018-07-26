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

    Test Cases:
     - MS: https://support.microsoft.com/en-us/help/4074594/windows-81-update-kb4074594
     - Missing characters: https://www.wireshark.org/security/wnpa-sec-2018-06.html (dot)
     - Forbidden: https://git-blame.blogspot.ca/2014/12/git-1856-195-205-214-and-221-and.html
     - h2 https://portal.msrc.microsoft.com/en-US/security-guidance/advisory/CVE-2017-8512

    Order of preference for title:
     - H1
     - H2 (if h1 not there)
     - Title
     - Content

#>

[CmdletBinding()]
Param(
    [string]$URL = "https://support.microsoft.com/en-us/help/4056895/windows-81-update-kb4056895",
    [switch]$Loop,
    [string]$Type = 'Report'
)

$UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)"

function Get-RedirectedURL ($URL) {
    # TODO: Clean up the logic here. IWR was added as a hack workaround.

    # Define supported SSL/TLS versions
    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12", "Tls11", "tls", "ssl3")
    $Request = [System.Net.WebRequest]::Create($URL)
    # Need a user agent to avoid 403 forbiddens
    $Request.UserAgent = $UserAgent
    try {
        Write-Verbose -Message 'Getting real URL'
        $Response = $Request.GetResponse()
        if ($Response.StatusCode -eq "OK") {
            $URL = $Response.ResponseUri.OriginalString
        }
        else {
            Write-Verbose -Message 'Response not OK'
            $Response
        }
    }
    catch {
        Write-Verbose -Message 'Whoops.'
        Write-Warning "$($error[0])"
        #$URL = $null
    }
    finally {
        Write-Verbose -Message 'Closing response'
        if ($Response) {
            $Response.Close()
        }
    }

    try {
        Write-Verbose -Message 'Trying a different way'
        $Response = Invoke-WebRequest -Uri $URL
        $URL = $Response.BaseResponse.ResponseUri
    }
    catch {
        Write-Verbose -Message "That didn't work either"
        Write-Warning "$($error[0])"
    }
    $URL
}

function Get-Title2 ($URL) {
    $Page = Invoke-WebRequest -Uri $URL -UserAgent $UserAgent
    $Content = $Page.Content
    $H1Regex = [regex] '(?<=<h1)([\S\s]*?)(?=</h1>)'
    $H2Regex = [regex] '(?<=<h2)([\S\s]*?)(?=</h2>)'
    $TitleRegex = [regex] '(?<=<title>)([\S\s]*?)(?=</title>)'
    $TitleRegexes = @($H1Regex, $H2Regex, $TitleRegex)

    foreach($TitleRegex in $TitleRegexes){
        try{
            $Title = $TitleRegex.Match($Content)
        }
        catch {

        }
        if($Title){
            Write-Host "[+] Title found: $Title"
            break
        }
    }
}

function Get-Title ($URL) {
    $TitleRegex = [regex] '(?<=<title>)([\S\s]*?)(?=</title>)'
    $ContentRegex = [regex] '(?<=content=")([\S\s]*?)(?=" />)'
    # $UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)"
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
    # Add support for <meta property="og:title" content="Microsoft Security Bulletin MS15-092 - Important" />
    elseif (!($Title)) {
        Write-Verbose -Message 'Finding title in content tag'
        $Title = $ContentRegex.Match($ParsedData).Value.Trim()
        Write-Host "[*] Title: $Title"
    }
    # TODO: This is awful too
    else {
        Write-Verbose -Message "Splitting $URLArray"
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
    Write-Verbose -Message "Processing: $URL"
    $URL = $URL.trim()
    Write-Verbose -Message "URL Trimmed: $URL"
    $URL = [System.Net.WebUtility]::HtmlEncode($URL)
    Write-Verbose -Message "HTML Encoded: $URL"
    $RURL = Get-RedirectedUrl $URL
    if ($RURL -ne $null) {
        Write-Verbose -Message "URL not null"
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
