####################################################################
# Device specific configuration starts here                        #
# Live Looper Configuration file for Arturia Beatstep              #

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
      ["track4", :t4_len, :t4_vol, :t4_lpf, :t4_hpf, :t4_play, :t4_rec]
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

# Midi rotary controller for volume
set :midi_metro_rot, 24

# List of Midi Number Pads per Track: :midi_pads
# 0: First index for track number: t1 = 0, t2 = 1 etc.
#   0: play toggle
#   1: initiate recording toggle
set :midi_pads, [
      [52, 56],
      [53, 57],
      [54, 58],
      [55, 59]
    ]

# List of Midi Number Knobs per Track: :midi_rotaries
# 0: First index for track number: t1 = 0, t2 = 1 etc.
#   0: volume
#   1: lpf
#   2: hpf
set :midi_rotaries, [
      [16, 28, 20],
      [17, 29, 21],
      [18, 30, 22],
      [19, 31, 23]
    ]

# FIXME: remove all led pad lights
midi_cc get(:midi_pads)[0][0], 0, port: get(:midi_port), channel: get(:midi_chan)
midi_cc get(:midi_pads)[0][1], 0, port: get(:midi_port), channel: get(:midi_chan)
midi_cc get(:midi_pads)[1][0], 0, port: get(:midi_port), channel: get(:midi_chan)
midi_cc get(:midi_pads)[1][1], 0, port: get(:midi_port), channel: get(:midi_chan)

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
