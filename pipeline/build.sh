mkdir -p ./bin
nasm -felf64 pipeline.asm -o ./bin/pipeline.o
ld -o ./bin/pipeline ./bin/pipeline.o
chmod u+x ./bin/pipeline

# display ELF structure of executable file
readelf -h ./bin/pipeline   # ELF header, specify
                    # ELF structure + globals

readelf -l ./bin/pipeline   # ELF program headers, specify
                    # how to load program to memory
                    # and execute (segments)

readelf -S ./bin/pipeline   # ELF sections, specify
                    # sections, blocks of code/data/maps
                    # in this program case
                    # readelf -S pipeline.o 
                    # will be the same

# using general purpouse tool to view object file:
objdump -tf -m intel ./bin/pipeline.o
# alternatively: readelf -s pipeline.o


readelf --relocs ./bin/pipeline.o

# disassembly:
objdump -D -M intel-mnemonic ./bin/pipeline.o

