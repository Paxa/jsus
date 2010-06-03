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

    protected

    def source_files
      @source_files ||= Container.new
    end
  end
end