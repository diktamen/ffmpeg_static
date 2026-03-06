# Build FFmpeg x64 only as truly static library (audio-only, staticlib-md triplet)
Write-Host "Building FFmpeg static for x64..."

& "$PSScriptRoot\vcpkg.exe" install `
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md" `
    --overlay-ports=overlays `
    --overlay-triplets=triplets `
    --host-triplet=x64-windows `
    --classic

Write-Host "Done."
