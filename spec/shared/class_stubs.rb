# Stubs for classes that mimic jsus classes without being actually them


class Source
  attr_accessor :provides
  attr_accessor :dependencies
  attr_accessor :content

  def initialize(options = {})
    options.each do |attr, value|
      send("#{attr}=", value)
    end
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

