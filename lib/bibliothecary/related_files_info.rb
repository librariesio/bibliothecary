module Bibliothecary
  class RelatedFilesInfo
    attr_reader :path
    attr_reader :platform
    attr_reader :manifests
    attr_reader :lockfiles

    def self.create_from_file_infos(file_infos)
      returns = []
      paths = file_infos.group_by { |info| File.dirname(info.relative_path) }
      paths.values.each do |path|
        same_pm = path.group_by { |info| info.package_manager}
        same_pm.values.each do |value|
          returns.append(RelatedFilesInfo.new(value))
        end
      end
      returns
    end

    def initialize(file_infos)
      package_manager = file_infos.first.package_manager
      @platform = package_manager.platform_name
      @path = Pathname.new(File.dirname(file_infos.first.relative_path)).cleanpath.to_path
      @manifests = RelatedFilesInfo.get_kind(package_manager, file_infos, "manifest")
      @lockfiles = RelatedFilesInfo.get_kind(package_manager, file_infos, "lockfile")
    end

    def self.get_kind(package_manager, file_infos, kind)
      matched_kinds = file_infos.select do |info|
        determined = package_manager.determine_kind_from_info(info)
        # if the determined is an array, check if it includes a string of the kind, otherwise just check equality
        if determined.is_a?(Array)
          determined.map(&:to_s).include?(kind)
        else
          determined == kind
        end
      end

      matched_kinds.map { |info| File.basename(info.relative_path) }
    end
  end
end
