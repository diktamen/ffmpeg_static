# Diktamen FFmpeg builds on top of vcpkg

This repository is a fork of [microsoft/vcpkg](https://github.com/microsoft/vcpkg)
that produces two FFmpeg builds for Windows (x64, x86, arm64). Everything that is
not stock vcpkg lives in these places:

| Path | Purpose |
|------|---------|
| `overlays/ffmpeg/` | Overlay port: copy of the upstream `ports/ffmpeg` files plus our changes |
| `triplets/*-windows-staticlib-md.cmake` | Custom triplets (see below) |
| `ports/ffmpeg/build.sh.in` | One-line hook, kept in sync with the overlay copy |
| `build-ffmpeg-dll.ps1` | Builds the self-contained DLLs |
| `build-ffmpeg-static.ps1`, `build-ffmpeg-static-x64.ps1` | Builds the audio-only static libs |
| `clean.bat` | Wipes build dirs and the local binary cache |

Branch `feature/static-ffmpeg` carries all of this. `master` tracks upstream.

## Why this repo exists

The C runtime selection is **not** what makes this repo special. Every build here
uses the dynamic CRT (`/MD`), which is exactly what vcpkg's stock
`x64-windows-static-md` triplet does. The repo exists for three things vcpkg
cannot do out of the box:

1. **Self-contained FFmpeg DLLs.** Stock `x64-windows` produces avcodec.dll plus
   separate DLLs for lame, opus, vorbis and speex. We build under a static triplet
   so every dependency is a static lib, then flip only FFmpeg itself to dynamic
   linkage. Result: FFmpeg DLLs with the codecs baked in, nothing else to ship,
   still on the shared CRT.

2. **An audio-only static library.** vcpkg features can add or remove whole
   libraries but cannot pass `--disable-everything` and re-enable a handful of
   decoders. We inject extra configure flags to get a small decoder-only build.

3. **A local source patch** to `libavformat/http.c` that is not upstream yet
   (see below).

If the DLL build stops mattering and the http patch lands upstream, only item 2
still justifies an overlay.

## How the two builds are selected

`overlays/ffmpeg/portfile.cmake` keys on the triplet name and then includes the
unmodified upstream `ports/ffmpeg/portfile.cmake`:

- **Stock `*-windows-static-md` triplets** (used by `build-ffmpeg-dll.ps1`):
  the overlay forces `VCPKG_LIBRARY_LINKAGE dynamic` for FFmpeg only. The
  dependencies were already built static by the triplet, so they get linked into
  the FFmpeg DLLs. Full feature set plus the ffmpeg, ffplay and ffprobe tools.

- **Custom `*-windows-staticlib-md` triplets** (used by the static scripts):
  identical content to the stock static-md triplets (static libs, dynamic CRT).
  They exist only so the overlay can tell the two builds apart by name. For these
  the overlay sets `EXTRA_CONFIGURE_OPTIONS` to `--disable-everything` followed by
  the audio decoders (mp3, aac, opus, vorbis, speex, flac, alac, pcm), their
  demuxers and parsers, and the file/pipe/crypto/data protocols. Windows video
  hardware paths (d3d11va, d3d12va, dxva2, mediafoundation) are disabled.

### The build.sh.in hook

Upstream's `build.sh.in` gives a portfile no way to add configure flags, so we
append `${EXTRA_CONFIGURE_OPTIONS}` to the configure line. The overlay copies its
patched `build.sh.in` over `ports/ffmpeg/build.sh.in` before including the
upstream portfile. Both copies must stay identical.

## Local source patches

`overlays/ffmpeg/0100-http-connection-token-parse.patch`

FFmpeg compared the whole `Connection` header value against `close`. Apache with
mod_http2 answers `Connection: Upgrade, close`, which did not match, so FFmpeg
reused a socket the server had already closed. The size-probing seek then failed,
`avio_size()` returned nothing, and the mp3 demuxer reported duration 0 and
stopped after half a second. The patch tokenises the header on commas. It was
submitted to ffmpeg-devel; drop the file once it appears upstream.

All other patches in `overlays/ffmpeg/` are verbatim copies of upstream's.

## Updating from upstream

```powershell
git fetch upstream
git merge upstream/master
```

Expect conflicts only in `ports/ffmpeg/` when upstream bumps FFmpeg. Then:

1. Resolve `ports/ffmpeg/portfile.cmake`: take upstream's patch list and keep
   `0100-http-connection-token-parse.patch` at the end.
2. Keep the `${EXTRA_CONFIGURE_OPTIONS}` line in `ports/ffmpeg/build.sh.in`.
3. Re-sync `overlays/ffmpeg/`: copy upstream's patches, `vcpkg.json`,
   `vcpkg-cmake-wrapper.cmake`, `FindFFMPEG.cmake.in` and `usage` over the
   overlay copies, delete patches upstream dropped, save upstream's portfile as
   `portfile.cmake.upstream` for reference, and copy the patched
   `build.sh.in` over the overlay's.
4. Check that `0100-...patch` still applies to the new FFmpeg version
   (`patch -p1 --dry-run` against `libavformat/http.c` from the matching tag).
5. Check that every flag in the overlay's `EXTRA_CONFIGURE_OPTIONS` still exists
   in the new `configure`.
6. Run the build scripts. A patch dry-run is not a build.

## Build notes

- Scripts clear `buildtrees`, `installed` and `packages` before each run and use
  a repo-local binary cache in `vcpkg_cache/` so unchanged ports are not rebuilt.
- `--host-triplet=x64-windows` is required so x86 and arm64 can be cross-built
  from an x64 host.
- vcpkg's pkgconfig post-processing step fails with "operation not permitted"
  under group policy on the build machine even though compilation succeeds. The
  scripts copy the finished output from `packages/` to `installed/` themselves.
- Output is deployed to `C:\libraries\` (headers, release and debug libs, and
  pkgconfig files).
