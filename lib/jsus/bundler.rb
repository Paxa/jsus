module Jsus
  class Bundler
    include Topsortable

    attr_accessor :required_files

    def initialize(directory)
      Dir[File.join(directory, "**", "package.yml")].each do |package_name|
        path = Pathname.new(package_name)
        Dir.chdir path.parent.parent.to_s do
          package = Package.new(path.parent.relative_path_from(path.parent.parent).to_s)
          self.packages << package
        end
      end
      calculate_requirement_order
    end

    def packages
      @packages ||= []
    end

    def packages=(new_value)
      @packages = new_value.compact
    end

    def compile(directory)
      FileUtils.mkdir_p(directory)
      Dir.chdir directory do
        packages.each do |package|
          output_dir = package.relative_directory
          package.compile(output_dir)
          package.generate_tree(output_dir)
          package.generate_scripts_info(output_dir)
        end
      end
    end


    protected
    def calculate_requirement_order
      @packages = topsort(:packages)
      @required_files = @packages.map {|p| p.required_files }.flatten
    end
  end
end