
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

    def clear
      CVFFI::cvClearSeq( @seq )
    end

    def remove(i)
      CVFFI::cvSeqRemove( @seq, i )
    end

  end

  class SequenceArray
    include Enumerable

    def self.sequence_class( klass )
      class_eval %(
        @wrapped_klass = klass
        class << self; attr_reader :wrapped_klass; end
      )
    end

    def sequence_class; @wrap; end

    attr_reader :seq, :pool

    def initialize( seq, pool, wrapper_klass = nil )
      @seq = Sequence.new(seq)
      @pool = pool

      @cache = Array.new( @seq.length )

      @wrap = wrapper_klass || self.class.wrapped_klass

      destructor = Proc.new { 
        releaseMemStorage( @pool )
      }
      ObjectSpace.define_finalizer( self, destructor )
    end

    def reset( seq = nil, pool  = @pool)
      if seq
        @seq = Sequence.new(seq)
        @pool = pool
      end
      @cache = Array.new( @seq.length )
      self
    end

    def wrap(i)
      @wrap ? @wrap.new( @seq[i] ) : @seq[i]
    end

    def at(i)
      @cache[i] ||= wrap(i)
    end

    def each
      @cache.each_index { |i| 
        yield at(i) 
      }
    end

    # Might be more efficient way to do this, but 
    # will gather all the keeps at once
    # and then drop them from the seq ... then
    # reset the cache
    def keep_if( &blk )
      del = []
      length.times { |i|
        del << i unless blk.call at(i)
      }
      # Do it in reverse order so earlier removals don't muck
      # with the indices
      del.reverse.each { |idx| @seq.remove( idx ) }
      reset
    end

    def delete_if( &blk )
      del = []
      length.times { |i|
        del << i if blk.call at(i)
      }
      del.reverse.each { |idx| @seq.remove( idx ) }
      reset
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

    def to_yaml
      to_a.to_yaml
    end

    def to_a
      Array.new( size ) { |i| at(i).to_a }
    end

    def random( i = 1, rng = Random::DEFAULT )
      case i
      when 1
        at( rand( length ) )
      else
        indices = Array.new( i ) { |i| rng.rand( length ) }.uniq
        while indices.length < i do
          indices += Array.new( 10 )  { |i| rng.rand(length) }
          indices.uniq!
        end

        indices.first( i ).map { |i| at(i) }
      end
    end

    # Well, this is awkward, isn't it?
    # TODO:  Does it have to be this way?
    def self.from_a( a, wrapper_klass = nil )
      klass = wrapper_klass || wrapped_klass
      a = YAML::load(a) if a.is_a? String
      raise "SequenceArray::from_a.  Don't know what to do with #{a}" unless a.is_a? Array

      pool = CVFFI::cvCreateMemStorage(0)
      cvseq = CVFFI::cvCreateSeq( 0, CvSeq.size, klass.size, pool )
      seq = Sequence.new cvseq

      a.each { |this_row| 
        seq.push( klass.from_a( this_row ) )
      }

      SequenceArray.new( cvseq, pool, klass )
    end

  end

end

