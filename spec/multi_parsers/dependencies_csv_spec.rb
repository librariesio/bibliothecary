describe Bibliothecary::MultiParsers::DependenciesCSV, :focus do
  let!(:parser_class) do
    k = Class.new do
      def platform_name; "whatever"; end
    end

    k.send(:include, described_class)
    k
  end

  let(:parser) { parser_class.new }
  let(:options) do
    { cache: {}, filename: "dependencies.csv" }
  end

  context 'with missing headers' do
    let!(:csv) do
      <<-CSV
cat,dog,requirement
meow,woof,>= 2.2.0
      CSV
    end

    it 'raises an error' do
      expect { parser.parse_dependencies_csv(csv, options: options) }.to raise_error(/Missing required headers platform, name/)
    end
  end

  context 'missing field' do
    let!(:csv) do
      <<-CSV
platform,name,requirement
meow,wow,>= 2.2.0
,wow,>= 2.2.0
      CSV
    end

    it 'raises an error' do
      expect { parser.parse_dependencies_csv(csv, options: options) }.to raise_error(/Missing required field 'platform' on line 3/)
    end
  end

  context 'all data ok' do
    let!(:csv) do
      <<-CSV
platform,name,requirement,type
meow,wow,>= 2.2.0,bird
hiss,wow,>= 2.2.0,
hiss,raow,>= 2.2.1,bird
      CSV
    end

    it 'parses, filters, and caches' do
      allow(parser).to receive(:platform_name).and_return("hiss")

      result = parser.parse_dependencies_csv(csv, options: options)

      expect(result).to eq([
        { platform: "hiss", name: "wow", requirement: ">= 2.2.0", type: "runtime" },
        { platform: "hiss", name: "raow", requirement: ">= 2.2.1", type: "bird" }
      ])

      # the cache should contain a CSVFile
      expect(options[:cache][options[:filename]].result.length).to eq(3)
    end
  end

  context 'each parser implements it' do
    # since extending a parser (as of 2022-05-02) required the correct
    # timing on when it's extended in the parser, we verify manually here that
    # every parser that should have DependenciesCSV (all of them) has it.

    Bibliothecary::Parsers.constants.each do |constant_symbol|
      constant = Bibliothecary::Parsers.const_get(constant_symbol)

      # only analyzers have platform_name on the class
      if constant.respond_to?(:platform_name)
        it "#{constant_symbol} should implement DependenciesCSV" do
          expect(constant.respond_to?(:parse_dependencies_csv)).to eq(true)
        end
      end
    end
  end
end
