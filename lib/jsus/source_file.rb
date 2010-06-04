module Jsus
  class SourceFile
    attr_accessor :header
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
    def dependencies(options = {})
      header["requires"] = [header["requires"] || []].flatten
      header["requires"].map! {|r| r.gsub(/^\//, "") }
      if options[:full] && package
        header["requires"].map {|r| "#{package.name}/#{r}"}
      else
        header["requires"]
      end
    end
    alias_method :requires, :dependencies

    def provides(options = {})
      header["provides"] = [header["provides"] || []].flatten
      if options[:full] && package
        header["provides"].map {|p| "#{package.name}/#{p}"}
      else
        header["provides"]
      end
    end

    def description
      header["description"] ||= ""
    end

    def to_hash
      {
        "desc"     => description,
        "requires" => dependencies,
        "provides" => provides
      }
    end

    def inspect
      self.to_hash.inspect
    end

  end
end