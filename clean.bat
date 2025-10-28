@echo off
REM Clean vcpkg build artifacts and binary caches for a fresh rebuild
echo Cleaning vcpkg build artifacts and caches...
echo.

REM Clean local vcpkg directories
echo Removing buildtrees directory...
if exist buildtrees rmdir /s /q buildtrees

echo Removing packages directory...
if exist packages rmdir /s /q packages

echo Removing installed directory...
if exist installed rmdir /s /q installed

echo Removing downloads directory...
if exist downloads rmdir /s /q downloads

echo.
echo Cleaning local vcpkg binary cache...

REM Clean the local binary cache directory
set LOCAL_CACHE=%~dp0vcpkg_cache
echo Removing local binary cache at %LOCAL_CACHE%...
if exist "%LOCAL_CACHE%" rmdir /s /q "%LOCAL_CACHE%"

echo.
echo Clean completed! You can now run build-ffmpeg-dll.bat for a fresh build.
