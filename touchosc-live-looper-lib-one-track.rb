# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-lib.rb
# contact: Martin Butz, mb@mkblog.org

use_osc get(:ip), get(:port)

use_bpm get(:my_bpm)

t1 = buffer[:track1, get(:track1_len)]

# t2 = buffer[:track2, get(:track2_len)]
# t3 = buffer[:track3, get(:track3_len)]
# t4 = buffer[:track4, get(:track4_len)]
# tfb = buffer[:tfb, 8]

# Get/set track to be armed
live_loop :t1 do
  use_real_time
  c = sync "/osc/looper/track_arm/2/1"
  set :track1, c[0]
  set :track_len, get(:track1_len)
  # set current metronom identifier
  set :sync_metro, ("metro" + get(:track_len).to_s).to_sym
  puts "ARM 1 metro: #{get(:sync_metro)} ---"
end

# Get/set metronom volume
live_loop :m_vol do
  use_real_time
  c = sync "/osc/looper/metro_vol"
  set :metro_vol, c[0]
end
# Start/stop metronom
live_loop :m do
  use_real_time
  c = sync "/osc/looper/metro"
  set :metro_toggle, c[0]
end

# beat marker
live_loop :beat do
  sleep 1
end
# set up metronom and mark 1 according to track length currently armed
live_loop :metro, sync: :beat do
  # metronom marks one with deeper click
  f = get(:track_len) - 1
  sample :elec_tick, amp: (get(:metro_vol) * get(:metro_vol_master)) * 2, rate: 1.0 if get(:metro_toggle) == 1
  sleep 1
  f.times do
    sample :elec_tick, amp: get(:metro_vol) * get(:metro_vol_master), rate: 1.25 if get(:metro_toggle) == 1
    sleep 1
  end
end

live_loop get(:sync_metro), sync: :metro do
  sleep get(:track_len)
  stop # run once and then quit
end

# Get/set playback volume
live_loop :t1_vol do
  use_real_time
  c = sync "/osc/looper/track1_vol"
  set :track1_vol, c[0]
end

# Record track 1
if get(:track1) == 1.0
  in_thread sync: get(:sync_metro) do
    puts "RECORD T1: #{get(:sync_metro)} ---"
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

# (Re)Play Tracks
live_loop :play_t1, sync: get(:sync_metro) do
  sample t1, amp: get(:track1_vol)
  sleep get(:track1_len)
end
