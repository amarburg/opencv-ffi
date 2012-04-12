# This must be the first require called, otherwise the
# results will be inaccurate
require 'simplecov'
SimpleCov.start

require 'test/unit'
require 'pp'

require 'opencv-ffi/highgui'
require 'opencv-ffi/imgproc'


IMG_PATH = "test/test_files/images/"
IMAGES = { test: "IMG_7089.JPG",
           small_test: "IMG_7089_small.jpg",
           tiny_test: "IMG_7089_tiny.jpg",
           second: "IMG_7088.JPG",
           dull: "dull_image.jpg" }

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

  def self.image( key, color = CVFFI::CV_LOAD_IMAGE_COLOR )
    raise "TestSetup doesn't have an image for key \"#{key}\"" unless IMAGES[key]
      filename = IMG_PATH + IMAGES[key]
      CVFFI::cvLoadImage( filename, color )
  end

  def self.image_accessor( name, key = nil )
    key = name unless key
    module_eval "def self.#{name}_image; image( :#{key} ); end"
  end

  image_accessor :dull
  image_accessor :test
  image_accessor :small_test
  image_accessor :tiny_test
  image_accessor :second

  #def self.dull_image; image( :dull ); end;
  #def self.test_image; image( :one ); end;
  #def self.small_test_image; image( :one_small ); end;
  #def self.second_test_image; image( :two ); end;

  def self.grey_test_image
    img = test_image
    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => img.height, 
                                                      :width => img.width }), 
                                                      :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( img, greyImg, :CV_BGR2GRAY )
    greyImg
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

