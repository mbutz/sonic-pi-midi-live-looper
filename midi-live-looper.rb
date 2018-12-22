# coding: utf-8
# Midi Live Looper for Sonic Pi
# Filename: midi-live-looper.rb
# Project site and documentation: https://github.com/mbutz/sonic-pi-live-looper
# License: https://github.com/mbutz/sonic-pi-live-looper/LICENSE.md
#
# Copyright 2018 by Martin Butz (http://www.mkblog.org).
# All rights reserved.
# Permission is granted for use, copying, modification, and
# distribution of modified versions of this work as long as this
# notice is included.
#
# Sonic Pi is provided by Sam Aaron:
# https://www.sonic-pi.net
# https://github.com/samaaron/sonic-pi
# Please consider to support Sam financially via https://www.patreon.com/samaaron

#
# Live Looper Concept and Logic ##################################################################
#
# There are 2 live_loops constantly running in parallel once you have started this script:
# play_track[n] and record_track[n]; length is set by :t[n]_len in the configuration section.
# These live_loops will be generated dynamically: if you set :track_conf[[...],[...]] you will
# get 2 tracks with 2 live_loops per track; you can configure as much tracks as you want. Note
# that for full functionality you'll need two midi toggles (play/record) and 3 rotaries (volume,
# lpf and hpf cutoff) per track. Essential are only the toggles. Of course you will have to set
# properties for all tracks in the configuration section below. Configure :track_conf as well
# as the other variables such as e. g. t[n]_len for track length in beats and t[n]_play (boolean)
# to indicate the starting value value for the play toggle (false = do not replay the loop).
#
# Notes on Playing and Recording (e. g. 4 cycles of the loops)
#
# The 'play' live_loop is replaying the recorded sample if t[n]_play == true and cueing the
# recording live_loop if t[n]_rec == true; the record live_loop will record if t[n]_rec == true
# or just sleep for configurated length.
#
# Let's assume we are talking about track no 1, meaning live_loop :play_track1 and :record_track1
# both with a length of 8 beats and 4 cycles to see how play and record are working together:
#
# key: - = 1 beat; ->1 = first run; x = some event (e. g. midi toggle or cue/sync)
#
# :play_track1
#  ->1                       ->2                       ->3                     ->4
# | -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  - | - play recorded
#            x              x                         x                            sample...
#    toggle rec pressed     1. cue :record_track1
#                           2. metronom signal in-    stop extra metronom signal
#                              dicating recording:
#                              "1...2...3.+.4..+"
#  :record_track1
# ->1                       ->2                       ->3                      ->4
# | -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  -  | -  -  -  -  -  -  -  - | - just sleep...
#                           x                         x                       x
#                       picks up sync        1. syncs and starts recording    LED cleared
#                                            2. blinking toggle LED           ^
#                                                     ^                       |
#                                                     |                       |
#                                                [if controller accepts midi feedback]
#
# In cycle 4 :play_track1 will replay the recorded track1 if t[1]_play # is true (= associated
# controller button 'on') and # :record_track1 will just sleep.
#
##################################################################################################

# FIXME: Volume and filter manipulation takes ages with MKII
# Find out how to fix that

# Set :msg to 1 if you want some feedback such as volume changes
set :msg, 1 # 0 = none, 1 = info, 2 = debug
set :monitor, true
set :time_fix_play, -0.05 # latency fix

set :master_vol_metro, 1 # metro master volume
set :vol_metro, 0.25 # metro volume, set to 0 if you don't want a metronome at all
set :rec_metro, get(:vol_metro) # recording metro volume
set :master_vol_rec, 1 # recording master volume
set :master_vol_play, 1 # playback master volume

# FIXME: First run of script: fix for error needed: "undefined method 'size' for nil" line 441
# it seems that :track_conf is not available at first start of the script

set :default_len_track, 8 # default track length
set :lpf_hpf_combined, true

use_bpm 120 # set BPM here

