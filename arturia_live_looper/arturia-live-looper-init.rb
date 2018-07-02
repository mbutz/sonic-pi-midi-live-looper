# Live Looper Library for Arturia MKII - Initiallisation
# filename: arturia-live-looper-init.rb
# contact: Martin Butz, mb@mkblog.org

# Set volume to 1
puts "INIT: Setting all VOLUMES to default volume."
set :metro_vol, 1
set :track1_vol, 1
set :track2_vol, 1
set :track3_vol, 1
set :track4_vol, 1

# Open HPF to 130
puts "INIT: Setting HPFs to 1."
set :track1_hpf, 0
set :track2_hpf, 0
set :track3_hpf, 0
set :track4_hpf, 0

# Open LPF to 0
puts "INIT: Setting LPFs to 0."
set :track1_lpf, 0
set :track2_lpf, 0
set :track3_lpf, 0
set :track4_lpf, 0

# Disarm all tracks
puts "INIT: Disarm all tracks for recording."
set :track1_armed, false
set :track2_armed, false
set :track3_armed, false
set :track4_armed, false

# Set all tracks to be quiet
puts "INIT: Mute all tracks."
set :track1, false
set :track2, false
set :track3, false
set :track4, false

# Feedback Volume
puts "INIT: Mute feedback loop."
set :fb_vol, 0
