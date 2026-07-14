[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetDirectory,

    [Alias('r')]
    [switch]$Recurse
)

$ErrorActionPreference = 'Stop'
$outputFileName = 'file-list.txt'
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = [System.IO.Path]::GetFullPath($MyInvocation.MyCommand.Path)
$outputPath = Join-Path $scriptDirectory $outputFileName
$temporaryPath = Join-Path $scriptDirectory ('.file-list.{0}.tmp' -f [Guid]::NewGuid())

try {
    if (Test-Path -LiteralPath $outputPath -PathType Container) {
        throw "Cannot create $outputFileName because a directory with that name already exists beside the script."
    }

    if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
        $TargetDirectory = Read-Host 'Enter the directory to list (press Enter to use the script directory)'
        $TargetDirectory = $TargetDirectory.Trim().Trim('"')
        if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
            $TargetDirectory = $scriptDirectory
        }
    }

    $target = Get-Item -LiteralPath $TargetDirectory -Force
    if (-not $target.PSIsContainer) {
        throw "Not a directory: $TargetDirectory"
    }

    $getChildItemParameters = @{
        LiteralPath = $target.FullName
        File        = $true
        Force       = $true
    }
    if ($Recurse) {
        $getChildItemParameters.Recurse = $true
    }

    $outputFullPath = [System.IO.Path]::GetFullPath($outputPath)
    $names = @(
        Get-ChildItem @getChildItemParameters |
            Where-Object {
                $fileFullPath = [System.IO.Path]::GetFullPath($_.FullName)
                (-not [StringComparer]::OrdinalIgnoreCase.Equals($fileFullPath, $outputFullPath)) -and
                    (-not [StringComparer]::OrdinalIgnoreCase.Equals($fileFullPath, $scriptPath))
            } |
            Sort-Object Name, FullName |
            Select-Object -ExpandProperty Name
    )

    $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($temporaryPath, [string[]]$names, $utf8WithoutBom)
    Move-Item -LiteralPath $temporaryPath -Destination $outputPath -Force

    Write-Host ("Wrote {0} file name(s) to: {1}" -f $names.Count, $outputPath)
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }
}
