require 'spec_helper'

describe Bibliothecary::Parsers::Pypi do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('pypi')
  end

  it 'parses dependencies from setup.py' do
    expect(described_class.analyse_contents('setup.py', load_fixture('setup.py'))).to eq({
      :platform=>"pypi",
      :path=>"setup.py",
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
        {:name=>"django-suit", :requirement=>"*", :type=>"runtime"},
        {:name=>"dummy", :requirement=>"==2.0beta1", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from requirements.txt' do
    expect(described_class.analyse_contents('requirements.txt', load_fixture('requirements.txt'))).to eq({
      :platform=>"pypi",
      :path=>"requirements.txt",
      :dependencies=>[
        {:name=>"Flask", :requirement=>"==0.8", :type=>"runtime"},
        {:name=>"zope.component", :requirement=>"==4.2.2", :type=>"runtime"},
        {:name=>"scikit-learn", :requirement=>"==0.16.1", :type=>"runtime"},
        {:name=>"Beaker", :requirement=>">=1.6.5", :type=>"runtime"},
        {:name=>"certifi", :requirement=>"==0.0.8", :type=>"runtime"},
        {:name=>"chardet", :requirement=>"==1.0.1", :type=>"runtime"},
        {:name=>"distribute", :requirement=>"==0.6.24", :type=>"runtime"},
        {:name=>"gunicorn", :requirement=>"==0.14.2", :type=>"runtime"},
        {:name=>"requests", :requirement=>"==0.11.1", :type=>"runtime"},
        {:name=>"Django", :requirement=>"==2.0beta1", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from pip-resolved-dependencies.txt' do
    expect(described_class.analyse_contents('pip-resolved-dependencies.txt', load_fixture('pip-resolved-dependencies.txt'))).to eq({
      :platform=>"pypi",
      :path=>"pip-resolved-dependencies.txt",
      :dependencies=>[
        {:name=>"asgiref", :requirement=>"==3.2.7", :type=>"runtime"},
        {:name=>"Django", :requirement=>"==3.0.6", :type=>"runtime"},
        {:name=>"sqlparse", :requirement=>"==0.3.1", :type=>"runtime"}
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from Pipfile' do
    expect(described_class.analyse_contents('Pipfile', load_fixture('Pipfile'))).to eq({
      :platform=>"pypi",
      :path=>"Pipfile",
      :dependencies=>[
        {:name=>"requests", :requirement=>"*", :type=>"runtime"},
        {:name=>"Django", :requirement=>">1.10", :type=>"runtime"},
        {:name=>"pinax", :requirement=>"git://github.com/pinax/pinax.git#1.4", :type=>"runtime"},
        {:name=>"nose", :requirement=>"*", :type=>"develop"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Pipfile.lock' do
    expect(described_class.analyse_contents('Pipfile.lock', load_fixture('Pipfile.lock'))).to eq({
      :platform=>"pypi",
      :path=>"Pipfile.lock",
      :dependencies=>[
        {:name=>"PySocks", :requirement=>"==1.6.5", :type=>"runtime"},
        {:name=>"requests", :requirement=>"==2.13.0", :type=>"runtime"},
        {:name=>"Django", :requirement=>"==1.10.5", :type=>"runtime"},
        {:name=>"pinax", :requirement=>"git://github.com/pinax/pinax.git#1.4", :type=>"runtime"},
        {:name=>"nose", :requirement=>"==1.3.7", :type=>"develop"}
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('requirements.txt')).to be_truthy
    expect(described_class.match?('requirements.pip')).to be_truthy
    expect(described_class.match?('setup.py')).to be_truthy
    expect(described_class.match?('Pipfile')).to be_truthy
    expect(described_class.match?('Pipfile.lock')).to be_truthy
    expect(described_class.match?('python/pip-requirements.txt')).to be_truthy
  end

  it 'fails to match invalid manifest filepaths' do
    expect(described_class.match?('some-random-file.txt')).to be_falsey
    expect(described_class.match?('require/some/other/folder/myhomework.txt')).to be_falsey
  end

  it 'parses dependencies from pyproject.toml' do
    expect(described_class.analyse_contents('pyproject.toml', load_fixture('pyproject.toml'))).to eq({
      :platform=>"pypi",
      :path=>"pyproject.toml",
      :dependencies=>[
        {:name=>"python", :requirement=>"^3.7", :type=>"runtime"},
        {:name=>"django", :requirement=>"^3.0.7", :type=>"runtime"},
        {:name=>"pytest", :requirement=>"^5.2", :type=>"develop"},
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Pipfile.lock' do
    expect(described_class.analyse_contents('poetry.lock', load_fixture('poetry.lock'))).to eq({
      :platform=>"pypi",
      :path=>"poetry.lock",
      :dependencies=>[
        {:name=>"asgiref", :requirement=>"3.2.10", :type=>"runtime"},
        {:name=>"atomicwrites", :requirement=>"1.4.0", :type=>"develop"},
        {:name=>"attrs", :requirement=>"19.3.0", :type=>"develop"},
        {:name=>"colorama", :requirement=>"0.4.3", :type=>"develop"},
        {:name=>"django", :requirement=>"3.0.7", :type=>"runtime"},
        {:name=>"importlib-metadata", :requirement=>"1.7.0", :type=>"develop"},
        {:name=>"more-itertools", :requirement=>"8.4.0", :type=>"develop"},
        {:name=>"packaging", :requirement=>"20.4", :type=>"develop"},
        {:name=>"pluggy", :requirement=>"0.13.1", :type=>"develop"},
        {:name=>"py", :requirement=>"1.9.0", :type=>"develop"},
        {:name=>"pyparsing", :requirement=>"2.4.7", :type=>"develop"},
        {:name=>"pytest", :requirement=>"5.4.3", :type=>"develop"},
        {:name=>"pytz", :requirement=>"2020.1", :type=>"runtime"},
        {:name=>"six", :requirement=>"1.15.0", :type=>"develop"},
        {:name=>"sqlparse", :requirement=>"0.3.1", :type=>"runtime"},
        {:name=>"wcwidth", :requirement=>"0.2.5", :type=>"develop"},
        {:name=>"zipp", :requirement=>"3.1.0", :type=>"develop"}
      ],
      kind: 'lockfile',
      success: true
    })
  end
end
