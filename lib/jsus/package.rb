module Jsus
  class Package
    attr_accessor :relative_directory
    attr_accessor :directory
    attr_accessor :pool
     # Constructors
    def initialize(directory, options = {})
      self.relative_directory = directory
      self.directory = File.expand_path(directory)
      self.header = YAML.load_file(File.join(directory, 'package.yml'))
      Dir.chdir(directory) do
        files.each do |source|
          source_file = SourceFile.from_file(source, :package => self)
          if source_file.extension?
            extensions << source_file
          else
            source_files << source_file
          end
        end
      end
      if options[:pool]
        self.pool = options[:pool]
        self.pool << self
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

    def files
      header["files"] = header["files"] || header["sources"] || []
    end

    alias_method :sources, :files

    def provides
      source_files.map {|s| s.provides }.flatten | linked_external_dependencies.map {|d| d.provides }.flatten
    end

    def provides_names
      source_files.map {|s| s.provides_names(:short => true) }.flatten |
      linked_external_dependencies.map {|d| d.provides_names }.flatten
    end

    def dependencies
      result = source_files.map {|source| source.dependencies }.flatten
      result |= linked_external_dependencies.map {|d| d.dependencies}.flatten
      result -= provides
      result
    end

    def dependencies_names
      dependencies.map {|d| d.name(:short => true) }
    end

    def external_dependencies
      source_files.map {|s| s.external_dependencies }.flatten
    end

    def external_dependencies_names
      external_dependencies.map {|d| d.name }
    end

    def linked_external_dependencies
      @linked_external_dependencies ||= Container.new
    end

    def linked_external_dependencies=(new_value)
      @linked_external_dependencies = new_value
    end

    def description
      header["description"] ||= ""
    end    

    def compile(directory = ".")
      Packager.new(*(source_files.to_a + linked_external_dependencies.to_a)).pack(File.join(directory, filename))
    end

    def generate_tree(directory = ".", filename = "tree.json")
      FileUtils.mkdir_p(directory)
      result = ActiveSupport::OrderedHash.new
      source_files.each do |source|
        components = File.dirname(source.relative_filename).split(File::SEPARATOR)
        # deleting source dir by convention
        components.delete("Source")
        node = result
        components.each do |component|
          node[component] ||= ActiveSupport::OrderedHash.new
          node = node[component]
        end
        node[File.basename(source.filename, ".js")] = source.to_hash
      end
      File.open(File.join(directory, filename), "w") { |resulting_file| resulting_file << JSON.pretty_generate(result) }
      result
    end

    def generate_scripts_info(directory = ".", filename = "scripts.json")
      FileUtils.mkdir_p directory
      File.open(File.join(directory, filename), "w") { |resulting_file| resulting_file << JSON.pretty_generate(self.to_hash) }
      self.to_hash
    end

    def include_dependencies!
      source_files.each do |source|
        linked_external_dependencies << pool.lookup_dependencies(source)
      end
    end

    def include_extensions!
      source_files.each do |source|
        source.include_extensions!
      end
    end

    def required_files
      source_files.map {|s| s.required_files }.flatten
    end

    def to_hash
      {
        name => {
          :desc => description,
          :provides => provides_names,
          :requires => dependencies_names
        }
      }
    end


    def source_files
      @source_files ||= Container.new
    end

    def extensions
      @extensions ||= Container.new
    end

    protected
  end
end