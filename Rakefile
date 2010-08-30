require 'rubygems'
require 'rake'
require 'echoe'
Echoe.new('jsus', '0.1.8') do |g|
  g.description    = "Packager/compiler for js-files that resolves dependencies and can compile everything into one file, providing all the neccessary meta-info."
  g.url            = "http://github.com/markiz/jsus"
  g.author         = "Markiz, idea by Inviz (http://github.com/Inviz)"
  g.email          = "markizko@gmail.com"
  g.ignore_pattern = ["nbproject/**/*", 'spec/*/public/**/*']
  g.runtime_dependencies   = ["activesupport", "json_pure", "rgl", "choice"]
  g.development_dependencies = ["rake"]
  g.use_sudo       = false
end