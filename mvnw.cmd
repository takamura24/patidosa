@echo off
REM Maven Wrapper script (Windows)
REM Downloads the Maven version specified in .mvn\wrapper\maven-wrapper.properties
REM into %USERPROFILE%\.m2\wrapper\dists and runs it, so you don't need Maven installed locally.

setlocal enabledelayedexpansion

set WRAPPER_DIR=%~dp0
set PROPS_FILE=%WRAPPER_DIR%.mvn\wrapper\maven-wrapper.properties

for /f "tokens=1,2 delims==" %%A in ('findstr "distributionUrl" "%PROPS_FILE%"') do set DIST_URL=%%B

for %%F in ("%DIST_URL%") do set DIST_ZIP=%%~nxF
set DIST_NAME=%DIST_ZIP:.zip=%
set CACHE_DIR=%USERPROFILE%\.m2\wrapper\dists\%DIST_NAME%
set MAVEN_HOME=%CACHE_DIR%\apache-maven

if not exist "%MAVEN_HOME%\bin\mvn.cmd" (
  echo Maven distribution not found locally, downloading: %DIST_URL%
  if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"
  set TMP_ZIP=%CACHE_DIR%\maven-dist.zip
  powershell -Command "Invoke-WebRequest -Uri '%DIST_URL%' -OutFile '%TMP_ZIP%'"
  powershell -Command "Expand-Archive -Path '%TMP_ZIP%' -DestinationPath '%CACHE_DIR%' -Force"
  for /d %%D in ("%CACHE_DIR%\apache-maven-*") do set EXTRACTED_DIR=%%D
  move "!EXTRACTED_DIR!" "%MAVEN_HOME%" >nul
  del "%TMP_ZIP%"
)

"%MAVEN_HOME%\bin\mvn.cmd" %*
