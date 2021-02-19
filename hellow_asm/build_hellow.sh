#!/bin/sh

mkdir -p ./bin
nasm -felf64 hellow.asm -o ./bin/hellow.o
ld -o ./bin/hellow ./bin/hellow.o
chmod u+x ./bin/hellow
./bin/hellow

# display ELF structure of executable file
readelf -h ./bin/hellow   # ELF header, specify
                    # ELF structure + globals

readelf -l ./bin/hellow   # ELF program headers, specify
                    # how to load program to memory
                    # and execute (segments)

readelf -S ./bin/hellow   # ELF sections, specify
                    # sections, blocks of code/data/maps
                    # in this program case
                    # readelf -S hellow.o 
                    # will be the same

# using general purpouse tool to view object file:
objdump -tf -m intel ./bin/hellow.o
# alternatively: readelf -s ./bin/hellow.o
