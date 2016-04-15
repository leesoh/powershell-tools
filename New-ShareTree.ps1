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
    $Path = 'C:\Users\liam\Downloads',
    [int]
    # Add range checking (between 1 and ?)
    $Depth = 2,
    [int]
    $Width = 5,
    [int]
    $Files = 5
)

function New-WideFolders {
    param (
        $Path,
        $FolderNames
    )
    # Create as many folders at this level as are required by $Width
    $AvailableFolders = $FolderNames
    for ($i = 0; $i -lt $Width; $i++) {
        $Folder = Get-Random -InputObject $AvailableFolders
        $AvailableFolders = $AvailableFolders | Where-Object {$_ -ne $Folder}
        Write-Host "Now creating $Folder in $Path"
        New-Item -Path $Path -ItemType Directory -Name $Folder
    }
}

function New-Folders {
    param (
        $Depth,
        $FolderNames,
        $Path
    )
    New-WideFolders -Path $Path -FolderNames $FolderNames

    if ($Depth -gt 0) {
        $Depth--
        $CurrentFolders = Get-ChildItem -Path $Path
        foreach ($c in $CurrentFolders) {
            New-Folders -Depth $Depth -FolderNames $FolderNames -Path "$Path\$c"
        }
    }

}

$ShareName = 'MyShare'
$SharePath = "$Path\$ShareName"
$FolderNames = @('Data', 'Logs', 'Reports', 'Files', 'Pictures', 'Scans')
$FileNames = @('first_try', 'pancakes', '2016-Financials', 'Ergo', 'Wingnuts', 'scan')

New-Item -Path $Path -Type Directory -Name $ShareName

New-Folders -Depth $Depth -FolderNames $FolderNames -Path $SharePath

