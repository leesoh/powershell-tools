<#
.SYNOPSIS
    Creates a folder structure, populates with data, and arbitrary files.

.DESCRIPTION
    Creates a mock filesystem. Be careful as the number of folders created will increase geometrically. Default
    settings result in 780 folders.

.PARAMETER Path
    Target for root of hierarchy.

.PARAMETER Depth
    Number of levels deep to write. Defaults to three.

.PARAMETER Width
    Number of folders to create at each level. Defaults to five.

.PARAMETER Files
    Number of files to create in each folder.

.EXAMPLE

.NOTES
    To Do:
    - Add randomness to number of files/folders at each level
    - Add file creation
#>

[CmdletBinding()]

Param (
    #[Parameter(Mandatory = $True)]
    #[ValidateScript({Test-Path -Path $_})]
    [string]
    $Path = "C:\Users\Liam\downloads",
    [int]
    [ValidateRange(0,4)]
    $Depth = 3,
    [int]
    [ValidateRange(1,15)]
    $Width = 5,
    [ValidateRange(1,15)]
    [int]
    $Files = 5
)

function New-WideFolders {
    param (
        [Parameter(Mandatory = $True)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $Path,
        [Parameter(Mandatory = $True)]
        [string[]]
        $FolderNames#,
        #[Parameter(Mandatory = $True)]
        #[ValidateRange(1,15)]
        #$Width
    )
    for ($i = 0; $i -lt $Width; $i++) {
        $Folder = Get-Random -InputObject $FolderNames
        $FolderNames = $FolderNames | Where-Object {$_ -ne $Folder}

        Write-Verbose -Message "Now creating $Folder in $Path"
        New-Item -Path $Path -ItemType Directory -Name $Folder
    }
}

function New-Folders {
    param (
        $Depth,
        $FolderNames,
        $Path
    )
    Write-Verbose -Message "Now at $Depth levels deep ($Path)"
    New-WideFolders -Path $Path -FolderNames $FolderNames
    # Probably make files here
    if ($Depth -gt 0) {
        Write-Verbose -Message "Going deeper..."
        $Depth--
        $CurrentFolders = Get-ChildItem -Path $Path
        foreach ($c in $CurrentFolders) {
            New-Folders -Depth $Depth -FolderNames $FolderNames -Path "$Path\$c"
        }
    }

}

$ShareName = 'MyShare'
$SharePath = "$Path\$ShareName"
$FolderNames = @('Data', 'Logs', 'Reports', 'Files', 'Pictures', 'Scans', 'Kangaroo', 'Peanut', 'Ice Cream')
$FileNames = @('first_try', 'pancakes', '2016-Financials', 'Ergo', 'Wingnuts', 'scan')

New-Item -Path $Path -Type Directory -Name $ShareName

New-Folders -Depth $Depth -FolderNames $FolderNames -Path $SharePath
