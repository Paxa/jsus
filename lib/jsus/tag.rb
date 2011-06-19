module Jsus
  #
  # Tag is basically just a string that contains a package name and a name for class
  # (or not necessarily a class) which the given SourceFile provides/requires/extends/replaces.
  #
  # @example
  # "Core/Class" is a tag
  class Tag
    # Owner package
    attr_accessor :package
    # Whether tag is external
    attr_accessor :external

    # Constructors

    #
    # Creates a tag from given name/options.
    #
    # The way it works may seem a bit tricky but actually it parses name/options
    # combinations in different ways and may be best described by examples:
    #
    # @example
    #
    #     a = Tag.new("Class")      # :package_name => "",     :name => "Class", :external => false
    #     b = Tag.new("Core/Class") # :package_name => "Core", :name => "Class", :external => true
    #     core = Package.new(...) # let's consider its name is 'Core'
    #     c = Tag.new("Class", :package => core) # :package_name => "Core", :name => "Class", :external => false
    #     d = Tag.new("Core/Class", :package => core) # :package_name => "Core", :name => "Class", :external => false
    #     mash = Package.new(...) # let's consider its name is 'Mash'
    #     e = Tag.new("Core/Class", :package => mash) # :package_name => "Core", :name => "Class", :external => true
    #
    # Between all those, tags b,c,d and e are equal, meaning they all use
    # the same spot in Hash or wherever else.
    #
    # @param [String] tag name
    # @param [Hash] options
    # @option options [String] :package_name owner package name
    # @option options [Jsus::Package] :package :owner package
    # @option options [Boolean] :external whether tag is considered external
    # @api public
    def initialize(name, options = {})
      normalized_options = Tag.normalize_name_and_options(name, options)
      [:name, :package, :package_name, :external].each do |field|
        self.send("#{field}=", normalized_options[field])
      end
    end

    # When given a tag instead of tag name, just returns it.
    # @api public
    def self.new(tag_or_name, *args, &block)
      if tag_or_name.kind_of?(Tag)
        tag_or_name
      else
        super
      end
    end

    # Alias for Tag.new
    # @api public
    def self.[](*args)
      new(*args)
    end

    # Public API

    # @returns [Boolean] whether tag is external
    # @api public
    def external?
      !!external
    end

    # @param [Hash] options
    # @option options [Boolean] :short whether the tag should try using short form
    # @note only non-external tags support short forms.
    # @example
    #     Tag.new('Core/Class').name(:short => true) # => 'Core/Class'
    #     core = Package.new(...) # let's consider its name is 'Core'
    #     Tag.new('Core/Class', :package => core).name(:short => true) # => 'Class'
    # @return [String] a well-formed name for the tag.
    # @api public
    def name(options = {})
      if !package_name || package_name.empty? || (options[:short] && !external?)
        @name
      else
        "#{package_name}/#{@name}"
      end
    end
    alias_method :to_s, :name

    # @returns [String] package name or an empty string
    # @api public
    def package_name
      @package_name ||= (@package ? @package.name : "")
    end

    # @return [Boolean] whether name is empty
    # @api public
    def empty?
      @name.empty?
    end

    # @api public
    def ==(other)
      if other.kind_of?(Tag)
        self.name == other.name
      else
        super
      end
    end

    # @api semipublic
    def eql?(other)
      self.==(other)
    end

    # @api semipublic
    def hash
      self.name.hash
    end

    # @return [String] human-readable representation
    # @api public
    def inspect
      "<Jsus::Tag: #{name}>"
    end

    # Private API

    # @api private
    def self.normalize_name_and_options(name, options = {})
      result = {}
      name.gsub!(%r(^(\.)?/), "")
      if name.index("/")
        parsed_name = name.split("/")
        result[:package_name], result[:name] = parsed_name[0..-2].join("/"), parsed_name[-1]
        result[:external] = options[:package] ? (result[:package_name] != options[:package].name) : true
      else
        if options[:package]
          result[:package] = options[:package]
          result[:package_name] = options[:package].name
        end
        result[:name] = name
      end
      result[:package_name] = normalize_package_name(result[:package_name]) if result[:package_name]
      result
    end

    # @api private
    def self.normalized_options_to_full_name(options)
      [options[:package_name], options[:name]].compact.join("/")
    end

    # @api private
    def self.name_and_options_to_full_name(name, options = {})
      normalized_options_to_full_name(normalize_name_and_options(name, options))
    end

    # @api private
    def self.normalize_package_name(name)
      package_chunks = name.split("/")
      package_chunks.map do |pc|
        Jsus::Util::Inflection.random_case_to_mixed_case(pc)
      end.join("/")
    end # normalize_name

    # @api private
    def package_name=(new_value)
      @package_name = new_value
    end

    # @api private
    def name=(new_value)
      @name = new_value
    end
  end
end
