require 'fileutils'
module Jsus
  module Util
    class FileCache
      def initialize(path)
        @path = path
      end # initialize

      def write(key, value)
        item_path = generate_path(key)
        FileUtils.mkdir_p(File.dirname(item_path))
        File.open(item_path, 'w+') {|f| f.write(value) }
        item_path
      end # write

      def read(key)
        item_path = generate_path(key)
        File.exists?(item_path) ? item_path : nil
      end # read

      def fetch(key, &block)
        read(key) || write(key, yield)
      end # fetch

      def delete(key)
        item_path = generate_path(key)
        if File.exists?(item_path)
          FileUtils.rm_f(item_path)
        end
      end # delete

      protected

      def generate_path(key)
        File.join(@path, key)
      end # generate_path
    end # class FileCache
  end # module Util
end # module Jsus