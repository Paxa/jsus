require 'rubygems'
require 'rgl/adjacency'
require 'json'
require 'js_source_file'
require 'js_package'
require 'pathname'
class JsBundler

  def initialize(directory)
    Dir[File.join(directory, "**", "package.yml")].each do |package_name|
      path = Pathname.new(package_name)
      Dir.chdir path.parent.parent.to_s do
        package = JsPackage.new(path.parent.relative_path_from(path.parent.parent).to_s)
        self.packages << package
      end
    end
    calculate_requirement_order
  end


  attr_writer :packages
  def packages
    @packages ||= []
  end

  attr_accessor :required_files

  def compile(directory)
    FileUtils.mkdir_p(directory)
    Dir.chdir directory do
      packages.each do |package|
        package.compile(package.relative_directory)
        package.generate_tree(package.relative_directory)
      end
    end
  end


  # Topological sort for packages and source files
  def self.topsort(items)
    graph = RGL::DirectedAdjacencyGraph.new
    provides_hash = {}
    # init vertices
    items.each do |item|
      graph.add_vertex(item)
      item.provides.each do |provides|
        provides_hash[provides] = item
      end
    end
    # init edges
    items.each do |item|
      item.dependencies.each do |dependency|
        if required_item = provides_hash[dependency]
          graph.add_edge(required_item, item)
        end
      end
    end
    result = []
    graph.topsort_iterator.each { |item| result << item }
    result
  end

  protected
  def calculate_requirement_order
    @packages = JsBundler.topsort(@packages)
    @required_files = @packages.map {|p| p.required_files }.flatten
  end
end