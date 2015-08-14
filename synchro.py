#!/usr/bin/python
'''
This script is to Instal and manage the files in this repository.
Use -h or --help for usage.
'''
import shutil
import os
import argparse

HOME=os.getenv('HOME')
ELIB=HOME+'/.emacs.d'

##         SOURCE          DEST
files=[('elisplib.el', ELIB+"/elisplib.el"),
       ('emacs.el',    HOME+"/.emacs")]

def update(files):
    for pairs in files:
        shutil.copy(pairs[1],pairs[0])
        print('...copy %s -----> %s'%(pairs[1],pairs[0]))

def install(files):
    for pairs in files:
        if not os.path.exists(ELIB):
            os.makedirs(ELIB)
        shutil.copy(pairs[0],pairs[1])
        print('...copy %s -----> %s'%(pairs[0],pairs[1]))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description="Install and config this repository.")
    group = parser.add_mutually_exclusive_group()

    update_help="update the scripts in this repository \
    if the installed scripts changed."
    install_help="install the scripts in this repository."
    
    group.add_argument("-u", "--update",
                       help=update_help, action="store_true")
    group.add_argument("-i", "--install",
                       help=install_help, action="store_true")
    args = parser.parse_args()
    
    if args.update:
        print("...update:")
        update(files)
    elif args.install:
        print("...install:")
        install(files)
    else:
        print("Nothing happened: -h or --help to see useage.")
