require 'js_source_file'
require 'rgl/topsort'
require 'pp'
require 'active_support/ordered_hash'
require 'pathname'
class JsPackage
   # Constructors
  def initialize(directory)
    self.relative_directory = Pathname.new(directory).relative_path_from(Pathname.new(".")).to_s
    self.directory = File.expand_path(directory)
    self.header = YAML.load_file(File.join(directory, 'package.yml'))
    Dir.chdir(directory) do
      files.each do |source|
        source_files << JsSourceFile.from_file(source)
      end      
    end
    calculate_requirement_order
  end


  # Public API
  attr_accessor :relative_directory
  attr_accessor :directory

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

  def description
    header["description"] ||= ""
  end

  attr_accessor :required_files

  def compile(directory = ".")
    FileUtils.mkdir_p directory
    Dir.chdir(directory) do
      File.open(filename, "w") do |resulting_file|
        required_files.each do |required_file|
          resulting_file.puts(IO.read(required_file))
        end
      end
      generate_scripts_info(".")
    end
  end

  def generate_tree(directory = ".", filename = "tree.json")
    FileUtils.mkdir_p(directory)
    result = ActiveSupport::OrderedHash.new
    source_files.each do |source|
      components = File.dirname(source.relative_filename).split(File::SEPARATOR)
      components.delete("Source")
      components << File.basename(source.filename, ".js")
      node = result
      components.each do |component|
        node[component] ||= ActiveSupport::OrderedHash.new
        node = node[component]
      end
      node["desc"] = source.description
      node["requires"] = source.dependencies
      node["provides"] = source.provides
    end
    Dir.chdir(directory) do
      File.open(filename, "w") { |resulting_file| resulting_file << result.to_json}
    end
  end

  def generate_scripts_info(directory = ".", filename = "scripts.json")
    Dir.chdir(directory) do
      result = {}
      result[name] = {}
      result[name]["desc"] = description
      result[name]["requires"] = dependencies
      result[name]["provides"] = provides
      File.open(filename, "w") { |resulting_file| resulting_file << result.to_json}
    end
  end

  protected

  attr_writer :source_files
  def source_files
    @source_files ||= []
    @source_files.compact!
    @source_files
  end

  def calculate_requirement_order
    self.source_files = JsBundler.topsort(source_files)
    self.required_files = source_files.map {|f| f.filename}
  end


end