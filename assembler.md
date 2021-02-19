
# Assembly programming

Note references/resources:
1. [Virtualised enviroment](https://github.com/kellyi/nasm-gcc-container)
2. [Book at github](https://github.com/Apress/low-level-programming)
3. [Book as APress](http://www.apress.com/us/book/9781484224021)


Tool stack:
* nasm - assembler compiler + linker
  * command line `$ nasm -f elf64 -g -o outputPath inputPath.asm`
  * [doc (html, pdf)](https://www.nasm.us/docs.php)
  * [offline nasm ref](references/nasmdoc.pdf)
* Intel 64x86 architecture:
  * Instruction set reference:
    * [Intel Reference](references/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)
    * [Web](https://www.felixcloutier.com/x86)
  * [Structured reference: instructions + registers](https://en.wikibooks.org/wiki/X86_Assembly/Data_Transfer)
* linker ld:
  * Using ld, the gnu linker. Available: <www.math.utah.edu/docs/info/ld_3.html>
* gcc - c compiler + linker
* make - dependencies resolver + executor
  * Gnu make manual. Available: <www.gnu.org/software/make/manual/>
* gdb - debugger
  * Debugging with gdb. Available: <http://sourceware.org/gdb/current/onlinedocs/gdb/>
  * <https://www.csee.umbc.edu/portal/help/nasm/nasm_64.shtml>


## Assemble then disassemble

```sh
as xor.s -o xor.o
objdump -D xor.o
```


# Working in command line


## Shell scripts

To construct shell script (for example for building asm file),
build_something.sh :

```sh
#!/bin/sh

# 1st command: compile to object file
nasm -felf64 hellow.asm -o hellow.o
# 2nd command: link object file to executable
ld -o hellow hellow.o
# 3rd command: change owner permissions to executable
chmod u+x hellow
# 4th command: run program
./hellow
```

Then to run this script:
```sh
# (do only once) permisions to execute to others
chmod o+x build_something.sh
# and execute
./build_something.sh
```

## Help

To search for help use *apropos*, for example:
```console
$ apropos pid
acpid (8)            - Advanced Configuration and Power 
                       Interface event daemon
getpid (2)           - get process identification
getppid (2)          - get process identification
git (1)              - the stupid content tracker
pid_namespaces (7)   - overview of Linux PID namespaces
pidof (8)            - find the process ID of a running 
                       program.
waitpid (2)          - wait for process to change state
fork (3am)           - basic process management
```

To see fourther details use *man*:
```console
$ man getpid
```

## Recalling last process exit code

```console
$ true
# 0
$ echo $?
# 0
```


# Users groups permissions

## Permissions - chmod

Change of access rigths to file can be done by `chmod`,
to change file `somefile.sh` to executable by owner do:

```console
$ chmod u+x somefile.sh
```

## Owner - chown

Change owner of file (can be done by owner or superuser).
For example:

```console
$ # Change the owner of /u to "root"
$ # and group of /u to staff
$ chown root:staff /u

$ # change the owner of /u to "mk"
$ # and group of /u to "mk"
$ sudo chown mk:mk /u
```

## List groups

```console
$ # list all groups
$ cat /etc/groups

$ # list user groups
$ groups mk
$ # or
$ getent group

$ # list current process groups
$ groups
```


## List users

```console
$ # to list all users
$ cat /etc/passwd
$ # or
$ getent passwd
```
`cat /etc/passwd` output is in form where for line
`vnstat:x:131:137:vnstat daemon,,,:/var/lib/vnstat:/usr/sbin/nologin`:

* vnstat – The user name or login name.
* x – Encrypted password is stored in the /etc/shadow file.
* 131 – UID (user ID number)
* 137 – Primary GID (group ID number)
* vnstat daemon – GECOS. It may includes user’s full name 
  (or application name, if the account is for a program), 
  building and room number or contact person, office 
  telephone number, home telephone number and any 
  other contact information.
* /var/lib/vnstat – Home directory for the user.
* /usr/sbin/nologin – Login shell for the user. 
  Pathnames of valid login shells comes from the /etc/shells file.


## stat - List file permissions

To check file permissions, use `stat`:
```console
$ stat build_hellow.sh 
  Plik: build_hellow.sh
  rozmiar: 96           bloków: 8          bloki I/O: 4096   plik zwykły
Urządzenie: 802h/2050d  inody: 14026578    dowiązań: 1
Dostęp: (0775/-rwxrwxr-x)  Uid: ( 1000/      mk)   Gid: ( 1000/      mk)
Dostęp:      2020-06-24 17:46:50.685418396 +0200
Modyfikacja: 2020-06-24 17:31:14.532768514 +0200
Zmiana:      2020-06-24 17:44:38.565376944 +0200
Utworzenie:  -
```

## getfacl - List file permissions

Or use `getfacl`:

```console
$ getfacl build_hellow.sh 
# file: build_hellow.sh
# owner: mk
# group: mk
user::rwx
group::rwx
other::r-x
```

## ls - List file permissions

Or use `ls -lu`:

```console
$ ls -lu build_hellow.sh 
-rwxrwxr-x 1 mk mk 96 cze 24 17:46 build_hellow.sh
```




# Computer program of user


Users are allowed to read/write to its own memory
and execute integer/floating point aritmetics.
Contact with the rest of the world is done by
services provided by OS in form of **system calls**.

Linux OS names world contact points as files.
To print something to terminal, we must know
file or filedescriptor of terminal.

Basic filedescriptor numbers for main terminal are:
* 0 - stdin - input stream (read character or line)
* 1 - stdout - output stream (write/print characters)
* 2 - stderr - output stream for errors 


To call some device function we must use system call.
Thus to print on terminal we need to invoke the write system call. 
It writes a given amount of bytes from memory starting at
a given address to a file with a given descriptor:

* Write system call number = 1.
  It must be stored in rax register at syscall invocation.
* Destination address/name will be stdout filedescriptor number = 1.
  It must be stored in rdi register at syscall invocation.
* Source address of bytes to write to terminal device, it is
  user program dependent and must be stored in rsi register at syscall
  invocation.
* Source byte length to write to terminal device, it is user program
  dependent and must be stored in rdx register at syscall invocation.

Such exemplary write call could look like:

```Assembly
mov     rax, 1      ; system call number should 
                    ; be stored in rax
mov     rdi, 1      ; argument #1 in rdi: 
                    ; where to write (descriptor)?
mov     rsi, addr   ; argument #2 in rsi: 
                    ; where does the string start?
mov     rdx, 9      ; argument #3 in rdx: 
                    ; how many bytes to write?
syscall             ; this instruction invokes 
                    ; a system call
```



# Program structure

## Sections

An assembly program is usually divided into sections. Each section has its use:
for example, `.text` holds instructions, `.data` is for global variables (data
available in every moment of the program execution). One can switch back and
forth between sections; in the resulting program all data, corresponding to each
section, will be gathered in one place.


### .data and .bss (nasm)

Section with initialized data is `.data`,
section with uninitialized data is `.bss`.
<https://www.nasm.us/xdoc/2.15.01/html/nasmdoc3.html#section-3.2.1>
<https://www.nasm.us/xdoc/2.15.01/html/nasmdoc3.html#section-3.2.2>


```Assembly
; To declare initialized storage space
section .data                 ; .data is a section
.data1:   db        'abc'
.data2:   db        'efg', 10
.data3:   db        15
.data4:   db        22, 0x1A7

; To declare uninitialized storage space:
section .bss
buffer:    resb     64        ; reserve 64 bytes 
wordvar:   resw     1         ; reserve a word 
realarray: resq     10        ; array of ten reals 
```

### .text (nasm)

`.text` section contains program instructions.
Usually it is read only.

```
mov   rax, 5
mov   rcx, 10
; etc.
```

### How to put data in .text section?

Actually assembly is mapped to stream of numbers,
(depending on context) those numbers means instructions,
so one can write `mov rax, 5` or `db 12,1241,2314,213,...`
where last numbers will represent instructions.

To create (simulate) initialized buffer in .text section
one can just put binary data and dont use it as instructions,
so for example:

```
global _start
section .text

_start:
    mov   rax, 5
                              ; other instruction
    jmp   .continue           ; skip data below
my_data:
    db    1,2,3,4,5,6,7       ; data in .text
.continue:
    mov   rcx, 10
    lea   rdx, [my_data + 2]  ; use data: 
                              ; rdx will contain 3
                              ; other instructions
```

## Constants (nasm) 

<https://www.nasm.us/xdoc/2.15.01/html/nasmdoc3.html#section-3.4.1>

```Assembler
mov     ax,200          ; decimal 
mov     ax,0d200        ; also decimal 

mov     ax,0xc8         ; hex yet again 

mov     ax,0o310        ; octal yet again

mov     ax,11001000b    ; binary 
mov     ax,1100_1000b   ; same binary constant 
mov     ax,0b1100_1000  ; same binary constant yet again
```

## Labels

To get rid of numeric address values programmers use labels.
They are just readable names and addresses. They can precede
any command and are usually separated from it by a colon,
for example `_start:` is a label.


### Local Labels

Notice the unusual label name .loop: it starts with a dot.
This label is local.  We can reuse the label names without
causing name conflicts as long as they are local. The last
used dotless global label is a base one for all subsequent
local labels (until the next global label occurs). The full
name for .loop label is _start.loop. We can use this name to
address it from anywhere in the program, even after other
global labels occurs.


```Assembly
section .data
message:                    ; message is a label
    db 'hello, world!'      ; db is directive

section .text
_start:                     ; _start is global label
    mov rax, 1
.loop:                      ; .loop is local label
    push rax

```



## Entry point

An assembly program can be divided into multiple files. One
of them should contain the `_start` label. It is the entry
point; it marks the first instruction to be executed. This
label should be declared global.

```Assembly
global _start               ; this is entry point
```

## Comments

Comments start with a semicolon and last until the end of
the line.  Example:

```Assembly
                            ; <-- this is a comment start
```

## Commands

Assembly language consists of commands, which are directly 
mapped into machine code.

Example:
```Assembly
mov     rax, 1              ; this is instruction
```

## Directives

Directives control the translation process.

```Assembly
global _start               ; global is directive
section .data               ; section is directive
message:                    ; message is label
    db 'hello, world!'      ; db is directive
```




# x86 registers

General-Purpose Registers (GPR) - 16-bit naming conventions

The 8 GPRs are:

1. Accumulator register (AX). Used in arithmetic operations
2. Counter register (CX). Used in shift/rotate instructions
   and loops.
3. Data register (DX). Used in arithmetic operations and I/O
   operations.
4. Base register (BX). Used as a pointer to data (located in
   segment register DS, when in segmented mode).
5. Stack Pointer register (SP). Pointer to the top of the
   stack.
6. Stack Base Pointer register (BP). Used to point to the
   base of the stack.
7. Source Index register (SI). Used as a pointer to a source
   in stream operations.
8. Destination Index register (DI). Used as a pointer to a
   destination in stream operations.

The order in which they are listed here is for a reason: it
is the same order that is used in a push-to-stack operation.

All registers can be accessed in 16-bit and 32-bit modes. In
16-bit mode, the register is identified by its two-letter
abbreviation from the list above. In 32-bit mode, this
two-letter abbreviation is prefixed with an 'E' (extended).
For example, 'EAX' is the accumulator register as a 32-bit
value.

Similarly, in the 64-bit version, the 'E' is replaced with
an 'R' (register), so the 64-bit version of 'EAX' is called
'RAX'.

It is also possible to address the first four registers (AX,
CX, DX and BX) in their size of 16-bit as two 8-bit halves.
The least significant byte (LSB), or low half, is identified
by replacing the 'X' with an 'L'. The most significant byte
(MSB), or high half, uses an 'H' instead. For example, CL is
the LSB of the counter register, whereas CH is its MSB.


| Reg | Accum | Counter | Data | Base | Stack Ptr | Stack Base | Src | Dst |
|----:|------:|--------:|-----:|-----:|----------:|-----------:|----:|----:|
|  64 |  RAX  |   RCX   | RDX  | RBX  |     RSP   |     RSB    | RSI | RDI |
|  32 |  EAX  |   ECX   | EDX  | EBX  |     ESP   |     ESB    | ESI | EDI |
|  16 |   AX  |    CX   |  DX  |  BX  |      SP   |      SB    |  SI |  DI |
|  H8 |   AH  |    CH   |  DH  |  BH  |           |            |     |     |
|  L8 |   AL  |    CL   |  DL  |  BL  |     SPL   |     SBL    | SIL | DIL |


## 64-bit

64-bit x86 adds 8 more general-purpose registers, 
named R8, R9, R10 and so on up to R15.

* R8–R15 are the new 64-bit registers.
* R8D–R15D are the lowermost 32 bits of each register.
* R8W–R15W are the lowermost 16 bits of each register.
* R8B–R15B are the lowermost 8 bits of each register.


## Instruction Pointer (rip, eip)

The EIP (32bit) or RIP (64bit) register contains 
the address of the next 
instruction to be executed if
no branching is done.

**EIP can only be read through the stack**
**after a call instruction.** 

## EFLAGS Register

<https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture#General-Purpose_Registers_(GPR)_-_16-bit_naming_conventions>

The EFLAGS is a 32-bit register used as 
a collection of bits representing Boolean 
values to store the results of operations 
and the state of the processor. 

The different use of these flags are:

* CF (0): Carry Flag. Set if the last arithmetic operation 
  carried (addition) or borrowed (subtraction) a bit beyond 
  the size of the register. This is then checked when the 
  operation is followed with an add-with-carry or 
  subtract-with-borrow to deal with values too large for 
  just one register to contain.
* PF (2): Parity Flag. Set if the number of set bits in 
  the least significant byte is a multiple of 2.
* AF (4): Adjust Flag. Carry of Binary Code Decimal (BCD) 
  numbers arithmetic operations.
* ZF (6): Zero Flag. Set if the result of an operation is Zero (0).
* SF (7): Sign Flag. Set if the result of an operation is negative.
* TF (8): Trap Flag. Set if step by step debugging.
* IF (9): Interruption Flag. Set if interrupts are enabled.
* DF (10): Direction Flag. Stream direction. If set, 
  string operations will decrement their pointer rather than
  incrementing it, reading memory backwards.
* OF (11): Overflow Flag. Set if signed arithmetic operations 
  result in a value too large for the register to contain.
* IOPL (12-13): I/O Privilege Level field (2 bits). 
  I/O Privilege Level of the current process.
* NT (14): Nested Task flag. Controls chaining of interrupts. 
  Set if the current process is linked to the next process.
* RF (16): Resume Flag. Response to debug exceptions.
* VM (17): Virtual-8086 Mode. Set if in 8086 compatibility mode.
* AC (18): Alignment Check. Set if alignment checking of memory 
  references is done.
* VIF (19): Virtual Interrupt Flag. Virtual image of IF.
* VIP (20): Virtual Interrupt Pending flag. 
  Set if an interrupt is pending.
* ID (21): Identification Flag. Support for CPUID instruction 
  if can be set. 


# x86 addressing modes

The addressing mode indicates the manner in which the
operand is presented.

Example:

```Assembly
; This is the way to move a number 10 into rax.
mov rax, 10


; This instruction transfers rbx value into rax.
mov rax, rbx


; This instruction transfers 8 bytes starting at 
; the tenth address into rax:
mov rax, [10]
; We can also take the address from register:
mov r9, 10
mov  rax, [r9]
; We can use precomputations:
buffer: dq 8841, 99, 00
; ...
mov rax, [buffer+8]


; Base-indexed with scale and displacement
; Address = base + index ∗ scale + displacement :
;   * Base is either immediate or a register
;   * Scale can only be immediate equal to 1, 2, 4, or 8;
;   * Index is immediate or a register; and
;   * Displacement is always immediate.
add r8, [9 + rbx*8 + 7]
```


## Register Addressing

```
mov ax, bx  ; moves contents of register bx into ax
```

## Immediate

```
mov ax, 1       ; moves value of 1 into register ax, or
mov ax, 010Ch   ; moves value of 0x010C into register ax
```

## Direct memory addressing

Operand address is in the address field

```
.data
    my_var dw 0abcdh    ; my_var = 0xabcd

.code
    mov ax, [my_var]    ; copy my_var content 
                        ; into ax (ax=0xabcd)
```

## Direct offset addressing

Uses arithmetics to modify address

```Assembly
.data
    byte_table db 12, 15, 16, 22    ; table of bytes

.code
    mov al, [byte_table + 2]
    mov al, byte_table[2]           ; same as previous 
                                    ; instruction
```

## Register Indirect

Field points to a register that contains the operand address


The registers used for indirect addressing are BX, BP, SI, DI.

```Assembly
mov ax, [di]
```


# Stack

The stack is a Last In First Out (LIFO) data structure; data
is pushed onto it and popped off of it in the reverse order.





# Commands


## Moving data - mov 

The mov instruction is used to write a value into either
register or memory. The value can be taken from other
register or from memory, or it can be an immediate one.
However,
1. mov cannot copy data from memory to memory;
2. the source and the destination operands must be of the
   same size.

## Jumping

```Assembler
; jump:
jnz .toLabel
jnz 5
; will jump if ZF in flags register is not 0
```

## Assigning

```Assembler
; mov toTargetRegister, valueFromSourceAddress
mov rax, .label
mov rax, 5
; or
; lea toTargetRegister [fromBaseAddress + offsetInRegister]
lea rsi [.label + rax]
lea rsi [5 + rax]
```

## Comparing

```Assembler
; test leftValueInRegister, rightValueInRegister
; will change flags to:
; ZF = leftValueInRegister & rightValueInRegister == 0 ? 1 : 0
; SF = MSB(leftValueInRegister & rightValueInRegister)
; PF = BitwiseXNOR((leftValueInRegister & rightValueInRegister)[0:7])

test rsi, rsi ; => ZF = 1 if rsi == 0, otherwise ZF = 0
```

## Shifting

```Assembler
; shr = shift logical right (keeps sign)
; sar = shift arythmetic right (dont use sign)
; sar toTargetRegisterAndSourceInRegister, byValueInRegister
sar rax, 4
mov rci, 8
sar rax, rci
```


## And Or

```Assembler
; and toTargetAndFirstOperandRegister, secondOperandValue
and rax, 0xff ; 0xff = 1111 1111 (first 8 bit mask)
; now rax is masked
```

## Adding substracting

```Assembler
; sub toTargetAndFirstOperandRegister, value
sub rax, 5
```

## pushing poping stack

```Assembler
; push valueInRegister (to top of the stack)
push rax
; pop valueToRegister (from top of the stack)
pop rax

```


# System calling

<https://en.wikibooks.org/wiki/X86_Assembly/Interfacing_with_Linux>


The x86_64 architecture introduced a dedicated instruction 
to make a syscall. It does not access the interrupt 
descriptor table and is faster. Parameters are passed by 
setting the general purpose registers as following:


| Syscall # |	 P1 |  P2 |  P3 |  P4 |  P5 |  P6 |
|-----------|-----|-----|-----|-----|-----|-----|
|    rax    |rdi  |rsi  |rdx  |10   |r8   |r9   |

| Return value |
|--------------|
|      rax     |


The syscall numbers are described in the Linux generated file 
`$build/usr/include/asm/unistd_64.h`. This file could also be 
present on your Linux system, just omit the $build.

All registers, except rcx and r11 (and the return value, rax), 
are preserved during the syscall.



In call of Linux's library functions parameter 4 is passed 
on RCX and further parameters, onto the stack.

|  P1 |  P2 |  P3 |  P4 | P5 | P6 |
|-----|-----|-----|-----|----|----|
| rdi | rsi | rdx | rcx | r8 | r9 |



## syscall (system call)

Each system call has a unique number. To perform it
1. The rax register has to hold system call’s number;
2. The following registers should hold its arguments: 
   rdi, rsi, rdx, r10, r8, and r9.
   System call cannot accept more than six arguments.
3. Execute syscall instruction.

It does not matter in which order the registers are initialized.
Note, that the syscall instruction changes rcx and r11!


## write syscall

```Assembler
section .data
.str  db 'la la lal la la'

mov rax, 1    ; -> write, 
mov rdi, 1    ; -> stdout,
mov rsi, .str ; address of chars
mov rdx, 8    ; number of characters to write before "\0"
; address of string can be dynamic or single value:
; mov r10, 5
; mov rsi, r10
; mov rdx, 1
syscall   ; execute system call!
```

## read syscall


## mmap syscall

mmap System Call:

* rax - 9 - System call identifier
* rdi - addr - An operating system attempts to map into 
  pages starting from this specific address. 
  This address should correspond to a page start. 
  A zero address indicates that the operating system 
  is free to choose any start.
* rsi - len - Region size
* rdx - prot - Protection flags (read, write, execute...)
* r10 - flags - Utility flags (shared or private, anonymous pages, etc.)
* r8 - fd - Optional descriptor of a mapped file. 
  The file should therefore be opened.
* r9 - offset - Offset in file.


## open syscall

open syscall:

* rax - 2 - System call identifier
* rdi - file name - Pointer to a null-terminated string, name.holding file
* rsi - flags - A combination of permission flags 
  (read only, write only, or both).
* rdx - mode - If sys open is called to create a file, 
  it will hold its file system permissions.



# Functions

Function call is done as follows:

```Assembly
call instructionsAddress
```

And it is identical (!!!) with:

```Assembly
push rip  ; rip is address of next instruction
jmp instructionsAddress
; execution will continue here after 
; rip + jmp_instruction_length
```

For example:

```Assembly
section .text
global _start

_start:
    mov rdi, `a`      ; first parameter of print_char
    call print_char   ; call instruction will put on top
                      ; of the stack address of next 
                      ; instruction (xor ...) and
                      ; jump to print_char label (address).
                      ; When function finish, it will
                      ; pop top of the stack and 
                      ; jump to popped value address.
    xor rdi, rdi      ; first argument to exit
    call exit         ; exit will terminate program


; function print_char
; Accepts a character code directly
; as its first argument (rdi)
; and prints it to stdout. (syscall # 1)
print_char:
    push rdi    ; copy rdi to the stack
    mov rax, 1  ; write syscall number
    mov rdi, 1  ; stdout filedescriptor
    mov rsi, rsp; character to print address 
                ; is address of top of the stack
    mov rdx, 1  ; print 1 char
    syscall
    pop rdi     ; leave stack in oryginal form
ret ; jump to address at the stack


; exit function
; calls exit system code
; takes exit code as argument (in rdi)
exit:
    mov rax, 60     ; exit syscall number
    ; rdi           ; in rdi is exit code
                    ; and rdi is first param
                    ; of exit syscall
    syscall         ; exit syscall will terminate
                    ; process, so next instruction
                    ; will not be executed in
                    ; this case
ret 
```

## Callee-saved registers 

Callee-saved registers must be restored by the procedure being called. 
So, if it needs to change them, it has to change them back.
These registers are callee-saved: 
* rbx, 
* rbp, 
* rsp, 
* r12-r15, 

a total of seven registers.
For example:

```Assembly
my_fun:
  push r12
  push r13
  ; ...
  pop r13
  pop r12
ret
```

## Caller-saved registers 

Caller-saved registers should be saved before invoking a
function and restored after. One does not have to save and
restore them if their value will not be of importance after.


```Assembly
mov rax, 5
push rax              ; save rax before call
mov rdi, .some_string ; call argument
call string_length    ; call will change registers
                      ; in rax after call is string length
mov rdx, rax          ; copy it to rdx, and use it elseware
pop rax               ; restore oryginal rax
; ...                 ; do other stuff
```


## Remember


A common mistake is not saving caller-saved registers
before call and using them after returning from
function.  Remember:
1. If you change rbx , rbp , rsp , or r12-r15 , change
   them back!
2. If you need any other register to survive function
   call, save it yourself before calling!



# Compilation pipeline


## Preprocessor

Preprocessor transforms the program source to obtain
other program in the same language. The transformations
are usually substitutions of one string instead of
others.

NASM preprocessor is extension of 
[C preprocessor](https://en.wikipedia.org/wiki/C_preprocessor).


Something can be defined with arguments,
arguments will be substituted literally,
and result will be string.

To check nasm preprocessor work do:
`nasm -E file_to_preprocess.asm`



Evaluation order is possible, because NASM provides slightly
different versions of macro definition directives, namely:

* %define for a deferred substitution. If macro body
  contains other macros, they will be expanded after the
  substitution.
* %xdefine performs substitutions when being defined. Then
  the resulting string will beused in substitutions.
* %assign is like %xdefine, but it also forces the
  evaluation of arithmetic expressions and throws an error
  if the computation result is not a number.


The key differences are that:

* %define may change its value between instantiations if
  parts of it are redefined.
* %xdefine has other macros on which it directly depends
  glued to it after being defined.
* %assign forces evaluation and substitutes values. Where
  xdefine would have left you with the preprocessor symbol
  equal to 4+2+3, %assign will compute it and assign value 9
  to it.


## Translation and Object files

Compiler transforms each source file into a file with
encoded machine instructions. However, such a file is
not yet ready to be executed because it lacks the right
connections with the other separately compiled files.
We are talking about cases in which instructions
address data or instructions, which are declared in
other files.


The object file is completed separately from other files but
refers to outside code and data.  It is not yet clear
whether that code or data will reside in memory, or the
position of the object file itself.  The assembly language
translation is quite straightforward because the
correspondence between assembly mnemonics and machine
instructions is almost one to one. Apart from label
resolution there is not much nontrivial work.

Object files are common intermediate step for different
higher level programming languages.

### Raalocable ELF object file 

Relocatable object files are .o-files, produced by compiler.


Relocation is a process of assigning definitive addresses to
various **program parts** and changing the program code the way
all links are attributed correctly. We are speaking about
all kinds of memory accesses by absolute addresses.


Relocation is needed, for example, when the program consists
of multiple modules, which are referencing one another. The
order in which they will be placed in memory is not yet
fixed, so the absolute addresses are not determined. Linkers
can combine these files to produce the next type of object
files.

## Linker

Linker establishes connections between files and makes
an executable file. After that, the program is ready to
be run.  Linkers operate with object files, whose
typical formats are ELF (Executable and Linkable
Format) and COFF (Common Object File Format).


Linker must perform the following tasks:
* Relocation
* Symbol resolution. Each time a symbol (function, variable)
  is dereferenced, a linker has to modify the object file
  and fill the instruction part, corresponding to the
  operand address, with the correct value.


## Linking to executable

Executable object file can be loaded in memory and executed
right away. It is essentially a structured storage for code,
data, and utility information.


## Linking to shared object

Shared object files can be loaded when needed by the main
program. They are linked to it dynamically. In Windows OS
these are well known dll-files; in *nix systems their names
often end with .so.

Dynamic libraries are loaded when they are needed. As they
are object files on their own, they have all kind of
meta-information about which code they provide for external
usage. This information is used by a loader to determine the
exact addresses of exported functions and data.

A program can work with any amount of shared libraries. Such
libraries should be loadable at any address. Otherwise they
would be stuck at the same address, which puts us in exactly
the same situation as when we are trying to execute multiple
programs in the same physical memory address space. There
are two ways to achieve that:

### Reallocation at runtime

We can perform a relocation in runtime, when the library is
being loaded. However, it steals a very attractive feature
from us: the possibility to reuse library code in physical
memory without its duplication when several processes are
using it. If each process performs library relocation to a
different address, the corresponding pages become patched
with different address values and thus become different for
different processes.


Effectively the .data section would be relocated anyway
because of its mutable nature. Renouncing global variables
allows us to throw away both the section and the need to
relocate it.


Another problem is that .text section must be left writable
in order to perform its modification during the relocation
process. It introduces certain security risks, leaving its
modification possible by malicious code. Moreover, changing
.text of every shared object when multiple libraries are
required for an executable to run can take a great deal of
time.


### Position Independent Code - relate everything to program counter (instruction counter)

We can write PIC (Position Independent Code). It is now
possible to write code which can be executed no matter where
it resides in memory. For that we have to get rid of
absolute addresses completely. These days processors support
rip-relative addressing, like mov rax, [rip + 13]. This
feature facilitates PIC generation.  This technique allows
for .text section sharing. Today programmers are strongly
encouraged to use PIC instead of relocations.

## Loader

The section loading addresses and relative placement can be
adjusted by using linker scripts, which describe the
resulting file. Such cases usually occur when you are
programming an operating system or a microcontroller
firmware. For details see: [Using ld, The GNU linker, ld version 2, January 1994, Steve Chamberlain, Cygnus Support](http://www.math.utah.edu/docs/info/ld_toc.html).


Loader accepts an executable file. Such files usually have a
structured view with metadata included. It then fills the
fresh address space of a newborn proc with its instructions,
stack, globally defined data, and runtime code provided by
the operating system.


Loader is a part of the operating system that prepares
executable file for execution. It includes:

* mapping itsrelevant sections into memory, 
* initializing .bss, 
* and sometimes mapping other files from disk.

For example program sections may be
(output from readelf -l executable_file):

```
Program Headers:
  Type           Offset             VirtAddr             PhysAddr
                 FileSiz            MemSiz                Flags  Align
  LOAD           0x0000000000000000 0x0000000000400000   0x0000000000400000
                 0x00000000000000e3 0x00000000000000e3    R E    200000
  LOAD           0x00000000000000e4 0x00000000006000e4   0x00000000006000e4
                 0x0000000000000010 0x000000000200001c    RW     200000
Section to Segment mapping:
  Segment Sections...
   00     .text
   01     .data .bss
```

The table tells us that two segments are present:

1. 00 segment:
   * Is loaded at 0x400000 aligned at 0x200000.
   * Contains section .text.
   * Can be executed and can be read. Cannot be written to
     (so you cannot overwrite code).
2. 01 segment:
   * Is loaded at 0x6000e4 aligned to 0x200000.
   * Can be read and written to.


Alignment means that the actual address will be the closest one to the start, divisible by 0x200000.

Thanks to virtual memory, you can load all programs at the same starting address. Usually it is **0x400000**.

There are some important observations to be made:
* Assembly sections with similar names, defined in different
  files, are merged.
* A relocation table is not needed in a pure executable
  file. Relocations partially remain for shared objects.


Let’s launch the resulting file and see its /proc/\<pid\>/maps
file as we did in Chapter 4. Listing 5-33 shows its sample
contents. The executable is crafted to loop infinitely.

```
$ ps
  PID TTY          TIME CMD
 7822 pts/1    00:00:00 bash
 7866 pts/1    00:00:07 main
 7873 pts/1    00:00:00 ps
$ cat proc/7866/maps
address                           perms offset   dev   inode       pathname
00400000-00401000                 r-xp  00000000 08:02 14027028    /home/mk/programming/ADaq/assembler/mappings_loop/main
00600000-00601000                 rwxp  00000000 08:02 14027028    /home/mk/programming/ADaq/assembler/mappings_loop/main
7ffd18b3e000-7ffd18b5f000         rwxp  00000000 00:00 0           [stack]
7ffd18bb4000-7ffd18bb7000         r--p  00000000 00:00 0           [vvar]
7ffd18bb7000-7ffd18bb9000         r-xp  00000000 00:00 0           [vdso]
ffffffffff600000-ffffffffff601000 r-xp  00000000 00:00 0           [vsyscall]
```
From above we can see that system placed segments at:
* 00400000-00401000
* 00600000-00601000


# Debugging with gdb

Best to enable debugging symbols (this way gdb list
command will work) when building executables:

```sh
# compile to object file with debug symbols
nasm -g -f elf64 -o main.o source.asm
# linker automatically will include debug symbols
# use option -s to strip debug symbols and comments
ld -o main main.o
```

First run gdb:

```sh
$ gdb 
```

than at gdb prompt some usefull commands are:

* `gdb> quit` - exits debugging
* `gdb> help show` - prints help about show command
* `gdb> show disassembly-flavor` - prints assembly syntax used
  (intel, mips, ...)
* `gdb> set disassembly-flavor intel` - sets syntax to intel
* `gdb> load main` - loads file main
* `gdb> run` starts program execution.
* `gdb> break x` creates a breakpoint near the label x. When
  performing run or continue we will stop at the first
  breakpoint hit, allowing us to examine the program state.
* `gdb> break *address` to place a breakpoint at a specified address.
  This will change assembly code, inserting instruction break
  at label (addres) location. To actually move we need to call
  start
* `gdb> continue` to continue running program
* `gdb> stepi` or `gdb> si` to step by one instruction;
* `gdb> ni` or `gdb> nexti` will execute one instruction as
  well, but will not enter functions if the instruction was
  call. Instead it will let the called function terminate
  and break at the next instruction
* `gdb> next` If there were line number debug information in
  the executable file, then  "next"  would setp one line


To view instruction context with addresses : `gdb> layout asm`

To view source code context : `gdb> list`

To view registers: `gdb> layout registers`

To analize (-> print) data at memory locations (labels):
`gdb> x /s message_laybel`. It is hardly customisable,
but it seems it is only way. Moor informations at
<https://sourceware.org/gdb/current/onlinedocs/gdb/Memory.html>

Workflow example
<https://www.csee.umbc.edu/portal/help/nasm/nasm_64.shtml>:

```sh
gdb> break main      # set breakpoint default program start
gdb> break _start    # breakpoint at laybel
gdb> run             # runes program until breakpoint reached
gdb> layout  asm     # display window with code
gdb> layout  regs    # display window with registers
gdb> set disassembly-flavor intel # disasemble display intel syntax
gdb> disassemble main # disasembly can be seen
gdb> x/90xb main     # display 90 units of bytes at address main
gdb> info registers  # print registers values
gdb> print/x $rsp    # display hex (/n) register rsp
gdb> print/d $rax    # display decimal (/d) register rsp
gdb> nexti           # execute and break at next instruction
gdb> print/x $rsp
gdb> print/x $rax
gdb> next            # step one line
gdb> info float      # display floating point registers
gdb> info stack      # display stack
gdb> q               # quit
gdb> y               # confirm yes
```

# Makefiles

Source of truth is make manual:
<https://www.gnu.org/software/make/manual/>
and experimentation ;-).

Very usefull are:
* [A Quick Reference](https://www.gnu.org/software/make/manual/html_node/Quick-Reference.html) 
* [Error messages descriptions](https://www.gnu.org/software/make/manual/html_node/Error-Messages.html)
* [Complex Makefile Example](https://www.gnu.org/software/make/manual/html_node/Complex-Makefile.html)

Makefile is set of tasks and its dependences
and actions (rules) associated with tasks.
Basic dependence is physical file.

Makefile have two syntaxes:
1. Makefile - for tasks and dependences and variables
2. Shell - for actions (rules)


Make algorithm works in two phases:
1. First go from top task to dependencies which dont
   have further dependencies
2. Second, when shortest dependency path is found
   task actions from bottom to top are executed

Default Task is top most task or all task if exists.


## Tasks

```Makefile
target1 target2 : dependence1 dependence2
target3 target4 : dependence5 dependence1
  <recipe> # every line starting with tab run in separate shell
  <recipe> # every line starting with tab run in separate shell
```

Makefile can have multiple Tasks, wher each:
1. Task is `target`. 
2. Task dependences are `dependence`, which could be:
   * some file
   * other task
   * abstract name (phony target) - which would cause
     refresh every time
3. Receipe is shell script.

Additionally Makefile can have multiple variable bindings
and references.


Every environment variable that make sees when it starts up
is transformed into a make variable with the same name and
value.


## Actions (recipes)

When make runs a recipe, variables defined in the makefile
are placed into the environment of each shell. This allows
you to pass values to sub-make invocations (see Recursive
Use of make). By default, only variables that came from the
environment or the command line are passed to recursive
invocations. You can use the export directive to pass other
variables. See 
[Communicating Variables to a Sub-make](https://www.gnu.org/software/make/manual/html_node/Variables_002fRecursion.html#Variables_002fRecursion), 
for full details. 

Every line in recipe is run in separate subshell.
This can be changed to one shell if anywhare in
Makefile one define `.ONESHELL:` (phony) task.

### Implicit actions

make comes with set of implicit rules and variables.
They exists for common tasks like compiling C files
to objects, etc.

So sometimes one dont need specify some rules.

List of those can be found at:
<https://www.gnu.org/software/make/manual/html_node/Catalogue-of-Rules.html>
<https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html#>


One can define an implicit rule by writing a pattern rule.
A pattern rule looks like an ordinary rule, except that its
target contains the character `%` (exactly one of them).

Thus, a pattern rule `%.o : %.c` says how to make any file
stem.o from another file stem.c. 

For details see:
<https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html>


## Variables

Variables binding may have 2 flavors:
1. `=` will be recursively expanded (lazyly)
2. `::=`(POSIX) or `:=` will be simply expanded, strictly 
  at definition time


Bindings have additional shortcut forms:
* `!=` is shell assignment operator. Shell script result
  will be assigned to variable.  
  * This operator first evaluates the right-hand side, then
    passes that result to the shell for execution. 
  * If the result of the execution ends in a newline, that
    one newline is removed; 
  * all other newlines are replaced by spaces. 
  * The resulting string is then placed into the named
    recursively-expanded variable.
  * If the result of the execution could produce a $, and
    you don’t intend what follows that to be interpreted as
    a make variable or function reference, then you must
    replace every $ with $$ as part of the execution.
  * exit status of the just-invoked shell script is stored
    in the `.SHELLSTATUS` variable
* `+=` appending. Works in 2 ways:
  * For strict variables it works by textual appending:
    ```Makefile
    variable := value
    variable += more
    # is equivalent to:
    # variable := value
    # variable := $(variable) more
    ```
  * For lazy variables it uses internal lazy temp variable:
    ```Makefile
    variable = value
    variable += more
    # is equivalent to:
    # temp = value
    # variable = $(temp) more
    ```

```Makefile
ASM = nasm             # variable declaration
ASM_DEBUG = $(ASM) -g  # variable declaration and reference

# make functions:
ALL_C_FILES = $(wildcard *.c)
MATCHING_O_FILES = $(patsubst %.c,%.o,$(wildcard *.c))

whoami    := $(shell whoami)
host-type := $(shell arch)
```

## Automatic variables

Here is a table of automatic variables:

* `$@` The file name of the target of the rule. If the
  target is an archive member, then `$@` is the name of the
  archive file. In a pattern rule that has multiple targets
  (see Introduction to Pattern Rules), `$@` is the name of
  whichever target caused the rule’s recipe to be run.
* `$%` The target member name, when the target is an archive
  member. See Archives. For example, if the target is
  foo.a(bar.o) then `$%` is bar.o and `$@` is foo.a. `$%` is
  empty when the target is not an archive member.
* `$<` The name of the first prerequisite. If the target got
  its recipe from an implicit rule, this will be the first
  prerequisite added by the implicit rule (see Implicit
  Rules).
* `$?` The names of all the prerequisites that are newer
  than the target, with spaces between them. If the target
  does not exist, all prerequisites will be included. For
  prerequisites which are archive members, only the named
  member is used (see Archives).
* `$^` The names of all the prerequisites, with spaces
  between them. For prerequisites which are archive members,
  only the named member is used (see Archives). A target has
  only one prerequisite on each other file it depends on, no
  matter how many times each file is listed as a
  prerequisite. So if you list a prerequisite more than once
  for a target, the value of `$^` contains just one copy of
  the name. This list does not contain any of the order-only
  prerequisites; for those see the `$|` variable, below.
* `$+` This is like `$^`, but prerequisites listed more than
  once are duplicated in the order they were listed in the
  makefile. This is primarily useful for use in linking
  commands where it is meaningful to repeat library file
  names in a particular order.
* `$|` The names of all the order-only prerequisites, with
  spaces between them.
* `$*` The stem with which an implicit rule matches (see How
  Patterns Match). If the target is dir/a.foo.b and the
  target pattern is a.%.b then the stem is dir/foo. The stem
  is useful for constructing names of related files.
* `$?` is useful even in explicit rules when you wish to
  operate on only the prerequisites that have changed.


## Conditional Parts of Makefiles

A conditional directive causes part of a makefile to be
obeyed or ignored depending on the values of variables.
Conditionals can compare the value of one variable to
another, or the value of a variable to a constant string.
Conditionals control what make actually “sees” in the
makefile, so they cannot be used to control recipes at the
time of execution. 

Syntax:

```Makefile
# textual comparison
ifeq (yoyo, ej) # ifneq , ifdef , ifndef
myvar = yo
compiler = nasm
else 
myvar = ho
compiler = gcc
else
myvar = hey
compiler = R
endif
```

## Example

Example Makefile

```Makefile
##########################################
# make execution
##########################################


# make calling
# $ make  # run default task (all or top most)
# $ make task # run selected task
# $ make -d   # prints lots of informations
# $ make -n		# dry run
# $ make -p		# print make internal database
# $ make -r		# turn off builtin rules
# $ make --trace # print tracing informations


##########################################
# Including files:
##########################################


# files can be included:
# include foo bar.mk c.mk d.mk


##########################################
# Variables and references:
##########################################


AFLAGS = -f elf64# 			# variable with compiler flags
AFLAGS_DEBUG = $(AFLAGS)#	# variable with debug flags
AFLAGS_DEBUG += -g -F dwarf## variable with debug flags
                            # -> -f elf64 -g -F dwarf
ASM = nasm#                   # variable with compiler path
LD = ld#                      # variable with linker path
EMPTYVAR =#                   # empty variable
EMPTYVAR = redefined#         # variable can be redefined

$(warning only references can also be used)
$(warning typically when they cause sideeffects)

# Target specific variables:
# One may declare task and 
# its dependencies specific variable.
# It will be valid inside task and its
# dependencies task actions, this behaviour
# can be suppressed using 'private'
tarsk_and_deps : AFLAGS = -f elf64 -g
# tarsk_and_deps : private AFLAGS = -f elf64 -g


# Pattern-specific Variable Values:
# 'elf64_arch/%.o' and '%.o' is called **stem**
# patern is moore specyfic if it has longer stem
elf64_arch/%.o: EXAMPLE_FLAGS := -f elf64 -g
%.o: EXAMPLE_FLAGS := -g


##########################################
# Predefined variables
##########################################


# Predefined variables used by implicit rules (tasks) are:
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html


##########################################
# Enviroment
##########################################


# MAKEFILE_LIST is special (make) variable
# its appended with name of parsed file
# each time file is parsed
# finally it contain space separated directory
# list
last_parsed_file := $(lastword $(MAKEFILE_LIST))

# Every shell enviroment variable is visible with 
# with the same name, e.g. $(PATH) will contain
# system path.

# export variables to sub-make (subshell)
export last_parsed_file
# to prevent exporting to sub-make (subshell)
unexport last_parsed_file
# to export all, use single export:
# export


##########################################
# Tasks
##########################################


# top most and default (all) task:
all: main

# variable with tasks (and also files) needed for build
OBJECTS = main.o dict.o lib.o main.lst dict.lst lib.lst

# build task for executable main
# action(s) must be tab indented
# they will be pushed to /bin/sh
# each line to separate subshell
# make will echo every action line if it not start with @
main: $(OBJECTS) # dependences are from variable reference
	$(LD) -o main main.o dict.o lib.o

# compile task for main
main.o main.lst: main.asm colon.inc words.inc
	$(ASM) $(AFLAGS) -l main.lst -o main.o main.asm
# compile task for lib
lib.o lib.lst: lib.asm 
	$(ASM) $(AFLAGS) -l lib.lst -o lib.o lib.asm
# compile task for dict
dict.o dict.lst: dict.asm 
	$(ASM) $(AFLAGS) -l dict.lst -o dict.o dict.asm

# one may create multiple targets with single action:
foo bar biz &: baz boz
	echo $^ > foo	# prints all dependencies to foo file
	echo $^ > bar	# prints all dependencies to bar file
	echo $^ > biz	# prints all dependencies to biz file


##########################################
# Phony tasks
##########################################


# Phony tasks are tasks which have no file backup!
# That is it. They differ because their version
# (taken from timestamp, which not exists for not file)
# is never actual.

baz: ;# (phony) task with no dependencies and actions
boz: ;# (phony) task with no dependencies and actions

# phony task
clean:
	rm -f main.lst main.o lib.lst lib.o dict.lst dict.o main

# phony task
help:
	echo 'This is the help' 

##########################################
# Functions
##########################################


# variable functions :
whoami    := $(shell whoami)#	# := is strict binding
host-type := $(shell arch)#		# $(shell ...) if function
MAJKI := ${MAKE} host-type=${host-type} whoami=${whoami}#

hash := $(shell printf 'Hellow world\n')
file_list := $(shell find . -name "*.asm")

# one may use variable to shell script binding:
hash_alt != printf 'Hellow world\n'
file_list_alt != find . -name '*.asm'


yo:
	@echo "I am: $(whoami)"
	@echo "My host is: $(host-type)"
	@echo "MAKE is: $(MAJKI)"
	@echo "hash is: $(hash)"
	@echo "file_list is: $(file_list)"
	@echo "hash_alt is: $(hash_alt)"
	@echo "file_list_alt is: $(file_list_alt)"


# substitutions:
foo := a.o b.o l.a c.o#
bar := $(foo:.o=.c)# 					# -> a.c b.c l.a c.c
bar_equiv := $(patsubst %.o,%.c,$(foo))## -> a.c b.c l.a c.c

substitutions:
	@echo $(bar)
	@echo $(bar_equiv)


##########################################
# Text Functions
##########################################


substitute := $(subst ee,EE,feet on the street)
# -> fEEt on the strEEt
needs_made =   	   	  # -> spaces and tabs
ifneq   "$(strip $(needs_made))" ""
will_make = yes
else
will_make = no
endif
# -> will_make = no
findstring = $(findstring a,a b c)
# -> a
different_sources := foo.c bar.c baz.s ugh.h
c_s_sources := $(filter %.c %.s,$(sources))
# -> foo.c bar.c baz.s
my_objects := main1.o foo.o main2.o bar.o
my_mains := main1.o main2.o
my_objects_without_mains := $(filter-out $(my_mains),$(my_objects))
# -> foo.o bar.o
sorted := $(sort foo bar lose)
# -> bar foo lose
second_word := $(word 2, foo bar baz)
# -> bar
word_sublist := $(wordlist 2, 3, foo bar baz)
# -> bar baz
number_of_words := $(words 1 2 yo hey)
# -> 4
last_word_of_text := $(word $(words text), 1 2 3 4 yo )
# -> yo
first_word := $(firstword foo bar)
# -> foo
lastword := $(lastword one two)
# -> two


##########################################
# Dir Functions
##########################################


dir_names := $(dir src/foo.c hacks)
# -> src/ ./
not_dir_names := $(notdir src/foo.c hacks)
# -> foo.c hacks
names_suffixes := $(suffix src/foo.c src-1.0/bar.c hacks)
# -> .c .c
base_names := $(basename src/foo.c src-1.0/bar hacks)
# -> src/foo src-1.0/bar hacks
added_suffixes := $(addsuffix .c,foo bar)
# -> foo.c bar.c
added_preffixes := $(addprefix src/,foo bar)
# -> src/foo src/bar
join_pairwise := $(join a b,.c .o)
# -> a.c b.o

# $(wildcard pattern)
# $(realpath names…)
# $(abspath names…)


##########################################
# Test Functions
##########################################


# $(if condition,then-part[,else-part])
# $(or condition1[,condition2[,condition3…]])
# $(and condition1[,condition2[,condition3…]])


##########################################
# Special Functions
##########################################


# foreach:
find_files = $(wildcard $(dir)/*)
dirs := a b c d
files := $(foreach dir,$(dirs),$(find_files))
# is quivalent to:
files := $(wildcard a/* b/* c/* d/*)


# read/write file:

# reading not supported by make --version < 4.2
# read_lib_asm := $(file < lib.asm)
read_lib_asm := $(shell cat lib.asm)
override_test_file := $(file >> test," Overriden by make function ")
append_test_file := $(file >> test," Appended by make function ")

# macros:

reverse = $(2) $(1)
foo = $(call reverse,a,b)
# -> b a

# keeping variable not expanded: 

# The value function provides
# a way for you to use the value of a variable without
# having it expanded
value_function_example = $PATH
value_function_example_task:
	# probably ATH because $P is undefined
	@echo $(FOO)
	# ok, will show $PATH env variable
	@echo $(value FOO)

# complex macros:

# use eval function
# example
# https://www.gnu.org/software/make/manual/html_node/Eval-Function.html


# what is variable origin? (undefined, default, environment, file ...)

phony_origin := $(origin .PHONY)

# what is flavor of variable? (undefined, recursive, simple)
phony_origin_flavor := $(flavor phony_origin)
# -> simple


# diagnostic functions:

# $(error text…)
$(warning I worn you)
$(info Just logging)


# taking results of shell:

content_of_dict := $(shell cat dict.asm)


##########################################
# Nested variables
##########################################


x = variable1#
variable2 := Hello#
y = $(subst 1,2,$(x))#	# y -> variable2 
z = y# 					# z -> y
a := $($($(z)))# 		# a ->  $(variable2) -> Hellow

x_objects := a.o b.o c.o
y_objects := 1.o 2.o 3.o
x_or_y := y
sources := $($(x_or_y)_objects:.o=.c)## -> 1.c 2.c 3.c

dir = .
$(dir)_objects := $(wildcard $(dir)/*.o)
define $(dir)_print =
cat $($(dir)_objects)
endef

nestedVariables:
	@echo $(a)
	@echo $(sources)
	@echo $($(dir)_objects)
	@echo $($(dir)_print)


##########################################
# Multiline variables
##########################################


# = means that two-lines variable is lazyely bound
# When used in a recipe, 
# the below example is 
# functionally equivalent to this: 
#
# two-lines = echo foo; echo $(bar)
# note 2 subshells will be executed
define two-lines =
echo foo
echo $(bar)
endef


##########################################
# Conditionals
##########################################


# As this example illustrates, conditionals work at the
# textual level: the lines of the conditional are treated as
# part of the makefile, or ignored, according to the
# condition.

libs_for_gcc = -lgnu
normal_libs =

ifeq ($(CC),gcc)
  libs=$(libs_for_gcc)
else
  libs=$(normal_libs)
endif


# declare what task are phony (for optimization)
.PHONY: clean help baz boz

```

# Programs access to devices


On Intel 64x86 the applications can access I/O ports in two
ways:
* using separate address space, or
* using common address space




## Access IO through a separate I/O address space.

There are 2 16 1-byte addressable I/O ports, from 0 through
FFFFH. The commands in and out are used to exchange data
between ports and eax register (or its parts).  The
permissions to perform writes and reads from ports are
controlled by checking:

* IOPL (I/O privilege level) field of rflags registers
  * Thus, setting IOPL in an application individually allows
    us to forbid it from writing even if it is working at a
    higher privilege level than the user applications.
* I/O Permission bit map of a Task State Segment.
  * Additionally, Intel 64 allows an even finer permission
    control through an I/O permission bit map. If the IOPL
    check has passed, the processor checks the bit
    corresponding to the used port. The operation proceeds
    only if this bit is not set.

The IOPL field in rflags register works as follows: if the
current privilege level is less or equal to the IOPL, the
following instructions are allowed to be executed:

* in and out (normal input/output).
* ins and outs (string input/output).
* cli and sti (clear/set interrupt flag).

### Task State Segment in long mode (64x86)

The I/O permission bit map is a part of Task State Segment
(TSS), which was created to be an entity unique to a
process. However, as the hardware task-switching mechanism
is considered obsolete, only one TSS (and I/O permission bit
map) can exist in long mode.

The **tr** register holds the segment selector to the TSS
descriptor.

TSS descriptor resides in the GDT (Global Descriptor Table)
and has a format similar to segment descriptors.

These days there is only one TSS used by an operating
system, with the structure:

* The first 16 bits store an offset to an Input/Output Port
  Permission Map
* 8 pointers to special interrupt stack tables (ISTs)
* 4 pairs of stack pointers for different rings (there are 4
  rings). Each time a privilege level changes, the stack is
  automatically changed accordingly.

Usually, the new rsp value will be taken from the TSS field
corresponding to the new protection ring.


## Access IO through memory-mapped I/O

A part of address space is specifically mapped to provide
interaction with such external devices that respond like
memory components. Consecutively, any memory addressing
instructions (mov, movsb, etc.) can be used to perform I/O
with these devices.

Standard segmentation and paging protection mechanisms are
applied to such I/O tasks.


# Interrupt Handlers

When an n-th interrupt occurs, the following actions are
performed from a programmer’s point of view:


1. The IDT address is taken from idtr.
2. The interrupt descriptor is located starting from 128 × n-th byte of IDT.
3. The segment selector and the handler address are loaded
   from the IDT entry into cs and rip, possibly changing
   privilege level. The old ss, rsp, rflags, cs, and rip are
   stored into stack
4. For some interrupts, an error code is pushed on top of
   handler’s stack. It provides additional information about
   interrupt cause.
5. If the descriptor’s type field defines it as an Interrupt
   Gate, the interrupt flag IF is cleared. The Trap Gate,
   however, does not clear it automatically, allowing nested
   interrupt handling.

If the interrupt flag is not cleared immediately after the
interrupt handler start, we cannot have any kind of
guarantees that we will execute even its first instruction
without another interrupt appearing asynchronously and
requiring our attention.

The interrupt handler is ended by a iretq instruction, which
restores all registers saved in the stack.

Stack when an interrupt handler starts contains:
1. ring 0 stack
2. ss (segment selector register)
3. rsp (stack pointer)
4. rflags
5. cs (code segment register)
6. rip (instruction pointer) at top of the stack
7. error code (optionally)

Interrupt handler rsp points to next 64 bits


Compare to the simple call instruction, which
restores only rip.


## Interrupt Descriptor Table

Abstract (or not) device may provoke an interrupt, which
results in some other code being executed. This code is
called an interrupt handler and is a part of an operating
system or driver software.

Intel separates external asynchronous interrupts from
internal synchronous exceptions, but both are handled alike.

Each interrupt is labeled with a fixed number, which serves
as its identifier.

When the n-th interrupt occurs, the CPU checks the Interrupt
Descriptor Table (IDT), which resides in memory. Analogously
to GDT, its address and size are stored in **idtr**.

**idtr** register contains:
* 64 bit IDT address and
* 16 bit IDT size

Each entry in IDT takes 16 bytes, and the n-th entry
corresponds to the n-th interrupt. The entry incorporates
some utility information as well as an address of the
interrupt handler:

1. 32 bit reserved
2. 32 bit handler address
3. 16 bit handler address
4. 1 bit P
5. 2 bit DPL - Descriptor Privilege Level, Current privilege
   level should be less or equal to DPL in order to call
   this handler using int instruction. Otherwise the check
   does not occur.
6. 1 bit 0
7. 4 bit type
   * 1110 - interrupt gate, IF (interrupt flag) is
     automatically cleared (interrupts ignored) in the handler
   * 1111 - trap gate, IF is not cleared (handler may be
     interrupted)
8. 5 bit 0
9.  3 bit IST (Interrupt Stack Table)
10. 16 bit segment selector SS (used by ss register)
11. 16 bit handler address

So handler address is spreaded 64 bits.

Set of interrupt descriptors:
* The first 30 interrupts are reserved. It means that you
  can provide interrupt handlers for them, but the CPU will
  use them for its internal events such as invalid
  instruction encoding. 
* Other interrupts can be used by the system programmer.


## Mode switch

The application code is executed with low privileges (in
ring3). Direct device control is only possible on higher
privilege levels. When a device requires attention by
sending an interrupt to the CPU, the handler should be
executed in a higher privilege ring. 

Change of mode from user to system requiries changing
the segment selector, to system segment selector with
higher privilages.


## Stack switch

Stack also must be changed, to one of Interrupt Stack Table
IST from the set of ISTs defined in Task State Segment (TSS).



# System calls

The mechanisms used to implement system calls vary in
different architectures. Overall, any instruction resulting
in an interrupt will do, for example, division by zero or
any incorrectly encoded instruction.  The interrupt handler
will be called and then the CPU will handle the rest. In
protected mode on Intel architecture, the interrupt with
code 0x80 was used by *nix operating systems. Each time a
user executed int 0x80, the interrupt handler checked the
register contents for system call number and arguments.


Intel 64 there is a new mechanism to perform system calls,
which uses **syscall** and **sysret** instructions to
implement them. Also some general purpose registers are now
implicitly used during system call:
* rcx is used to store old rip
* r11 is used to store old rflags

## Model-Specific Registers (MSR)

Sometimes when a new CPU appears it has additional
registers, which other, more ancient ones, do not have.
Quite often these are so-called Model-Specific Registers.
When these registers are rarely modified, their manipulation
is performed via two commands:
* rdmsr to read to read register with identifying number
  * identyfing number passed in ecx,
  * register value in edx:eax
* wrmsr to write register with identifying number
  * identyfing number passed in ecx,
  * register value is passed in edx:eax

## syscall

The syscall instruction depends on several MSRs:
* STAR (MSR number 0xC0000081), which holds two pairs of cs
  and ss values
  * GDT should store two particular descriptors for code and
    data specifically for syscall support
* LSTAR (MSR number 0xC0000082) holds the system call
  handler address (new rip)
* SFMASK (MSR number 0xC0000084) shows which bits in rflags
  should be cleared in the system call handler.

The **syscall** performs the following actions:
1. Loads cs from STAR (fixed by os config) - syscall
   handler is responsible for its own stack
2. Changes rflags with regards to SFMASK (fixed by os config)
3. Saves rip into rcx; and
4. Initializes rip with LSTAR value and takes new cs and ss
   from STAR

System call handling ends with **sysret** instruction, which:
1. loads cs from STAR (fixed by os config)
2. loads ss from STAR (fixed by os config)
3. restore rip from rcx (syscall saved it there)


[1001 Ways of Implementing a System Call](https://x86.lol/generic/2019/07/04/kernel-entry.html)
<https://www.bottomupcs.com/index.xhtml>



# State machine

State machine may do lot of tasks, but
some trivial tasks it cannot do.

For example state machine cannot count arbitrary
length stings (because it must have fixed number
of states), but can count strings up to fixed length
(as max integer for example).

## Regular expressions are a way to encode finite automatons

If state machine is sequence of inputs associated with sequence
of states than all possible pairs of such sequences describe
state machine as graph or matrix (with 0 elements for wronge, 1 
for right combinations) of states and state transitions and inputs. 

Such set can be described also by regular expressions.


# Stack machine

Push and pop from the stack => functions to manipulate
stack. Such machine probably is indeterministic
because sometimes it can not terminate.

Lets implement some time Forth Machine!!!



# Calling convention

[Michael Matz, Jan Hubicka, Andreas Jaeger, and Mark Mitchell. System V
Application Binary Interface. AMD64 Architecture Processor Supplement.]

The calling conventions declare, among other things, the
argument passing algorithm. In the case of the typical *nix
x86 64 convention we are using, the description that follows
is an accurate enough approximation of how the function is
called.

# Shared Objects

`man dlopen , dlsym , dlclose`


## Dynamic Loading

The initial stage of loading an executable is to create an
address space and perform memory mappings according to the
program headers table with appropriate permissions. This is
performed by the operating system kernel. Once the virtual
address space is set, the other program has to interfere
(i.e., dynamic loader).  The latter should be an executable
program, and fully relocatable (so it should be able to be
loaded at whatever address we want).  The purpose of the
dynamic linker is to:

* Determine all dependencies and load them.
* Perform relocation of the applications and dependencies.
* Initialize the application and its dependencies and pass
  the control to the application.

Now, the program execution will start.

Determining dependencies and loading them is relatively
easy: it boils down to searching dependencies recursively
and checking whether the object has been already loaded or
not. Initializing is also not very mystified.

There are two kinds of relocations:
* Links to locations in the same object. The static linker
  is performing all such relocations since they are known at
  the link time.
* Symbol dependencies, which are usually in the different
  object (dynamic linker).


The second kind of relocation is more costly and is
performed by the dynamic linker.

## Position Independent Code (PIC)

Position Independent Code (PIC) implies using two utility
tables:Global Offset Table (GOT) and Program Linkage Table
(PLT).

























