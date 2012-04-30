
require 'opencv-ffi/core/dynamic'

module CVFFI

  class Sequence
    include Enumerable

    attr_accessor :seq

    def initialize( seq )
      raise "Don't know how to handle class #{seq.class}" unless seq.is_a?(CvSeq)
      @seq = seq
    end

    def each
      size.times { |i|
        yield CVFFI::cvGetSeqElem( @seq, i )
      }
    end

    def push( a )
      CVFFI::cvSeqPush( @seq, a )
    end

    def size
      @seq.total
    end
    alias :length :size

    def [](i)
      CVFFI::cvGetSeqElem( @seq, i )
    end
    alias :at :[]

  end

  class SequenceArray
    include Enumerable

    attr_reader :seq, :pool

    def initialize( seq, pool, wrapper_klass = nil )
      @seq = Sequence.new(seq)
      @pool = pool

      @cache = Array.new( @seq.length )

      @wrap = wrapper_klass

      destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer 
        poolPtr.putPointer( 0, @pool ) 
        cvReleaseMemStorage( poolPtr ) }
        ObjectSpace.define_finalizer( self, destructor )
    end

    def reset( seq )
      @seq = Sequence.new(seq)
      @pool = kp.storage
      @cache = Array.new( @seq.length )
      self
    end

    def at(i)
      @cache[i] ||= @wrap ? @wrap.new( @seq[i] ) : @seq[i]
    end

    def each
      @cache.each_index { |i| 
        yield at(i) 
      }
    end

    def [](i)
      at(i)
    end

    def size
      @seq.size
    end
    alias :length :size

    def to_CvSeq
      @seq.seq
    end

    def to_a
      Array.new( size ) { |i| at(i).to_a }
    end

    # Well, this is awkward, isn't it?
    # TODO:  Does it have to be this way?
    def self.from_a( a, wrapper_klass )
        a = YAML::load(a) if a.is_a? String
        raise "Don't know what to do" unless a.is_a? Array

        pool = CVFFI::cvCreateMemStorage(0)
        cvseq = wrapper_klass.create_cvseq( pool )
        seq = Sequence.new cvseq

        a.each { |this_row| 
          seq.push( wrapper_klass.from_a( this_row ) )
        }

        ra = ResultArray.new( cvseq, pool )

    end
  end

end

