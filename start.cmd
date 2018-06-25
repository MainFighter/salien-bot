@echo off

:: Made by Main Fighter [mainfighter.com]
:: Simple start script for meepen's sailen-bot [https://github.com/meepen/salien-bot]
:: v1.7.0 [24-06-2018]

::===============================================================================================================::

:Greeting

:: Calls configuration stuff
call configuration.cmd
@echo %echo%

title "Start script for meepen's sailent-bot"
color 0A

:: Checks
:: NodeJS
node.exe --version >nul 2>nul 
if %errorlevel%==9009 (color 40 & echo [NEEDED] Node is needed for bot & start "" https://nodejs.org/en/ & pause & exit)
:: Git
git.exe --version >nul 2>nul 
if %autodownloadbot%==true if %autoupdatebot%==true if %errorlevel%==9009 (color 40 & echo [OPTIONAL] Git is required for Auto Download and Update functions & set autodownloadbot=false & set autoupdatebot=false & start "" https://git-scm.com/ & pause)

::===============================================================================================================::

:: Sets rootdir var to the currently directory of script
set rootdir=%~dp0

:: Clone botfiles
if %autodownloadbot%==true (
    cls
    title Downloading bot files
    echo Downloading bot files
    echo.
    cd %rootdir%
    call :DownloadBotFiles
    if %debug%==true pause
)

:: Update botfiles
if %autoupdatebot%==true (
    cls
    title Updating bot files
    echo Updating bot files
    echo.
    cd %rootdir%
    call :UpdateBotFiles
    if %debug%==true pause
)

:: Sets up token for all bots
cls
title Setting up bot tokens
echo Setting up bot tokens
echo.
cd %rootdir%
for %%f in ("instances\*.cmd") do call :SetDefaults & cd %rootdir% & call "%%f" & call :SetupToken
if %debug%==true pause

:: Start all bots in config
cls
title Starting bots
echo Starting bots
echo.
cd %rootdir%
for %%f in ("instances\*.cmd") do call :SetDefaults & cd %rootdir% & call "%%f" & call :StartScript
if %debug%==true pause

::===============================================================================================================::

:Farewell

exit

::===============================================================================================================::

:DownloadBotFiles

title Downloading bot files
echo.
echo Downloading bot Files

:: Checks if bot files don't already exist > if they don't creates folder > if they don't clones bot to directory
if not exist botfiles ( git clone --quiet https://github.com/meepen/salien-bot.git botfiles ) else ( echo Bot files already exist )

goto :eof

::===============================================================================================================::

:UpdateBotFiles

title Updating bot files
echo.
echo Updating bot files

:: Checks if bot directory exists > if it does change to bot directory > if exists git pull to update
if exist botfiles ( cd botfiles & git pull --quiet ) else ( echo Bot files don't exist )

goto :eof

::===============================================================================================================::

:SetupToken

:: Probably not the best way to do it but it works
if %enabled%==false goto :eof

title Setting up token
echo.
echo Setting up token

:: Checks
if not exist "botfiles\%name%.json" if not defined gettoken echo %name% Token not in instance config & goto :eof

:: Checks if gettoken.json exists > if it doesn't write the token from the instance config file
if not exist "botfiles\%name%.json" ( echo %gettoken% >> botfiles\%name%.json & echo %name% - Token setup ) else ( echo %name% - Token already setup )

goto :eof

::===============================================================================================================::

:StartScript

:: Probably not the best way to do it but it works
if %enabled%==false goto :eof

title %name% - Starting Bot
echo.
echo %name% - Starting bot

:: Checks
if not exist "botfiles\%name%.json" ( echo %name% - Token is missing bot not starting & pause & goto :eof )

:: Opens CMD Window > Sets title and color of window > Changes to dir > runs npm install if enabled > starts bot
set commandline="title Sailen Bot - %name% & color %color% & cd botfiles & if %npminstall%==true call npm install & node headless --token %name%.json %botargs% & if %debug%==true pause & exit"
if %minimized%==true (start /min cmd /k  %commandline%) else (start cmd /k %commandline%)

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