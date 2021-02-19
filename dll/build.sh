
mkdir -p ./bin
# object file from library
nasm -f elf64 -o ./bin/libso.o libso.asm
# dll (executable) from library
ld -shared -o ./bin/libso.so ./bin/libso.o --dynamic-linker=/lib64/ld-linux-x86-64.so.2

# object file from program
nasm -f elf64 -o ./bin/main.o libso_main.asm
# executable from program and library
ld -o ./bin/main ./bin/main.o -d ./bin/libso.so

# sections of dll
echo "\n\nDLL:\n\n"
readelf -S ./bin/libso.so
# sections of program using dll
echo "\n\nEXE:\n\n"
readelf -S ./bin/main

# symbol tables of dll elf
echo "\n\nEXE:\n\n"
readelf --dyn-syms ./bin/main
