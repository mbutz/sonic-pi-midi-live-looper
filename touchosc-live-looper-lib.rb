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
# Arm Tracks for Recording                                         #
# -----------------------------------------------------------------#

# Set up recording tracks
# All tracks can be addressed in a for further manipulation via:
# 'sample "~/.sonic-pi/store/default/cached_samples/track[1..4].wav"' resp.
t1 = buffer[:track1, get(:track1_len)]
t2 = buffer[:track2, get(:track2_len)]
t3 = buffer[:track3, get(:track3_len)]
t4 = buffer[:track4, get(:track4_len)]

live_loop :t1_arm do
  use_real_time
  a = sync "/osc/looper/track_arm/2/1"
  set :track1, a[0]
  set :track_len, get(:track1_len)
end
live_loop :t2_arm do
  use_real_time
  b = sync "/osc/looper/track_arm/2/2"
  set :track2, b[0]
  set :track_len, get(:track2_len)
end
live_loop :t3_arm do
  use_real_time
  c = sync "/osc/looper/track_arm/1/1"
  set :track3, c[0]
  set :track_len, get(:track3_len)
end
live_loop :t4_arm do
  use_real_time
  d = sync "/osc/looper/track_arm/1/2"
  set :track4, d[0]
  set :track_len, get(:track4_len)
end

live_loop :t1_on do
  use_real_time
  a = sync "/osc/looper/track1_on"
  set :track1_on, a[0]
end
live_loop :t2_on do
  use_real_time
  b = sync "/osc/looper/track2_on"
  set :track2_on, b[0]
end
live_loop :t3_on do
  use_real_time
  c = sync "/osc/looper/track3_on"
  set :track3_on, c[0]
end
live_loop :t4_on do
  use_real_time
  e = sync "/osc/looper/track4_on"
  set :track4_on, e[0]
end

# -----------------------------------------------------------------#
# Metronome                                                        #
# -----------------------------------------------------------------#

# Get/set metronome volume
live_loop :metro_amp do
  use_real_time
  c = sync "/osc/looper/metro_vol"
  set :metro_vol, c[0]
  control get(:metronome), amp: get(:metro_vol) * get(:metro_vol_master)
end
# Start/stop metronome
live_loop :metro_onoff do
  use_real_time
  c = sync "/osc/looper/metro"
  set :metro_toggle, c[0]
end

live_loop :beat do
  s = sample :elec_tick, amp: get(:metro_vol) * get(:metro_vol_master) * 0.5, rate: 1.00 if get(:metro_toggle) == 1
  set :metronome, s
  sleep 1
end

live_loop :m do
  sync :metro
  s = sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 0.75 if get(:metro_toggle) == 1
  set :metronome, s
  sleep get(:track_len)
end

# -----------------------------------------------------------------#
# (Re)Play Tracks                                                  #
# -----------------------------------------------------------------#

# Play tracks
live_loop :t1 do
 on get(:track1) do
   cue :metro
 end
 on get(:track1_on) do
   r = sample t1, amp: get(:track1_vol), hpf: get(:track1_hpf), lpf: get(:track1_lpf)
   set :t1_ref, r
 end
 sleep get(:track1_len)
end
live_loop :t2 do
  on get(:track2) do
    cue :metro
  end
  on get(:track2_on) do
    r = sample t2, amp: get(:track2_vol), hpf: get(:track2_hpf), lpf: get(:track2_lpf)
    set :t2_ref, r
  end
  sleep get(:track2_len)
end
live_loop :t3 do
  on get(:track3) do
    cue :metro
  end
  on get(:track3_on) do
    r = sample t3, amp: get(:track3_vol), hpf: get(:track3_hpf), lpf: get(:track3_lpf)
    set :t3_ref, r
  end
  sleep get(:track3_len)
end
live_loop :t4 do
  on get(:track4) do
    cue :metro
  end
  on get(:track4_on) do
    r = sample t4, amp: get(:track4_vol), hpf: get(:track4_hpf), lpf: get(:track4_lpf)
    set :t4_ref, r
  end
  sleep get(:track4_len)
end

# Get playback volume, filter and rate settings from touchosc
live_loop :t1_vol do
  use_real_time
  c = sync "/osc/looper/track1_vol"
  set :track1_vol, c[0]
  s = get(:t1_ref)
  control s, amp: c[0]
end
live_loop :t1_hpf do
  use_real_time
  f = sync "/osc/looper/track1_hpf"
  set :track1_hpf, f[0]
  s = get(:t1_ref)
  control s, hpf: f[0]
end
live_loop :t1_lpf do
  use_real_time
  f = sync "/osc/looper/track1_lpf"
  set :track1_lpf, f[0]
  s = get(:t1_ref)
  control s, lpf: f[0]
end

live_loop :t2_vol do
  use_real_time
  c = sync "/osc/looper/track2_vol"
  set :track2_vol, c[0]
  s = get(:t2_ref)
  control s, amp: c[0]
