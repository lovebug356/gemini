project (gemini-terminal)
cmake_minimum_required(VERSION 2.8)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
include(ValaPrecompile)
include(ValaVersion)

find_package(PkgConfig REQUIRED)

find_package(Vala REQUIRED)

ensure_vala_version("0.10.0" MINIMUM)

pkg_check_modules (GLIB REQUIRED glib-2.0)
pkg_check_modules (GOBJECT REQUIRED gobject-2.0)
pkg_check_modules (GEE REQUIRED gee-1.0)
pkg_check_modules (GTK gtk+-2.0)
pkg_check_modules (VTE vte)

set (CFLAGS
  ${GLIB_CFLAGS}
  ${GOBJECT_CFLAGS}
  ${GEE_CFLAGS}
  ${GTK_CFLAGS}
  ${VTE_CFLAGS}
)
add_definitions (${CFLAGS} "-O0 -g3")

set (LIBS
  ${GLIB_LIBRARIES}
  ${GOBJECT_LIBRARIES}
  ${GEE_LIBRARIES}
  ${GTK_LIBRARIES}
  ${VTE_LIBRARIES}
)
link_libraries (${LIBS})

enable_testing ()

add_subdirectory (lib)
add_subdirectory (tests)
add_subdirectory (src)
