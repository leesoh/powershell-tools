powershell-tools
=======

A repository of simple PowerShell tools.

##Get-Base.ps1
Encode text to a Base64 string and back again.

Get-Base -String 'Hello World!' >>> SGVsbG8gV29ybGQh  
Get-Base -Base64 'SGVsbG8gV29ybGQh' >>> Hello World!
