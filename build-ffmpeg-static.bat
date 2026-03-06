@echo off
REM Build FFmpeg as truly static libraries with /MD runtime (staticlib-md triplets)
REM These triplets bypass the overlay's dynamic linkage override in overlays/ffmpeg/portfile.cmake.
REM The overlay checks TARGET_TRIPLET for "staticlib-md" suffix and skips forcing dynamic linkage.
REM
REM Prerequisites:
REM   - vcpkg bootstrapped in this directory
REM   - Custom triplets in triplets/ (x64/x86/arm64-windows-staticlib-md.cmake)
REM   - Overlay port in overlays/ffmpeg/
REM
REM Output: installed\*-windows-staticlib-md\lib\ will contain static .lib files
REM
REM Note: vcpkg's pkgconfig post-processing step fails with "operation not permitted"
REM on this machine (group policy). The actual FFmpeg compilation succeeds, but vcpkg
REM reports BUILD_FAILED. The workaround is to copy the built files from packages\ to
REM installed\ manually -- this script does that automatically.

echo Building FFmpeg as static libraries for x64, x86, and arm64 architectures...

vcpkg install ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x86-windows-staticlib-md ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:arm64-windows-staticlib-md --overlay-ports=overlays --overlay-triplets=triplets --host-triplet=x64-windows --classic

echo.
echo Copying FFmpeg libs from packages to installed (pkgconfig workaround)...

for %%A in (x64 x86 arm64) do (
    set "TRIPLET=%%A-windows-staticlib-md"
    call :copy_if_needed %%A
)

echo.
echo Done. Verify with:
echo   dir installed\x64-windows-staticlib-md\lib\*.lib
echo   dir installed\x86-windows-staticlib-md\lib\*.lib
echo   dir installed\arm64-windows-staticlib-md\lib\*.lib
goto :eof

:copy_if_needed
set "ARCH=%1"
set "TRIPLET=%ARCH%-windows-staticlib-md"
set "PKGDIR=%~dp0packages\ffmpeg_%TRIPLET%"
set "INSTDIR=%~dp0installed\%TRIPLET%"

if not exist "%PKGDIR%\lib" (
    echo   %TRIPLET% : no package output found, skipping
    goto :eof
)
if exist "%INSTDIR%\lib\avcodec.lib" (
    echo   %TRIPLET% : already installed, skipping
    goto :eof
)

echo   %TRIPLET% : copying from packages...
if not exist "%INSTDIR%\lib" mkdir "%INSTDIR%\lib"
if not exist "%INSTDIR%\include" mkdir "%INSTDIR%\include"
if not exist "%INSTDIR%\debug\lib" mkdir "%INSTDIR%\debug\lib"

xcopy /Y /Q "%PKGDIR%\lib\*.lib" "%INSTDIR%\lib\" >nul
xcopy /Y /Q /S "%PKGDIR%\include\*" "%INSTDIR%\include\" >nul
xcopy /Y /Q "%PKGDIR%\debug\lib\*.lib" "%INSTDIR%\debug\lib\" >nul
goto :eof
