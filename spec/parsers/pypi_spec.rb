require 'spec_helper'

describe Bibliothecary::Parsers::Pypi do
  it 'has a platform name' do
    expect(Bibliothecary::Parsers::Pypi::platform_name).to eq('pypi')
  end

  it 'parses dependencies from setup.py' do
    expect(Bibliothecary::Parsers::Pypi.analyse_file('setup.py', fixture_path('setup.py'))).to eq({
      :platform=>"pypi",
      :path=>"spec/fixtures/setup.py",
      :dependencies=>[
        {:name=>"Install", :requirement=>"*", :type=>"runtime"},
        {:name=>"django-bootstrap3", :requirement=>">=6.2,<6.3", :type=>"runtime"},
        {:name=>"lesscpy", :requirement=>"*", :type=>"runtime"},
        {:name=>"unicodecsv", :requirement=>"==0.14.1", :type=>"runtime"},
        {:name=>"django-coffeescript", :requirement=>">=0.7,<0.8", :type=>"runtime"},
        {:name=>"django-compressor", :requirement=>">=1.6,<1.7", :type=>"runtime"},
        {:name=>"django-datetime-widget",
        :requirement=>">=0.9,<1.0",
        :type=>"runtime"},
        {:name=>"django-filter", :requirement=>">=0.11,<0.12", :type=>"runtime"},
        {:name=>"django-representatives-votes",
        :requirement=>">=0.0.13",
        :type=>"runtime"},
        {:name=>"django-representatives", :requirement=>">=0.0.14", :type=>"runtime"},
        {:name=>"django-taggit", :requirement=>">=0.17,<0.18", :type=>"runtime"},
        {:name=>"django", :requirement=>">=1.8,<1.9", :type=>"runtime"},
        {:name=>"djangorestframework",
        :requirement=>">=3.2.0,<3.3.0",
        :type=>"runtime"},
        {:name=>"hamlpy", :requirement=>">=0.82,<0.83", :type=>"runtime"},
        {:name=>"ijson", :requirement=>">=2.2,<2.3", :type=>"runtime"},
        {:name=>"python-dateutil", :requirement=>">=2.4,<2.5", :type=>"runtime"},
        {:name=>"pytz", :requirement=>"==2015.7", :type=>"runtime"},
        {:name=>"django-suit", :requirement=>"*", :type=>"runtime"}
      ]
    })
  end

  it 'parses dependencies from requirements.txt' do
    expect(Bibliothecary::Parsers::Pypi.analyse_file('requirements.txt', fixture_path('requirements.txt'))).to eq({
      :platform=>"pypi",
      :path=>"spec/fixtures/requirements.txt",
      :dependencies=>[
        {:name=>"Flask", :requirement=>"==0.8", :type=>"runtime"},
        {:name=>"zope.component", :requirement=>"==4.2.2", :type=>"runtime"},
        {:name=>"scikit-learn", :requirement=>"==0.16.1", :type=>"runtime"},
        {:name=>"Beaker", :requirement=>">=1.6.5", :type=>"runtime"},
        {:name=>"certifi", :requirement=>"==0.0.8", :type=>"runtime"},
        {:name=>"chardet", :requirement=>"==1.0.1", :type=>"runtime"},
        {:name=>"distribute", :requirement=>"==0.6.24", :type=>"runtime"},
        {:name=>"gunicorn", :requirement=>"==0.14.2", :type=>"runtime"},
        {:name=>"requests", :requirement=>"==0.11.1", :type=>"runtime"}
      ]
    })
  end

  it 'correctly detected different requirements.txt file names' do
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('requirements.txt')).to be true
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('requirements.pip')).to be true
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('requirements-test.txt')).to be true
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('requirements-test.pip')).to be true
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('test-requirements.txt')).to be true
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('test-requirements.pip')).to be true
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('test-invalid.pip')).to be false
      expect(Bibliothecary::Parsers::Pypi.is_requirements_file('some-random-file.txt')).to be false
  end
end
