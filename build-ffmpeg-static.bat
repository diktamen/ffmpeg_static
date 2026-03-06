@echo off
REM Build FFmpeg as truly static libraries with /MD runtime (staticlib-md triplets)
REM These triplets bypass the overlay's dynamic linkage override.
echo Building FFmpeg as static libraries for x64, x86, and arm64 architectures...

vcpkg install ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x86-windows-staticlib-md ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:arm64-windows-staticlib-md --overlay-ports=overlays --classic

echo.
echo Build completed. Check installed\*-windows-staticlib-md\lib\ for static .lib files.
