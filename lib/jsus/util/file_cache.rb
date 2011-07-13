require 'fileutils'
module Jsus
  module Util
    #
    # Simple file cache manager.
    #
    class FileCache
      # Initializes filecache to given directory
      # @param [String] output directory
      # @api public
      def initialize(path)
        @path = path
      end # initialize

      # Creates a file with given value for given key in cache directory
      #
      # @param [String] key
      # @param [String] value
      # @return [String] actual path for stored file.
      # @api public
      def write(key, value)
        item_path = generate_path(key)
        FileUtils.mkdir_p(File.dirname(item_path))
        File.open(item_path, 'w+') {|f| f.write(value) }
        item_path
      end # write

      # @param [String] key
      # @return [String, nil] path to cached file or nil
      # @api public
      def read(key)
        item_path = generate_path(key)
        File.exists?(item_path) ? item_path : nil
      end # read
      alias_method :exists?, :read

      # @param [String] key
      # @yield block with routine to call on cache miss
      # @return [String] path to stored file
      # @api public
      def fetch(key, &block)
        read(key) || write(key, yield)
      end # fetch

      # Deletes cache entry for given key.
      # @param [String] key
      # @api public
      def delete(key)
        item_path = generate_path(key)
        if File.exists?(item_path)
          FileUtils.rm_f(item_path)
        end
      end # delete

      protected

      # Generates path by cache key.
      #
      # Default strategy: relative path references via ../ are escaped.
      # @api private
      def generate_path(key)
        key = key.gsub(%r{(^|/)\.\./}, ".")
        File.join(@path, key)
      end # generate_path
    end # class FileCache
  end # module Util
end # module Jsus
