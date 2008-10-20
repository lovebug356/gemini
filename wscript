#!/usr/bin/env python

import Options

VERSION="0.2.2"
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

def dist ():
  import os
  folder = 'build/%s-%s' % (APPNAME, VERSION)
  os.system ('rm -rf FOLDER ; mkdir FOLDER ; cp waf FOLDER ; cp wscript FOLDER && cd FOLDER && vim wscript -c ":%s/ vala//" -c ":wq"'.replace ('FOLDER', folder))
  for src_folder in ['src']:
    os.system ('cp -r SRCFOLDER FOLDER ; for file in `find ./build/default/SRCFOLDER -name "*.[ch]"` ; do cp $file FOLDER/src ; done'.replace('SRCFOLDER', src_folder).replace ('FOLDER', folder))
  os.system ('for file in `find FOLDER -name "*.vala"` ; do rm -rf $file ; done ; cd build ; tar -zcf APPNAME-VERSION.tar.gz APPNAME-VERSION ; tar -jcf APPNAME-VERSION.tar.bz2 APPNAME-VERSION.tar.bz2 ; rm -rf APPNAME-VERSION'.replace ('APPNAME', APPNAME).replace ('VERSION', VERSION).replace('FOLDER', folder))

