module Bibliothecary
  class RelatedFilesInfo
    attr_reader :folder_path
    attr_reader :relative_folder_path
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
      @folder_path = File.join(file_infos.first.folder_path, File.dirname(file_infos.first.relative_path))
      @relative_folder_path = File.dirname(file_infos.first.relative_path)
      @manifests = file_infos.select { |info| package_manager.determine_kind_from_info(info) == "manifest" }.map { |info| File.basename(info.relative_path) }
      @lockfiles = file_infos.select { |info| package_manager.determine_kind_from_info(info) == "lockfile" }.map { |info| File.basename(info.relative_path) }
    end
  end
end
