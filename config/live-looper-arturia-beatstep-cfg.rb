# Midi Live Looper Configuration Example for Sonic Pi
# Filename: live-looper-arturia-beatstep-cfg.rb
# Project site and documentation: https://github.com/mbutz/sonic-pi-live-looper
# License: https://github.com/mbutz/sonic-pi-live-looper/LICENSE.md
#
# Copyright 2018 by Martin Butz (http://www.mkblog.org).
# All rights reserved.
# Permission is granted for use, copying, modification, and
# distribution of modified versions of this work as long as this
# notice is included.
#
####################################################################
# Device specific configuration starts here                        #
#                                                                  #
# Copy this file (live-looper-[device]-cfg.rb) into one buffer     #
# and the live looper script (live-looper.rb) into another buffer  #
# Evaluate first the configuration and then the script buffer.     #
#                                                                  #
# Live Looper Configuration file for Arturia Beatstep              #
#                                                                  #
# In my setup 8-Track configuration works with                     #
# Arturia Beatstep Preset No. 10                                   #
####################################################################

set :midi_port, "arturia_beatstep_midi_1"

# FIXME: Can this also be * (any) or do we need a specific channel?
set :midi_chan, 10

set :midi_path, "/midi/arturia_beatstep_midi_1/*/10/control_change"

# :track_conf is a wrapper for track variables.
# Some of these need to be changed during runtime and
# be set or retrieved using a loop and by index.
# Volume of track 1 can e. g. be set/retrieved with:
# set: `set :t1_vol, 0` or `set get(:track_conf)[2][0], 0`
# get: `get(:t1_vol, 1)` or `get(get(:track_conf))[2][0]`
# ! Beware of the position of the last round parenthesis !
# You can get the readable var name with: `get(:track_conf)[2][0]`
set :track_conf, [
  # 0: track 1; 1: track 2; ...
  #   0: name postfix for buffer, recorded sample name (e. g. track1.wav)
  #   1: length
  #   2: playback volume
  #   3: lpf cutoff value
  #   4: hpf cutoff value
  #   5: play toggle
  #   6: record toggle
  ["track1", :t1_len, :t1_vol, :t1_lpf, :t1_hpf, :t1_play, :t1_rec],
  ["track2", :t2_len, :t2_vol, :t2_lpf, :t2_hpf, :t2_play, :t2_rec],
  ["track3", :t3_len, :t3_vol, :t3_lpf, :t3_hpf, :t3_play, :t3_rec],
  ["track4", :t4_len, :t4_vol, :t4_lpf, :t4_hpf, :t4_play, :t4_rec],
  ["track5", :t5_len, :t5_vol, :t5_lpf, :t5_hpf, :t5_play, :t5_rec],
  ["track6", :t6_len, :t6_vol, :t6_lpf, :t6_hpf, :t6_play, :t6_rec],
  ["track7", :t7_len, :t7_vol, :t7_lpf, :t7_hpf, :t7_play, :t7_rec]
]

# Initial (readable!) track configuration:
set :t1_len, 4
set :t1_vol, 2
set :t1_lpf, 130
set :t1_hpf, 0
set :t1_play, false
set :t1_rec, false

set :t2_len, 4
set :t2_vol, 1
set :t2_lpf, 130
set :t2_hpf, 0
set :t2_play, false
set :t2_rec, false

set :t3_len, 4
set :t3_vol, 1
set :t3_lpf, 130
set :t3_hpf, 0
set :t3_play, false
set :t3_rec, false

set :t4_len, 8
set :t4_vol, 1
set :t4_lpf, 130
set :t4_hpf, 0
set :t4_play, false
set :t4_rec, false

set :t5_len, 8
set :t5_vol, 1
set :t5_lpf, 130
set :t5_hpf, 0
set :t5_play, false
set :t5_rec, false

set :t6_len, 8
set :t6_vol, 1
set :t6_lpf, 130
set :t6_hpf, 0
set :t6_play, false
set :t6_rec, false

set :t7_len, 8
set :t7_vol, 1
set :t7_lpf, 130
set :t7_hpf, 0
set :t7_play, false
set :t7_rec, false

# Midi rotary controller for volume
set :midi_metro_rot, 23
set :midi_metro_pad, 105

# List of Midi Pad Numbers per Track: :midi_pads
# 0: First index for track number: t1 = 0, t2 = 1 etc.
#   0: play toggle
#   1: initiate recording toggle
set :midi_pads, [
  [52, 56],
  [53, 57],
  [54, 58],
  [55, 59],
  [102, 106],
  [103, 107],
  [104, 108]
]

# List of Midi Number Knobs per Track: :midi_rotaries
# 0: First index for track number: t1 = 0, t2 = 1 etc.
#   0: volume
#   Filter knob has a double function:
#   if turned left, lpf (130-0), if turned right, hpf (0-130)
#   1: lpf
#   2: hpf
set :midi_rotaries, [
  [16, 24, 24],
  [17, 25, 25],
  [18, 26, 26],
  [19, 27, 27],
  [20, 28, 28],
  [21, 29, 29],
  [22, 30, 30]
]

# FIXME: Clear all pad LEDs and set rotaries to correct values
# For Arturia Beatstep and Minilab this will be done via sysex commands
# once I have figured this out. For the moment the pads can be set via
# ordinary midi control commands.
# Basically the following has to be done:
# 1. Clear LEDs (if you configure 4 channels: 4x record LEC, 4x play LED)
# 2. Set rotaries to appropriate values: volume to 1, lpf to 65, hpf to 65
i = 0
get(:midi_pads).size.times do |i|
  k = 0
  get(:midi_pads)[0].size.times do |k|
    midi_cc get(:midi_pads)[i][k], 0, port: get(:midi_port), channel: get(:midi_chan)
    msg("i: ", i) if get(:msg) == 2
    msg("k: ", k) if get(:msg) == 2
    k =+ 1
  end
  i =+ 1
end
# Set metronome toggle pad to 0
midi_cc get(:midi_metro_pad), 0, port: get(:midi_port), channel: get(:midi_chan)
