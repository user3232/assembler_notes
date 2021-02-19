#!/bin/sh

mkdir -p ./bin
nasm -f elf64 -o ./bin/main.o mappings_loop.asm
ld -o ./bin/main ./bin/main.o
./bin/main &
pidof main
cat /proc/"pidof main"/maps
kill "pidof main"
