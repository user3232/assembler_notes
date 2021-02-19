#!/bin/sh

#####################################
# This script can be run as:
# $ sh script.sh
# or if script.sh have execute permission
# $ ./script.sh
#####################################


mkdir -p ./bin
# build object in elf64 format
nasm -felf64 print_rax_hex.asm -o ./bin/print_rax_hex.o
# link to executable
ld ./bin/print_rax_hex.o -o ./bin/print_rax_hex
# make program executable by owner
chmod u+x ./bin/print_rax_hex
# make this script executable by owner
chmod u+x build_print_rax_hex.sh
# run program
./bin/print_rax_hex
