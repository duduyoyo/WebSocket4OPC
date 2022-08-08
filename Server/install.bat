@echo off

IF "%1"=="" GOTO :BLANK
IF "%2"=="" GOTO :BLANK

IF NOT EXIST C:\Windows\System32\inetsrv\appcmd.exe (
ECHO IIS service not installed. Run command to install: DISM /online /enable-feature /featureName:IIS-DefaultDocument /All
GOTO :BLANK
)

DISM /online /get-features | findstr /I /C:"IIS-WebSockets"
IF NOT %errorlevel% == 0 (
ECHO WebSockets not installed. Run command to install: DISM /online /enable-feature /featurename:IIS-WebSockets
GOTO :BLANK
)

copy /Y OPCModule.dll %windir%\System32\inetsrv
IF NOT %errorlevel% == 0 (
ECHO Copying OPCModule.dll to %windir%\System32\inetsrv failed. Check your folder and privilege.
GOTO :BLANK
)

SET currentPath=%cd%

pushd %windir%\System32\inetsrv

FOR /F delims^=^"^ tokens^=2 %%G IN ('appcmd list site /id:1') DO SET site=%%G
IF NOT %errorlevel% == 0 (
ECHO No site available. At least you need create a site as default one for IIS
GOTO :BLANK
)

FOR /F %%I in ('appcmd.exe list app "%site%/" /"text:[path='/'].physicalPath"') do set rootPathTemp=%%I
IF NOT %errorlevel% == 0 (
ECHO No physical path found for site. Check site configuration for proper physical path
GOTO :BLANK
)

FOR /F %%a in ('echo %rootPathTemp%') do set rootPath=%%a
IF NOT %errorlevel% == 0 (
ECHO No physical path %rootPath% found. Check your privilege accessing path %rootPathTemp%
GOTO :BLANK
)

IF exist %rootPath%\OPC (
rmdir /S /Q %rootPath%\OPC
)

xcopy /Y /I /Q /S %currentPath%\OPC %rootPath%\OPC\
IF NOT %errorlevel% == 0 (
ECHO Copying %currentPath%\OPC to %rootPath%\OPC\ failed. Check your folder and privilege.
GOTO :BLANK
)

regsvr32 /s %rootPath%\OPC\x64Proxy\opccomn_ps.dll
regsvr32 /s %rootPath%\OPC\x64Proxy\opcproxy.dll
regsvr32 /s %rootPath%\OPC\x64Proxy\opc_aeps.dll

appcmd add apppool /name:OPCPool
IF NOT %errorlevel% == 0 (
ECHO Add appPool OPCPool failed
GOTO :BLANK
)

appcmd set apppool "OPCPool" /autoStart:true /managedRuntimeVersion:"" /processModel.identityType:SpecificUser /processModel.userName:%1 /processModel.password:%2
IF NOT %errorlevel% == 0 (
ECHO Add account for OPCPool failed. Check user name and password (admin privilege required^)
GOTO :BLANK
)

appCmd set config -section:system.applicationHost/applicationPools /[name='OPCPool'].recycling.periodicRestart.time:"00:00:00"
IF NOT %errorlevel% == 0 (
ECHO Set OPCPool recycling time failed. Make sure OPCPool exists 
GOTO :BLANK
)

appcmd install module /add:false /name:OPCModule /image:%windir%\System32\inetsrv\OPCModule.dll
IF NOT %errorlevel% == 0 (
ECHO Register OPC module failed. Make sure %windir%\System32\inetsrv\OPCModule.dll exist
GOTO :BLANK
)

appcmd add app /site.name:"%site%" /path:/OPC /physicalPath:%rootPath%\OPC /applicationPool:OPCPool
IF NOT %errorlevel% == 0 (
ECHO Add OPC app failed. Make sure %currentPath%\OPC and OPCPool exist
GOTO :BLANK
)

appcmd unlock config /section:system.webServer/modules
IF NOT %errorlevel% == 0 (
ECHO Unlock config modules failed.
GOTO :BLANK
)

appcmd add module /name:OPCModule /app.name:"%site%/OPC"
IF NOT %errorlevel% == 0 (
ECHO Add OPC module failed. Make sure OPC module registered
GOTO :BLANK
)

appcmd unlock config /section:handlers
appcmd.exe set config "%site%/OPC" /section:handlers /+[name='OPCHandler',path='*.opc',modules='OPCModule',verb='*',resourceType='File',requireAccess='Read']
IF NOT %errorlevel% == 0 (
ECHO Add OPC handler failed. Make sure OPC module available and %site%/OPC exist
GOTO :BLANK
)

GOTO :DONE
:BLANK
ECHO usage: install.bat userAccount userPassword
ECHO 	userAccount - need have administrator privilege
:DONE
popd