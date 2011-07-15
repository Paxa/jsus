module Jsus
  module Util
    class Compressor
      attr_reader :result
      def initialize(source, options = {}) # todo - non-java compressor
        @result = compress_with_yui(source)
      end # initialize

      def compress_with_yui(source)
        begin
          require 'yui/compressor'
          compressor = YUI::JavaScriptCompressor.new(:munge => true)
          compressed_content = compressor.compress(source)
        rescue LoadError
          Jsus.logger.fatal 'ERROR: You need "yui-compressor" gem in order to use --compress option'
        end
        compressed_content
      end # compress_with_yui
    end # class Compressor
  end # module Util
end # module Jsus
