# frozen_string_literal: true

module Bibliothecary
  class RelatedFilesInfo
    attr_reader :path, :parser, :manifests, :lockfiles

    # Create a set of RelatedFilesInfo for the provided file_infos,
    # where each RelatedFilesInfo contains all the file_infos
    def self.create_from_file_infos(file_infos)
      returns = []

      file_infos_by_directory = file_infos.group_by { |info| File.dirname(info.relative_path) }
      file_infos_by_directory.each_value do |file_infos_for_path|
        groupable, ungroupable = file_infos_for_path.partition(&:groupable?)

        # add ungroupable ones as separate RFIs
        ungroupable.each do |file_info|
          returns.append(RelatedFilesInfo.new([file_info]))
        end

        file_infos_by_directory_by_parser = groupable.group_by(&:parser)

        file_infos_by_directory_by_parser.each_value do |file_infos_in_directory_for_parser|
          returns.append(RelatedFilesInfo.new(file_infos_in_directory_for_parser))
        end
      end

      returns
    end

    def initialize(file_infos)
      parser = file_infos.first.parser
      ordered_file_infos = file_infos

      if parser.respond_to?(:lockfile_preference_order)
        ordered_file_infos = parser.lockfile_preference_order(file_infos)
      end

      @parser = parser.parser_name
      @path = Pathname.new(File.dirname(file_infos.first.relative_path)).cleanpath.to_path

      @manifests = filter_file_infos_by_parser_type(
        file_infos: ordered_file_infos,
        parser: parser,
        type: "manifest"
      )

      @lockfiles = filter_file_infos_by_parser_type(
        file_infos: ordered_file_infos,
        parser: parser,
        type: "lockfile"
      )
    end

    private

    def platform
      raise "Bibliothecary::RelatedFileInfo#platform() has been removed in bibliothecary 15.0.0. Use parser() instead, which now includes MultiParsers."
    end

    def filter_file_infos_by_parser_type(file_infos:, parser:, type:)
      # `parser.determine_kind_from_info(info)` can be an Array, so use include? which also works for string
      file_infos.select { |info| parser.determine_kind_from_info(info).include?(type) }.map(&:relative_path)
    end
  end
end
