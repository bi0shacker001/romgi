cmake_minimum_required(VERSION 3.22.1)
project(romgi_pkg2zip)

# pkg2zip (https://github.com/mmozeiko/pkg2zip) is vendored unmodified as a git
# submodule at external/pkg2zip (repo root). Its main() already implements
# exactly the operation we need - "decrypt file.pkg [zRIF] -> zip" - as a CLI
# tool, so rather than reverse-engineer its internals into a library API it's
# compiled as-is into a native executable and invoked as a subprocess from
# Dart (lib/services/vita_decrypt_service.dart), the same way the upstream
# project intends it to be used. This is the "ship a prebuilt binary, invoke
# via subprocess" approach: Android allows this as long as the binary lives
# under the app's own nativeLibraryDir, which is why the build step below
# packages it into src/main/jniLibs/<abi>/libpkg2zip.so - it's a real ELF
# executable, just named and placed the way Android's APK packaging expects
# native code to live.
set(PKG2ZIP_DIR ${CMAKE_SOURCE_DIR}/../../../../../external/pkg2zip)

add_executable(pkg2zip_bin
    ${PKG2ZIP_DIR}/pkg2zip.c
    ${PKG2ZIP_DIR}/pkg2zip_aes.c
    ${PKG2ZIP_DIR}/pkg2zip_aes_x86.c
    ${PKG2ZIP_DIR}/pkg2zip_crc32.c
    ${PKG2ZIP_DIR}/pkg2zip_crc32_x86.c
    ${PKG2ZIP_DIR}/pkg2zip_out.c
    ${PKG2ZIP_DIR}/pkg2zip_psp.c
    ${PKG2ZIP_DIR}/pkg2zip_sys.c
    ${PKG2ZIP_DIR}/pkg2zip_zip.c
    ${PKG2ZIP_DIR}/pkg2zip_zrif.c
    ${PKG2ZIP_DIR}/miniz_tdef.c
    ${PKG2ZIP_DIR}/puff.c
)

target_include_directories(pkg2zip_bin PRIVATE ${PKG2ZIP_DIR})

set(JNILIBS_ABI_DIR ${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})

add_custom_command(TARGET pkg2zip_bin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${JNILIBS_ABI_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:pkg2zip_bin> ${JNILIBS_ABI_DIR}/libpkg2zip.so
)
