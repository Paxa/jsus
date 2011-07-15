require 'logger'
module Jsus
  module Util
    # Extension of ruby logger allowing for message buffering.
    class Logger < ::Logger
      module Buffering
        # Buffer storing logged messages
        def buffer
          @buffer ||= []
        end # buffer

        def buffer=(value)
          @buffer = value
        end # buffer=

        def add(severity, message = nil, progname = nil, &block)
          unless @logdev.nil? or severity < @level
            if message.nil?
              if block_given?
                message = yield
              else
                message = progname
                progname = @progname
              end
            end
            buffer << [severity, message]
          end
          super
        end # add
      end # module Buffering

      include Buffering
    end # class Logger
  end # module Util
end # module Jsus