end
live_loop :t2_hpf do
  use_real_time
  f = sync "/osc/looper/track2_hpf"
  set :track2_hpf, f[0]
  s = get(:t2_ref)
  control s, hpf: f[0]
end
live_loop :t2_lpf do
  use_real_time
  f = sync "/osc/looper/track2_lpf"
  set :track2_lpf, f[0]
  s = get(:t2_ref)
  control s, lpf: f[0]
end

live_loop :t3_vol do
  use_real_time
  c = sync "/osc/looper/track3_vol"
  set :track3_vol, c[0]
  s = get(:t3_ref)
  control s, amp: c[0]
end
live_loop :t3_hpf do
  use_real_time
  f = sync "/osc/looper/track3_hpf"
  set :track3_hpf, f[0]
  s = get(:t3_ref)
  control s, hpf: f[0]
end
live_loop :t3_lpf do
  use_real_time
  f = sync "/osc/looper/track3_lpf"
  set :track3_lpf, f[0]
  s = get(:t3_ref)
  control s, lpf: f[0]
end

live_loop :t4_vol do
  use_real_time
  c = sync "/osc/looper/track4_vol"
  set :track4_vol, c[0]
  s = get(:t4_ref)
end
live_loop :t4_hpf do
  use_real_time
  f = sync "/osc/looper/track4_hpf"
  set :track4_hpf, f[0]
  s = get(:t4_ref)
  control s, hpf: f[0]
end
live_loop :t4_lpf do
  use_real_time
  f = sync "/osc/looper/track4_lpf"
  set :track4_lpf, f[0]
  s = get(:t4_ref)
  control s, lpf: f[0]
end


# -----------------------------------------------------------------#
# Record Tracks                                                    #
# -----------------------------------------------------------------#
# # Track 1
on get(:track1) do
  live_loop :t1_rec do
    #use_real_time
    sync :metro
    n = get(:track1_len) / 2.0
    sleep n # + 1
    n.times do
      sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 1.5 if get(:metro_toggle) == 1
      sleep 1
    end

    sample_free "~/.sonic-pi/store/default/cached_samples/track1.wav"
    osc "/looper/track1_rec", 1

    with_fx :record, buffer: t1, pre_amp: get(:rec_level) do
      live_audio :audio_in1, stereo: true
    end

    sleep get(:track1_len) - 1
    sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 2.0 if get(:metro_toggle) == 1

    #cue :play_track1
    sleep 1
    live_audio :audio_in1, :stop
    osc "/looper/track_arm/2/1", 0
    osc "/looper/track1_rec", 0
    #cue :pt1
    stop
  end
end

# Track 2
on get(:track2) do
  live_loop :t2_rec do
    #use_real_time
    sync :metro
    n = get(:track2_len) / 2.0
    sleep n # + 1
    n.times do
      sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 1.5 if get(:metro_toggle) == 1
      sleep 1
    end

    sample_free "~/.sonic-pi/store/default/cached_samples/track2.wav"
    osc "/looper/track2_rec", 1

    with_fx :record, buffer: t2, pre_amp: get(:rec_level) do
      live_audio :audio_in2, stereo: true
    end

    sleep get(:track2_len) - 1
    sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 2.0 if get(:metro_toggle) == 1
    #cue :play_track2
    sleep 1
    osc "/looper/track_arm/2/2", 0
    osc "/looper/track2_rec", 0
    live_audio :audio_in2, :stop
    set :track2, 0
    stop
  end
end

# Track 3
on get(:track3) do
  live_loop :t3_rec do
    #use_real_time
    sync :metro
    n = get(:track3_len) / 2.0
    sleep n # + 1
    n.times do
      sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 1.5 if get(:metro_toggle) == 1
      sleep 1
    end

    sample_free "~/.sonic-pi/store/default/cached_samples/track3.wav"
    osc "/looper/track3_rec", 1

    with_fx :record, buffer: t3, pre_amp: get(:rec_level) do
      live_audio :audio_in3, stereo: true
    end

    sleep get(:track3_len) - 1
    sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 2.0 if get(:metro_toggle) == 1
    #cue :play_track3
    sleep 1
    osc "/looper/track_arm/1/1", 0
    osc "/looper/track3_rec", 0
    live_audio :audio_in3, :stop
    set :track3, 0
    stop
  end
end

# Track 4
on get(:track4) do
  live_loop :t4_rec do
    #use_real_time
    sync :metro
    n = get(:track4_len) / 2.0
    sleep n # + 1
    n.times do
      sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 1.5 if get(:metro_toggle) == 1
      sleep 1
    end

    sample_free "~/.sonic-pi/store/default/cached_samples/track4.wav"
    osc "/looper/track4_rec", 1

    with_fx :record, buffer: t4, pre_amp: get(:rec_level) do
      live_audio :audio_in4, stereo: true
    end

    sleep get(:track4_len) - 1
    sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 2.0 if get(:metro_toggle) == 1
    #cue :play_track4
    sleep 1
    osc "/looper/track_arm/1/2", 0
    osc "/looper/track4_rec", 0
    live_audio :audio_in4, :stop
    set :track4, 0
    stop
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
