module Jsus
  class Tag
    attr_accessor :package, :type, :external

    # initialization

    def initialize(name, options = {})
      normalized_options = Tag.normalize_name_and_options(name, options)
      [:name, :package, :package_name, :external].each do |field|
        self.send("#{field}=", normalized_options[field])
      end
    end

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
      result
    end

    def self.normalized_options_to_full_name(options)
      [options[:package_name], options[:name]].compact.join("/")
    end

    def self.name_and_options_to_full_name(name, options = {})
      normalized_options_to_full_name(normalize_name_and_options(name, options))
    end

    def self.[](*args)
      new(*args)
    end

    # Public API

    def external?
      !!external
    end

    def name(options = {})
      if !package_name || package_name.empty? || (options[:short] && !external?)
        @name
      else
        "#{package_name}/#{@name}"
      end
    end
    alias_method :to_s, :name


    def name=(new_value)
      @name = new_value
    end

    def package_name
      @package_name ||= (@package ? @package.name : "")
    end

    def package_name=(new_value)
      @package_name = new_value
    end

    def ==(other)
      if other.kind_of?(Tag)
        self.name == other.name
      else
        super
      end
    end

    def eql?(other)
      self.==(other)
    end

    def hash
      self.name.hash
    end


    def inspect
      "<Jsus::Tag: #{name}>"
    end
  end
end