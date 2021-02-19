
mkdir -p ./bin
# compile
nasm -f elf64 lib_main.asm -o ./bin/lib_main.o

# release
ld ./bin/lib_main.o -o ./bin/lib_main

# set permissions to executable
chmod u+x ./bin/lib_main build_lib_main.sh

# execute program
./bin/lib_main
