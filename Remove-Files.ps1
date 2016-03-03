<#
.SYNOPSIS
    Deletes old files.

.DESCRIPTION
    Recursively removes files in target folder older than n days (default 15).

.PARAMETER MaxAge
    Age of files. Everything older will be deleted.

.PARAMETER Path
    Path to files

.EXAMPLE
    Remove-Files.ps1 -MaxAge 15 -Path C:\Path\To\Files
#>

[CmdletBinding(SupportsShouldProcess = $True)]

Param (
    # Maximum file age, in days.
    [Parameter(Mandatory = $False)]
    [int]$MaxAge = 30,

    # Target path.
    [Parameter(Mandatory = $False)]
    [string]$Path = "C:\Users\$([Environment]::Username)\Downloads"
)

Begin {
    $Now = Get-Date
    $LastWrite = $Now.AddDays(-$MaxAge)
    $Files = Get-ChildItem -Path $Path -Recurse | Where {$_.LastWriteTime -le $LastWrite}
}

Process {
    foreach ($File in $Files) {
        if ($PSCmdlet.ShouldProcess($File)) {
            Remove-Item $File.FullName -Verbose
        }
    }
}

End {
    Write-Verbose 'Delete complete!'
}