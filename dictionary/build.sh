
# to see how preprocessed list
# with stripped (macro) comments:
nasm -E main.asm | grep "^[^%]"

# alternatively one may use other grep patterns
# which ignore lines starting with % or ; :
# grep ^[^%\;]
# grep '^[[:blank:]]*[^[:blank:]%;]'
# grep -vxE '[[:blank:]]*([%;].*)?'
#
# grep with inverted match (-v option)
# grep -v ^[%\;]
#
# This says, "find all lines that start with %
# and delete them, leaving everything else."
# sed '/^%/d'


## See also: 12 useful commands for text
## https://www.tecmint.com/linux-file-operations-commands/

make
./main
