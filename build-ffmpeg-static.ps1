# Build FFmpeg as truly static libraries with /MD runtime (staticlib-md triplets)
# These triplets bypass the overlay's dynamic linkage override in overlays/ffmpeg/portfile.cmake.
# The overlay checks TARGET_TRIPLET for "staticlib-md" suffix and skips forcing dynamic linkage.
#
# Prerequisites:
#   - vcpkg bootstrapped in this directory
#   - Custom triplets in triplets/ (x64/x86/arm64-windows-staticlib-md.cmake)
#   - Overlay port in overlays/ffmpeg/
#
# Output: C:\libraries\ffmpeg_static\{arch}\

# Clear build artifacts from any previous run to avoid cross-contamination.
# Downloads are preserved - they contain cached tarballs and tools.
Write-Host "Clearing build directories..."
foreach ($dir in @("buildtrees", "installed", "packages")) {
    $path = "$PSScriptRoot\$dir"
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
    }
}

# Add Defender exclusions so vcpkg tools (pkgconf, conftest, msys2) aren't blocked
# by group policy. This is idempotent - adding the same path twice is a no-op.
Write-Host "Ensuring Windows Defender exclusions for vcpkg directories..."
try {
    Add-MpPreference -ExclusionPath "$PSScriptRoot\buildtrees" -ErrorAction Stop
    Add-MpPreference -ExclusionPath "$PSScriptRoot\installed" -ErrorAction Stop
    Add-MpPreference -ExclusionPath "$PSScriptRoot\downloads" -ErrorAction Stop
} catch {
    Write-Host "  Warning: could not add Defender exclusions (need admin?): $_"
    Write-Host "  Build may fail if group policy blocks newly-built executables."
}

Write-Host "Building FFmpeg as static libraries for x64, x86, and arm64 architectures..."

& "$PSScriptRoot\vcpkg.exe" install `
    "ffmpeg[avcodec,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md" `
    "ffmpeg[avcodec,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:x86-windows-staticlib-md" `
    "ffmpeg[avcodec,avformat,core,swresample,swscale,mp3lame,opus,speex,vorbis]:arm64-windows-staticlib-md" `
    --overlay-ports=overlays `
    --overlay-triplets=triplets `
    --host-triplet=x64-windows `
    --classic

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed - aborting deploy."
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Deploying to C:\libraries\ffmpeg_static\..."
foreach ($arch in @("x64", "x86", "arm64")) {
    $triplet = "$arch-windows-staticlib-md"
    $dest = "C:\libraries\ffmpeg_static\$arch"

    New-Item -ItemType Directory -Force $dest | Out-Null
    Copy-Item "installed\$triplet\*" $dest -Recurse -Force

    Write-Host "  $arch`: done"
}
Write-Host "Done."
