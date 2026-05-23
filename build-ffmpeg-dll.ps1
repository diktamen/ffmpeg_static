# Build FFmpeg as shared DLLs using the static-md triplets.
# The overlay portfile.cmake forces VCPKG_LIBRARY_LINKAGE=dynamic for any triplet
# that does NOT end with "staticlib-md", so these produce DLLs despite the triplet
# nominally being "static".
#
# Output: C:\libraries\ffmpeg_dll\{arch}\

# Clear build artifacts from any previous run to avoid cross-contamination.
# Downloads are preserved - they contain cached tarballs and tools.
Write-Host "Clearing build directories..."
foreach ($dir in @("buildtrees", "installed", "packages")) {
    $path = "$PSScriptRoot\$dir"
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
    }
}

Write-Host "Building FFmpeg as DLLs for x64, x86, and arm64 architectures..."

& "$PSScriptRoot\vcpkg.exe" install `
    "ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x64-windows-static-md" `
    "ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x86-windows-static-md" `
    "ffmpeg[ffmpeg,avcodec,avdevice,avfilter,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:arm64-windows-static-md" `
    --overlay-ports=overlays `
    --overlay-triplets=triplets `
    --host-triplet=x64-windows `
    --classic

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed - aborting deploy."
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Deploying to C:\libraries\ffmpeg_dll\..."
foreach ($arch in @("x64", "x86", "arm64")) {
    $triplet = "$arch-windows-static-md"
    $dest = "C:\libraries\ffmpeg_dll\$arch"

    New-Item -ItemType Directory -Force $dest | Out-Null
    Copy-Item "installed\$triplet\*" $dest -Recurse -Force

    Write-Host "  $arch`: done"
}
Write-Host "Done."
