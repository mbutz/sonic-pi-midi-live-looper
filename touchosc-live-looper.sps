# Script to be loaded run in Sonic Pi
# filename: touchosc-live-looper.sps
# contact: Martin Butz, mb@mkblog.org
#
# Conveniently I load this as a snippet (unsupported feature):
# for more information about 'snippets' see:
# https://groups.google.com/forum/#!topic/sonic-pi/LP6qYmj1tRM
#
# If you do not want to use snippets just load this file into
# a Sonic Pi buffer, adjust the following variables and run it once.
#
#
# Please configure connections between Sonic Pi and touchosc:
#
# IP of mobile device running touchOSC:
set :ip, "192.168.2.150"
# PORT of mobile device running touchOSC:
set :port, 4000

# Set the path where the library script can be found on your harddisk:
set :libpath, "~/projects/sonicpi/github/sonic-pi-live-looper/touchosc-live-looper-lib.rb"
#set :libpath, "~/projects/sonicpi/github/sonic-pi-live-looper/touchosc-live-looper-lib-one-track.rb"

# Defaults: Adjust to your convenience:
set :metro_vol_master, 4
set :my_bpm, 120
set :playback_master, 10
set :rec_level, 3
set :track1_len, 4
set :track2_len, 8
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