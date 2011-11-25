
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/sift'

class TestSIFT < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
    @kp_ptr = FFI::MemoryPointer.new :pointer
    @mem_storage = CVFFI::cvCreateMemStorage( 0 )

    @greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
                                                         :width => @img.width }), 
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( @img, @greyImg, :CV_RGB2GRAY )

    @params = CVFFI::CvSIFTParams.new( nOctaves: 4,
                                      nOctaveLayers: 3,
                                      threshold: 0.04,
                                      edgeThreshold: 10.0,
                                      magnification: 3.0 )
   end

  def test_cvSIFTDetect
   CVFFI::cvSIFTDetect( @greyImg, nil, @kp_ptr, @mem_storage, @params )

    assert_not_nil @kp_ptr
    assert_not_nil @kp_ptr.read_pointer()

    keypoints = CVFFI::CvSeq.new( @kp_ptr.read_pointer() )

    puts "SIFT detect only found #{keypoints.total} keypoints"
  end

  def test_cvSIFTDetectDescribe

    desc = CVFFI::CvMat.new CVFFI::cvCreateMat( 1,1, :CV_32F )
    CVFFI::cvSIFTDetectDescribe( @greyImg, nil, @kp_ptr, desc, @mem_storage, @params )

    assert_not_nil @kp_ptr
    assert_not_nil @kp_ptr.read_pointer()

    keypoints = CVFFI::CvSeq.new( @kp_ptr.read_pointer() )

    assert_equal keypoints.total, desc.height

    puts "SIFT detect and describe found #{keypoints.total} keypoints"
  end


  # Tests the "wrapper" version
  def test_SIFTDetect
    params = CVFFI::SIFT::Params.new
    kps = CVFFI::SIFT::detect( @greyImg, params )

    assert_not_nil kps

    puts "The SIFT wrapper found #{kps.size} keypoints"

    puts "here's the first keypoint:"
    p kps[0]

  end

end
