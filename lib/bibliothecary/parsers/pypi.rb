module Bibliothecary
  module Parsers
    class Pypi
      PLATFORM_NAME = 'pypi'
      INSTALL_REGEXP = /install_requires\s*=\s*\[([\s\S]*?)\]/
      REQUIRE_REGEXP = /([a-zA-Z0-9]+[a-zA-Z0-9\-_\.]+)([><=\d\.,]+)?/
      REQUIREMENTS_REGEXP = /^#{REQUIRE_REGEXP}/

      def self.parse(filename, file_contents)
        is_valid_requirements_file = is_requirements_file(filename)
        if is_valid_requirements_file
          parse_requirements_txt(file_contents)
        elsif filename.match(/setup\.py$/)
          parse_setup_py(file_contents)
        else
          []
        end
      end

      def self.analyse(folder_path, file_list)
        [analyse_requirements_txt(folder_path, file_list),
        analyse_setup_py(folder_path, file_list)].flatten
      end

      def self.analyse_requirements_txt(folder_path, file_list)
        paths = file_list.select do |path|
          p = path.gsub(folder_path, '').gsub(/^\//, '')
          p.match(/require.*\.(txt|pip)$/) && !path.match(/^node_modules/)
        end
        return unless paths.any?

        paths.map do |path|
          manifest = File.open(path).read

          {
            platform: PLATFORM_NAME,
            path: path,
            dependencies: parse_requirements_txt(manifest)
          }
        end
      rescue
        []
      end

      def self.analyse_setup_py(folder_path, file_list)
        paths = file_list.select{|path| path.gsub(folder_path, '').gsub(/^\//, '').match(/setup\.py$/) }
        return unless paths.any?

        paths.map do |path|
          manifest = File.open(path).read

          {
            platform: PLATFORM_NAME,
            path: path,
            dependencies: parse_setup_py(manifest)
          }
        end
      rescue
        []
      end

      def self.parse_setup_py(manifest)
        match = manifest.match(INSTALL_REGEXP)
        return [] unless match
        deps = []
        match[1].gsub(/',(\s)?'/, "\n").split("\n").each do |line|
          next if line.match(/^#/)
          match = line.match(REQUIRE_REGEXP)
          next unless match
          deps << {
            name: match[1],
            requirement: match[2] || '*',
            type: 'runtime'
          }
        end
        deps
      end

      def self.parse_requirements_txt(manifest)
        deps = []
        manifest.split("\n").each do |line|
          match = line.match(REQUIREMENTS_REGEXP)
          next unless match
          deps << {
            name: match[1],
            requirement: match[2] || '*',
            type: 'runtime'
          }
        end
        deps
      end

      def self.is_requirements_file(filename)
        is_requirements_file = filename.match(/require.*\.(txt|pip)$/)
        if filename.match(/require.*\.(txt|pip)$/) and !filename.match(/^node_modules/)
          return true
        else
          return false
        end
      end
    end
  end
end
