# Stubs for classes that mimic jsus classes without being actually them


class Source
  attr_accessor :provides
  attr_accessor :dependencies
  attr_accessor :content
  attr_accessor :filename
  attr_accessor :replaces
  def initialize(options = {})
    options.each do |attr, value|
      send("#{attr}=", value)
    end
  end

  def required_files
    [filename]
  end
end


class Package
  attr_accessor :name

  def initialize(options = {})
    options.each do |attr, value|
      send("#{attr}=", value)
    end
  end
end

