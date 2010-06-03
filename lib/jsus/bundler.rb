module Jsus
  class Bundler
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


    attr_writer :packages
    def packages
      @packages ||= []
    end

    attr_accessor :required_files

    def compile(directory)
      FileUtils.mkdir_p(directory)
      Dir.chdir directory do
        packages.each do |package|
          package.compile(package.relative_directory)
          package.generate_tree(package.relative_directory)
        end
      end
    end


    protected
    def calculate_requirement_order
      @packages = Jsus.topsort(packages)
      @required_files = @packages.map {|p| p.required_files }.flatten
    end
  end
end