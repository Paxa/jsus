module Jsus
  class Package
    attr_accessor :relative_directory
    attr_accessor :directory

     # Constructors
    def initialize(directory)
      self.relative_directory = Pathname.new(directory).relative_path_from(Pathname.new(".")).to_s
      self.directory = File.expand_path(directory)
      self.header = YAML.load_file(File.join(directory, 'package.yml'))
      Dir.chdir(directory) do
        files.each do |source|
          source_files << SourceFile.from_file(source)
        end
      end
    end


    # Public API
    def header
      @header ||= {}
    end

    def header=(new_header)
      @header = new_header
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
      header["files"] = header["files"] || header["sources"] || []
    end

    alias_method :sources, :files

    def dependencies
      @dependencies ||= dependencies!
    end

    def dependencies!
      source_files.map {|source| source.dependencies }.flatten.compact.uniq - provides!
    end

    def description
      header["description"] ||= ""
    end    

    def compile(directory = ".")
      Packager.new(*source_files).pack(File.join(directory, filename))
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
        File.open(filename, "w") { |resulting_file| resulting_file << JSON.pretty_generate(result) }
      end
    end

    def generate_scripts_info(directory = ".", filename = "scripts.json")
      FileUtils.mkdir_p directory
      Dir.chdir(directory) do
        result = {}
        result[name] = {}
        result[name]["desc"] = description
        result[name]["requires"] = dependencies
        result[name]["provides"] = provides
        File.open(filename, "w") { |resulting_file| resulting_file << JSON.pretty_generate(result) }
      end
    end


    def required_files
      Container.new(*source_files).map {|s| s.filename }
    end
    protected


    def source_files
      @source_files ||= []
      @source_files
    end

    def source_files=(new_value)
      @source_files = new_value.compact
    end
  end
end