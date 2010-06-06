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
          source_files << SourceFile.from_file(source, :package => self)
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

    def provides
      source_files.map {|source| source.provides(:short => true) }.flatten +
        external_dependencies.map {|d| d.provides }.flatten
    end

    def files
      header["files"] = header["files"] || header["sources"] || []
    end

    alias_method :sources, :files

    def dependencies
      source_files.map {|source| source.dependencies(:short => true) }.flatten.compact.uniq - provides
    end

    def external_dependencies
      @external_dependencies ||= Container.new
    end

    def external_dependencies=(new_value)
      @external_dependencies = new_value
    end

    def description
      header["description"] ||= ""
    end    

    def compile(directory = ".")
      Packager.new(*(source_files.to_a + external_dependencies.to_a)).pack(File.join(directory, filename))
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
        self.external_dependencies << pool.lookup_dependencies(source)
      end
    end


    def required_files
      source_files.map {|s| s.filename }
    end

    def to_hash
      {
        name => {
          :desc => description,
          :provides => provides,
          :requires => dependencies
        }
      }
    end


    def source_files
      @source_files ||= Container.new
    end

    protected
  end
end