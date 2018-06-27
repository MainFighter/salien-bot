@echo off

:: Made by Main Fighter [mainfighter.com]
:: Simple start script for meepen's sailen-bot [https://github.com/meepen/salien-bot]
:: v1.7.2 [24-06-2018]

::===============================================================================================================::

:Greeting

call configuration.cmd 
@echo %echo%

title "Start script for meepen's sailens-bot"
color %cmdcolor%

:: Checks
:: NodeJS
node.exe --version >nul 2>nul 
if %errorlevel%==9009 ( set error=NodeJS not found & set fatal=true & start "" https://nodejs.org/en/ & call :ErrorScreen )
:: Git
git.exe --version >nul 2>nul 
if %autodownloadbot%==true if %autoupdatebot%==true if %errorlevel%==9009 ( set error=Git not found & set autodownloadbot=false & set autoupdatebot=false & start "" https://git-scm.com/ & call :ErrorScreen )

::===============================================================================================================::

:: Sets rootdir var to the currently directory of script
set rootdir=%~dp0

:: Clone botfiles
if %autodownloadbot%==true (
    color %cmdcolor%
    title Bot File Download
    echo.
    echo Downloading bot files
    echo.
    cd "%rootdir%"
    call :DownloadBotFiles
    if %debug%==true pause
    cls
)

:: Checks if bot files exist, if they don't the script will throw fatal error
if not exist "%botdirectory%" ( 
    set error=%botdirectory% not found 
    set fatal=true
    
    if not exist "%botdirectory%\headless.js" ( 
        set error2=%botdirectory%\headless.js not found 
        set fatal=true 
    )
    
    call :ErrorScreen
    if %debug%==true pause
    cls
)

:: Update botfiles
if %autoupdatebot%==true (
    color %cmdcolor%
    title Update Bot Files
    echo.
    echo Updating bot files
    echo.
    cd "%rootdir%"
    call :UpdateBotFiles
    if %debug%==true pause
    cls
)

:: npm install
if %npminstall%==true (
    color %cmdcolor%
    title Run npm install
    echo.
    echo Running npm install
    echo.
    cd "%rootdir%"
    call :npmInstall
    if %debug%==true pause
    cls
)

:: Sets up token for all bots
color %cmdcolor%
title Bot Token Setup
echo.
echo Setting up bot tokens
cd "%rootdir%"
for %%a in ("instances\*.cmd") do call :SetDefaults & cd "%rootdir%" & call "%%a" & call :SetupToken
if %debug%==true pause
cls

:: Start all bots in config
color %cmdcolor%
title Bot Start
echo.
echo Starting bots
cd "%rootdir%"
for %%a in ("instances\*.cmd") do call :SetDefaults & cd "%rootdir%" & call "%%a" & call :StartScript
if %debug%==true pause
cls

::===============================================================================================================::

:Farewell

exit

::===============================================================================================================::

:DownloadBotFiles

:: Checks to make sure botfiles doesn't already exist > if it doesn't it clones the bot files to the botfiles directory
if not exist "%botdirectory%" ( git clone --quiet https://github.com/meepen/salien-bot.git "%botdirectory%" ) else ( echo Bot files already exist )

goto :eof

::===============================================================================================================::

:UpdateBotFiles

:: Checks if botfiles exists > if it does then update botfiles using git and run npm install
if exist "%botdirectory%" ( cd "%botdirectory%" & git pull --quiet ) else ( echo Bot files don't exist )

goto :eof

::===============================================================================================================::

:npmInstall

:: Checks if botfiles exists > if exists change to directory and run npm install
if exist "%botdirectory%" ( cd "%botdirectory%" & call npm install & @echo %echo% ) else ( echo Bot files don't exist )

goto :eof

::===============================================================================================================::

:SetupToken

echo.

:: Probably not the best way to do it but it works
if %name%==untitled ( goto :eof )
if %enabled%==false ( echo %name% - Disabled & goto :eof )

echo %name% - Setting up token

:: Checks
if not exist "tokens\%name%.json" if not defined gettoken ( echo %name% - Token file not found and token not set in instance config & goto :eof )

:: Checks if gettoken.json exists > if it doesn't write the token from the instance config file
if not exist "tokens" ( mkdir "tokens" )
if not exist "tokens\%name%.json" ( echo %gettoken% >> "tokens\%name%.json" & echo %name% - Token setup ) else ( echo %name% - Token already setup )

goto :eof

::===============================================================================================================::

:StartScript

echo.

:: Probably not the best way to do it but it works
if %name%==untitled ( goto :eof )
if %enabled%==false ( echo %name% - Disabled & goto :eof )

echo %name% - Starting bot

:: Checks
if not exist "tokens\%name%.json" ( echo %name% - No token file bot not starting & pause & goto :eof )

:: Opens CMD Window > Sets title and color of window > Changes to dir > starts bot
set commandline="title Sailen Bot - %name% & color %color% & cd %botdirectory% & node headless --token ..\tokens\%name%.json %botargs% & if %debug%==true pause & exit"
if %minimized%==true (start /min cmd /k  %commandline%) else (start cmd /k %commandline%)

goto :eof

::===============================================================================================================::

:ErrorScreen

cls
color 47
if %fatal%==true ( title %name% - ERROR ) else ( title %name% - FATAL ERROR )
echo.
if %fatal%==true ( echo FATAL ERROR & echo %error% & if defined error2 echo %error2% ) else ( echo ERROR & echo %error% & if defined error2 echo %error2% )
echo.

pause
if %fatal%==true exit

set error=unknown
set error2=
set fatal=false

goto :eof

::===============================================================================================================::

:SetDefaults

:: Don't change these
set enabled=false
set gettoken=
set botargs=
set minimized=false
set name=untitled
set color=0C

goto :eof