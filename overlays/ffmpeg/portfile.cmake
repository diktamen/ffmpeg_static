# Force dynamic linkage for the original static-md triplets (other projects need DLLs).
# The new staticlib-md triplets keep their native static linkage.
if(NOT VCPKG_TARGET_TRIPLET MATCHES "staticlib-md$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include("${VCPKG_ROOT_DIR}/ports/ffmpeg/portfile.cmake")
