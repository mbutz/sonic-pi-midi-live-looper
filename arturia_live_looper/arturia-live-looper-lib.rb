# Live Looper Library for Arturia MKII - Library
# filename: arturia-live-looper-lib.rb
# contact: Martin Butz, mb@mkblog.org

# Pads and Knobs
# Pad 1-4: Switch on track 1-4
# Pad 9-12: Arm track 1-4
# Knob 1-4: Volume of track 1-4
# Knob 9: Volume of Metronome
# Knob 5-8: Highpass for track 1-4
# Knob 13-16: Lowpass for track 1-4
# Knob 1/Click: Run script = Start recording

# How to refer to the recorded tracks:
# cache = "/home/marty/.sonic-pi/store/default/cached_samples"
#
# live_loop :track_i1, sync: :t1 do
#   sample cache, "track1.wav", rate: 2
#   sleep 4
# end

use_bpm get(:my_bpm)

# Calculate proper values for volume and cutoff values
define :scale_vol do |v|
  max = 1
  a = max.to_f / 127 * v.to_f * get(:track_level)
  return a
end

define :scale_ctf do |v|
  max = 130
  a = max.to_f / 127 * v.to_f
  return a
end

define :rec_msg do |n|
  #-----------------------------------------------#
  puts "------------------------------"
  puts " "
  puts " "
  puts " "
  puts " "
  puts " "
  puts "RECORDING SOON: Track No. #{n} / #{get(:my_bpm)}"
  puts " "
  puts "RECORDING SOON: Track No. #{n}"
  puts " "
  puts "RECORDING SOON: Track No. #{n}"
  puts " "
  puts " "
  puts " "
  puts " "
  puts " "
  puts "------------------------------"
  #-----------------------------------------------#

end

live_loop :midi_pads do
  use_real_time
  pad = sync "/midi/arturia_minilab_mkii_midi_1/1/10/control_change"

  puts "Pad Number: #{pad[0]} / Pad Status: #{pad[1]}"

  # Get track number to play
  if pad[0] == 9 and pad[1] == 127
    set :track1, true
  elsif pad[0] == 9 and pad[1] == 0
    set :track1, false
  end
  if pad[0] == 3 and pad[1] == 127
    set :track2, true
  elsif pad[0] == 3 and pad[1] == 0
    set :track2, false
  end
  if pad[0] == 38 and pad[1] == 127
    set :track3, true
  elsif pad[0] == 38 and pad[1] == 0
    set :track3, false
  end
  if pad[0] == 39 and pad[1] == 127
    set :track4, true
  elsif pad[0] == 39 and pad[1] == 0
    set :track4, false
  end

  # Get pad number and set tracks to be armed for recording
  if pad[0] == 40 and pad[1] == 127
    set :track1_armed, true
    set :track_len, get(:track1_len)
  elsif pad[0] == 40 and pad[1] == 0
    set :track1_armed, false
  end
  if pad[0] == 41 and pad[1] == 127
    set :track2_armed, true
    set :track_len, get(:track2_len)
  elsif pad[0] == 41 and pad[1] == 0
    set :track1_armed, false
  end
  if pad[0] == 42 and pad[1] == 127
    set :track3_armed, true
    set :track_len, get(:track3_len)
  elsif pad[0] == 42 and pad[1] == 0
    set :track3_armed, false
  end
  if pad[0] == 43 and pad[1] == 127
    set :track4_armed, true
    set :track_len, get(:track4_len)
  elsif pad[0] == 43 and pad[1] == 0
    set :track4_armed, false
  end
end

