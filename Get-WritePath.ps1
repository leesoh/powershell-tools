<#
.SYNOPSIS
    Checks for directories writable by the current user.

.DESCRIPTION
    Iterates through provided path or $env:Path and attempts to create a file with a random filename in each
    directory, which it then immediately deletes. Returns success or failure as an object.

.PARAMETER Path
    Path to check for permissions. Defaults to $env:Path.
#>

[CmdletBinding()]

Param (
    [Parameter(Mandatory = $False,
               ValueFromPipeline = $True)]
    [string[]]
    $Path
)

$Results = @()
# Need to do this instead of default values since we're processing it differently.
if ($Path) {
    Write-Verbose -Message 'Path specified. Getting file list.'
    $Path = Get-ChildItem -Path $Path -Directory -Recurse | % {$_.FullName}
}
else {
    Write-Verbose -Message 'Path not specified, using $env:Path'
    $Path = ($env:Path).Split(';')
}

foreach ($P in $Path) {
    $TestFileName = Get-Random
    Write-Verbose -Message "Now processing $P. Test file is $TestFileName."
    try {
        New-Item -Path $P -Name $TestFileName -ErrorAction Stop | Out-Null
        Remove-Item -Path "$P\$TestFileName"
        $Results += [pscustomobject]@{Path   = $P
                                      Status = 'Success'}
    }
    catch {
        $Results += [pscustomobject]@{Path   = $P
                                      Status = 'Failed'}
    }
}
$Results