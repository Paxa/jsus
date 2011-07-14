module Jsus
  module Util
    # Code generation routines.
    module CodeGenerator
      class <<self
        # @param [Array] paths list of paths
        # @return [String] javascript for includes for a list of given paths
        # @api public
        def generate_includes(paths, options = {})
          script = %{
          (function(prefix, loader) {
            var sources = %sources%;
            if (!loader) loader = function(path) {
              document.write('<scr' + 'ipt src="' + (prefix || '') + path + '"></script>');
            }
            for (var i = 0, j = sources.length; i < j; i++) loader(sources[i]);
          })(#{options[:prefix] || 'window.prefix'}, window.loader);}.sub("%sources%", JSON.pretty_generate(paths))
        end # generate_includes
      end # class <<self
    end # module CodeGenerator
  end # module Util
end # module Jsus
