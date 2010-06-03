require 'yaml'
require 'pathname'
require 'rubygems'
require 'json'
require 'active_support/ordered_hash'
require 'rgl/adjacency'
require 'rgl/topsort'

require 'jsus/topsortable'
require 'jsus/source_file'
require 'jsus/package'
require 'jsus/bundler'

module Jsus
  # Shortcut for Bundler.new
  def self.new(*args, &block)
    Bundler.new(*args, &block)
  end

end