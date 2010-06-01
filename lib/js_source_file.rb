require 'yaml'

class JsSourceFile

  attr_accessor :header
  attr_accessor :filename
  # constructors

  def self.from_file(filename)    
    if File.exists?(filename)
      source = File.read(filename) # TODO: read only first several lines of file      
      yaml_data = source.match(%r(^/\*\s*(---.*?)\*/)m)
      if (yaml_data && yaml_data[1] && header = YAML.load(yaml_data[1]))
        result = new
        result.header = header
        result.filename = File.expand_path(filename)
        result
      else
        # puts "WARNING: file #{filename} has invalid format (should be YAML)"
        nil
      end
    else
      # puts "WARNING: file #{filename} does not exist"
      nil
    end
  end

  # Public API
  def dependencies
    header["requires"] ||= []
  end

  def provides
    header["provides"] ||= []
  end

  def description
    header["description"] ||= ""
  end

end