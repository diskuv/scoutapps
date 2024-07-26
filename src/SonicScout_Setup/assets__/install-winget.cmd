@ECHO OFF

REM https://github.com/microsoft/terminal/issues/280#issuecomment-1728298632
REM (also see install-winget.ps1)
chcp 437 > NUL

powershell -ExecutionPolicy Bypass %~dp0install-winget.ps1 %*