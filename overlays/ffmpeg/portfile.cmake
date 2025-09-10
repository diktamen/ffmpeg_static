# Force FFmpeg to build as shared even under a static triplet
set(VCPKG_LIBRARY_LINKAGE dynamic)

# Include the original portfile with forced dynamic linkage
include("${VCPKG_ROOT_DIR}/ports/ffmpeg/portfile.cmake")