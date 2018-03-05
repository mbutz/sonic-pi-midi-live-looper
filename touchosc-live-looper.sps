# path: ~/.sonic-pi/snippets/live_looper_plus_feedback_touchosc.sps
# Please configure connections between Sonic Pi and touchosc:
# In case of using Emacs/sonic-pi.el
set :ip, "192.168.2.150" # IP of mobile device, see touchOSC
set :port, 4000 # port of mobile device, see touchOSC
# where can this script find the library?
set :libpath, "~/projects/sonicpi/playground/code/lib/lib-live-looper-plus-feedback-touchosc.rb"

# Defaults: Adjust to your convenience:
set :metro_vol_master, 1
set :my_bpm, 120
set :playback_master, 10
set :rec_level, 3
set :track1_len, 4
set :track2_len, 4
set :track3_len, 8
set :track4_len, 8
set :fbtrack_len, 8

# Initialization of looper and touchosc interface
use_osc get(:ip), get(:port)
osc "/looper/track1_len", get(:track1_len)
osc "/looper/track2_len", get(:track2_len)
osc "/looper/track3_len", get(:track3_len)
osc "/looper/track4_len", get(:track4_len)

osc "/looper/track1_vol", 0
osc "/looper/track2_vol", 0
osc "/looper/track3_vol", 0
osc "/looper/track4_vol", 0

osc "/looper/metro_vol", 0
osc "/looper/metro", 0

osc "/looper/track_arm/2/1", 0
osc "/looper/track_arm/2/2", 0
osc "/looper/track_arm/1/1", 0
osc "/looper/track_arm/1/2", 0

osc "/looper/feedback_vol/1/1", 1

set :track1_vol, 0
set :track2_vol, 0
set :track3_vol, 0
set :track4_vol, 0
set :fb_vol, 0
set :metro_vol, 0
set :metro_toggle, 0
set :track_len, 8
set :sync_metro, ("metro" + get(:track_len).to_s).to_sym

live_loop :go do
  use_real_time
  p = sync "/osc/looper/go"
  if p[0] > 0 then
    run_file get(:libpath) # live_looper_touchosc
  end
end

