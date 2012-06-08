
require 'opencv-ffi/features2d'
require 'opencv-ffi-wrappers'
#require 'opencv-ffi-ext/vector_math'
require 'base64'

module CVFFI

  ## Monkey type some new functions into the point
  class CvSURFPoint
    def x; pt.x; end
    def y; pt.y; end

    def distance_to( q )
      #  Here's the pure-Ruby way to do it
      #  @desc.inject_with_index(0.0) { |x,d,i| x + (d-q.desc.d[i])**2  }

      #  CVFFI::VectorMath::L2distance( @desc, q.desc )
      0.0
    end

    def to_vector
      Vector.[]( x, y, 1 )
    end

    def to_Point
      pt.to_Point
    end

    def self.keys
      [ :x, :y, :laplacian, :size, :dir, :hessian ]
    end
    def keys; self.class.keys; end

    def to_a
      [ pt.x, pt.y, laplacian, size, dir, hessian, 
        descriptor.desc_length,
        Base64.encode64(descriptor.desc.to_a.pack( "g#{descriptor.desc_length}" )) ]
    end

    # TODO:  Doesn't unserialize the descriptor at present....
    def self.from_a( a )
      kp = CvSURFPoint.new
      kp.pt.x = a.shift
      kp.pt.y = a.shift
      kp.laplacian = a.shift
      kp.size = a.shift
      kp.dir = a.shift
      kp.hessian = a.shift
      kp
    end

    def ==(b)
      keys.inject(true) { |m,key|
        m and ( (send key) == (b.send key) )
      }
    end

    def descriptor=( d ); @descriptor = d; end
    def descriptor; @descriptor || nil; end

  end


  module SURF

    class SURF64Descriptor < NiceFFI::Struct
      layout :desc, [ :float, 64 ]
      attr_accessor :desc_length
    end

    class SURF128Descriptor < NiceFFI::Struct
      layout :desc, [ :float, 128 ]
      attr_accessor :desc_length
    end

      class Params < CVFFI::Params
        param :extended, 1
        param :upright, 1
        param :hessianThreshold, 300.0
        param :nOctaves, 3
        param :nOctaveLayers, 4

        def to_CvSURFParams
          CvSURFParams.new( @params  )
        end
      end

      class DescriptorSequence < SequenceArray
        # Shares a pool with the Results, assume it will take care
        # of pool destruction
        attr_accessor :desc_length

        def initialize( seq, length )
          @desc_length = length
          super( seq, nil, descriptor_type )
        end

        def wrap(i)
          a = super(i)
          a.desc_length = desc_length
          a
        end

        def descriptor_type
          case desc_length
          when 64
            SURF64Descriptor
          when 128
            SURF128Descriptor
          else
            raise "Hm, don't know how to handle a SURF descriptor of length #{desc_length}."
          end
        end

      end

      class Results < SequenceArray

        attr_accessor :descriptors
        attr_accessor :desc_length

        def initialize( seq, descriptors, desc_length, pool )
          super( seq, pool, CVFFI::CvSURFPoint )
          @descriptors = DescriptorSequence.new( descriptors, desc_length )
        end

        def wrap(i)
          a = super(i)
          a.descriptor = descriptors.at(i)
          a
        end

        def self.from_a( a )
          SequenceArray.from_a( a, CVFFI::CvSURFPoint )
        end
      end

    def self.detect( img, params )
        params = params.to_CvSURFParams unless params.is_a?( CvSURFParams )

      img = CVFFI::IplImage.new img.to_IplImage.ensure_greyscale

      kp_ptr = FFI::MemoryPointer.new :pointer
      desc_ptr = FFI::MemoryPointer.new :pointer

      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      CVFFI::cvExtractSURF( img, nil, kp_ptr, desc_ptr, mem_storage, params, :false )

      keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )
      descriptors = CVFFI::CvSeq.new( desc_ptr.read_pointer() )

      descriptor_length = params.extended ? 128 : 64
      Results.new( keypoints, descriptors, descriptor_length, mem_storage )
    end
  end
end
