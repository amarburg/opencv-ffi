## An omnibus file which brings in all the core/* sub-files

require 'core/library'

module CVFFI

  enum :cvBoolean, [ :false, 0,
                     :true ]

end

require 'core/types'
require 'core/dynamic'
require 'core/draw'
require 'core/operations'
