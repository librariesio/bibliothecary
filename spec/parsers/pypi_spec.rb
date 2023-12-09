require 'spec_helper'

describe Bibliothecary::Parsers::Pypi do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('pypi')
  end

  it 'parses dependencies from setup.py' do
    expect(described_class.analyse_contents('setup.py', load_fixture('setup.py'))).to eq({
      platform: "pypi",
      path: "setup.py",
      dependencies: [
        { name: "Install", requirement: "*", type: "runtime" },
        { name: "django-bootstrap3", requirement: ">=6.2,<6.3", type: "runtime" },
        { name: "lesscpy", requirement: "*", type: "runtime" },
        { name: "unicodecsv", requirement: "==0.14.1", type: "runtime" },
        { name: "django-coffeescript", requirement: ">=0.7,<0.8", type: "runtime" },
        { name: "django-compressor", requirement: ">=1.6,<1.7", type: "runtime" },
        { name: "django-datetime-widget",
        requirement: ">=0.9,<1.0",
        type: "runtime" },
        { name: "django-filter", requirement: ">=0.11,<0.12", type: "runtime" },
        { name: "django-representatives-votes",
        requirement: ">=0.0.13",
        type: "runtime" },
        { name: "django-representatives", requirement: ">=0.0.14", type: "runtime" },
        { name: "django-taggit", requirement: ">=0.17,<0.18", type: "runtime" },
        { name: "django", requirement: ">=1.8,<1.9", type: "runtime" },
        { name: "djangorestframework",
        requirement: ">=3.2.0,<3.3.0",
        type: "runtime" },
        { name: "hamlpy", requirement: ">=0.82,<0.83", type: "runtime" },
        { name: "ijson", requirement: ">=2.2,<2.3", type: "runtime" },
        { name: "python-dateutil", requirement: ">=2.4,<2.5", type: "runtime" },
        { name: "pytz", requirement: "==2015.7", type: "runtime" },
        { name: "django-suit", requirement: "*", type: "runtime" },
        { name: "dummy", requirement: "==2.0beta1", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from requirements.txt' do
    expect(described_class.analyse_contents('requirements.txt', load_fixture('requirements.txt'))).to eq({
      platform: "pypi",
      path: "requirements.txt",
      dependencies: [
        { name: "Flask", requirement: "==0.8", type: "runtime" },
        { name: "zope.component", requirement: "==4.2.2", type: "runtime" },
        { name: "scikit-learn", requirement: "==0.16.1", type: "runtime" },
        { name: "Beaker", requirement: ">=1.6.5", type: "runtime" },
        { name: "certifi", requirement: "==0.0.8", type: "runtime" },
        { name: "chardet", requirement: "==1.0.1", type: "runtime" },
        { name: "distribute", requirement: "==0.6.24", type: "runtime" },
        { name: "gunicorn", requirement: "==0.14.2", type: "runtime" },
        { name: "requests", requirement: "==0.11.1", type: "runtime" },
        { name: "Django", requirement: "==2.0beta1", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from requirements-dev.txt' do
    expect(described_class.analyse_contents('requirements-dev.txt', load_fixture('requirements-dev.txt'))).to eq({
      platform: "pypi",
      path: "requirements-dev.txt",
      dependencies: [{ name: "astroid", requirement: "==2.9.0", type: "development" }, { name: "attrs", requirement: "==21.4.0", type: "development" }, { name: "boto3", requirement: "==1.20.26", type: "development" }, { name: "botocore", requirement: "==1.23.26", type: "development" }, { name: "certifi", requirement: "==2021.10.8", type: "development" }, { name: "charset-normalizer", requirement: "==2.0.9", type: "development" }, { name: "coverage", requirement: "==6.2", type: "development" }, { name: "doc8", requirement: "==0.10.1", type: "development" }, { name: "docutils", requirement: "==0.17.1", type: "development" }, { name: "flake8", requirement: "==4.0.1", type: "development" }, { name: "hypothesis", requirement: "==6.31.6", type: "development" }, { name: "idna", requirement: "==3.3", type: "development" }, { name: "importlib-metadata", requirement: "==4.2.0", type: "development" }, { name: "iniconfig", requirement: "==1.1.1", type: "development" }, { name: "isort", requirement: "==5.10.1", type: "development" }, { name: "jmespath", requirement: "==0.10.0", type: "development" }, { name: "lazy-object-proxy", requirement: "==1.7.1", type: "development" }, { name: "mccabe", requirement: "==0.6.1", type: "development" }, { name: "mock", requirement: "==4.0.3", type: "development" }, { name: "mypy", requirement: "==0.812", type: "development" }, { name: "mypy-extensions", requirement: "==0.4.3", type: "development" }, { name: "packaging", requirement: "==21.3", type: "development" }, { name: "pbr", requirement: "==5.8.0", type: "development" }, { name: "platformdirs", requirement: "==2.4.0", type: "development" }, { name: "pluggy", requirement: "==1.0.0", type: "development" }, { name: "py", requirement: "==1.11.0", type: "development" }, { name: "pycodestyle", requirement: "==2.8.0", type: "development" }, { name: "pydocstyle", requirement: "==6.1.1", type: "development" }, { name: "pyflakes", requirement: "==2.4.0", type: "development" }, { name: "pygments", requirement: "==2.11.0", type: "development" }, { name: "pylint", requirement: "==2.12.2", type: "development" }, { name: "pyparsing", requirement: "==3.0.6", type: "development" }, { name: "pytest", requirement: "==6.2.5", type: "development" }, { name: "pytest-cov", requirement: "==3.0.0", type: "development" }, { name: "python-dateutil", requirement: "==2.8.2", type: "development" }, { name: "requests", requirement: "==2.26.0", type: "development" }, { name: "restructuredtext-lint", requirement: "==1.3.2", type: "development" }, { name: "s3transfer", requirement: "==0.5.0", type: "development" }, { name: "six", requirement: "==1.16.0", type: "development" }, { name: "snowballstemmer", requirement: "==2.2.0", type: "development" }, { name: "sortedcontainers", requirement: "==2.4.0", type: "development" }, { name: "stevedore", requirement: "==3.5.0", type: "development" }, { name: "toml", requirement: "==0.10.2", type: "development" }, { name: "tomli", requirement: "==1.2.3", type: "development" }, { name: "typed-ast", requirement: "==1.4.3", type: "development" }, { name: "typing-extensions", requirement: "==4.0.1", type: "development" }, { name: "urllib3", requirement: "==1.26.7", type: "development" }, { name: "websocket-client", requirement: "==1.2.3", type: "development" }, { name: "wheel", requirement: "==0.37.1", type: "development" }, { name: "wrapt", requirement: "==1.13.3", type: "development" }, { name: "zipp", requirement: "==3.6.0", type: "development" }],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from requirements/test.txt' do
    expect(described_class.analyse_contents('requirements/test.txt', load_fixture('requirements/test.txt'))).to eq({
      platform: "pypi",
      path: "requirements/test.txt",
      dependencies: [{ name: "attrs", requirement: "==21.4.0", type: "test" }, { name: "exceptiongroup", requirement: "==1.0.0rc8", type: "test" }, { name: "execnet", requirement: "==1.9.0", type: "test" }, { name: "iniconfig", requirement: "==1.1.1", type: "test" }, { name: "packaging", requirement: "==21.3", type: "test" }, { name: "pexpect", requirement: "==4.8.0", type: "test" }, { name: "pluggy", requirement: "==1.0.0", type: "test" }, { name: "ptyprocess", requirement: "==0.7.0", type: "test" }, { name: "py", requirement: "==1.11.0", type: "test" }, { name: "pyparsing", requirement: "==3.0.9", type: "test" }, { name: "pytest", requirement: "==7.1.2", type: "test" }, { name: "pytest-forked", requirement: "==1.4.0", type: "test" }, { name: "pytest-xdist", requirement: "==2.5.0", type: "test" }, { name: "sortedcontainers", requirement: "==2.4.0", type: "test" }, { name: "tomli", requirement: "==2.0.1", type: "test" }],
      kind: 'manifest',
      success: true
    })
  end

  context 'git urls' do
    it 'parses dependencies from requirements-git.txt' do
      expect(described_class.analyse_contents('requirements-git.txt', load_fixture('requirements-git.txt'))).to eq({
        platform: "pypi",
        path: "requirements-git.txt",
        dependencies: [
          { name: "pygame", requirement: "2.1.2", type: "runtime" }
        ],
        kind: 'manifest',
        success: true
      })
    end

    it 'skips poorly-formed lines' do
      result = described_class.analyse_contents(
        'requirements.git.txt', <<-REQ
git://what@::/:/:/
        REQ
      )

      expect(result[:dependencies].count).to eq(0)
    end

    it 'parses URLs with no version' do
      result = described_class.parse_requirements_txt_url('git+http://github.com/libraries/test#egg=test')

      expect(result).to eq(
        name: "test",
        requirement: "*"
      )
    end

    it 'fails if there is no egg specified' do
      expect {
        described_class.parse_requirements_txt_url('git+http://github.com/libraries/test@2.1.3')
      }.to raise_error(described_class::NoEggSpecified)
    end
  end

  it 'parses dependencies from requirements.in' do
    expect(described_class.analyse_contents('requirements.in', load_fixture('pip-compile/requirements.in'))).to eq({
      platform: "pypi",
      path: "requirements.in",
      dependencies: [
        { name: "invoke", requirement: "*", type: "runtime" },
        { name: "black", requirement: "*", type: "runtime" },
        { name: "google-cloud-storage", requirement: "*", type: "runtime" },
        { name: "six", requirement: "*", type: "runtime" },
        { name: "progress", requirement: "*", type: "runtime" },
        { name: "questionary", requirement: "*", type: "runtime" },
        { name: "pyyaml", requirement: "*", type: "runtime" },
        { name: "semver", requirement: "*", type: "runtime" },
        { name: "Jinja2", requirement: "*", type: "runtime" },
        { name: "pip-tools", requirement: "*", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end
  it 'parses dependencies from requirements.txt as lockfile because of pip-compile' do
    expect(described_class.analyse_contents('requirements.txt', load_fixture('pip-compile/requirements.txt'))).to eq({
      platform: "pypi",
      path: "requirements.txt",
      dependencies: [
        { name: "black", requirement: "==21.9b0", type: "runtime" },
        { name: "cachetools", requirement: "==4.2.2", type: "runtime" },
        { name: "certifi", requirement: "==2021.5.30", type: "runtime" },
        { name: "charset-normalizer", requirement: "==2.0.6", type: "runtime" },
        { name: "click", requirement: "==8.0.1", type: "runtime" },
        { name: "google-api-core", requirement: "==2.0.1", type: "runtime" },
        { name: "google-auth", requirement: "==2.1.0", type: "runtime" },
        { name: "google-cloud-core", requirement: "==2.0.0", type: "runtime" },
        { name: "google-cloud-storage", requirement: "==1.42.2", type: "runtime" },
        { name: "google-crc32c", requirement: "==1.2.0", type: "runtime" },
        { name: "google-resumable-media", requirement: "==2.0.3", type: "runtime" },
        { name: "googleapis-common-protos", requirement: "==1.53.0", type: "runtime" },
        { name: "idna", requirement: "==3.2", type: "runtime" },
        { name: "invoke", requirement: "==1.6.0", type: "runtime" },
        { name: "jinja2", requirement: "==3.0.1", type: "runtime" },
        { name: "markupsafe", requirement: "==2.0.1", type: "runtime" },
        { name: "mypy-extensions", requirement: "==0.4.3", type: "runtime" },
        { name: "pathspec", requirement: "==0.9.0", type: "runtime" },
        { name: "pep517", requirement: "==0.11.0", type: "runtime" },
        { name: "pip-tools", requirement: "==6.2.0", type: "runtime" },
        { name: "platformdirs", requirement: "==2.3.0", type: "runtime" },
        { name: "progress", requirement: "==1.6", type: "runtime" },
        { name: "prompt-toolkit", requirement: "==3.0.20", type: "runtime" },
        { name: "protobuf", requirement: "==3.18.0", type: "runtime" },
        { name: "pyasn1", requirement: "==0.4.8", type: "runtime" },
        { name: "pyasn1-modules", requirement: "==0.2.8", type: "runtime" },
        { name: "pyyaml", requirement: "==5.4.1", type: "runtime" },
        { name: "questionary", requirement: "==1.10.0", type: "runtime" },
        { name: "regex", requirement: "==2021.8.28", type: "runtime" },
        { name: "requests", requirement: "==2.26.0", type: "runtime" },
        { name: "rsa", requirement: "==4.7.2", type: "runtime" },
        { name: "semver", requirement: "==2.13.0", type: "runtime" },
        { name: "six", requirement: "==1.16.0", type: "runtime" },
        { name: "tomli", requirement: "==1.2.1", type: "runtime" },
        { name: "typing-extensions", requirement: "==3.10.0.2", type: "runtime" },
        { name: "urllib3", requirement: "==1.26.6", type: "runtime" },
        { name: "wcwidth", requirement: "==0.2.5", type: "runtime" },
        { name: "wheel", requirement: "==0.37.0", type: "runtime" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from pip-resolved-dependencies.txt' do
    expect(described_class.analyse_contents('pip-resolved-dependencies.txt', load_fixture('pip-resolved-dependencies.txt'))).to eq({
      platform: "pypi",
      path: "pip-resolved-dependencies.txt",
      dependencies: [
        { name: "asgiref", requirement: "==3.2.7", type: "runtime" },
        { name: "Django", requirement: "==3.0.6", type: "runtime" },
        { name: "sqlparse", requirement: "==0.3.1", type: "runtime" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from requirements.frozen' do
    expect(described_class.analyse_contents('requirements.frozen', load_fixture('requirements.frozen'))).to eq({
      platform: "pypi",
      path: "requirements.frozen",
      dependencies: [
        { name: "asgiref", requirement: "==3.2.7", type: "runtime" },
        { name: "Django", requirement: "==3.0.6", type: "runtime" },
        { name: "sqlparse", requirement: "==0.3.1", type: "runtime" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from Pipfile' do
    expect(described_class.analyse_contents('Pipfile', load_fixture('Pipfile'))).to eq({
      platform: "pypi",
      path: "Pipfile",
      dependencies: [
        { name: "requests", requirement: "*", type: "runtime" },
        { name: "Django", requirement: ">1.10", type: "runtime" },
        { name: "pinax", requirement: "git://github.com/pinax/pinax.git#1.4", type: "runtime" },
        { name: "nose", requirement: "*", type: "develop" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Pipfile.lock' do
    expect(described_class.analyse_contents('Pipfile.lock', load_fixture('Pipfile.lock'))).to eq({
      platform: "pypi",
      path: "Pipfile.lock",
      dependencies: [
        { name: "PySocks", requirement: "==1.6.5", type: "runtime" },
        { name: "requests", requirement: "==2.13.0", type: "runtime" },
        { name: "Django", requirement: "==1.10.5", type: "runtime" },
        { name: "pinax", requirement: "git://github.com/pinax/pinax.git#1.4", type: "runtime" },
        { name: "nose", requirement: "==1.3.7", type: "develop" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it "parses dependencies from conda environment.yml.lock with pip" do
    expect(described_class.analyse_contents("conda_with_pip/environment.yml.lock", load_fixture("conda_with_pip/environment.yml"))).to eq(
      {
        platform: "pypi",
        path: "conda_with_pip/environment.yml.lock",
        dependencies: [
          { name: "urllib3", requirement: "*", type: "runtime" },
          { name: "Django", requirement: "==2.0.0", type: "runtime" }
        ],
        kind: "lockfile",
        success: true
       }
    )
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('requirements.txt')).to be_truthy
    expect(described_class.match?('requirements-dev.txt')).to be_truthy
    expect(described_class.match?('requirements/dev.txt')).to be_truthy
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
      platform: "pypi",
      path: "pyproject.toml",
      dependencies: [
        { name: "python", requirement: "^3.7", type: "runtime" },
        { name: "django", requirement: "^3.0.7", type: "runtime" },
        { name: "pytest", requirement: "^5.2", type: "development" },
        { name: "wcwidth", requirement: "*", type: "development" },
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'handles pyproject.toml with no deps' do
    source = <<~FILE
      [tool.black]
      line-length = 100
    FILE

    expect(described_class.analyse_contents('pyproject.toml', source)).to eq({
      platform: "pypi",
      path: "pyproject.toml",
      dependencies: [],
      kind: 'manifest',
      success: true
    })
  end

  # https://packaging.python.org/en/latest/specifications/declaring-project-metadata/#declaring-project-metadata
  it 'handles pyproject.toml with pep621-style deps' do
    source = <<~FILE
[project]
name = "a_pep621_project"
version = "0.1.0"
dependencies = [
    "black",
    "isort",
    "pytest == 7.2.1",
    "python-gitlab == 3.12.0",
    "Click~=8.1.0",
    "marshmallow-dataclass[union]~=8.5.6",
]
    FILE

    expect(described_class.analyse_contents('pyproject.toml', source)).to eq({
      platform: "pypi",
      path: "pyproject.toml",
      dependencies: [
        {name: "black", requirement: "*", type: "runtime"}, 
        {name: "isort", requirement: "*", type: "runtime"}, 
        {name: "pytest", requirement: "== 7.2.1", type: "runtime"}, 
        {name: "python-gitlab", requirement: "== 3.12.0", type: "runtime"},
        {name: "Click", requirement: "~=8.1.0", type: "runtime"},
        {name: "marshmallow-dataclass", requirement: "[union]~=8.5.6", type: "runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from Poetry.lock' do
    expect(described_class.analyse_contents('poetry.lock', load_fixture('poetry.lock'))).to eq({
      platform: "pypi",
      path: "poetry.lock",
      dependencies: [
        { name: "asgiref", requirement: "3.2.10", type: "runtime" },
        { name: "atomicwrites", requirement: "1.4.0", type: "develop" },
        { name: "attrs", requirement: "19.3.0", type: "develop" },
        { name: "colorama", requirement: "0.4.3", type: "develop" },
        { name: "django", requirement: "3.0.7", type: "runtime" },
        { name: "importlib-metadata", requirement: "1.7.0", type: "develop" },
        { name: "more-itertools", requirement: "8.4.0", type: "develop" },
        { name: "packaging", requirement: "20.4", type: "develop" },
        { name: "pluggy", requirement: "0.13.1", type: "develop" },
        { name: "py", requirement: "1.9.0", type: "develop" },
        { name: "pyparsing", requirement: "2.4.7", type: "develop" },
        { name: "pytest", requirement: "5.4.3", type: "develop" },
        { name: "pytz", requirement: "2020.1", type: "runtime" },
        { name: "six", requirement: "1.15.0", type: "develop" },
        { name: "sqlparse", requirement: "0.3.1", type: "runtime" },
        { name: "wcwidth", requirement: "0.2.5", type: "develop" },
        { name: "zipp", requirement: "3.1.0", type: "develop" }
      ],
      kind: 'lockfile',
      success: true
    })
  end
end
