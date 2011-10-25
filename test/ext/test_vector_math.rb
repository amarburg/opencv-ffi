
require 'test/setup'
require 'opencv-ffi-ext/vector_math'
require 'opencv-ffi-wrappers/enumerable'
require 'benchmark'

class TestVectorMath < Test::Unit::TestCase

  def setup
    @zero_vector = CVFFI::Float64.new( "\0" )
    @random_vector_one = CVFFI::Float64.new( "\0" )
    @random_vector_two = CVFFI::Float64.new( "\0" )

    CVFFI::Float64::nElem.times { |i|
      @zero_vector.d[i] = 0.0
      @random_vector_one.d[i] = rand
      @random_vector_two.d[i] = rand
    }
  end


  def test_L2distance
    
    Benchmark.bm(10) do |x|
      x.report("Zero vector") {
        assert_equal 0.0, CVFFI::VectorMath::L2distance( @zero_vector, @zero_vector )
      }

      l2dist = 0.0
      x.report("64-entry by hand") {
        l2dist = @random_vector_one.inject_with_index(0.0) { |x, f, i|
          x + (f - @random_vector_two.d[i])**2
        }
      }

      x.report("Random vectors") { 
        assert_in_delta l2dist, CVFFI::VectorMath::L2distance( @random_vector_one, @random_vector_two ), 1e-3
      }

    end

  end

  def test_L2distance_8u
    Benchmark.bm(10) do |x|
      a = Array.new( 1000 ) { |i| rand(256) }
      b = Array.new( 1000 ) { |i| rand(256) }

      l2dist = 0.0
      x.report("1000-entry uint8 in pure ruby") {
        l2dist = a.inject_with_index(0.0) { |x,f,i| 
        x + (f-b[i])**2
      }
      }

      x.report("With libcv-ffi") {
        assert_in_delta l2dist, CVFFI::VectorMath::L2distance_8u( a, b )
      }
      
    end
  end

end
