@echo off
REM Build FFmpeg as shared DLLs using the static-md triplets.
REM The overlay portfile.cmake forces VCPKG_LIBRARY_LINKAGE=dynamic for any triplet
REM that does NOT end with "staticlib-md", so these produce DLLs despite the triplet
REM nominally being "static".
REM
REM Output: installed\*-windows-static-md\bin\ will contain .dll files
REM         installed\*-windows-static-md\lib\ will contain import .lib files

echo Building FFmpeg as DLLs for x64, x86, and arm64 architectures...

vcpkg install ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x64-windows-static-md ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x86-windows-static-md ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:arm64-windows-static-md --overlay-ports=overlays --overlay-triplets=triplets --host-triplet=x64-windows --classic

echo.
echo Build completed. FFmpeg DLLs should be available in installed\*-windows-static-md\bin\.
