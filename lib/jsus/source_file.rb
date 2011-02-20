#
# SourceFile is a base for any Jsus operation.
# 
# It contains basic info about source as well as file content.
#
#
module Jsus
  class BadSourceFileException < Exception; end
  
  class SourceFile
    attr_accessor :relative_filename, :filename, :package # :nodoc:
    # Constructors

    # Basic constructor.
    #
    # You probably should use SourceFile.from_file instead.
    #
    # But if you know what you are doing, it accepts the following values:
    # * +package+ — an instance of Package, normally passed by a parent
    # * +relative_filename+ — used in Package, for generating tree structure of the source files
    # * +filename+ — full filename for the given package
    # * +content+ — file content of the source file
    # * +pool+ — an instance of Pool
    def initialize(options = {})
      [:package, :header, :relative_filename, :filename, :content, :pool].each do |field|
        send("#{field}=", options[field]) if options[field]
      end
    end

    #
    # Initializes a SourceFile given the filename and options
    # 
    # options:
    # * <tt>:pool:</tt> — an instance of Pool
    # * <tt>:package:</tt> — an instance of Package
    #
    # returns either an instance of SourceFile or nil when it's not possible to parse the input
    #
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
          raise BadSourceFileException, "#{filename} is missing a header or header is invalid"
        end
      else
        raise BadSourceFileException, "Referenced #{filename} does not exist. #{options[:package] ? "Referenced from package #{options[:package].name}" : ""}"
      end
    rescue Exception => e
      if !e.kind_of?(BadSourceFileException) # if we didn't raise the error; like in YAML, for example
        raise "Exception #{e.inspect} happened on #{filename}. Please take appropriate measures"
      else # if we did it, just reraise
        raise e
      end
    end

    # Public API

    #
    # Returns a header parsed from YAML-formatted source file first comment.
    # Contains information about authorship, naming, source files, etc.
    #
    def header
      self.header = {} unless @header
      @header
    end

    #
    # A string containing the description of the source file.
    #
    def description
      header["description"]
    end

    # 
    # Returns an array of dependencies tags. Unordered.
    #
    def dependencies
      @dependencies
    end
    alias_method :requires, :dependencies

    #
    # Returns an array with names of dependencies. Unordered.
    # Accepts options:
    # * <tt>:short:</tt> — whether inner dependencies should not prepend package name
    #   e.g. 'Class' instead of 'Core/Class' when in package 'Core').
    #   Doesn't change anything for external dependencies
    #
    def dependencies_names(options = {})
      dependencies.map {|d| d.name(options) }
    end    
    alias_method :requires_names, :dependencies_names

    #
    # Returns an array of external dependencies tags. Unordered.
    #
    def external_dependencies
      dependencies.select {|d| d.external? }
    end

    #
    # Returns an array with names for external dependencies. Unordered.
    #
    def external_dependencies_names
      external_dependencies.map {|d| d.name }
    end

    # 
    # Returns an array with provides tags.
    #
    def provides
      @provides
    end
        
    # 
    # Returns an array with provides names. 
    # Accepts options:
    # * <tt>:short:</tt> — whether provides should not prepend package name
    #   e.g. 'Class' instead of 'Core/Class' when in package 'Core')
    def provides_names(options = {})
      provides.map {|p| p.name(options)}
    end

    #
    # Returns a tag for replaced file, if any
    #
    def replaces
      @replaces
    end
    

    #
    # Returns a tag for source file, which this one is an extension for.
    #
    # E.g.: file Foo.js in package Core provides ['Class', 'Hash']. File Bar.js in package Bar
    # extends 'Core/Class'. That means its contents would be appended to the Foo.js when compiling 
    # the result.
    #
    def extends
      @extends
    end

    #
    # Returns whether the source file is an extension.
    #
    def extension?
      extends && !extends.empty?
    end

    #
    # Returns an array of included extensions for given source.
    #
    def extensions
      @extensions ||= []
      @extensions = @extensions.flatten.compact.uniq
      @extensions
    end
        
    def extensions=(new_value) # :nodoc:
      @extensions = new_value
    end

    #
    # Looks up for extensions in the #pool and then includes
    # extensions for all the provides tag this source file has.
    # Caches the result.
    #
    def include_extensions
      @included_extensions ||= include_extensions!
    end

    def include_extensions! # :nodoc:
      if pool        
        provides.each do |p|
          extensions << pool.lookup_extensions(p)
        end
      end
    end

    # 
    # Returns an array of files required by this files including all the filenames for extensions.
    # SourceFile filename always goes first, all the extensions are unordered.
    #
    def required_files
      include_extensions
      [filename, extensions.map {|e| e.filename}].flatten
    end

    # 
    # Returns a hash containing basic info with dependencies/provides tags' names
    # and description for source file.
    #
    def to_hash
      {
        "desc"     => description,
        "requires" => dependencies_names(:short => true),
        "provides" => provides_names(:short => true)
      }
    end

    def inspect # :nodoc:
      self.to_hash.inspect
    end
    # Private API
    
    def header=(new_header) # :nodoc:
      @header = new_header
      # prepare defaults
      @header["description"] ||= ""
      # handle tags
      @dependencies = [@header["requires"] || []].flatten
      @dependencies.map! {|tag_name| Tag.new(tag_name, :package => package) }
      @provides = [@header["provides"] || []].flatten
      @provides.map! {|tag_name| Tag.new(tag_name, :package => package) }
      @extends = (@header["extends"] && !@header["extends"].empty?) ? Tag.new(@header["extends"]) : nil
      @replaces = @header["replaces"] ? Tag.new(@header["replaces"]) : nil
    end

    def content=(new_value) # :nodoc:
      @content = new_value
    end

    def content # :nodoc:
      include_extensions
      [@content, extensions.map {|e| e.content}].flatten.compact.join("\n")
    end 
    
    def original_content # :nodoc:
      @content
    end

    # Assigns an instance of Jsus::Pool to the source file.
    # Also performs push to that pool.
    def pool=(new_value)
      @pool = new_value
      @pool << self if @pool
    end

    # A pool which the source file is assigned to. Used in #include_extensions!
    def pool
      @pool
    end
   
    def ==(other) # :nodoc:
      eql?(other)
    end
    
    def eql?(other) # :nodoc:
      filename == other.filename
    end
    
    def hash
      [self.class, filename].hash
    end
  end
end