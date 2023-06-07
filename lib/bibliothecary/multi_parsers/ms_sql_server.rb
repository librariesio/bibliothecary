module Bibliothecary
  module MultiParsers
    module MsSqlServer
      def identify_ms_sql_server_version(dsp)
        version_number = dsp.match(/\d+/)&.[](0)
        return nil unless version_number

        case version_number.length
        when 3
          version_number.insert(-2, '.')
        when 2
          version_number.insert(1, '.') unless version_number.start_with?("1")
        end

        version_number += '.0' unless version_number.end_with?('.0')
        version_number
      rescue
        nil
      end
    end
  end
end
