module Jsus
  class SourceFile
    attr_accessor :relative_filename
    attr_accessor :filename
    attr_accessor :content
    attr_accessor :package
    # constructors

    def initialize(options = {})
      [:package, :header, :relative_filename, :filename, :content].each do |field|
        send("#{field}=", options[field]) if options[field]
      end
      options[:pool] << self if options[:pool]
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
          #puts "WARNING: file #{filename} has invalid format (should be YAML)"
          nil
        end
      else
        #puts "WARNING: file #{filename} does not exist"
        nil
      end
    end

    # Public API
    def header=(new_header)
      @header = new_header
      # prepare defaults
      @header["description"] ||= ""
      @dependencies = [@header["requires"] || []].flatten
      @dependencies.map! {|tag_name| Tag.new(tag_name, :package => package) }
      @provides = [@header["provides"] || []].flatten
      @provides.map! {|tag_name| Tag.new(tag_name, :package => package) }
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

    def description
      header["description"]
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