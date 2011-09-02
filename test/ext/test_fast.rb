
require 'test/setup'
require 'opencv-ffi-ext/fast'
require 'opencv-ffi'

class TestSURF < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def test_cvFASTDetector
    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
                                                         :width => @img.width }), 
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    smallGreyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => greyImg.height/2,
                                                              :width => greyImg.width/2 } ),
                                    :IPL_DEPTH_8U, 1 )

    CVFFI::cvResize( greyImg, smallGreyImg, :CV_INTER_LINEAR )

    #CVFFI::cvSaveImage( TestSetup::output_filename("greyImage.jpg"), smallGreyImg.to_ptr )
    
    nResults = FFI::MemoryPointer.new :int

results = FFI::Pointer.new :pointer, CVFFI::FAST::fast12_detect( smallGreyImg.imageData, smallGreyImg.width, smallGreyImg.height, smallGreyImg.widthStep, 50, nResults )

    # Dereference the two pointers
    nPoints = nResults.read_int
    points = FFI::Pointer.new CVFFI::FAST::Xy, results

    #p points.inspect
    #p nPoints.inspect

    0.upto(nPoints-1) { |i|
      pt = CVFFI::FAST::Xy.new( points[i] )

      CVFFI::cvCircle( smallGreyImg, CVFFI::CvPoint.new( :x => pt.x.to_i, :y => pt.y.to_i ), 5,
                      CVFFI::CvScalar.new( :w=>255, :x=>255, :y=>255, :z=>0 ), -1, 8, 0 )
    }
    CVFFI::cvSaveImage( TestSetup::output_filename("greyImageFASTPts.jpg"), smallGreyImg )


    results.free
 end

end
