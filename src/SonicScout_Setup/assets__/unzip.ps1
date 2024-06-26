param(
    [Parameter(Position = 0)]
    $ZipFile,
    [Parameter(Position = 1)]
    $DestDir
)

Expand-Archive -Force -LiteralPath $ZipFile -DestinationPath $DestDir
