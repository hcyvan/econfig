#!/usr/bin/python
'''
This script is to synchronize the files in *files1* and *filess*.
You can ignore this script. This script is to be improved.
'''
import shutil
import os
import argparse

HOME=r'/home/navy'

files1=['elisplib.el','emacs.el']
files2=[r'%s/.emacs.d/elisplib.el'%HOME,
        r'%s/.emacs'%HOME]

def fail(message):
    print(message)
    exit()

def copyFiles(source, dest):
    if len(source)!=len(dest):
        fail("The files number in source and dest are not equle.")
    for i in range(len(source)):
        sfile=source[i]
        dfile=dest[i]
        if not os.path.isfile(sfile):
            fail("No file %s"%sfile)
        if not os.path.isfile(dfile):
            fail("No file %s"%dfile)
        shutil.copy(sfile, dfile)
        print("... copy: %s ---->  %s"%(sfile, dfile))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description="Install and config this repository.")
    group = parser.add_mutually_exclusive_group()

    update_help="update the scripts in this repository if the installed scripts changed."
    install_help="install the scripts in this repository."
    group.add_argument("-u", "--update", help=update_help, action="store_true")
    group.add_argument("-i", "--install", help=install_help, action="store_true")
    args = parser.parse_args()
    
    if args.update:
        print("...update:")
        copyFiles(files2,files1)
    elif args.install:
        print("...install:")
        copyFiles(files1, files2)
