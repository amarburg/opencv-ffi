
require 'test/setup'
require 'opencv-ffi-wrappers/core'


class TestIplImageWrapper < Test::Unit::TestCase


  def setup
  end

  def test_cast_to_mat
   img = TestSetup::test_image

   assert img.is_a? CVFFI::IplImage

   mat = img.to_Mat
   assert mat.is_a? CVFFI::Mat
   assert img.width == mat.width
   assert img.height == mat.height

   cvmat = img.to_CvMat
   assert cvmat.is_a? CVFFI::CvMat
   assert img.width == cvmat.width
   assert img.height == cvmat.height
  end




end
