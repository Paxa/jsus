module Jsus
  class Documenter
    attr_accessor :options

    def initialize(options = {:highlight_source => true})
      require "murdoc"
      self.options = options
    rescue LoadError
      raise "You should install murdoc gem in order to produce documentation"
    end

    def generate(doc_dir = Dir.pwd)
      #FileUtils.rm_rf(doc_dir)
      FileUtils.mkdir_p(doc_dir)
      template_path = File.dirname(__FILE__) + "/../../markup"
      template = File.read("#{template_path}/template.haml")
      index_template = File.read("#{template_path}/index_template.haml")
      stylesheet_path = "#{template_path}/stylesheet.css"
      documented_sources.traverse(true) do |node|
        if node.value # leaf
          dir = doc_dir + File.dirname(node.full_path)
          FileUtils.mkdir_p(dir)
          file_from_contents(dir + "/#{node.name}.html", create_documentation_for_source(node.value, template))
        else
          dir = doc_dir + node.full_path
          FileUtils.mkdir_p(dir)
          FileUtils.cp(stylesheet_path, dir)
          file_from_contents(dir + "/index.html", create_index_for_node(node, index_template))
        end
      end
    end

    def create_documentation_for_source(source, template)
      skipped_lines = 0
      content = source.original_content.gsub(/\A\s*\/\*.*?\*\//m) {|w| skipped_lines += w.split("\n").size; "" }
      annotator = Murdoc::Annotator.new(content, :javascript, options)
      Murdoc::Formatter.new(template).render(:paragraphs => annotator.paragraphs, :header => source.header, :source => source, :skipped_lines => skipped_lines)
    end

    def create_index_for_node(node, template)
      Haml::Engine.new(template).render(self, :node => node)
    end    

    def <<(source)
      filename = File.basename(source.filename)
      if source.package
        tree.insert("/#{source.package.name}/#{filename}", source)
      else
        tree.insert("/#{filename}", source)
      end
      self
    end

    def tree
      @tree ||= Tree.new
    end

    def current_scope
      @current_scope ||= default_scope
    end

    def default_scope
      ["/**/*"]
    end

    def current_scope=(scope)
      @current_scope = scope
    end

    # exclusive scope
    def only(scope)
      result = clone
      result.current_scope = [scope].flatten
      result
    end

    # additive scope
    def or(scope)
      result = clone
      result.current_scope = current_scope + [scope].flatten
      result
    end

    def documented_sources
      @documented_sources ||= documented_sources!
    end

    def documented_sources!
      doctree = Tree.new
      current_scope.map {|pathspec| tree.glob(pathspec) }.flatten.each {|s| doctree.insert(s.full_path, s.value)}
      doctree
    end

    protected
    def file_from_contents(filename, contents)
      File.open(filename, "w+") {|f| f << contents }
    end
  end
end