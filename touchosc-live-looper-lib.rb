# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-lib.rb
# contact: Martin Butz, mb@mkblog.org

# FIXME: Create functions for handling tracks where advisable:
# define :track_record
# define :track_set_volume
# define : track_play
# aso.

use_osc get(:ip), get(:port)
use_bpm get(:my_bpm)

# -----------------------------------------------------------------#
# Audible Metronome                                                #
# -----------------------------------------------------------------#

# Get/set metronome volume
live_loop :m_vol do
  use_real_time
  c = sync "/osc/looper/metro_vol"
  set :metro_vol, c[0]
end
# Start/stop metronome
live_loop :m do
  use_real_time
  c = sync "/osc/looper/metro"
  set :metro_toggle, c[0]
end

# Metronome reflects number of beats of the choosen track: if track is 8 beats
# long the metronome will be also; metronome marks '1' with louder
# and deeper click.
# The metronome will start, once a recording track has been selected.

define :metronome do | len |
  f = len - 1
  sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 1.0 if get(:metro_toggle) == 1
  sleep 1
  f.times do
    sample :elec_tick, amp: get(:metro_vol) * get(:metro_vol_master) * 0.5, rate: 1.25 if get(:metro_toggle) == 1
    sleep 1
  end
end

# -----------------------------------------------------------------#
# Arm Tracks for Recording                                         #
# -----------------------------------------------------------------#

# Set up recording tracks
# All tracks can be addressed in a for further manipulation via:
# 'sample "~/.sonic-pi/store/default/cached_samples/track[1..4].wav"' resp.
t1 = buffer[:track1, get(:track1_len)]
t2 = buffer[:track2, get(:track2_len)]
t3 = buffer[:track3, get(:track3_len)]
t4 = buffer[:track4, get(:track4_len)]

live_loop :t1 do
  use_real_time
  c = sync "/osc/looper/track_arm/2/1"
  set :track1, c[0]
  set :track_len, get(:track1_len)
end
live_loop :t2 do
  use_real_time
  c = sync "/osc/looper/track_arm/2/2"
  set :track2, c[0]
  set :track_len, get(:track2_len)
end
live_loop :t3 do
  use_real_time
  c = sync "/osc/looper/track_arm/1/1"
  set :track3, c[0]
  set :track_len, get(:track3_len)
end
live_loop :t4 do
  use_real_time
  c = sync "/osc/looper/track_arm/1/2"
  set :track4, c[0]
  set :track_len, get(:track4_len)
end

# -----------------------------------------------------------------#
# (Re)Play Tracks                                                  #
# -----------------------------------------------------------------#

# Get playback volume from touchosc
live_loop :t1_vol do
  use_real_time
  c = sync "/osc/looper/track1_vol"
  set :track1_vol, c[0]
end
live_loop :t2_vol do
  use_real_time
  c = sync "/osc/looper/track2_vol"
  set :track2_vol, c[0]
end
live_loop :t3_vol do
  use_real_time
  c = sync "/osc/looper/track3_vol"
  set :track3_vol, c[0]
end
live_loop :t4_vol do
  use_real_time
  c = sync "/osc/looper/track4_vol"
  set :track4_vol, c[0]
end

# Play tracks, switch metronome on if recording track is slected
live_loop :play_t1 do
  sample t1, amp: get(:track1_vol)
  if get(:track1) == 1.0
    metronome(get(:track1_len))
  else
    sleep get(:track1_len)
  end
end
live_loop :play_t2 do
  sample t2, amp: get(:track2_vol)
  if get(:track2) == 1.0
    metronome(get(:track2_len))
  else
    sleep get(:track2_len)
  end
end
live_loop :play_t3 do
  sample t3, amp: get(:track3_vol)
  if get(:track3) == 1.0
    metronome(get(:track3_len))
  else
    sleep get(:track3_len)
  end
end
live_loop :play_t4 do
  sample t4, amp: get(:track4_vol)
  if get(:track4) == 1.0
    metronome(get(:track4_len))
  else
    sleep get(:track4_len)
  end
end

# -----------------------------------------------------------------#
# Record Tracks                                                    #
# -----------------------------------------------------------------#

