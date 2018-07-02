# key: arturia
# point_line: 14
# point_index: 0
# --
# Live Looper Library with Arturia Minilab MKii Control
# filename: arturia-live-looper-setup.sps
# contact: Martin Butz, mb@mkblog.org
#
# Setup script for Arturia live looper
#
# Conveniently I load this as a snippet, that's why the filename ends with ".sps".
# Snippets are so far an unsupported feature of Sonic Pi.
# For more information about how to setup and use 'snippets' see:
# https://github.com/samaaron/sonic-pi/issues/587#issuecomment-131945899
#
# If you /do not want to use/ snippets just load this file into
# a Sonic Pi buffer, adjust the following variables and run it once.

# Pads and Knobs
# Pad 1-4: Switch on track 1-4
# Pad 9-12: Arm track 1-4
# Knob 1-4: Volume of track 1-4
# Knob 9: Volume of Metronome
# Knob 5-8: Highpass for track 1-4
# Knob 13-16: Lowpass for track 1-4
# Knob 1/Click: Run script = Start recording

# ALL VOLUMES AND FILTERS ARE INITIALLY SET TO ZERO!!!

# Yoshimi Setup "default.state":
# 1-4: Lead Sounds (Rhodes, SynthPiano, Organ, LeadSynth)
# 5-8: Bells & Vibes
# 9-12: Pads
# 13-16: Bass

# How to refer to the recorded tracks:
#
# cache = "/home/marty/.sonic-pi/store/default/cached_samples"
#
# live_loop :track_i1, sync: :t1 do
#   sample cache, "track1.wav", rate: 2
#   sleep 4
# end


set :my_bpm, 120 # set BPM
set :metro_master, 1 # metro master volume
set :rec_level, 3 # recording volume
set :track_level, 2
set :track_len, 8
set :track1_len, 8 # length of loops
set :track2_len, 8
set :track3_len, 8
set :track4_len, 8
set :fbtrack_len, 8 # length of feedback loops

# Set the path where the init and recorder script can be found on your harddisk:
set :path, "~/projects/sonicpi/playground/code/arturia_live_looper/"

# You can leave this as it is unless you change the filenames
# set :init, "touchosc-live-looper-init.rb"
set :lib, "arturia-live-looper-lib.rb"
set :init, "arturia-live-looper-init.rb"
use_bpm get(:my_bpm)

# -----------------------------------------------------------------#
# Initialization of looper                                         #
# -----------------------------------------------------------------#

# Initialize live looper
run_file get(:path) + get(:init)
run_file get(:path) + get(:lib)

# Listen to 'record button' and execute lib
live_loop :go do
  use_real_time
  p = sync "/midi/arturia_minilab_mkii_midi_1/1/1/control_change"
  if p[0] == 113 and p[1] == 127 then
    run_file get(:path) + get(:lib)
  end
end