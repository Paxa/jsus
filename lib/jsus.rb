require 'yaml'
require 'pathname'
require 'rubygems'
require 'json'
require 'active_support/ordered_hash'
require 'active_support/core_ext/module/delegation'
require 'rgl/adjacency'
require 'rgl/topsort'

require 'fileutils'
require 'pathname'

require 'jsus/source_file'
require 'jsus/package'
require 'jsus/tag'
require 'jsus/container'
require 'jsus/packager'
require 'jsus/pool'
require 'jsus/tree'
require 'jsus/documenter'
require 'jsus/validator'

#
# Jsus -- a library for packaging up your source files.
#
# For better understanding of jsus ideas start with http://github.com/Markiz/jsus-examples
#
#
module Jsus
  # Returns whether or not jsus is in verbose mode  
  def self.verbose?
    !!@verbose
  end

  # Sets verbose mode to on. In verbose mode jsus shows a lot of warnings
  # like missing dependencies.
  def self.verbose=(verbose)
    @verbose = verbose
  end
  
  # Returns current version
  def self.version
    @version ||= File.read(File.dirname(__FILE__) + "/../VERSION")
  end
end