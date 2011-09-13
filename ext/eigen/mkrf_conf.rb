require 'mkrf'

Mkrf::Generator.new('libeigentocv', [ "*.cpp" ]) { |g|
  g.ldshared = "-lstdc++ -lopencv_core"
}
