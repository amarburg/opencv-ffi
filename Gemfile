source "http://rubygems.org"

# Specify your gem's dependencies in opencv-ffi.gemspec
gemspec

def my_github( x ); "http://github.com/amarburg/#{x}.git"; end

gem "nice-ffi", :git=>my_github("nice-ffi")

group :development do
  gem "redcarpet"
  gem "simplecov", :require => false
end

group :test do
  gem "rake"
  gem "yard"
end
