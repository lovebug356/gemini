set (PROGRAMS
  test-copy.vala
  test-freighter.vala
  test-hauler.vala
  test-layout-fullscreen.vala
  test-layout-tile.vala
  test-terminal.vala
)

add_definitions (-I${CMAKE_SOURCE_DIR}/lib)

foreach (PROGRAM ${PROGRAMS})
 string(REPLACE ".vala" "" PROGRAM_EXE ${PROGRAM})

  vala_precompile(VALA_C
    ${PROGRAM}
  OPTIONS
    --thread
    --vapidir ${CMAKE_SOURCE_DIR}/lib
  PACKAGES
    gee-1.0
    gtk+-2.0
    vte
    gemini
  )

  add_executable (${PROGRAM_EXE} ${VALA_C})
  add_test (${PROGRAM_EXE} ${PROGRAM_EXE})
  target_link_libraries (${PROGRAM_EXE} gemini)
endforeach (PROGRAM ${PROGRAMS})
