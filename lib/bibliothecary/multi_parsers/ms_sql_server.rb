module Bibliothecary
  module MultiParsers
    module MsSqlServer
      def identify_ms_sql_server_version(dsp)
        number_part = dsp.match(/Sql(\d+)DatabaseSchemaProvider/)
        return nil unless number_part

        version_number = number_part[1].insert(-2, '.')
        version_number
      rescue
        nil
      end
    end
  end
end
