
require 'test/unit'
require 'pp'


module TestSetup

  def self.output_filename( s )
    "test/test_files/images/" + s
  end

  EPSILON = 1e-3


end

TEST_IMAGE_FILE = "test/test_files/images/IMG_7089.JPG"
TEST_IMAGE_OUTPUT = TestSetup.output_filename( "output.jpg" )
