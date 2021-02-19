#!/bin/sh

mkdir -p ./bin
# build object
nasm -felf64 print_call.asm -o ./bin/print_call.o
# link executable
ld ./bin/print_call.o -o ./bin/print_call


# change file permissions to executable
chmod u+x ./bin/print_call
chmod u+x build_print_call.sh

# execute program
./bin/print_call
