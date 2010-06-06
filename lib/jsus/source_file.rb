module Jsus
  class SourceFile
    attr_accessor :relative_filename
    attr_accessor :filename
    attr_accessor :content
    attr_accessor :package
    # constructors

    def initialize(options = {})
      [:header, :relative_filename, :filename, :content, :package].each do |field|
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
      @header["requires"] = [@header["requires"] || []].flatten
      @header["requires"].map! {|r| r.gsub(/^(\.)?\//, "") }
      @header["provides"] = [@header["provides"] || []].flatten
    end

    def header
      self.header = {} unless @header
      @header
    end

    def dependencies(options = {})            
      if !options[:short] && package
        header["requires"].map {|r| r.index("/") ? r : "#{package.name}/#{r}"}
      else
        header["requires"]
      end
    end
    alias_method :requires, :dependencies

    def external_dependencies
      dependencies(:short => true).select {|d| d.index("/") }
    end

    def internal_dependencies
      dependencies(:short => true) - external_dependencies
    end

    def provides(options = {})      
      if !options[:short] && package
        header["provides"].map {|p| "#{package.name}/#{p}"}
      else
        header["provides"]
      end
    end

    def description
      header["description"]
    end

    def to_hash
      {
        "desc"     => description,
        "requires" => dependencies(:short => true),
        "provides" => provides(:short => true)
      }
    end

    def inspect
      self.to_hash.inspect
    end

  end
end