####################################################################
# Device specific configuration starts here                        #
# Live Looper Configuration file for Arturia Beatstep              #

set :midi_port, "arturia_beatstep_midi_1"

# FIXME: Can this also be * (any) or do we need a specific channel?
set :midi_chan, 10

set :midi_path, "/midi/arturia_beatstep_midi_1/*/10/control_change"

#
# 8-Track configuration works with Arturia Preset No. 10
#

# TODO:
# + comment :lpf_hpf_combined
# + check FIXMEs
# + separate device specific configuration (don't forget to set bpm for both buffers)
# 
#
#
# + update Git


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
  ["track7", :t7_len, :t7_vol, :t7_lpf, :t7_hpf, :t7_play, :t7_rec],
  ["track8", :t8_len, :t8_vol, :t8_lpf, :t8_hpf, :t8_play, :t8_rec]
]

# Initial (readable!) track configuration:
set :t1_len, 8
set :t1_vol, 2
set :t1_lpf, 130
set :t1_hpf, 0
set :t1_play, false
set :t1_rec, false

set :t2_len, 8
set :t2_vol, 1
set :t2_lpf, 130
set :t2_hpf, 0
set :t2_play, false
set :t2_rec, false

set :t3_len, 8
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

set :t5_len, 16
set :t5_vol, 1
set :t5_lpf, 130
set :t5_hpf, 0
set :t5_play, false
set :t5_rec, false

set :t6_len, 16
set :t6_vol, 1
set :t6_lpf, 130
set :t6_hpf, 0
set :t6_play, false
set :t6_rec, false

set :t7_len, 16
set :t7_vol, 1
set :t7_lpf, 130
set :t7_hpf, 0
set :t7_play, false
set :t7_rec, false

set :t8_len, 16
set :t8_vol, 1
set :t8_lpf, 130
set :t8_hpf, 0
set :t8_play, false
set :t8_rec, false

# Midi rotary controller for volume
set :midi_metro_rot, 7

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
  [104, 108],
  [105, 109]
]

