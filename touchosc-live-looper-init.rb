# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-init.rb
# contact: Martin Butz, mb@mkblog.org

use_osc get(:ip), get(:port)

# Initialization of looper and touchosc interface
# You shouldn't need to touch this except maybe
# the metronome: this will initially be switched on
# and set to maximum volume; see end of file if you
# want that to be changed
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

set :track1_vol, 0
set :track2_vol, 0
set :track3_vol, 0
set :track4_vol, 0

# FIXME: Check if this can be placed here and be removed from lib...
# Initial setting of sync metronome live_loop name.
set :sync_metro, ("metro" + get(:track_len).to_s).to_sym


