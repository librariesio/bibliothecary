module Bibliothecary
  class RelatedFilesInfo
    attr_reader :path
    attr_reader :platform
    attr_reader :manifests
    attr_reader :lockfiles

    # Create a set of RelatedFilesInfo for the provided file_infos,
    # where each RelatedFilesInfo contains all the file_infos 
    def self.create_from_file_infos(file_infos)
      returns = []

      file_infos_by_directory = file_infos.group_by { |info| File.dirname(info.relative_path) }
      file_infos_by_directory.values.each do |file_infos_for_path|
        groupable, ungroupable = file_infos_for_path.partition(&:groupable?)

        # add ungroupable ones as separate RFIs
        ungroupable.each do |file_info|
          returns.append(RelatedFilesInfo.new([file_info]))
        end

        file_infos_by_directory_by_package_manager = groupable.group_by { |info| info.package_manager}

        file_infos_by_directory_by_package_manager.values.each do |file_infos_in_directory_for_package_manager|
          returns.append(RelatedFilesInfo.new(file_infos_in_directory_for_package_manager))
        end
      end

      returns
    end

    def initialize(file_infos)
      package_manager = file_infos.first.package_manager
      ordered_file_infos = file_infos

      if package_manager.respond_to?(:lockfile_preference_order)
        ordered_file_infos = package_manager.lockfile_preference_order(file_infos)
      end

      @platform = package_manager.platform_name
      @path = Pathname.new(File.dirname(file_infos.first.relative_path)).cleanpath.to_path

      @manifests = filter_file_infos_by_package_manager_type(
        file_infos: ordered_file_infos,
        package_manager: package_manager,
        type: "manifest"
      )

      @lockfiles = filter_file_infos_by_package_manager_type(
        file_infos: ordered_file_infos,
        package_manager: package_manager,
        type: "lockfile"
      )
    end

    private

    def filter_file_infos_by_package_manager_type(file_infos:, package_manager:, type:)
      # `package_manager.determine_kind_from_info(info)` can be an Array, so use include? which also works for string
      file_infos.select { |info| package_manager.determine_kind_from_info(info).include?(type) }.map(&:relative_path)
    end
  end
end