# List of Midi Number Knobs per Track: :midi_rotaries
# 0: First index for track number: t1 = 0, t2 = 1 etc.
#   0: volume
#   1: lpf
#   2: hpf
set :midi_rotaries, [
  [16, 24, 24],
  [17, 25, 25],
  [18, 26, 26],
  [19, 27, 27],
  [20, 28, 28],
  [21, 29, 29],
  [22, 30, 30],
  [23, 31, 31]
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


# Send start signal for Arturia Beatstep sequencer
midi_start

# sync Arturia Beatstep sequencer
live_loop :beatstep do
  time_warp 0.1 do
    midi_clock_beat
  end
  sleep 1
end

# Device specific configuration ends here                          #
####################################################################

# Some Functions                                                   #
# -----------------------------------------------------------------#
# print debug message
define :msg do | text, var=" " |
  puts "--------------------"
  puts "#{text} #{var}"
  puts "++++++++++++++++++++"
  puts "                    "
end

# Calculate proper values for volume # or cutoff
# vol: 0 - 127
# lowpass:  none = 130, max cutoff = 0
# highpass: none = 0, max cutoff = 130
# will display volume changes in log window if log level 1 or 2
if get(:lpf_hpf_combined)
  define :scale_val do |val, opt=""|
    max = 130
    if opt == "lpf"
      if val <= 64
        v = (max.to_f / 64 * val.to_f)
        msg("LowPass Filter:", v.to_int) if get(:msg) == 1 || 2
      else
        v = 130
      end
    elsif opt == "hpf"
      if val > 64
        v = (max.to_f / 64 * val.to_f) - 130
        msg("HighPass Filter:", v.to_int) if get(:msg) == 1 || 2
      else
        v = 0
      end
    else
      max = 1
      v = max.to_f / 127 * val.to_f * get(:master_vol_play)
      msg("Volume:", v.round(2)) if get(:msg) == 1 || 2
    end
    return v
  end
else
  define :scale_val do |val, opt=""|
    max = 130
    if opt == "lpf"
      a = max - (max.to_f / 127 * val.to_f)
      msg("LPF:", a.to_int) if get(:msg) == 1 || 2
    elsif opt == "hpf"
      a = (max.to_f / 127 * val.to_f)
      msg("HPF:", a.to_int) if get(:msg) == 1 || 2
    else
      max = 1
      a = max.to_f / 127 * val.to_f * get(:master_vol_play)
      msg("VOL:", a.round(2)) if get(:msg) == 1 || 2
    end
    return a
  end
end

# Start Metronome                                                  #
# -----------------------------------------------------------------#

live_loop :beat do
  s = sample :elec_tick, amp: get(:vol_metro)
  set :beat_metro, s # set pointer for control statement
  sleep 1
end

# Listen to Midi Controller                                        #
# -----------------------------------------------------------------#

# Get midi toggle and set boolean var in Sonic Pi
define :toggle2sp do | midi_sync, midi_num, cnf, vals |
  if midi_sync[0] == midi_num and midi_sync[1] == vals[0]
    set cnf, true
  elsif midi_sync[0] == midi_num and midi_sync[1] == vals[1]
    set cnf, false
  end
end

# Listen to toggles and call toggle2sp for all pads of a track
# (play + rec toggle); proceed then to next track
# 1. Get track number; 2. get settings per track (only
# :t[n]_play and :t[n]_rec from track_conf
live_loop :getset_toggle_pads do
  use_real_time
  s = sync get(:midi_path)
  i = 0
  get(:midi_pads).size.times do |i|
    k = 0
    get(:midi_pads)[0].size.times do |k|
      cnf = (ring 5, 6)[k]
      toggle2sp(s, get(:midi_pads)[i][k], get(:track_conf)[i][cnf], [127, 0])
      k =+ 1
    end
    i =+ 1
  end
end

# Listen to rotaries
# Build a pointer (ctrl) to control sample params
# see: :build_playback_loop
# count 3 controllers and start again for next track
# get :track_conf option index for vol, hpf, lpf
# set option in question
# get value and set value in Sonic Pi
# control changes in real time (opt=>)
live_loop :getset_rotary_controllers do
  use_real_time
  s = sync get(:midi_path)
  i = 0
  get(:midi_rotaries).size.times do |i| # track number one after the other
    ctrl = ("ctrl_" + (get(:track_conf)[i][0])).to_sym
    k = 0
    get(:midi_rotaries)[0].size.times do |k| # get rotary numbers per track
      num = (ring 0, 1, 2)[k]
      cnf = (ring 2, 3, 4)[k]
      opt = (ring :amp, :lpf, :hpf)[k]
      if s[0] == get(:midi_rotaries)[i][num]
        set get(:track_conf)[i][cnf], scale_val(s[1], opt.to_s)
        control get(ctrl), opt=>get(get(:track_conf)[i][cnf])
      end
      k =+ 1
    end
    i =+ 1
  end

  # Metro volume (not within track_conf so let's get this by foot)
  if s[0] == get(:midi_metro_rot)
    set :vol_metro, scale_val(s[1])
    control get(:beat_metro), amp: get(:vol_metro)
    control get(:marker_metro), amp: get(:vol_metro)
  end
end

# Metronome                                                        #
# -----------------------------------------------------------------#
# marks the "1" in case a track is set up for recording
live_loop :metro_marking_one do
  sync :rec
  s = sample :elec_tick, amp: get(:vol_metro) * get(:master_vol_metro), rate: 0.75
  set :marker_metro, s
  sleep get(:default_len_track)
end

# (Re)Play and Record Functions                                    #
# -----------------------------------------------------------------#
#
# All tracks can be addressed for further manipulation via:
# 'sample "~/.sonic-pi/store/default/cached_samples/track[1..4].wav"' resp.
# Synchronisation of all additional live_loops with: sync: :play_track1[..4]

# Dynamically builds as much play back live_loops as configurated
# if recording toggle true:
# 1. send cue and start metronome on loop run in advance (fix: will also run
# during recording as toggle is still true as long as the recording hasn't
# finished so use modulo and let metro only be audible _before_ recording
# 2. play recorded track[n] sample already contains if t[n]_play == true.
#
# FIXME:
# Not sure if we need time_warp fix but it is a tool for fine-tuning any
# latency issues; if not needed it can be set to 0 in the configuration section
define :build_playback_loop do |idx|

  # FIXME: idx.to_int needed?
  track_sample = buffer[get(:track_conf)[idx][0], get(get(:track_conf)[idx][1])]

  ctrl = ("ctrl_" + (get(:track_conf)[idx.to_int][0])).to_sym

  live_loop ("play_" + (get(:track_conf)[idx.to_int][0])).to_sym do
    on get(get(:track_conf)[idx][6]) do
      cue :rec
      cnt = tick % 2
      in_thread do
        if cnt < 1
          n = get(get(:track_conf)[idx][1]) / 2.0
          sleep n
          n.times do
            m = sample :elec_tick, rate: 1.5, amp: get(:vol_metro) * get(:master_vol_metro)
            set :mute_metro, m
            sleep 1
          end
        end
      end
    end #on :t[n]_rec
    on get(get(:track_conf)[idx][5]) do
      time_warp get(:time_fix_play) do
        s = sample track_sample, amp: get(get(:track_conf)[idx][2]), lpf: get(get(:track_conf)[idx][3]), hpf: get(get(:track_conf)[idx][4])
        set ctrl, s
      end # time_warp
    end
    sleep get(get(:track_conf)[idx][1])
  end
end

# Dynamically builds as much recording live_loops as configurated
# in contrast to playback loops: Recording only works for one track at a time
#
# if recording toggle true:
# 1. set it to false, we only want to record one loop running
# 2. let LED blink (needs support from controller)
# 3. shut down live audio for monitoring incoming sound while not recording
# 4. record to prepared buffer for loop length
# 5. stop recording and clear LED
# else just sleep for loop length
define :build_recording_loop do |idx|

  # for easy access to recording buffer name and live audio
  track_sample = buffer[get(:track_conf)[idx][0], get(get(:track_conf)[idx][1])]

  # FIXME: idx.to_int needed?
  audio = ("audio_" + (get(:track_conf)[idx.to_int][0])).to_sym

  live_loop ("record_" + (get(:track_conf)[idx.to_int][0])).to_sym do
    if get(get(:track_conf)[idx][6]) == true # if :t[n]_rec true
      sync :rec
      set get(:track_conf)[idx][6], false # :t[n]_rec
      in_thread do
        # FIXME: This is controller specific, so store the command in a variable
        # and move it to the controller specific configuration.
        get(get(:track_conf)[idx][1]).times do
          midi_cc get(:midi_pads)[idx][1], 127, port: get(:midi_port), channel: get(:midi_chan)
          sleep 0.5
          midi_cc get(:midi_pads)[idx][1], 0, port: get(:midi_port), channel: get(:midi_chan)
          sleep 0.5
        end
      end
      live_audio :mon, :stop
      with_fx :record, buffer: track_sample, pre_amp: get(:master_vol_rec) do
        live_audio audio, stereo: true
      end
      sleep get(get(:track_conf)[idx][1])
      live_audio audio, :stop
      midi_cc get(:midi_pads)[idx][1], 0, port: get(:midi_port), channel: get(:midi_chan)
    elsif
      if get(:monitor)
        live_audio :mon, stereo: true # switch monitor on
      end
      sleep get(get(:track_conf)[idx][1])
    end
  end
end

# Create the play back and recording live_loops; look into track_conf to find out how many...
i = 0
# FIXME: On first run this throughs an error: "undefined method size"
get(:track_conf).size.times do |i|
  build_playback_loop(i)
  build_recording_loop(i)
  i =+ 1
end
