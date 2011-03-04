module Jsus
  #
  # Package is a (self-contained) unit with all the info required to build
  # a javascript package.
  #
  class Package
    attr_accessor :directory # directory which this package resides in (full path)
    attr_accessor :pool      # an instance of Pool
    # Constructors
     
    #
    # Creates a package from given directory.
    #
    # Accepts options:
    # * +:pool:+ -- which pool the package should belong to.
    #
    # Raises an error when the given directory doesn't contain a package.yml or package.json
    # file with meta info.
    #
    def initialize(directory, options = {})
      self.directory          = File.expand_path(directory)
      if File.exists?(File.join(directory, 'package.yml'))
        self.header           = YAML.load_file(File.join(directory, 'package.yml'))
      elsif File.exists?(File.join(directory, 'package.json'))
        self.header           = JSON.load(IO.read(File.join(directory, 'package.json')))
      else
        raise "Directory #{directory} does not contain a valid package.yml / package.json file!"
      end
      Dir.chdir(directory) do
        files.each do |source|
          source_file = SourceFile.from_file(source, :package => self)
          if source_file
            if source_file.extension?
              extensions << source_file
            else
              source_files << source_file
            end
          else
            puts "Warning: #{source} is not found for #{name}" if Jsus.verbose?
          end
        end
      end
      if options[:pool]
        self.pool = options[:pool]
        self.pool << self
      end
    end


    # Public API
    
    # Returns a package.yml header.
    def header
      @header ||= {}
    end

    # Returns a package name.
    def name
      header["name"] ||= ""
    end
    
    # Returns a package description.
    def description
      header["description"] ||= ""
    end    

    # Returns a filename for compiled package.
    def filename
      header["filename"] ||= name + ".js"
    end

    # Returns a list of sources filenames.
    def files
      header["files"] = header["files"] || header["sources"] || []
    end
    alias_method :sources, :files

    # Returns an array of provided tags including those provided by linked external dependencies.
    def provides
      source_files.map {|s| s.provides }.flatten | linked_external_dependencies.map {|d| d.provides }.flatten
    end

    # Returns an array of provided tags names including those provided by linked external dependencies.
    def provides_names      
      source_files.map {|s| s.provides_names(:short => true) }.flatten |
      linked_external_dependencies.map {|d| d.provides_names }.flatten
    end

    # Returns an array of unresolved dependencies' tags for the package.
    def dependencies
      result = source_files.map {|source| source.dependencies }.flatten
      result |= linked_external_dependencies.map {|d| d.dependencies}.flatten
      result -= provides
      result
    end

    # Returns an array of unresolved dependencies' names.
    def dependencies_names
      dependencies.map {|d| d.name(:short => true) }
    end

    # Returns an array of external dependencies' tags (including resolved ones).
    def external_dependencies
      source_files.map {|s| s.external_dependencies }.flatten
    end
    
    # Returns an array of external dependencies' names (including resolved ones).
    def external_dependencies_names
      external_dependencies.map {|d| d.name }
    end

    # Returns source files with external dependencies in correct order.
    def linked_external_dependencies
      @linked_external_dependencies ||= Container.new
    end
    
    # Compiles source files and linked external source files into a given category.
    def compile(directory = ".")
      fn = directory ? File.join(directory, filename) : nil
      Packager.new(*(source_files.to_a + linked_external_dependencies.to_a)).pack(fn)
    end

    # Generates tree structure for files in package into a json file.
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

    # Generates info about resulting compiled package into a json file.
    def generate_scripts_info(directory = ".", filename = "scripts.json")
      FileUtils.mkdir_p directory
      File.open(File.join(directory, filename), "w") { |resulting_file| resulting_file << JSON.pretty_generate(self.to_hash) }
      self.to_hash
    end

    # Looks up all the external dependencies in the pool.
    def include_dependencies!
      source_files.each do |source|
        if pool
          deps = pool.lookup_dependencies(source).to_a - @source_files.to_a
          linked_external_dependencies << deps
        end
      end
    end

    # Executes #include_extensions for all the source files.
    def include_extensions!
      source_files.each do |source|
        source.include_extensions!
      end
    end

    # Lists the required files for the package.
    def required_files      
      source_files.map {|s| s.required_files }.flatten
    end

    def to_hash # :nodoc:
      {
        name => {
          :desc => description,
          :provides => provides_names,
          :requires => dependencies_names
        }
      }
    end

    # Container with source files
    def source_files
      @source_files ||= Container.new
    end

    # Container with extensions (they aren't compiled or included into #reqired_files list)
    def extensions
      @extensions ||= Container.new
    end

    # Private API
    
    def header=(new_header) # :nodoc:
      @header = new_header
    end

    def linked_external_dependencies=(new_value) # :nodoc:
      @linked_external_dependencies = new_value
    end

    protected
  end
end
