

require 'test/setup'

require 'opencv-ffi'

class TestSURF < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def test_cvExtractSURF
    kp_ptr = FFI::MemoryPointer.new :pointer
    desc_ptr = FFI::MemoryPointer.new :pointer

    mem_storage = CVFFI::cvCreateMemStorage( 0 )

    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
                                                         :width => @img.width }), 
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    smallGreyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => greyImg.height/2,
                                                              :width => greyImg.width/2 } ),
                                    :IPL_DEPTH_8U, 1 )

    CVFFI::cvResize( greyImg, smallGreyImg, :CV_INTER_LINEAR )

    #CVFFI::cvSaveImage( TestSetup::output_filename("greyImage.jpg"), smallGreyImg.to_ptr )

    params = CVFFI::CvSURFParams.new( :hessianThreshold => 500.0,
                                      :upright => 0,
                                      :extended => 0,
                                      :nOctaves => 3,
                                      :nOctaveLayers => 4 )
    CVFFI::cvExtractSURF( smallGreyImg, nil, kp_ptr, desc_ptr, mem_storage, params, :false )

    assert_not_nil kp_ptr
    assert_not_nil kp_ptr.read_pointer()

    assert_not_nil desc_ptr
    assert_not_nil desc_ptr.read_pointer()

    keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )
    descriptors = CVFFI::CvSeq.new( desc_ptr.read_pointer() )

    puts "#{keypoints.total} keypoints"
    puts "#{descriptors.total} descriptors"

    (0...keypoints.total).each { |i|
      kp = CVFFI::CvSURFPoint.new( CVFFI::cvGetSeqElem( keypoints.to_ptr, i ) )

      # cvCircle takes a CvPoint(int), but the CvSURFPoint contains CvPoint2D32f, need 
      # to manually typecast...
      CVFFI::cvCircle( smallGreyImg, CVFFI::CvPoint.new( :x => kp.pt.x.to_i, :y => kp.pt.y.to_i ), 5,
                      CVFFI::CvScalar.new( :w=>255, :x=>255, :y=>255, :z=>0 ), -1, 8, 0 )
    }
    CVFFI::cvSaveImage( TestSetup::output_filename("greyImagePts.jpg"), smallGreyImg )
  end

end
