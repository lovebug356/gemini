#!/usr/bin/env python

import Options

VERSION="0.3.0"
APPNAME="gemini"

srcdir = '.'
blddir = 'build'

def set_options (opt):
  opt.tool_options ('compiler_cc')

def configure (conf):
  conf.check_tool ('compiler_cc vala')
  conf.check_cfg (package='gthread-2.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='glib-2.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='vte',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='gee-1.0',mandatory=1, args='--cflags --libs')
  conf.check_cfg (package='gtk+-2.0',mandatory=1, args='--cflags --libs')

def build (bld):
  bld.add_subdirs ('src')
  bld.add_subdirs ('share')
