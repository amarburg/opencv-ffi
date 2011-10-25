require 'opencv-ffi-wrappers/features2d/star'
require 'opencv-ffi-wrappers/features2d/image_patch'

module CVFFI
  def self.draw_keypoints( img, pts, opts = {} )
    color = opts[:color] || CVFFI::CvScalar.new( {:w=>255, :x=>255, :y=>255, :z=>0} )
    radius = opts[:radius] || 2
    fill = opts[:fill] || true

    pts.each { |kp|
      CVFFI::cvCircle( img, CVFFI::Point.new( kp ).to_CvPoint,
                      radius, color, (fill ? -1: 1), 8, 0 )
    }
    img
  end
end
