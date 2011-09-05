
require 'opencv-ffi/core/types'

module CVFFI
  module SizeFunctions
    def x; self.width; end
    def y; self.height; end

    def x=(a); self.width=a; end
    def y=(a); self.height=a; end
  end

  class CvSizeBase
    include SizeFunctions
  end

end
