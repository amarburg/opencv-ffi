require 'opencv-ffi/core/types'

module CVFFI

  def self.print_matrix(m, opts={})

    puts opts[:caption] if opts[:caption]

    # Lots of potential to make this better...
    f = '%'
    case opts[:format]
    when :e, :exp, :exponential 
      f += '- 10.5e'
    else
      f += '- 10.5f'
    end

    nChannels = CVFFI::matChannels(m)
    #  puts "#{nChannels} channel data"

    m.height.times { |i|
      m.width.times {|j|
        scalar = CVFFI::cvGet2D( m, i, j )
        case nChannels
        when 1
          printf "#{f}  ", scalar.w
        when 2
          printf "[#{f} #{f}] ", scalar.w, scalar.x
        when 3
          printf "[#{f} #{f} #{f}] ", scalar.w, scalar.x, scalar.y
        when 4
          printf "[#{f} #{f} #{f} #{f}] ", scalar.w, scalar.x, scalar.y, scalar.z
        end
      }
      puts
    }

  end

end
