# Mitigate https://github.com/microsoft/terminal/issues/280#issuecomment-1728298632
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Where is scoutapps/ ?
$projectDir = Split-Path -Parent $PSScriptRoot

# Make a desktop folder for Sonic Scout
$desktopDir = [Environment]::GetFolderPath("Desktop")
$scoutDir = "$desktopDir\Sonic Scout"
if (-not (Test-Path "$scoutDir")) { $null = New-Item -ItemType Directory "$scoutDir" }

# Link to Android Studio
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$scoutDir\Scout Android Studio.lnk")
$shortcut.TargetPath = "$projectDir\dk.cmd"
$shortcut.IconLocation = "$projectDir\packaging\icons\android-studio.ico"
$shortcut.Arguments = "SonicScout_Setup.Develop android"
$shortcut.Save()

# Link to QR Scanner
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$scoutDir\Scout QR Scanner.lnk")
$shortcut.TargetPath = "$projectDir\dk.cmd"
$shortcut.IconLocation = "$projectDir\packaging\icons\qrscanner.ico"
$shortcut.Arguments = "SonicScout_Setup.Develop scanner"
$shortcut.Save()

# Link to compile. Pause at end since text with no UI.
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$scoutDir\Scout Compile.lnk")
$shortcut.TargetPath = "$projectDir\dk.cmd"
$shortcut.IconLocation = "$projectDir\packaging\icons\compile.ico"
$shortcut.Arguments = "SonicScout_Setup.Develop compile & pause"
$shortcut.Save()

# Link to database
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$scoutDir\Scout Database.lnk")
$shortcut.TargetPath = "$projectDir\dk.cmd"
$shortcut.IconLocation = "$projectDir\packaging\icons\database.ico"
$shortcut.Arguments = "SonicScout_Setup.Develop database"
$shortcut.Save()

# Link to clean. Pause at end since text with no UI.
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$scoutDir\Scout Clean.lnk")
$shortcut.TargetPath = "$projectDir\dk.cmd"
$shortcut.IconLocation = "$projectDir\packaging\icons\clean-danger2.ico"
$shortcut.Arguments = "SonicScout_Setup.Clean --all & pause"
$shortcut.Save()

# Link to upgrade. Pause at end since text with no UI.
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$scoutDir\Scout Update.lnk")
$shortcut.TargetPath = "cmd"
$shortcut.WorkingDirectory = "$projectDir"
$shortcut.IconLocation = "$projectDir\packaging\icons\update.ico"
$shortcut.Arguments = "/C `"git pull --ff-only & pause`""
$shortcut.Save()
