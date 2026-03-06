# Build FFmpeg as truly static libraries with /MD runtime (staticlib-md triplets)
# These triplets bypass the overlay's dynamic linkage override in overlays/ffmpeg/portfile.cmake.
# The overlay checks TARGET_TRIPLET for "staticlib-md" suffix and skips forcing dynamic linkage.
#
# Prerequisites:
#   - vcpkg bootstrapped in this directory
#   - Custom triplets in triplets/ (x64/x86/arm64-windows-staticlib-md.cmake)
#   - Overlay port in overlays/ffmpeg/
#
# Output: installed\*-windows-staticlib-md\lib\ will contain static .lib files
#
# Note: vcpkg's pkgconfig post-processing step fails with "operation not permitted"
# on this machine (group policy). The actual FFmpeg compilation succeeds, but vcpkg
# reports BUILD_FAILED. The workaround is to copy the built files from packages\ to
# installed\ manually — this script does that automatically.

$triplets = @("x64", "x86", "arm64")

Write-Host "Building FFmpeg as static libraries for x64, x86, and arm64 architectures..."

& "$PSScriptRoot\vcpkg.exe" install `
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md" `
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x86-windows-staticlib-md" `
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:arm64-windows-staticlib-md" `
    --overlay-ports=overlays `
    --overlay-triplets=triplets `
    --host-triplet=x64-windows `
    --classic

# Workaround: copy FFmpeg libs from packages/ to installed/ for any triplet where
# vcpkg's pkgconfig step failed (the compilation itself succeeded).
Write-Host ""
Write-Host "Copying FFmpeg libs from packages to installed (pkgconfig workaround)..."

foreach ($arch in $triplets) {
    $triplet = "$arch-windows-staticlib-md"
    $pkgDir = "$PSScriptRoot\packages\ffmpeg_$triplet"
    $instDir = "$PSScriptRoot\installed\$triplet"

    if (-not (Test-Path "$pkgDir\lib")) {
        Write-Host "  $triplet : no package output found, skipping (build may have failed)"
        continue
    }

    # Check if installed dir already has the ffmpeg libs (vcpkg succeeded for this triplet)
    if (Test-Path "$instDir\lib\avcodec.lib") {
        Write-Host "  $triplet : already installed, skipping"
        continue
    }

    Write-Host "  $triplet : copying from packages..."

    # Create target directories
    New-Item -ItemType Directory -Force -Path "$instDir\lib" | Out-Null
    New-Item -ItemType Directory -Force -Path "$instDir\include" | Out-Null
    New-Item -ItemType Directory -Force -Path "$instDir\debug\lib" | Out-Null

    # Copy release libs, headers, and debug libs
    Copy-Item "$pkgDir\lib\*.lib" "$instDir\lib\" -Force
    Copy-Item "$pkgDir\include\*" "$instDir\include\" -Recurse -Force
    Copy-Item "$pkgDir\debug\lib\*.lib" "$instDir\debug\lib\" -Force
}

Write-Host ""
Write-Host "Done. Verify with:"
foreach ($arch in $triplets) {
    Write-Host "  dir installed\$arch-windows-staticlib-md\lib\*.lib"
}
