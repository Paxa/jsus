unless ARGV.length == 2
  puts "SYNOPSYS: ruby js-bundle.rb <input_directory_with_packages> <output_directory_for_packages>"
  exit
else
  $LOAD_PATH.unshift("lib")
  require 'lib/js_bundler'
  JsBundler.new(ARGV[0]).compile(ARGV[1])
end
