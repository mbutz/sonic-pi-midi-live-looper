# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-init.rb
# contact: Martin Butz, mb@mkblog.org
#
# Initialization of looper and touchosc interface
# You shouldn't need to touch this except maybe
# the metronome: this will initially be switched on
# and set to maximum volume; see end of file if you
# want that to be changed
use_osc get(:ip), get(:port)

# Initially switch off feedback loop by default.
set :fb_vol, 0
osc "/looper/feedback_vol/1/1", 1

# Get track length config
osc "/looper/track1_len", get(:track1_len)
osc "/looper/track2_len", get(:track2_len)
osc "/looper/track3_len", get(:track3_len)
osc "/looper/track4_len", get(:track4_len)

# Set track volume to 0
set :track1_vol, 0
set :track2_vol, 0
set :track3_vol, 0
set :track4_vol, 0
osc "/looper/track1_vol", 0
osc "/looper/track2_vol", 0
osc "/looper/track3_vol", 0
osc "/looper/track4_vol", 0

# Show all tracks disarmed for recording
set :track1, 0
set :track2, 0
set :track3, 0
set :track4, 0
osc "/looper/track_arm/2/1", 0
osc "/looper/track_arm/2/2", 0
osc "/looper/track_arm/1/1", 0
osc "/looper/track_arm/1/2", 0

# Reset all recording LEDs
osc "/looper/track1_rec", 0
osc "/looper/track2_rec", 0
osc "/looper/track3_rec", 0
osc "/looper/track4_rec", 0

# Set track length
set :track_len, get(:track1_len)
