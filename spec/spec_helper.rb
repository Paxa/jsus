require 'lib/jsus'

# cleanup compiled stuff
def cleanup
  `rm -rf spec/data/Basic/public`
  `rm -rf spec/data/OutsideDependencies/public`
  `rm -rf spec/tmp/`
end