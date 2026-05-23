# Build FFmpeg as shared DLLs using the static-md triplets.
# The overlay portfile.cmake forces VCPKG_LIBRARY_LINKAGE=dynamic for any triplet
# that does NOT end with "staticlib-md", so these produce DLLs despite the triplet
# nominally being "static".
#
# Output: C:\libraries\ffmpeg_dll\{arch}\

# Clear build artifacts from any previous run to avoid cross-contamination.
# Downloads are preserved — they contain cached tarballs and tools.
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
    Write-Host "Build failed — aborting deploy."
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Deploying to C:\libraries\ffmpeg_dll\..."
foreach ($arch in @("x64", "x86", "arm64")) {
    $triplet = "$arch-windows-static-md"
    $dest = "C:\libraries\ffmpeg_dll\$arch"

    New-Item -ItemType Directory -Force "$dest\bin" | Out-Null
    New-Item -ItemType Directory -Force "$dest\lib" | Out-Null
    Copy-Item "installed\$triplet\bin\*.dll" "$dest\bin" -Force
    Copy-Item "installed\$triplet\lib\*.lib" "$dest\lib" -Force

    $pdbs = Get-ChildItem "installed\$triplet\bin\*.pdb" -ErrorAction SilentlyContinue
    if ($pdbs) { Copy-Item $pdbs.FullName "$dest\bin" -Force }

    New-Item -ItemType Directory -Force "$dest\lib\pkgconfig" | Out-Null
    Copy-Item "installed\$triplet\lib\pkgconfig\*.pc" "$dest\lib\pkgconfig" -Force

    Copy-Item "installed\$triplet\include" "$dest\include" -Recurse -Force

    $dlls = (Get-ChildItem "$dest\bin\*.dll").Count
    $libs = (Get-ChildItem "$dest\lib\*.lib").Count
    $pcs  = (Get-ChildItem "$dest\lib\pkgconfig\*.pc").Count
    $hdrs = (Get-ChildItem "$dest\include" -Recurse -File).Count
    Write-Host "  $arch`: $dlls DLLs, $libs import libs, $pcs .pc files, $hdrs headers"
}
Write-Host "Done."
