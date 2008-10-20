#!/usr/bin/env python

import Options

VERSION="0.2.4"
APPNAME="gemini"

srcdir = '.'
blddir = 'build'

def set_options (opt):
  opt.tool_options ('compiler_cc')

def configure (conf):
  conf.check_tool ('compiler_cc vala')
  conf.check_pkg ('gthread-2.0', destvar='GTHREAD', vnum='2.16', mandatory=True)
  conf.check_pkg ('glib-2.0', destvar='GLIB', vnum='2.10.0', mandatory=True)
  conf.check_pkg ('vte', destvar='VTE', vnum='0.16.13', mandatory=True)
  conf.check_pkg ('gee-1.0', destvar='GEE', vnum='0.1.4', mandatory=True)

def build (bld):
  bld.add_subdirs ('src')

def dist ():
  import os
  folder = 'build/%s-%s' % (APPNAME, VERSION)
  os.system ('rm -rf FOLDER ; mkdir FOLDER ; cp waf FOLDER ; cp wscript FOLDER && cd FOLDER && vim wscript -c ":%s/ vala//" -c ":wq"'.replace ('FOLDER', folder))
  for src_folder in ['src']:
    os.system ('cp -r SRCFOLDER FOLDER ; for file in `find ./build/default/SRCFOLDER -name "*.[ch]"` ; do cp $file FOLDER/src ; done'.replace('SRCFOLDER', src_folder).replace ('FOLDER', folder))
  os.system ('for file in `find FOLDER -name "*.vala"` ; do rm -rf $file ; done ; cd build ; tar -zcf APPNAME-VERSION.tar.gz APPNAME-VERSION ; tar -jcf APPNAME-VERSION.tar.bz2 APPNAME-VERSION.tar.bz2 ; rm -rf APPNAME-VERSION'.replace ('APPNAME', APPNAME).replace ('VERSION', VERSION).replace('FOLDER', folder))

