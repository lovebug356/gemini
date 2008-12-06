#!/usr/bin/env python

import Options

VERSION="0.4.0"
APPNAME="gemini"

srcdir = '.'
blddir = 'build'

def set_options (opt):
  opt.tool_options ('compiler_cc')
  opt.add_option ('--debian-only', action='store_true', default=False,
      help='Only build the debian files')

def configure (conf):
  conf.check_tool ('compiler_cc vala misc')
  conf.check_cfg (package='gthread-2.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='glib-2.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='vte',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='gee-1.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='gtk+-2.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='gdk-pixbuf-2.0',mandatory=1, args='--cflags --libs')
  conf.env['VERSION'] = VERSION
  conf.env['srcdir'] = srcdir
  conf.define ('VERSION', VERSION)
  conf.write_config_header ('config.h')

def build (bld):
  import Options
  if Options.options.debian_only:
    bld.add_subdirs ('debian')
    return
  bld.add_subdirs ('lib')
  bld.add_subdirs ('src')
  bld.add_subdirs ('src2')
  bld.add_subdirs ('share')

def shutdown ():
  import UnitTest
  unittest = UnitTest.unit_test ()
  unittest.want_to_see_test_output = True
  unittest.want_to_see_test_error = True
  unittest.run ()
  unittest.print_results ()
