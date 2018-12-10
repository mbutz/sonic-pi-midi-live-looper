# Live Looper Script for Sonic Pi

## Introduction

This is a script to capture external sound and loop it within Sonic Pi; recording and playback will be triggered and controlled by a given Midi controller. I tested the script with an Arturia Beatstep as well as an Arturia MiniLab MKII (note: I have no affiliation whatsoever to Arturia besides the fact that I own the two mentioned products).

The idea behind the Live Looper script: If you want to jam using Sonic Pi together with other musicians, capture incomming sound, loop and work with it. I'd also like to use an external controller so that I can do the recording and playback control of these captured loops without having to code. The (live) coding part is reserved for the manipulation of the recorded sounds and additional sound creation and manipulation within Sonic Pi.

## Live Looper Concept and Logic

There are two live loops constantly running in parallel once you have started this script:

* `play_track[n]` and 
* `record_track[n]`

Length of these live loops is set by `:t[n]_len` in the configuration section.

These live loops will be generated dynamically: if you set `:track_conf[[...],[...]]` you will get 2 tracks with 2 live loops per track; you can configure as much tracks as you want. Note that for full functionality you'll need two midi toggles (play/record) and 3 rotaries (volume, lpf and hpf cutoff) per track. Essential are only the toggles. Of course you will have to set properties for all tracks in the configuration. Configure `:track_conf` as well as the other variables such as e. g. `t[n]_len` for track length in beats and `t[n]_play` (boolean) to indicate the starting value for the play toggle (false = do not replay the loop).

## Notes on Playing and Recording (a picture of 4 loop cycles)

The 'play' live loop is replaying the recorded sample if `t[n]_play == true` and cueing the recording live loop if `t[n]_rec == true`; the record live loop will record if `t[n]_rec == true` or just sleep for the configurated length.

Let's assume we are talking about track no 1, meaning live loop `:play_track1` and `:record_track1` both with a length of 8 beats and 4 cycles to see how play and record are working together:

key: - = 1 beat; ->1 = first run; x = some event (e. g. midi toggle or cue/sync)

```
:play_track1
 ->1                       ->2                       ->3                     ->4
| -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  - | - play recorded
           x              x                         x                            sample...
   toggle rec pressed     1. cue :record_track1
                          2. metronom signal in-    stop extra metronom signal
                             dicating recording:
                             "1...2...3.+.4..+"
 :record_track1
->1                       ->2                       ->3                      ->4
| -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  - | - just sleep...
                          x                         x                       x
                      picks up sync        1. syncs and starts recording    LED cleared
                                           2. blinking toggle LED           ^
                                                    ^                       |
                                                    |                       |
                                               [if controller accepts midi feedback]
```

In cycle 4 `:play_track1` will replay the recorded track1 if `t[1]_play` is true (= associated controller button 'on') and `:record_track1` will just sleep.

## Components

Only one file: `midi-live-looper.rb`

## Setup

See the configuration section in `midi-live-looper.rb`; there is a (mainly) device specific section, which covers e. g. Midi setup, pads and rotary controllers of your Midi device. The file is - I hope - well documented.

## Working with recorded loops

One of the more interesting things is to record some sound and work with it in a separate buffer. You can address all tracks for further manipulation in a separate buffer via:

```
sample "~/.sonic-pi/store/default/cached_samples/track[1..4].wav"
```

Try e. g. with a 4-beat-loop:

```
live_loop :my_track, sync: :play_track1 do # for syncing available: :play_track[1..4]
  sample "~/.sonic-pi/store/default/cached_samples/track1.wav", beat_stretch: 8
  sleep 8
end
```

Note: The path syntax is for Linux. You will have to adjust the path if working with Windows or MacOSX.

## TODOs

There are several 'FIXME's in the code. I will address these as soon as possible.
