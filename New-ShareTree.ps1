<#
.SYNOPSIS
    Creates a folder structure, populates with data, and arbitrary files.

.DESCRIPTION

.PARAMETER Path
    Target for hierarchy.

.PARAMETER Depth
    Number of levels deep to write. Defaults to three.

.PARAMETER Files
    Number of files to create in each folder.

.EXAMPLE
     -Depth
#>

[CmdletBinding()]

Param (
    #[Parameter(Mandatory = $True)]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $Path,
    [int]
    $Depth = 3,
    [int]
    $Width = 5,
    [int]
    $Files = 5
)

function New-Folders {
    param (
        $Depth
    )
    # Work through this, decrementing depth each time. When $Depth is 0, Break
    while ($Depth -ge 0) {
        Write-Host "Now at $Depth"
        $Depth--
        # Call New-Folders with newly-reduced $Depth
        New-Folders -Depth $Depth
    }
    Break
}

New-Folders -Depth 5