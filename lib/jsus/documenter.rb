module Jsus
  # Very opinionated documenter class. It uses Murdoc to generate the 
  # documentation using the template and stylesheet bundled with the 
  # jsus gem file. Also generates indices for navigation.
  class Documenter
    # Default documenter options
    DEFAULT_OPTIONS = {:highlight_source => true}
    
    # Documenter options
    attr_accessor :options
    
    # Constructor. Accepts options as the argument.
    def initialize(options = DEFAULT_OPTIONS)
      require "murdoc"
      self.options = options
    rescue LoadError
      raise "You should install murdoc gem in order to produce documentation"
    end

    # Generates documentation tree into the given directory.
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

    # Adds a source file to the documented source tree
    def <<(source) # :nodoc:
      filename = File.basename(source.filename)
      if source.package
        tree["/#{source.package.name}/#{filename}"] = source
      else
        tree["/#{filename}"] = source
      end
      self
    end

    def tree # :nodoc:
      @tree ||= Tree.new
    end

    # Scope for documentation in pathspec format. See Jsus::Tree::Node#find_children_matching
    def current_scope
      @current_scope ||= default_scope
    end

    def default_scope # :nodoc:
      ["/**/*"]
    end

    def current_scope=(scope) # :nodoc:
      @current_scope = scope
    end

    # Sets documenter to exclusive scope for documentation.
    # Exclusive scope overrides all the other scopes.
    def only(scope)
      result = clone
      result.current_scope = [scope].flatten
      result
    end

    # Sets documenter to additive scope for documentation.
    # Additive scopes match any of the pathspecs given
    def or(scope)
      result = clone
      result.current_scope = current_scope + [scope].flatten
      result
    end

    # Returns the tree with documented sources.
    def documented_sources
      @documented_sources ||= documented_sources!
    end

    def documented_sources! # :nodoc:
      doctree = Tree.new
      current_scope.map {|pathspec| tree.glob(pathspec) }.flatten.each {|s| doctree.insert(s.full_path, s.value)}
      doctree
    end

    protected

    def create_documentation_for_source(source, template) # :nodoc:
      skipped_lines = 0
      content = source.original_content.gsub(/\A\s*\/\*.*?\*\//m) {|w| skipped_lines += w.split("\n").size; "" }
      annotator = Murdoc::Annotator.new(content, :javascript, options)
      Murdoc::Formatter.new(template).render(:paragraphs => annotator.paragraphs, :header => source.header, :source => source, :skipped_lines => skipped_lines)
    end

    def create_index_for_node(node, template) # :nodoc:
      Haml::Engine.new(template).render(self, :node => node)
    end    
        
    def file_from_contents(filename, contents) # :nodoc:
      File.open(filename, "w+") {|f| f << contents }
    end
  end
end