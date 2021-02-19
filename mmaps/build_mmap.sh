#!/bin/sh

mkdir -p ./bin
nasm -f elf64 -o ./bin/map_test.o mmap.asm
ld -o ./bin/map_test_file ./bin/map_test.o
chmod u+x ./bin/map_test_file
./bin/map_test_file


