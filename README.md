powershell-tools
=======

A repository of simple PowerShell tools.

##Get-Base.ps1
Encode text to a Base64 string and back again.

```
Get-Base -String 'Hello World!' >>> SGVsbG8gV29ybGQh
Get-Base -Base64 'SGVsbG8gV29ybGQh' >>> Hello World!
```

##Get-Netstat
Parses saved Netstat output (supports any/all of -a, -n, -o) and returns an object.

```
Get-Netstat -Path C:\Path\To\File(s)
```

##Get-ScriptState & Set-ScriptState
Used to store persistent script states between program execution. Will store parameters and values in a CSV in the script's directory. Set will set, Get will get. Huh.
```
Set-ScriptState -Name 'ExecutionState' -Value '1'

Get-ScriptState -StateFile '.\scriptstate.csv'

ExecutionState
--------------
1
```

##Get-Slice.ps1
Grab a slice of text from target file.

```
Get-Slice.ps1 -Text "sample.txt" -StartSlice "The quick brown" -EndSlice "lazy dog"
```

##Get-Substring.ps1
Returns the text between two strings.

```
Get-Substring -Start 'The quick' -End 'lazy dog' -Path C:\StoryAboutAFox.txt
```

##Test-Port.ps1
Checks for open port and returns $True if open.

```
Test-Port.ps1 -Protocol TCP -Port 3389 -Targets 192.168.1.10
```
