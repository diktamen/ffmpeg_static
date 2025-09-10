@echo off
REM Build FFmpeg with DLL overlay to force shared libraries even with static triplets
echo Building FFmpeg with DLL overlay for x64, x86, and arm64 architectures...

vcpkg install ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x64-windows-static-md ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x86-windows-static-md ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:arm64-windows-static-md --overlay-ports=overlays --classic

echo.
echo Build completed. FFmpeg DLLs should be available in the installed directory.
