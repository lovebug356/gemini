if (GTK_FOUND)
  list (APPEND PROGRAMS
    gemini-terminal.vala
  )
endif (GTK_FOUND)

add_definitions (-I${CMAKE_SOURCE_DIR}/lib)

foreach (PROGRAM ${PROGRAMS})
 string(REPLACE ".vala" "" PROGRAM_EXE ${PROGRAM})

  vala_precompile(VALA_C
    ${PROGRAM}
  OPTIONS
    --thread
    --vapidir ${CMAKE_SOURCE_DIR}/lib
  PACKAGES
    glib-2.0
    gtk+-2.0
    gee-1.0
    gemini
    vte
  )

  add_executable (${PROGRAM_EXE} ${VALA_C})
  target_link_libraries (${PROGRAM_EXE} gemini)

  install (
  TARGETS
    ${PROGRAM_EXE}
  RUNTIME
  DESTINATION
    bin
  )
endforeach (PROGRAM ${PROGRAMS})
