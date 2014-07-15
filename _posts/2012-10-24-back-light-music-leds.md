---
layout: post
title:  "Back-light Music LEDs"
date:   2012-10-24
---

[![](http://1.bp.blogspot.com/-OFSn--cd2dQ/UIdrY6kyN1I/AAAAAAAAAX8/_JEaGnLWr3Q/s640/setup.jpg)](http://1.bp.blogspot.com/-OFSn--cd2dQ/UIdrY6kyN1I/AAAAAAAAAX8/_JEaGnLWr3Q/s1600/setup.jpg)

#### tl;dr
The LED lamp behind my monitor pulsates with the audio from my computer. Video is at the bottom.
[The Code](https://github.com/Zolmeister/AudioMan) (warning, ugly code ahead)

#### Setup:
So the way the led lamp works, is that it is hooked up to an arduino which connects over USB to my tower. My computer is running a python script which sends the arduino the value of brightness to set the lamp at, based on the audio output of the music.

PulseAudio -> python -> arduino -> LED lamp

#### Getting the audio output into python:
This was probably the most silly issue that I had to deal with, because it seemed so simple in terms of what I needed to do, but took a ton of trial and error and lots of failing. Let me save you the trouble. You may have heard of [JACK](http://jackaudio.org/). JACK is a pain, takes a lot of work, and for me it didn't work at all. Save yourself the trouble and stay away from JACK. I use [PulseAudio](http://www.freedesktop.org/wiki/Software/PulseAudio) for my sound system as it works &nbsp;with my USB headphones (they're virtual 7.1 surround sound and have drivers that only work on windows XP). Setting up my headphones is a pain, but worth it because of the fuzz (the part that goes over my ears is fuzzy which makes them extremely comfortable). Ok, enough background, here is the secret:

*   Open Pulse Audio Volume control (pavucontrol).
*   Open Sound Recorder.
*   Start recording, and go to the "Recording" tab of the volume controller
*   Click on the input, and change it to "Monitor of XXX" (where XXX is your audio device)
*   Done! (Just remember to do this for the python script while running it for the first time)

#### Python and beat detection:
You can check out the code [here](https://github.com/Zolmeister/AudioMan). Basically it uses the [pyaudio](http://people.csail.mit.edu/hubert/pyaudio/) library to record audio, write streaming data chunks to a temporary wav file (this could be improved upon), and use some magic to get amplitude data from the wav file. Then it normalizes the amplitude over the 0-255 range of LED brightness for the arduino, smooths the curve slightly, and sends the amplitude over to the arduino at 115200 baud (not sure if this is too much/not enough, but it worked for me - 9600 baud hung because it was too slow).

**Beat detection snippet (thanks [Mr.Doob](http://ricardocabello.com/blog/post/677) and [Dean McNamee](http://www.deanmcnamee.com/))**

```python
w = wave.open(WAVE_OUTPUT_FILENAME, 'rb')
summ = 0
value = 1
delta = 1
amps = [ ]
for i in xrange(0, w.getnframes()):
  data = struct.unpack('<h', w.readframes(1))
  summ += (data[0]*data[0]) / 2
  if (i != 0 and (i % 1470) == 0):
    value = int(math.sqrt(summ / 1470.0) / 10)
    amps.append(value - delta)
    summ = 0
    tarW=str(amps[0]*1.0/delta/100)

    # this method normalized the data and sends it to the arduino
    sendVal(tarW)
    delta = value
```

My normalization algorithm for the value consists of storing the last 100 values of data and dividing new data by the max of the last X values (all values before a reset) to get a value between 0 and 1, which I then multiply by 255 to get 0-255\. After a period of low values (ie. silence), detected by the store of last 100 values, the&nbsp;minimum&nbsp;and maximum values reset to allow for a new song which may not fit the amplitude of the previous song. I smooth the data by averaging the current point with the previous point.

#### Arduino LED fading (pwm):
So the arduino UNO that I have has 6 pwm digital I/O pins, which allows me to dim LEDs attached to those pins. After that, just running an analogWrite() on them with a value between 0-255 will dim the LED accordingly. One thing I did have trouble with though was sending the 0-255 number over serial from python, which I fixed by using a buffer and made the python always write out 3 character strings of data and used the atoi() command (ascii to int) to get the values back out.

#### The lamp:
I hooked up 12 LEDs, 6 pairs of 2 LEDs hooked up in parallel connected to one of six pwm I/O pins. After lots of frustration regarding the illumination of the LEDs (I used a dremel to diffuse the LEDs, and ended up arcing them as shown below), I finally got it to work. I just can't let the arduino fall off because the wires going to it come out easily (design issue, but hey it works).

[![](http://4.bp.blogspot.com/-IlfyYj4ZvM4/UIdrYTVbR3I/AAAAAAAAAX0/PR0QRVM_DNw/s640/lamp.jpg)](http://4.bp.blogspot.com/-IlfyYj4ZvM4/UIdrYTVbR3I/AAAAAAAAAX0/PR0QRVM_DNw/s1600/lamp.jpg)</div>

#### The result:
<iframe allowfullscreen="allowfullscreen" frameborder="0" height="480" src="http://www.youtube.com/embed/V7WKf7O7V5E" width="640"></iframe>
(yes I have 5 monitors, song: Bopalong, Kinobe)
