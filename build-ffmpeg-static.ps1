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

# Add Defender exclusions so vcpkg tools (pkgconf, conftest, msys2) aren't blocked
# by group policy. This is idempotent — adding the same path twice is a no-op.
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
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x64-windows-staticlib-md" `
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:x86-windows-staticlib-md" `
    "ffmpeg[avcodec,avformat,core,swresample,mp3lame,opus,speex,vorbis]:arm64-windows-staticlib-md" `
    --overlay-ports=overlays `
    --overlay-triplets=triplets `
    --host-triplet=x64-windows `
    --classic

Write-Host ""
Write-Host "Done. Verify with:"
Write-Host "  dir installed\x64-windows-staticlib-md\lib\*.lib"
Write-Host "  dir installed\x86-windows-staticlib-md\lib\*.lib"
Write-Host "  dir installed\arm64-windows-staticlib-md\lib\*.lib"
