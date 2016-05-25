This repository contains simple PowerShell tools used for parsing text, remotely gathering data, and doing stupid
things like encoding and decoding Base64.

#NetworkParsers
Collection of tools for parsing output of basic network commands

##Import-Netstat
Parses saved Netstat output (supports any/all of -a, -n, -o) and returns an object.

```
Import-Netstat -Path C:\Path\To\File(s)
```

##Import-IPConfig
Parses text files containing output of ipconfig or ipconfig /all and returns an object.

```
Import-IPConfig -Path C:\Path\To\File(s)
```
---
##Get-Base.ps1
Encode text to a Base64 string and back again.

```
Get-Base -String 'Hello World!' >>> SGVsbG8gV29ybGQh
Get-Base -Base64 'SGVsbG8gV29ybGQh' >>> Hello World!
```

##Get-Slice.ps1
Grab a slice of text from target file. Ideally this merges with Get-Substring.

```
Get-Slice.ps1 -Text "sample.txt" -Start "The quick brown" -End "lazy dog"
```

##Get-Substring.ps1
Returns the text between two strings.

```
Get-Substring -Start 'The quick' -End 'lazy dog' -Path C:\StoryAboutAFox.txt
```

##Remove-Files.ps1
Removes files older than n days. Defaults to C:\Users\<YOU>\Downloads and 30 days

```
Remove-Files -Path C:\Path\To\Files -MaxAge 60
```

##Test-Port.ps1
Checks for open port and returns $True if open.

```
Test-Port.ps1 -Protocol TCP -Port 3389 -Targets 192.168.1.10
```
