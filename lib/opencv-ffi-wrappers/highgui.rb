

require 'opencv-ffi/highgui'

module CVFFI

  def self.save_image( fname, img )
    CVFFI::cvSaveImage( fname, img.to_IplImage )
  end
end
