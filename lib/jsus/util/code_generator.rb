module Jsus
  module Util
    module CodeGenerator
      class <<self
        def generate_includes(paths)
          script = %{
          (function(prefix, loader) {
            var sources = %sources%;
            if (!loader) loader = function(path) {
              document.write('<scr' + 'ipt src="' + (prefix || '') + path + '"></script>');
            }
            for (var i = 0, j = sources.length; i < j; i++) loader(sources[i]);
          })(window.prefix, window.loader);}.sub("%sources%", JSON.pretty_generate(paths))
        end # generate_includes
      end # class <<self
    end # module CodeGenerator
  end # module Util
end # module Jsus
