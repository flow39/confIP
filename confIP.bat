@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
	
REM Debut du script de configuration des interfaces reseau
echo Choix :
echo [a] Contexte 1
echo [b] Contexte 2
echo [c] Contexte 3
echo.
:choice
SET /P C=[a,b]?
for %%? in (a) do if /I "%C%"=="%%?" goto a
for %%? in (b) do if /I "%C%"=="%%?" goto b
goto choice
:a
@ECHO OFF
ECHO Activation du DHCP
SET NomConnexion=Wi-Fi

netsh interface ip set address name=%NomConnexion% source=dhcp
netsh interface IP set dnsservers name=%NomConnexion% source=dhcp

ipconfig /renew

echo Suppression du proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /t REG_SZ /d "" /f

ECHO Nouvelle configuration pour %computername%:
netsh int ip show config

pause
goto end

:b
@ECHO OFF
SET IP=xx.xx.xx.xx
SET Mask=255.255.255.0
SET Gate=xx.xx.xx.xx
SET DNS=xx.xx.xx.xx
SET NomConnexion=Ethernet 11

netsh interface ip set address name=%NomConnexion% source=static
netsh interface ip set address name=%NomConnexion% static %IP% %Mask% %Gate% 1
netsh interface IP set DNS name=%NomConnexion% static %DNS% primary

ECHO Configuration du proxy Entreprise
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /t REG_SZ /d http://[URL].pac /f

netsh int ip show config
pause
goto end

:c
@ECHO OFF
ECHO Activation du DHCP
SET NomConnexion=Ethernet 11

netsh interface ip set address name=%NomConnexion% source=dhcp
netsh interface IP set dnsservers name=%NomConnexion% source=dhcp

ipconfig /renew

echo Suppression du proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /t REG_SZ /d "" /f

ECHO Nouvelle configuration pour %computername%:
netsh int ip show config

pause
goto end


:end