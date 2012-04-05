# This must be the first require called, otherwise the
# results will be inaccurate
require 'simplecov'
SimpleCov.start

require 'test/unit'
require 'pp'

require 'opencv-ffi/highgui'
require 'opencv-ffi/imgproc'


TEST_IMAGE_FILE = "test/test_files/images/IMG_7089.JPG"
SMALL_TEST_IMAGE_FILE = "test/test_files/images/IMG_7088_small.JPG"
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
  
  @dirname = "/tmp/opencv-ffi-test"

  def self.test_image
    CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def self.small_test_image
    CVFFI::cvLoadImage( SMALL_TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def self.grey_test_image
    img = test_image
    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => img.height, 
                                                      :width => img.width }), 
                                                      :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( img, greyImg, :CV_BGR2GRAY )
    greyImg
  end

  def self.second_test_image
    CVFFI::cvLoadImage( TEST_IMAGE_FILE_TWO, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def self.save_image( fname, img )
    fname += ".jpg" unless fname.match('\.')
    CVFFI::cvSaveImage( output_filename(fname), img )
  end

  def self.output_filename( s )
    FileUtils.mkdir_p @dirname unless FileTest::directory? @dirname    
    @dirname + '/' + s
  end

  EPSILON = 1e-3

end

