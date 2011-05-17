require 'fileutils'
module Jsus
  module Util
    #
    # Simple file cache manager.
    #
    class FileCache
      # Initializes filecache to given directory
      def initialize(path)
        @path = path
      end # initialize

      # Creates a file with given value for given key in cache directory
      #
      # Returns actual path for stored file.
      def write(key, value)
        item_path = generate_path(key)
        FileUtils.mkdir_p(File.dirname(item_path))
        File.open(item_path, 'w+') {|f| f.write(value) }
        item_path
      end # write

      # If file exists for given cache key, returns path to that file.
      # If file doesn't exist, returns nil.
      def read(key)
        item_path = generate_path(key)
        File.exists?(item_path) ? item_path : nil
      end # read
      alias_method :exists?, :read

      # If file with given key exists, returns path to it.
      # Otherwise, writes value of yielded block.
      def fetch(key, &block)
        read(key) || write(key, yield)
      end # fetch

      # Deletes cache entry for given key.
      def delete(key)
        item_path = generate_path(key)
        if File.exists?(item_path)
          FileUtils.rm_f(item_path)
        end
      end # delete

      protected

      # Generates path by cache key.
      #
      # Default strategy: append key to cache directory
      # (slashes are replaced with dots)
      def generate_path(key)
        key = key.gsub(File::SEPARATOR, ".")
        File.join(@path, key)
      end # generate_path
    end # class FileCache
  end # module Util
end # module Jsus
