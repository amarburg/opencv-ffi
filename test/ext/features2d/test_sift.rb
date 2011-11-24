
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/sift'

class TestSIFT < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def test_cvSIFTDetect
    kp_ptr = FFI::MemoryPointer.new :pointer
    mem_storage = CVFFI::cvCreateMemStorage( 0 )

    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
                                                         :width => @img.width }), 
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    params = CVFFI::CvSIFTParams.new( nOctaves: 4,
                                      nOctaveLayers: 3,
                                      threshold: 0.04,
                                      edgeThreshold: 10.0,
                                      magnification: 3.0 )
    CVFFI::cvSIFTDetect( greyImg, nil, kp_ptr, mem_storage, params )

    assert_not_nil kp_ptr
    assert_not_nil kp_ptr.read_pointer()

    keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )
    descriptors = CVFFI::CvSeq.new( desc_ptr.read_pointer() )

    puts "SIFT found #{keypoints.total} keypoints"
    #puts "#{descriptors.total} descriptors"

    #(0...keypoints.total).each { |i|
    #  kp = CVFFI::CvSURFPoint.new( CVFFI::cvGetSeqElem( keypoints.to_ptr, i ) )

      # cvCircle takes a CvPoint(int), but the CvSURFPoint contains CvPoint2D32f, need 
      # to manually typecast...
    #  CVFFI::cvCircle( smallGreyImg, CVFFI::CvPoint.new( :x => kp.pt.x.to_i, :y => kp.pt.y.to_i ), 5,
    #                  CVFFI::CvScalar.new( :w=>255, :x=>255, :y=>255, :z=>0 ), -1, 8, 0 )
    #}
    #CVFFI::cvSaveImage( TestSetup::output_filename("greyImagePts.jpg"), smallGreyImg )
  end

end
