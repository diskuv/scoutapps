param(
    [Parameter(Position = 0)]
    $ZipFile,
    [Parameter(Position = 1)]
    $DestDir
)

# https://github.com/microsoft/terminal/issues/280#issuecomment-1728298632
# This happens in Windows Sandbox which starts in Consolas font.
# (also see unzip.cmd)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# https://github.com/PowerShell/Microsoft.PowerShell.Archive/issues/32
$progressPreference = 'SilentlyContinue';

Expand-Archive -Force -LiteralPath $ZipFile -DestinationPath $DestDir
