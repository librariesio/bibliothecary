require 'spec_helper'

describe Bibliothecary::MultiParsers::BundlerLikeManifest do
	describe '#extract_gems_by_pattern' do
    let(:gemfile_content) do
      <<-GEMFILE
        gem 'oj'

        gem 'rails', '4.2.0'
        gem 'redis', require: %w[redis redis/connection/hiredis]

        gem 'leveldb-ruby','0.15', require: 'leveldb'
      GEMFILE
    end


    context 'when the pattern matches gems with require option' do
      it 'extracts gems with the specified pattern' do
        pattern = /gem\s+['"]([^'"]+)['"],\s*require:\s*%w\[([^\]]+)\]/

        extracted_gems = Bibliothecary::Parsers::Rubygems.extract_gems_by_pattern(pattern, gemfile_content)

        expect(extracted_gems).to contain_exactly(
          { name: 'redis', type: :runtime }
        )
      end
    end

    context 'when the pattern does not match any gems' do
      it 'returns an empty array' do
        pattern = /invalid_pattern/

        extracted_gems = Bibliothecary::Parsers::Rubygems.extract_gems_by_pattern(pattern, gemfile_content)

        expect(extracted_gems).to be_empty
      end
    end
 end
end
