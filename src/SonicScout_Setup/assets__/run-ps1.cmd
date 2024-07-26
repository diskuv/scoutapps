@ECHO OFF

REM https://github.com/microsoft/terminal/issues/280#issuecomment-1728298632
REM (also see RunCMake.ml's writing of vsdev-*.ps1)
chcp 437 > NUL

powershell -ExecutionPolicy Bypass %*
