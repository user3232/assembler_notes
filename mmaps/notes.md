# Memory maps

from man procfs

## Example

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

## Address

The address field is the address space in the process 
that the mapping occupies.  

## Permissions

The perms field is a set of permissions:

* r = read
* w = write
* x = execute
* s = shared
* p = private (copy on write)

## Offset

The  offset  field  is  the  offset into the file/whatever; 

## Dev

dev is the device (major:minor); 

## inode

inode is the inode on that device.  0  indicates that  no
inode  is associated with the memory region, as would be the
case with BSS (uninitialized data).

## Pathname

The pathname field will usually be the file that is backing
the  map‐ ping.   For ELF files, you can easily coordinate
with the offset field by looking at the Offset field  in
the  ELF  program  headers  (read‐ elf -l).

There are additional helpful pseudo-paths:

* [stack] The  initial  process's  (also known as the main
        thread's) stack.

* [stack:<tid>] (since Linux 3.4) A thread's stack (where
        the <tid> is  a  thread  ID).   It corresponds to
        the /proc/[pid]/task/[tid]/ path.

* [vdso] The   virtual   dynamically  linked  shared
        object.   See vdso(7).

* [heap] The process's heap.

If the pathname field is  blank,  this  is  an  anonymous
mapping  as obtained via mmap(2).  There is no easy way to
coordinate this back to a process's source, short of running
it through gdb(1), strace(1),  or similar.


# Linux conventions finding

Lets find kernel symbol for PROT_READ constant.

## Serch system include files

```
~$ cd /usr/include
/usr/include$ grep -r PROT_READ
asm-generic/mman-common.h:#define PROT_READ	0x1		/* page can be read */
x86_64-linux-gnu/bits/mman-linux.h:#define PROT_READ	0x1		/* Page can be read.  */
```

## Use internet

Possibilities:
* <http://lxr.free-electrons.com/>
* or google: lxr PROT_READ

