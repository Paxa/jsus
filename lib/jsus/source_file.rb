module Jsus
  # Generic exception for 'bad' source files (no yaml header, for example)
  class BadSourceFileException < Exception; end

  #
  # SourceFile is a base for any Jsus operation.
  #
  # It contains general info about source as well as file content.
  #
  class SourceFile
    # Filename relative to package root
    attr_accessor :relative_filename
    # Full filename
    attr_accessor :filename
    # Package owning the sourcefile
    attr_accessor :package

    # Constructors

    # Basic constructor.
    #
    # You probably should use SourceFile.from_file instead of this one.
    #
    # @param [Hash] options
    # @option options [Jsus::Package] :package package to assign source file to.
    # @option options [String] :relative_filename used in Package to generate
    #   tree structure of the source files
    # @option options [String] :filename full filename for the given source file
    # @option options [String] :content file content of the source file
    # @option options [Jsus::Pool] :pool owner pool for that file
    # @option options [String] :header header of the file
    # @api semipublic
    def initialize(options = {})
      [:package, :header, :relative_filename, :filename, :content, :pool].each do |field|
        send("#{field}=", options[field]) if options[field]
      end
    end

    #
    # Initializes a SourceFile given the filename and options
    #
    # @param [String] filename
    # @param [Hash] options
    # @option options [Jsus::Pool] :pool owning pool
    # @option options [Jsus::Package] :package owning package
    # @return [Jsus::SourceFile]
    # @raise [Jsus::BadSourceFileException] when file cannot be parsed
    # @api public
    def self.from_file(filename, options = {})
      if File.exists?(filename)
        source = File.open(filename, 'r:utf-8') {|f| f.read }
        bom = RUBY_VERSION =~ /1.9/ ? "\uFEFF" : "\xEF\xBB\xBF"
        source.gsub!(bom, "")
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

    # @return [Hash] a header parsed from YAML-formatted source file first comment.
    # @api public
    def header
      self.header = {} unless @header
      @header
    end

    # @return [String] description of the source file.
    # @api public
    def description
      header["description"]
    end

    # @return [Array] list of dependencies for given file
    # @api public
    def dependencies
      @dependencies
    end
    alias_method :requires, :dependencies

    #
    # @param [Hash] options
    # @option options [Boolean] :short whether inner dependencies should not
    #   prepend package name, e.g. 'Class' instead of 'Core/Class' when in
    #   package 'Core'.
    #
    #   Note Doesn't change anything for external dependencies
    #
    # @return [Array] array with names of dependencies. Unordered.
    # @api public
    def dependencies_names(options = {})
      dependencies.map {|d| d.name(options) }
    end
    alias_method :requires_names, :dependencies_names

    # @return [Array] array of external dependencies tags. Unordered.
    # @api public
    def external_dependencies
      dependencies.select {|d| d.external? }
    end

    # @returns [Array] array with names for external dependencies. Unordered.
    # @api public
    def external_dependencies_names
      external_dependencies.map {|d| d.name }
    end

    # @return [Array] array with provides tags.
    # @api public
    def provides
      @provides
    end

    # @param [Hash] options
    # @option options [Boolean] :short whether provides should not prepend package
    #   name, e.g. 'Class' instead of 'Core/Class' when in package 'Core'.
    # @return [Array] array with provides names.
    # @api public
    def provides_names(options = {})
      provides.map {|p| p.name(options)}
    end

    # @return [Jsus::Tag] tag for replaced file, if any
    # @api public
    def replaces
      @replaces
    end


    # @returns [Jsus::Tag] tag for source file, for which this one is an extension.
    # @example file Foo.js in package Core provides ['Class', 'Hash']. File
    # Bar.js in package Bar extends 'Core/Class'. That means its contents would be
    # appended to the Foo.js when compiling the result.
    # @api public
    def extends
      @extends
    end

    # @return [Boolean] whether the source file is an extension.
    # @api public
    def extension?
      extends && !extends.empty?
    end

    # @return [Array] new_value array of included extensions for given source.
    # @api public
    def extensions
      @extensions ||= []
      @extensions = @extensions.flatten.compact.uniq
      @extensions
    end

    # @param [Array] new_value list of extensions for given file
    # @api semipublic
    def extensions=(new_value)
      @extensions = new_value
    end

    # Looks up for extensions in the pool and then includes
    # extensions for all the provides tag this source file has.
    # Caches the result.
    #
    # @api semipublic
    def include_extensions
      @included_extensions ||= include_extensions!
    end

    # @see #include_extensions
    # @api semipublic
    def include_extensions!
      if pool
        provides.each do |p|
          extensions << pool.lookup_extensions(p)
        end
      end
    end

    # @return [Array] array of files required by this files including all the filenames for extensions.
    #    SourceFile filename always goes first, all the extensions are unordered.
    # @api public
    def required_files
      include_extensions
      [filename, extensions.map {|e| e.filename}].flatten
    end

    # @return [Hash] hash containing basic info with dependencies/provides tags' names
    #   and description for source file.
    #
    # @api public
    def to_hash
      {
        "desc"     => description,
        "requires" => dependencies_names(:short => true),
        "provides" => provides_names(:short => true)
      }
    end

    # Human readable description of source file.
    # @return [String]
    # @api public
    def inspect
      self.to_hash.inspect
    end

    # Parses header and gets info from it.
    # @param [String] new_header header content
    # @api private
    def header=(new_header)
      @header = new_header
      # prepare defaults
      @header["description"] ||= ""
      # handle tags
      @dependencies = parse_tag_list(Array(@header["requires"]))
      @provides = parse_tag_list(Array(@header["provides"]))

      @extends = case @header["extends"]
      when Array then Tag.new(@header["extends"][0])
      when String then Tag.new(@header["extends"])
      else nil
      end

      @replaces = case @header["replaces"]
      when Array then Tag.new(@header["replaces"][0])
      when String then Tag.new(@header["replaces"])
      else nil
      end
    end

    # @param [String] new_value file content
    # @api private
    def content=(new_value)
      @content = new_value
    end

    # @return [String] file contents, *including* extensions
    # @api semipublic
    def content
      include_extensions
      [@content, extensions.map {|e| e.content}].flatten.compact.join("\n")
    end

    # @return [String] Original file contents
    # @api semipublic
    def original_content
      @content
    end

    # @param [Enumerable] tag_list list of tags
    # @return [Array] normalized tags list
    # @api private
    def parse_tag_list(tag_list)
      tag_list.map do |tag_name|
        case tag_name
        when String
          Tag.new(tag_name, :package => package)
        when Hash
          tags = []
          tag_name.each do |pkg_name, sources|
            normalized_package_name = pkg_name.sub(/(.+)\/.*$/, "\\1")
            Array(sources).each do |source|
              tags << Tag.new([normalized_package_name, source].join("/"))
            end
          end
          tags
        end
      end.flatten
    end # parse_tag_list

    # Assigns an instance of Jsus::Pool to the source file.
    # Also performs push to that pool.
    # @param [Jsus::Pool] new_value
    # @api private
    def pool=(new_value)
      @pool = new_value
      @pool << self if @pool
    end

    # A pool which the source file is assigned to. Used in #include_extensions!
    # @return [Jsus::Pool]
    # @api semipublic
    def pool
      @pool
    end

    # @api public
    def ==(other)
      eql?(other)
    end

    # @api public
    def eql?(other)
      other.kind_of?(SourceFile) && filename == other.filename
    end

    # @api public
    def hash
      [self.class, filename].hash
    end
  end
end
