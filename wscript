#!/usr/bin/env python

import Options

VERSION="0.3.1"
APPNAME="gemini"

srcdir = '.'
blddir = 'build'

def set_options (opt):
  opt.tool_options ('compiler_cc')

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

def build (bld):
  bld.add_subdirs ('debian')
  bld.add_subdirs ('src')
  bld.add_subdirs ('share')
