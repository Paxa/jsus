require 'lib/js_bundler'

# cleanup compiled stuff
def cleanup
  `rm -rf spec/data/Basic/public`
  `rm -rf spec/data/OutsideDependencies/public`
end