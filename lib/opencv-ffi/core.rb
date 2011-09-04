## An omnibus file which brings in all the core/* sub-files

require 'opencv-ffi/core/library'

module CVFFI

  enum :cvBoolean, [ :false, 0,
                     :true ]

end

require 'opencv-ffi/core/types'
require 'opencv-ffi/core/dynamic'
require 'opencv-ffi/core/draw'
require 'opencv-ffi/core/operations'
