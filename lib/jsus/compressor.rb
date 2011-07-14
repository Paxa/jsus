module Jsus
  class Compressor
    attr_reader :result
    def initialize(source, options = {}) # todo - non-java compressor
      @result = compress_with_yui(source)
    end
    
    def compress_with_yui(source)
      begin
        require 'yui/compressor'
        compressor = YUI::JavaScriptCompressor.new(:munge => true)
        compressed_content = compressor.compress(source)
      rescue LoadError
        Jsus::Middleware.errors << 'ERROR: You need "yui-compressor" gem in order to use --compress option'
          .tap {|a| puts a }
      end
      compressed_content
    end
  end
end