live_loop :midi_knobs do
  use_real_time
  knob = sync "/midi/arturia_minilab_mkii_midi_1/1/1/control_change"

  # Metronome VOLUME
  if knob[0] == 114
    set :metro_vol, scale_vol(knob[1])
    control get(:metronome), amp: get(:metro_vol) * get(:metro_master)
    puts "Knob 114 (Metronome): #{get(:metro_vol) * get(:metro_master)}"
  end

  # track VOLUME
  if knob[0] == 112
    set :track1_vol, scale_vol(knob[1])
    control get(:t1), amp: get(:track1_vol)
    puts "Knob 1: #{get(:track1_vol)}"
  end
  if knob[0] == 74
    set :track2_vol, scale_vol(knob[1])
    control get(:t2), amp: get(:track2_vol)
    puts "Knob 2: #{get(:track2_vol)}"
  end
  if knob[0] == 71
    set :track3_vol, scale_vol(knob[1])
    control get(:t3), amp: get(:track3_vol)
    puts "Knob 3: #{get(:track3_vol)}"
  end
  if knob[0] == 76
    set :track4_vol, scale_vol(knob[1])
    control get(:t4), amp: get(:track4_vol)
    puts "Knob 4: #{get(:track4_vol)}"
  end

  # Track HPF
  if knob[0] == 77
    set :track1_hpf, scale_ctf(knob[1])
    control get(:t1), hpf: get(:track1_hpf)
    puts "Knob 5: #{get(:track1_hpf)}"
  end
  if knob[0] == 93
    set :track2_hpf, scale_ctf(knob[1])
    control get(:t2), hpf: get(:track2_hpf)
    puts "Knob 6: #{get(:track2_hpf)}"
  end
  if knob[0] == 73
    set :track3_hpf, scale_ctf(knob[1])
    control get(:t3), hpf: get(:track3_hpf)
    puts "Knob 7: #{get(:track3_hpf)}"
  end
  if knob[0] == 75
    set :track4_hpf, scale_ctf(knob[1])
    control get(:t4), hpf: get(:track4_hpf)
    puts "Knob 8: #{get(:track4_hpf)}"
  end

  # Track LPF
  if knob[0] == 17
    set :track1_lpf, scale_ctf(knob[1])
    control get(:t1), lpf: get(:track1_lpf)
    puts "Knob 13: #{get(:track1_lpf)}"
  end
  if knob[0] == 91
    set :track2_lpf, scale_ctf(knob[1])
    control get(:t2), lpf: get(:track2_lpf)
    puts "Knob 14: #{get(:track2_lpf)}"
  end
  if knob[0] == 79
    set :track3_lpf, scale_ctf(knob[1])
    control get(:t3), lpf: get(:track3_lpf)
    puts "Knob 15: #{get(:track3_lpf)}"
  end
  if knob[0] == 72
    set :track4_lpf, scale_ctf(knob[1])
    control get(:t4), lpf: get(:track4_lpf)
    puts "Knob 16: #{get(:track4_lpf)}"
  end

end

# Set up recording tracks
# All tracks can be addressed in a for further manipulation via:
# 'sample "~/.sonic-pi/store/default/cached_samples/track[1..4].wav"' resp.
# Synchronisation of all additional live_loops with: sync: :t1[..4]
t1 = buffer[:track1, get(:track1_len)]
t2 = buffer[:track2, get(:track2_len)]
t3 = buffer[:track3, get(:track3_len)]
t4 = buffer[:track4, get(:track4_len)]

# -----------------------------------------------------------------#
# Metronome                                                        #
# -----------------------------------------------------------------#
#with_fx :sound_out_stereo, output: 15 do
live_loop :beat do
  s = sample :elec_tick, amp: get(:metro_vol) * get(:metro_master)
  set :metronome, s
  sleep 1
end

live_loop :m do
  sync :metro # marks the "1" in case a track is armed
  s = sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 0.75
  set :metronome, s
  sleep get(:track_len)
end
#end


# -----------------------------------------------------------------#
# (Re)Play Tracks                                                  #
# -----------------------------------------------------------------#

# Play tracks
live_loop :t1 do
  on get(:track1_armed) do
    cue :metro
  end
  on get(:track1) do
    #with_fx :sound_out_stereo, output: 3 do
    s = sample t1, amp: get(:track1_vol), hpf: get(:track1_hpf), lpf: get(:track1_lpf)
    set :t1, s
    #end
  end
  sleep get(:track1_len)
end
live_loop :t2 do
  on get(:track2_armed) do
    cue :metro
  end
  on get(:track2) do
    #with_fx :sound_out_stereo, output: 5 do
    s = sample t2, amp: get(:track2_vol), hpf: get(:track2_hpf), lpf: get(:track2_lpf)
    set :t2, s
    #end
  end
  sleep get(:track2_len)
end
live_loop :t3 do
  on get(:track3_armed) do
    cue :metro
  end
  on get(:track3) do
    #with_fx :sound_out_stereo, output: 7 do
    s = sample t3, amp: get(:track3_vol), hpf: get(:track3_hpf), lpf: get(:track3_lpf)
    set :t3, s
    #end
  end
  sleep get(:track3_len)
end
live_loop :t4 do
  on get(:track4_armed) do
    cue :metro
  end
  on get(:track4) do
    #with_fx :sound_out_stereo, output: 9 do
    s = sample t4, amp: get(:track4_vol), hpf: get(:track4_hpf), lpf: get(:track4_lpf)
    set :t4, s
    #end
  end
  sleep get(:track4_len)
