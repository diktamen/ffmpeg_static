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

REM Add Defender exclusions so vcpkg tools (pkgconf, conftest, msys2) aren't blocked
REM by group policy. This is idempotent -- adding the same path twice is a no-op.
echo Ensuring Windows Defender exclusions for vcpkg directories...
powershell -Command "try { Add-MpPreference -ExclusionPath '%~dp0buildtrees','%~dp0installed','%~dp0downloads' -ErrorAction Stop } catch { Write-Host '  Warning: could not add Defender exclusions (need admin?)' }"

echo Building FFmpeg as static libraries for x64, x86, and arm64 architectures...

vcpkg install ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x86-windows-staticlib-md ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:arm64-windows-staticlib-md --overlay-ports=overlays --overlay-triplets=triplets --host-triplet=x64-windows --classic

echo.
echo Done. Verify with:
echo   dir installed\x64-windows-staticlib-md\lib\*.lib
echo   dir installed\x86-windows-staticlib-md\lib\*.lib
echo   dir installed\arm64-windows-staticlib-md\lib\*.lib
