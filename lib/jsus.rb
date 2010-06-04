require 'yaml'
require 'pathname'
require 'rubygems'
require 'json'
require 'active_support/ordered_hash'
require 'active_support/core_ext/module/delegation'
require 'rgl/adjacency'
require 'rgl/topsort'

require 'jsus/topsortable'
require 'jsus/source_file'
require 'jsus/container'
require 'jsus/packager'
require 'jsus/pool'
require 'jsus/package'

module Jsus
  # Shortcut for Bundler.new
  def self.new(*args, &block)
    Bundler.new(*args, &block)
  end

end