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

#
# Jsus -- your better javascript packager.
#
module Jsus
  autoload :SourceFile, 'jsus/source_file'
  autoload :Package,    'jsus/package'
  autoload :Tag,        'jsus/tag'
  autoload :Container,  'jsus/container'
  autoload :Packager,   'jsus/packager'
  autoload :Pool,       'jsus/pool'
  autoload :Util,       'jsus/util'
  autoload :Middleware, 'jsus/middleware'
  autoload :Compressor, 'jsus/compressor'

  # In verbose mode jsus shows a lot of warnings like missing dependencies.
  # Default: false
  #
  # @return [Boolean] jsus verbosity mode
  # @api public
  def self.verbose?
    !!@verbose
  end

  # @see .verbose?
  # @param [Boolean] verbose verbose verbosity mode
  # @api public
  def self.verbose=(verbose)
    @verbose = verbose
  end

  # @return [String] Jsus version
  # @api public
  def self.version
    @version ||= File.read(File.dirname(__FILE__) + "/../VERSION")
  end


  # Circular dependencies cannot be resolved and lead to "impossible"
  # situations and problems, like missing source files or incorrect ordering.
  #
  # However, checking for cycles is quite computationally expensive, which
  # is why you may want to disable it in production mode.
  #
  # @return [Boolean]
  # @api public
  def self.look_for_cycles?
    @look_for_cycles == nil ? true : @look_for_cycles
  end

  # @see .look_for_cycles?
  # @param [Boolean]
  def self.look_for_cycles=(value)
    @look_for_cycles = value
  end
end
