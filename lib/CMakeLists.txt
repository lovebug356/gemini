vala_precompile (VALA_C
  configuration.vala
  File.vala
  freighter.vala
  hauler.vala
  layout-fullscreen.vala
  layout-tile.vala
  layout.vala
  terminal.vala
OPTIONS
  --thread
  -H gemini.h
  --library gemini
PACKAGES
  gee-1.0
  gtk+-2.0
  vte
)

add_library (gemini SHARED ${C_FILES} ${VALA_C})

install (
  TARGETS gemini
  DESTINATION lib
)
