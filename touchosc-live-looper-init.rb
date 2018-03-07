# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-init.rb
# contact: Martin Butz, mb@mkblog.org

use_osc get(:ip), get(:port)

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

