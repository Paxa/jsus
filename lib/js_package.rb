require 'js_source_file'
require 'rgl/topsort'
require 'pp'
class JsPackage
   # Constructors
  def initialize(directory)
    self.header = YAML.load_file(File.join(directory, 'package.yml'))
    Dir.chdir(directory) do
      files.each do |source|
        source_files << JsSourceFile.from_file(source)
      end
      calculate_requirement_order
    end
  end


  # Public API
  attr_writer :header
  def header
    @header ||= {}
  end

  def name
    header["name"] ||= ""
  end

  def filename
    header["filename"] ||= name + ".js"
  end

  def provides
    @provides ||= provides!
  end

  def provides!
    source_files.map {|source| source.provides }.flatten
  end

  def files
    header["files"] ||= []
  end

  def dependencies
    @dependencies ||= dependencies!
  end

  def dependencies!
    source_files.map {|source| source.dependencies }.flatten.compact.uniq - provides!
  end

  attr_accessor :required_files

  protected

  attr_writer :source_files
  def source_files
    @source_files ||= []
    @source_files.compact!
    @source_files
  end

  def calculate_requirement_order
    graph = RGL::DirectedAdjacencyGraph.new
    provides_hash = {}
    # init vertices
    source_files.each do |source|
      graph.add_vertex(source)
      source.provides.each do |provides|
        provides_hash[provides] = source
      end
    end
    # init edges
    source_files.each do |source|
      source.dependencies.each do |dependency|
        if required_source = provides_hash[dependency]
          graph.add_edge(required_source, source)
        end
      end
    end
    @required_files = []
    graph.topsort_iterator.each do |vertex|
      @required_files << vertex.filename
    end

  end

end