module Jsus
  #
  # Tag is basically just a string that contains a package name and a name for class
  # (or not necessarily a class) which the given SourceFile provides/requires/extends/replaces.
  #  
  class Tag
    attr_accessor :package, :external # :nodoc:

    # Constructors
    
    #
    # Creates a tag from given name/options.
    # 
    # The way it works may seem a bit tricky but actually it parses name/options
    # combinations in different ways and may be best described by examples:
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
    # the same spot in Hash or whatever else.
    #
    def initialize(name, options = {})
      normalized_options = Tag.normalize_name_and_options(name, options)
      [:name, :package, :package_name, :external].each do |field|
        self.send("#{field}=", normalized_options[field])
      end
    end

    def self.new(tag_or_name, *args, &block) # :nodoc:
      if tag_or_name.kind_of?(Tag)
        tag_or_name
      else
        super
      end
    end

    # alias for Tag.new
    def self.[](*args)
      new(*args)
    end

    # Public API

    #
    # Returns true if tag is external. See initialization for more info on cases.
    #
    def external?
      !!external
    end

    #
    # Returns a well-formed name for the tag.
    # Options:
    # * +:short:+ -- whether the tag should try using short form
    #
    # Important note: only non-external tags support short forms.
    # 
    #    Tag.new('Core/Class').name(:short => true) # => 'Core/Class'
    #    core = Package.new(...) # let's consider its name is 'Core'
    #    Tag.new('Core/Class', :package => core).name(:short => true) # => 'Class'
    def name(options = {})
      if !package_name || package_name.empty? || (options[:short] && !external?)
        @name
      else
        "#{package_name}/#{@name}"
      end
    end
    alias_method :to_s, :name

    # Returns its package name or an empty string
    def package_name
      @package_name ||= (@package ? @package.name : "")
    end

    # Returns true if its name is empty
    def empty?
      @name.empty?
    end

    # Returns true if it has the same name as other tag
    def ==(other)
      if other.kind_of?(Tag)
        self.name == other.name
      else
        super
      end
    end
    
    # Private API
    
    def self.normalize_name_and_options(name, options = {}) # :nodoc:
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
      result
    end

    def self.normalized_options_to_full_name(options) # :nodoc:
      [options[:package_name], options[:name]].compact.join("/")
    end

    def self.name_and_options_to_full_name(name, options = {}) # :nodoc:
      normalized_options_to_full_name(normalize_name_and_options(name, options))
    end
        
    def package_name=(new_value) # :nodoc:
      @package_name = new_value
    end

    def name=(new_value) # :nodoc:
      @name = new_value
    end

    def eql?(other) # :nodoc:
      self.==(other)
    end

    def hash # :nodoc:
      self.name.hash
    end

    def inspect # :nodoc
      "<Jsus::Tag: #{name}>"
    end    
  end
end