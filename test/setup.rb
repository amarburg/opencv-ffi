
require 'test/unit'
require 'pp'

require 'opencv-ffi/highgui'


TEST_IMAGE_FILE = "test/test_files/images/IMG_7089.JPG"
TEST_IMAGE_FILE_TWO = "test/test_files/images/IMG_7088.JPG"

def recursive_test name
  dirname = [ 'test', name] .join('/')
  if File.directory? dirname
    Find.find( dirname ) { |f|
      require f if File.basename(f).match( "^test_[\w]*" )
    }
  end
end



module TestSetup

  def self.load_test_image
    CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def self.load_second_test_image
    CVFFI::cvLoadImage( TEST_IMAGE_FILE_TWO, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def self.output_filename( s )
    "test/test_files/images/" + s
  end

  EPSILON = 1e-3

end

TEST_IMAGE_OUTPUT = TestSetup.output_filename( "output.jpg" )
