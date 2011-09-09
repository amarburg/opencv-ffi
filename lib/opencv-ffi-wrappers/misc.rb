require 'opencv-ffi/core/types'

module CVFFI

  def self.print_matrix(m, opts={})

    puts opts[:caption] if opts[:caption]
    nChannels = CVFFI::matChannels(m)
    #  puts "#{nChannels} channel data"

    m.height.times { |i|
      m.width.times {|j|
        scalar = CVFFI::cvGet2D( m, i, j )
        case nChannels
        when 1
          printf "%- 10.5f  ", scalar.w
        when 2
          printf "[%- 10.5f %- 10.5f] ", scalar.w, scalar.x
        when 3
          printf "[%- 10.5f %- 10.5f %- 10.5f] ", scalar.w, scalar.x, scalar.y
        when 4
          printf "[%- 10.5f %- 10.5f %- 10.5f %- 10.5f] ", scalar.w, scalar.x, scalar.y, scalar.z
        end
      }
      puts
    }

  end

end
