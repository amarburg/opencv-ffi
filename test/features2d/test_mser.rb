

require 'test/setup'

require 'opencv-ffi'

class TestMSER < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def test_cvExtractMSER
    contour_ptr = FFI::MemoryPointer.new :pointer
    mem_storage = CVFFI::cvCreateMemStorage( 0 )

    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
                                                         :width => @img.width }), 
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    params = CVFFI::CvMSERParams.new( delta: 5,
                                      minArea: 60,
                                      maxArea: 14400,
                                      maxVariation: 0.25,
                                      minDiversity: 0.2,
                                      maxEvolution: 200,
                                      areaThreshold: 1.01,
                                      minMargin: 0.003,
                                      edgeBlurSize: 5 )

    CVFFI::cvExtractMSER( greyImg, nil, contour_ptr, mem_storage, params )

    assert_not_nil contour_ptr
    contours = CVFFI::CvSeq.new( contour_ptr.read_pointer() )

    puts "MSER found #{contours.total} contours"

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
