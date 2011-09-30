#
# A simple example of opencv-ffi
#
# Opens a file and displays its size.
#
# Usage:    ruby load_image.rb file_name
#

require 'opencv-ffi'
require 'opencv-ffi-wrappers'

if ARGV.length == 0
  puts "Usage: #{__FILE__} image_file_name"
  abort
end

img_name = ARGV[0]
abort "Can't open file \"#{img_name}\"" unless FileTest::readable?( img_name )

img = CVFFI::cvLoadImage( img_name )

puts "Image \"#{img_name}\" is #{img.width} x #{img.height}"



