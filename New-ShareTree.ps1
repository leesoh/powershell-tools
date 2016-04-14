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
    [Parameter(Mandatory = $True)]
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

function New-Subfolders {
    param(
        [Parameter(Mandatory = $True)]
        #[ValidateScript({Test-Path -Path $_})]
        [string]
        $Path,
        [Parameter(Mandatory = $True)]
        [string[]]
        $FolderNames,
        [Parameter(Mandatory = $True)]
        [int]
        $Width
    )

    for ($i = 0; $i -lt $Width; $i++) {
        $Folder = Get-Random -InputObject $FolderNames
        New-Item -Path $Path -Name $Folder -ItemType Directory
        $FolderNames = $FolderNames | Where-Object {$_ -ne $Folder}
    }
}

$ShareName = 'MyShare'
$SharePath = "$Path\$ShareName"
$FolderNames = @('Pictures', 'Reports', 'Logs', 'Data', 'Text Files', 'Databases', 'Reviews')
$FileNames = @('passwords', 'users', 'test')

New-Item -Path $Path -Name $ShareName -ItemType Directory

New-Subfolders -Path $ShareName -FolderNames $FolderNames -Width $Width

$FolderArray = Get-ChildItem -Path $SharePath

foreach ($f in $FolderArray) {
    New-Subfolders -Path "$SharePath\$f" -Width $Width -FolderNames $FolderNames
}