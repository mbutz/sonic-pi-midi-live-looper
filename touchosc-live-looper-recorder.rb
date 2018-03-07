# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-recorder.rb
# contact: Martin Butz, mb@mkblog.org

use_osc get(:ip), get(:port)

t1 = buffer[:track1, get(:track1_len)]
t2 = buffer[:track2, get(:track2_len)]
t3 = buffer[:track3, get(:track3_len)]
t4 = buffer[:track4, get(:track4_len)]

# Record track 1
if get(:track1) == 1.0
  in_thread(name: :t1_rec) do
    sync (get(:sync_metro).to_s).to_sym
    osc "/looper/track1_rec", 1
    with_fx :record, buffer: t1, pre_amp: get(:rec_level) do
      live_audio :audio_in1, stereo: true
    end
    sleep get(:track1_len)
    live_audio :audio_in1, :stop
    osc "/looper/track_arm/2/1", 0
    osc "/looper/track1_rec", 0
    set :track1, 0
    cue :t1_rec
  end
end
# Record track 2
if get(:track2) == 1.0
  in_thread(name: :t2_rec) do
    # puts "+++++++++++++++++++++++++++++++++++++++++++++"
    # puts "RECORD T2: #{get(:sync_metro)} <<< <<< <<<"
    # puts "+++++++++++++++++++++++++++++++++++++++++++++"
    sync (get(:sync_metro).to_s).to_sym
    with_fx :record, buffer: t2, pre_amp: get(:rec_level) do
      osc "/looper/track2_rec", 1
      live_audio :audio_in2, stereo: true
    end
    sleep get(:track2_len)
    live_audio :audio_in2, :stop
    osc "/looper/track_arm/2/2", 0
    osc "/looper/track2_rec", 0
    set :track2, 0
    cue :t2_rec
  end
end
# Record track 3
if get(:track3) == 1.0
  in_thread(name: :t3_rec) do
    # puts "+++++++++++++++++++++++++++++++++++++++++++++"
    # puts "RECORD T3: #{get(:sync_metro)} <<< <<< <<<"
    # puts "+++++++++++++++++++++++++++++++++++++++++++++"
    sync (get(:sync_metro).to_s).to_sym
    with_fx :record, buffer: t3, pre_amp: get(:rec_level) do
      osc "/looper/track3_rec", 1
      live_audio :audio_in3, stereo: true
    end
    sleep get(:track3_len)
    live_audio :audio_in3, :stop
    osc "/looper/track_arm/1/1", 0
    osc "/looper/track3_rec", 0
    set :track3, 0
    cue :t3_rec
  end
end
# Record track 4
if get(:track4) == 1.0
  in_thread(name: :t4_rec) do
    # puts "+++++++++++++++++++++++++++++++++++++++++++++"
    # puts "RECORD T4: #{get(:sync_metro)} <<< <<< <<<"
    # puts "+++++++++++++++++++++++++++++++++++++++++++++"
    sync (get(:sync_metro).to_s).to_sym
    with_fx :record, buffer: t4, pre_amp: get(:rec_level) do
      osc "/looper/track4_rec", 1
      live_audio :audio_in4, stereo: true
    end
    sleep get(:track4_len)
    live_audio :audio_in4, :stop
    osc "/looper/track_arm/1/2", 0
    osc "/looper/track4_rec", 0
    set :track4, 0
    cue :t4_rec
  end
end

# (Re)Play Tracks
live_loop :play_t1, sync: :t1_rec do
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  # puts "PLAY BACK T1 <<< <<< <<<"
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  sample t1, amp: get(:track1_vol)
  sleep get(:track1_len)
end
live_loop :play_t2, sync: :t2_rec do
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  # puts "PLAY BACK T2 <<< <<< <<<"
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  sample t2, amp: get(:track2_vol)
  sleep get(:track2_len)
end
live_loop :play_t3, sync: :t3_rec do
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  # puts "PLAY BACK T3 <<< <<< <<<"
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  sample t3, amp: get(:track3_vol)
  sleep get(:track3_len)
end
live_loop :play_t4, sync: :t4_rec do
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  # puts "PLAY BACK T4 <<< <<< <<<"
  # puts "+++++++++++++++++++++++++++++++++++++++++++++"
  sample t4, amp: get(:track4_vol)
  sleep get(:track4_len)
end