# Track 1
if get(:track1) == 1.0
  in_thread(name: :t1_rec) do
    sync :play_t1
    sample_free "~/.sonic-pi/store/default/cached_samples/track1.wav"
    with_fx :record, buffer: t1, pre_amp: get(:rec_level) do
      osc "/looper/track1_rec", 1
      live_audio :audio_in1, stereo: true
    end
    sleep get(:track1_len)
    live_audio :audio_in1, :stop
    osc "/looper/track_arm/2/1", 0
    osc "/looper/track1_rec", 0
    set :track1, 0
  end
end
# Track 2
if get(:track2) == 1.0
  in_thread(name: :t2_rec) do
    sync :play_t2
    sample_free "~/.sonic-pi/store/default/cached_samples/track2.wav"
    with_fx :record, buffer: t2, pre_amp: get(:rec_level) do
      osc "/looper/track2_rec", 1
      live_audio :audio_in2, stereo: true
    end
    sleep get(:track2_len)
    live_audio :audio_in2, :stop
    osc "/looper/track_arm/2/2", 0
    osc "/looper/track2_rec", 0
    set :track2, 0
  end
end
# Track 3
if get(:track3) == 1.0
  in_thread(name: :t3_rec) do
    sync :play_t3
    with_fx :record, buffer: t3, pre_amp: get(:rec_level) do
      osc "/looper/track3_rec", 1
      live_audio :audio_in3, stereo: true
    end
    sleep get(:track_len)
    live_audio :audio_in3, :stop
    osc "/looper/track_arm/1/1", 0
    osc "/looper/track3_rec", 0
    set :track3, 0
  end
end
# Track 4
if get(:track4) == 1.0
  in_thread(name: :t4_rec) do
    sync :play_t4
    with_fx :record, buffer: t4, pre_amp: get(:rec_level) do
      osc "/looper/track4_rec", 1
      live_audio :audio_in4, stereo: true
    end
    sleep get(:track_len)
    live_audio :audio_in4, :stop
    osc "/looper/track_arm/1/2", 0
    osc "/looper/track4_rec", 0
    set :track4, 0
  end
end

# -----------------------------------------------------------------#
# Feedback Loop Section                                            #
# -----------------------------------------------------------------#

# Get feedback volume from touchosc
# Feedback volume = volume for rerecording pevious loop sound:
# the lower this is the faster the loop will fade.
# 0.00 = bottom button = no feedback loop
# 1.45 = top button = feedback loop will play forever allthough
# with every record the sound will change and probably loose quality.

# Set up feedback track ('tfb')
# Track can be addressed in a for further manipulation via:
# 'sample "~/.sonic-pi/store/default/cached_samples/tfb.wav"'
tfb = buffer[:tfb, 8]

live_loop :osc_sync_feedback_vol0 do
  use_real_time
  c = sync "/osc/looper/feedback_vol/1/1"
  if c[0] == 1.0
    set :fb_vol, 0
  end
end
live_loop :osc_sync_feedback_vol1 do
  use_real_time
  c = sync "/osc/looper/feedback_vol/2/1"
  if c[0] == 1.0
    set :fb_vol, 1.05
  end
end
live_loop :osc_sync_feedback_vol2 do
  use_real_time
  c = sync "/osc/looper/feedback_vol/3/1"
  if c[0] == 1.0
    set :fb_vol, 1.15
  end
end
live_loop :osc_sync_feedback_vol3 do
  use_real_time
  c = sync "/osc/looper/feedback_vol/4/1"
  if c[0] == 1.0
    set :fb_vol, 1.25
  end
end
live_loop :osc_sync_feedback_vol4 do
  use_real_time
  c = sync "/osc/looper/feedback_vol/5/1"
  if c[0] == 1.0
    set :fb_vol, 1.35
  end
end
live_loop :osc_sync_feedback_vol5 do
  use_real_time
  c = sync "/osc/looper/feedback_vol/6/1"
  if c[0] == 1.0
    set :fb_vol, 1.45
  end
end

live_loop :record_fb do
  with_fx :record, buffer: tfb, pre_amp: get(:fb_vol), pre_mix: 1 do
    sample tfb, amp: 1
    live_audio :audio_fb
  end
  sleep get(:fbtrack_len)
end

# (Re)Play Tracks
live_loop :play_fb do
  sample tfb, amp: 1
  sleep get(:fbtrack_len)
end
