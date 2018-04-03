# key: live looper
# point_line: 19
# point_index: 9
# --
# Live Looper Library with TouchOSC Control
# filename: touchosc-live-looper-setup.sps
# contact: Martin Butz, mb@mkblog.org
#
# Setup script for touchOSC live looper
#
# Conveniently I load this as a snippet, that's why the filename ends with ".sps".
# Snippets are so far an unsupported feature of Sonic Pi.
# For more information about how to setup and use 'snippets' see:
# https://github.com/samaaron/sonic-pi/issues/587#issuecomment-131945899
#
# If you /do not want to use/ snippets just load this file into
# a Sonic Pi buffer, adjust the following variables and run it once.

# -----------------------------------------------------------------#
# Adjust/check these settings                                      #
# -----------------------------------------------------------------#

# IP of mobile device running touchOSC:
set :ip, "192.168.2.150"

# PORT of mobile device running touchOSC:
set :port, 4000

use_osc get(:ip), get(:port)

# Set the path where the init and recorder script can be found on your harddisk:
set :path, "~/projects/sonicpi/github/sonic-pi-live-looper/"

# You can leave this as it is unless you change the filenames
set :init, "touchosc-live-looper-init.rb"
set :lib, "touchosc-live-looper-lib.rb"

# -----------------------------------------------------------------#
# Adjust to your convenience or leave as they are                  #
# -----------------------------------------------------------------#

# Note: If you change values here you might have to adjust the touchosc
# interface in the next section to reflect you initialisation of values.

set :my_bpm, 120 # set BPM

set :playback_master, 10 # playback volume
set :rec_level, 3 # recording volume

set :metro_toggle, 1 # initially start metronome and ...
set :metro_vol, 1 # ... set max. volume
set :metro_vol_master, 4 # master metronome volume

# Track length for your 4 recordings tracks/loops; you can have any number of beats:
set :track1_len, 8 # length of loop 1
set :track2_len, 4 # length of loop 2
set :track3_len, 4 # length of loop 3
set :track4_len, 8 # length of loop 4
set :fbtrack_len, 8 # length of feedback loops

# -----------------------------------------------------------------#
# Initialization of looper and touchosc interface                  #
# -----------------------------------------------------------------#

# Initialize live looper, see: "touchosc-live-looper-init.rb".
run_file get(:path) + get(:init)
run_file get(:path) + get(:lib)

# Switch on metronome by default.
osc "/looper/metro_vol", 1
osc "/looper/metro", 1

# Listen to 'record button' and execute lib
live_loop :go do
  use_real_time
  p = sync "/osc/looper/go"
  if p[0] > 0 then
    run_file get(:path) + get(:lib)
  end
end
