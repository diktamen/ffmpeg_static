# Force dynamic linkage for the original static-md triplets (other projects need DLLs).
# The new staticlib-md triplets keep their native static linkage.
if(NOT TARGET_TRIPLET MATCHES "staticlib-md$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

# For staticlib-md (audio-only decoder DLL), strip all video and unneeded components.
# We set EXTRA_CONFIGURE_OPTIONS env var and patch the upstream build.sh.in to use it.
# Since these flags come AFTER the upstream's options, --disable-everything overrides
# any earlier --enable flags, then selective --enable-decoder=X re-enables audio only.
if(TARGET_TRIPLET MATCHES "staticlib-md$")
    set(ENV{EXTRA_CONFIGURE_OPTIONS} "\
--disable-d3d11va \
--disable-d3d12va \
--disable-dxva2 \
--disable-mediafoundation \
--disable-everything \
--enable-demuxer=ogg \
--enable-demuxer=mp3 \
--enable-demuxer=mov \
--enable-demuxer=wav \
--enable-demuxer=caf \
--enable-demuxer=aac \
--enable-demuxer=flac \
--enable-demuxer=matroska \
--enable-decoder=opus \
--enable-decoder=libopus \
--enable-decoder=mp3 \
--enable-decoder=mp3float \
--enable-decoder=aac \
--enable-decoder=aac_fixed \
--enable-decoder=vorbis \
--enable-decoder=libvorbis \
--enable-decoder=speex \
--enable-decoder=libspeex \
--enable-decoder=flac \
--enable-decoder=alac \
--enable-decoder=pcm_s16le \
--enable-decoder=pcm_s16be \
--enable-decoder=pcm_s24le \
--enable-decoder=pcm_s24be \
--enable-decoder=pcm_s32le \
--enable-decoder=pcm_f32le \
--enable-decoder=pcm_f64le \
--enable-decoder=pcm_mulaw \
--enable-decoder=pcm_alaw \
--enable-decoder=mp3adu \
--enable-decoder=mp3on4 \
--enable-decoder=mp3on4float \
--enable-decoder=mp3adufloat \
--enable-parser=opus \
--enable-parser=mpegaudio \
--enable-parser=aac \
--enable-parser=aac_latm \
--enable-parser=vorbis \
--enable-parser=flac \
--enable-protocol=file \
--enable-protocol=pipe \
--enable-protocol=crypto \
--enable-protocol=data \
--enable-muxer=pcm_s16le \
--enable-encoder=pcm_s16le")
endif()

# Replace upstream build.sh.in with our patched version that appends
# ${EXTRA_CONFIGURE_OPTIONS} to the configure command line.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/build.sh.in"
     DESTINATION "${VCPKG_ROOT_DIR}/ports/ffmpeg/")

include("${VCPKG_ROOT_DIR}/ports/ffmpeg/portfile.cmake")
