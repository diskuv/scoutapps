param(
    [Parameter(Position = 0)]
    $ZipFile,
    [Parameter(Position = 1)]
    $DestDir
)

# https://github.com/PowerShell/Microsoft.PowerShell.Archive/issues/32
$progressPreference = 'SilentlyContinue';

Expand-Archive -Force -LiteralPath $ZipFile -DestinationPath $DestDir