end

# -----------------------------------------------------------------#
# Record Tracks                                                    #
# -----------------------------------------------------------------#
# Fixme: set input channel for recording if you want to
# record Sonic Pi output

on get(:track1_armed) do
  live_loop :t1_rec do
    #use_real_time
    sync :metro
    n = get(:track1_len) / 2.0
    sleep n # + 1
    rec_msg(1)
    #with_fx :sound_out_stereo, output: 15 do
    n.times do
      sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 1.5
      sleep 1
    end
    #end
    #sample_free "~/.sonic-pi/store/default/cached_samples/track1.wav"
    with_fx :record, buffer: t1, pre_amp: get(:rec_level) do
      live_audio :audio_in1, stereo: true
    end
    sleep get(:track1_len) - 1
    sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 2.0
    sleep 1
    live_audio :audio_in1, :stop
    set :track1_armed, false
    stop
  end
end

on get(:track2_armed) do
  live_loop :t2_rec do
    #use_real_time
    sync :metro
    n = get(:track2_len) / 2.0
    sleep n # + 1
    rec_msg(2)
    #with_fx :sound_out_stereo, output: 15 do
    n.times do
      sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 1.5
      sleep 1
    end
    #end
    #sample_free "~/.sonic-pi/store/default/cached_samples/track2.wav"
    with_fx :record, buffer: t2, pre_amp: get(:rec_level) do
      live_audio :audio_in2, stereo: true
    end
    sleep get(:track2_len) - 1
    sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 2.0
    sleep 1
    live_audio :audio_in2, :stop
    set :track2_armed, false
    stop
  end
end

on get(:track3_armed) do
  live_loop :t3_rec do
    # use_real_time
    sync :metro
    n = get(:track3_len) / 2.0
    sleep n # + 1
    rec_msg(2)
    #with_fx :sound_out_stereo, output: 15 do
    n.times do
      sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 1.5
      sleep 1
    end
    #end
    #sample_free "~/.sonic-pi/store/default/cached_samples/track3.wav"
    with_fx :record, buffer: t3, pre_amp: get(:rec_level) do
      live_audio :audio_in3, stereo: true
    end
    sleep get(:track3_len) - 1
    sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 2.0
    sleep 1
    live_audio :audio_in3, :stop
    set :track3_armed, false
    stop
  end
end

on get(:track4_armed) do
  live_loop :t4_rec do
    # use_real_time
    sync :metro
    n = get(:track4_len) / 2.0
    sleep n # + 1
    rec_msg(4)
    #with_fx :sound_out_stereo, output: 15 do
    n.times do
      sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 1.5
      sleep 1
    end
    #end
    #sample_free "~/.sonic-pi/store/default/cached_samples/track4.wav"
    with_fx :record, buffer: t4, pre_amp: get(:rec_level) do
      live_audio :audio_in4, stereo: true
    end
    sleep get(:track4_len) - 1
    sample :elec_tick, amp: get(:metro_vol) * get(:metro_master), rate: 2.0
    sleep 1
    live_audio :audio_in4, :stop
    set :track4_armed, false
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

live_loop :midi_pads_fbl do
  use_real_time
  pad = sync "/midi/arturia_minilab_mkii_midi_1/1/10/control_change"

  puts "FB Pad Number: #{pad[0]} / FB Pad Status: #{pad[1]}"

  # Set Feedback Volume
  if pad[0] == 44 and pad[1] == 127
    set :fb_vol, 0.0
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 45 and pad[1] == 127
    set :fb_vol, 0.5
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 46 and pad[1] == 127
    set :fb_vol, 0.75
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 47 and pad[1] == 127
    set :fb_vol, 1.00
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 48 and pad[1] == 127
    set :fb_vol, 1.15
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 49 and pad[1] == 127
    set :fb_vol, 1.26
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 50 and pad[1] == 127
    set :fb_vol, 1.35
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end
  if pad[0] == 51 and pad[1] == 127
    set :fb_vol, 1.45
  elsif pad[0] == 9 and pad[1] == 0
    set :fb_vol, 0
  end

end

live_loop :record_fb do
  with_fx :record, buffer: tfb, pre_amp: get(:fb_vol), pre_mix: 1 do
    sample tfb, amp: 1
    live_audio :audio_fb, stereo: true
  end
  sleep get(:fbtrack_len)
end

# (Re)Play Tracks
live_loop :play_fb do
  sample tfb, amp: 1
  sleep get(:fbtrack_len)
end
