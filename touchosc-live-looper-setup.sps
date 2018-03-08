# key: live looper
# point_line: 15
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
#
# IP of mobile device running touchOSC:
set :ip, "192.168.2.150"
# PORT of mobile device running touchOSC:
set :port, 4000

# Set the path where the init and recorder script can be found on your harddisk:
set :libpath, "~/projects/sonicpi/github/sonic-pi-live-looper/"

# You can leave this as it is unless you changed the filenames
set :init, "touchosc-live-looper-init.rb"
set :lib, "touchosc-live-looper-lib.rb"

# Defaults: Adjust to your convenience or leave them untouched for your first try.
set :metro_vol_master, 8 # master volume for audible metronome
set :playback_master, 10 # master volume for loop playback
set :rec_level, 3 # master volume for recording

set :my_bpm, 120 # bmp for your loops

# Initial track length and number of beats for metronome:
# It will count to 4 stressing the first beat.
set :track_len, 4

# Track length for your 4 recordings tracks/loops; you can have an number of beats:
set :track1_len, 4
set :track2_len, 8
set :track3_len, 8
set :track4_len, 2
set :fbtrack_len, 8

# Initialize live looper, see: "touchosc-live-looper-init.rb".
run_file get(:path) + get(:init)
run_file get(:path) + get(:lib)

# Listen to record button and run recorder script, see "touchosc-live-looper-recorder.rb".
live_loop :go do
  use_real_time
  p = sync "/osc/looper/go"
  if p[0] > 0 then
    run_file get(:path) + get(:lib)
  end
end
