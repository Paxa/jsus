module Jsus
  class SourceFile
    attr_accessor :relative_filename
    attr_accessor :filename
    attr_accessor :package
    # constructors

    def initialize(options = {})
      [:package, :header, :relative_filename, :filename, :content, :pool].each do |field|
        send("#{field}=", options[field]) if options[field]
      end
    end

    def self.from_file(filename, options = {})
      if File.exists?(filename)
        source = File.read(filename)
        yaml_data = source.match(%r(^/\*\s*(---.*?)\*/)m)
        if (yaml_data && yaml_data[1] && header = YAML.load(yaml_data[1]))          
          options[:header]            = header
          options[:relative_filename] = filename
          options[:filename]          = File.expand_path(filename)
          options[:content]           = source
          new(options)
        else
#          puts "WARNING: file #{filename} has invalid format (should be YAML)"
          nil
        end
      else
#        puts "WARNING: file #{filename} does not exist"
        nil
      end
    end

    # Public API
    def header=(new_header)
      @header = new_header
      # prepare defaults
      @header["description"] ||= ""
      # handle 
      @dependencies = [@header["requires"] || []].flatten
      @dependencies.map! {|tag_name| Tag.new(tag_name, :package => package) }
      @provides = [@header["provides"] || []].flatten
      @provides.map! {|tag_name| Tag.new(tag_name, :package => package) }
      @extends = (@header["extends"] && !@header["extends"].empty?) ? Tag.new(@header["extends"]) : nil
    end

    def content=(new_value)
      @content = new_value
    end

    def content
      [@content, extensions.map {|e| e.content}].flatten.compact.join("\n")
    end

    def pool=(new_value)
      @pool = new_value
      @pool << self if @pool
    end

    def pool
      @pool
    end

    def header
      self.header = {} unless @header
      @header
    end

    def dependencies
      @dependencies
    end
    alias_method :requires, :dependencies

    def dependencies_names(options = {})
      dependencies.map {|d| d.name(options) }
    end    
    alias_method :requires_names, :dependencies_names

    def external_dependencies
      dependencies.select {|d| d.external? }
    end

    def provides
      @provides ||= []
    end

    def provides_names(options = {})
      provides.map {|p| p.name(options)}
    end

    def extends
      @extends
    end

    def extension?
      extends && !extends.empty?
    end

    def extensions
      @extensions ||= []
      @extensions = @extensions.flatten.compact.uniq
      @extensions
    end

    def extensions=(new_value)
      @extensions = new_value
    end

    def include_extensions!
      if pool        
        provides.each do |p|
          extensions << pool.lookup_extensions(p)
        end
      end
    end

    def description
      header["description"]
    end

    def required_files
      [filename, extensions.map {|e| e.filename}].flatten
    end

    def to_hash
      {
        "desc"     => description,
        "requires" => dependencies_names(:short => true),
        "provides" => provides_names(:short => true)
      }
    end

    def inspect
      self.to_hash.inspect
    end

  end
end