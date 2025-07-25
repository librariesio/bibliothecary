# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Pypi do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("pypi")
  end

  it "parses dependencies from setup.py" do
    expect(described_class.analyse_contents("setup.py", load_fixture("setup.py"))).to eq({
                                                                                           platform: "pypi",
                                                                                           path: "setup.py",
                                                                                           project_name: nil,
                                                                                           dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "Install", requirement: "*", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-bootstrap3", requirement: ">=6.2,<6.3", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "lesscpy", requirement: "*", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "unicodecsv", requirement: "==0.14.1", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-coffeescript", requirement: ">=0.7,<0.8", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-compressor", requirement: ">=1.6,<1.7", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-datetime-widget", requirement: ">=0.9,<1.0", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-filter", requirement: ">=0.11,<0.12", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-representatives-votes", requirement: ">=0.0.13", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-representatives", requirement: ">=0.0.14", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-taggit", requirement: ">=0.17,<0.18", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django", requirement: ">=1.8,<1.9", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "djangorestframework", requirement: ">=3.2.0,<3.3.0", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "hamlpy", requirement: ">=0.82,<0.83", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "ijson", requirement: ">=2.2,<2.3", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "python-dateutil", requirement: ">=2.4,<2.5", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytz", requirement: "==2015.7", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django-suit", requirement: "*", type: "runtime", source: "setup.py"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "dummy", requirement: "==2.0beta1", type: "runtime", source: "setup.py"),
      ],
                                                                                           kind: "manifest",
                                                                                           success: true,
                                                                                         })
  end

  it "parses dependencies from requirements.txt" do
    expect(described_class.analyse_contents("requirements.txt", load_fixture("requirements.txt"))).to eq({
                                                                                                           platform: "pypi",
                                                                                                           path: "requirements.txt",
                                                                                                           project_name: nil,
                                                                                                           dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "Flask", requirement: "==0.8", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "zope.component", requirement: "==4.2.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "scikit-learn", requirement: "==0.16.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Beaker", requirement: ">=1.6.5", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "certifi", requirement: "==0.0.8", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "chardet", requirement: "==1.0.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "distribute", requirement: "==0.6.24", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "gunicorn", requirement: "==0.14.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "requests", requirement: "==0.11.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Django", requirement: "==2.0beta1", type: "runtime", source: "requirements.txt"),
      ],
                                                                                                           kind: "manifest",
                                                                                                           success: true,
                                                                                                         })
  end

  it "parses dependencies from requirements-dev.txt" do
    expect(described_class.analyse_contents("requirements-dev.txt", load_fixture("requirements-dev.txt"))).to eq({
                                                                                                                   platform: "pypi",
                                                                                                                   path: "requirements-dev.txt",
                                                                                                                   project_name: nil,
                                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "astroid", requirement: "==2.9.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "attrs", requirement: "==21.4.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "boto3", requirement: "==1.20.26", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "botocore", requirement: "==1.23.26", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "certifi", requirement: "==2021.10.8", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "charset-normalizer", requirement: "==2.0.9", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "coverage", requirement: "==6.2", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "doc8", requirement: "==0.10.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "docutils", requirement: "==0.17.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "flake8", requirement: "==4.0.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "hypothesis", requirement: "==6.31.6", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "idna", requirement: "==3.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "importlib-metadata", requirement: "==4.2.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "iniconfig", requirement: "==1.1.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "isort", requirement: "==5.10.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "jmespath", requirement: "==0.10.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "lazy-object-proxy", requirement: "==1.7.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "mccabe", requirement: "==0.6.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "mock", requirement: "==4.0.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "mypy", requirement: "==0.812", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "mypy-extensions", requirement: "==0.4.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "packaging", requirement: "==21.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pbr", requirement: "==5.8.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "platformdirs", requirement: "==2.4.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pluggy", requirement: "==1.0.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "py", requirement: "==1.11.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pycodestyle", requirement: "==2.8.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pydocstyle", requirement: "==6.1.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyflakes", requirement: "==2.4.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pygments", requirement: "==2.11.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pylint", requirement: "==2.12.2", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyparsing", requirement: "==3.0.6", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest", requirement: "==6.2.5", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest-cov", requirement: "==3.0.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "python-dateutil", requirement: "==2.8.2", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "requests", requirement: "==2.26.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "restructuredtext-lint", requirement: "==1.3.2", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "s3transfer", requirement: "==0.5.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "six", requirement: "==1.16.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "snowballstemmer", requirement: "==2.2.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "sortedcontainers", requirement: "==2.4.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "stevedore", requirement: "==3.5.0", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "toml", requirement: "==0.10.2", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "tomli", requirement: "==1.2.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "typed-ast", requirement: "==1.4.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "typing-extensions", requirement: "==4.0.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "urllib3", requirement: "==1.26.7", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "websocket-client", requirement: "==1.2.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "wheel", requirement: "==0.37.1", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "wrapt", requirement: "==1.13.3", type: "development", source: "requirements-dev.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "zipp", requirement: "==3.6.0", type: "development", source: "requirements-dev.txt"),
    ],
                                                                                                                   kind: "manifest",
                                                                                                                   success: true,
                                                                                                                 })
  end

  it "parses dependencies from requirements/test.txt" do
    expect(described_class.analyse_contents("requirements/test.txt", load_fixture("requirements/test.txt"))).to eq({
                                                                                                                     platform: "pypi",
                                                                                                                     path: "requirements/test.txt",
                                                                                                                     project_name: nil,
                                                                                                                     dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "attrs", requirement: "==21.4.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "exceptiongroup", requirement: "==1.0.0rc8", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "execnet", requirement: "==1.9.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "iniconfig", requirement: "==1.1.1", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "packaging", requirement: "==21.3", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pexpect", requirement: "==4.8.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pluggy", requirement: "==1.0.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "ptyprocess", requirement: "==0.7.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "py", requirement: "==1.11.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyparsing", requirement: "==3.0.9", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest", requirement: "==7.1.2", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest-forked", requirement: "==1.4.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest-xdist", requirement: "==2.5.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "sortedcontainers", requirement: "==2.4.0", type: "test", source: "requirements/test.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "tomli", requirement: "==2.0.1", type: "test", source: "requirements/test.txt"),
      ],
                                                                                                                     kind: "manifest",
                                                                                                                     success: true,
                                                                                                                   })
  end

  context "git urls" do
    it "parses dependencies from requirements-git.txt" do
      expect(described_class.analyse_contents("requirements-git.txt", load_fixture("requirements-git.txt"))).to eq({
                                                                                                                     platform: "pypi",
                                                                                                                     path: "requirements-git.txt",
                                                                                                                     project_name: nil,
                                                                                                                     dependencies: [
          Bibliothecary::Dependency.new(platform: "pypi", name: "pygame", requirement: "2.1.2", type: "runtime", source: "requirements-git.txt"),
        ],
                                                                                                                     kind: "manifest",
                                                                                                                     success: true,
                                                                                                                   })
    end

    it "skips poorly-formed lines" do
      result = described_class.analyse_contents(
        "requirements.git.txt", <<~REQ
          git://what@::/:/:/
        REQ
      )

      expect(result[:dependencies].count).to eq(0)
    end

    it "parses URLs with no version" do
      result = described_class.parse_requirements_txt_url("git+http://github.com/libraries/test#egg=test")

      expect(result).to eq(Bibliothecary::Dependency.new(platform: "pypi",
                                                         name: "test",
                                                         requirement: "*"))
    end

    it "fails if there is no egg specified" do
      expect do
        described_class.parse_requirements_txt_url("git+http://github.com/libraries/test@2.1.3")
      end.to raise_error(described_class::NoEggSpecified)
    end
  end

  it "parses dependencies from requirements.in" do
    expect(described_class.analyse_contents("requirements.in", load_fixture("pip-compile/requirements.in"))).to eq({
                                                                                                                     platform: "pypi",
                                                                                                                     path: "requirements.in",
                                                                                                                     project_name: nil,
                                                                                                                     dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "invoke", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "black", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-cloud-storage", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "six", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "progress", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "questionary", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyyaml", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "semver", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Jinja2", requirement: "*", type: "runtime", source: "requirements.in"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pip-tools", requirement: "*", type: "runtime", source: "requirements.in"),
      ],
                                                                                                                     kind: "manifest",
                                                                                                                     success: true,
                                                                                                                   })
  end
  it "parses dependencies from requirements.txt as lockfile because of pip-compile" do
    expect(described_class.analyse_contents("requirements.txt", load_fixture("pip-compile/requirements.txt"))).to eq({
                                                                                                                       platform: "pypi",
                                                                                                                       path: "requirements.txt",
                                                                                                                       project_name: nil,
                                                                                                                       dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "black", requirement: "==21.9b0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "cachetools", requirement: "==4.2.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "certifi", requirement: "==2021.5.30", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "charset-normalizer", requirement: "==2.0.6", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "click", requirement: "==8.0.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-api-core", requirement: "==2.0.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-auth", requirement: "==2.1.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-cloud-core", requirement: "==2.0.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-cloud-storage", requirement: "==1.42.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-crc32c", requirement: "==1.2.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "google-resumable-media", requirement: "==2.0.3", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "googleapis-common-protos", requirement: "==1.53.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "idna", requirement: "==3.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "invoke", requirement: "==1.6.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "jinja2", requirement: "==3.0.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "markupsafe", requirement: "==2.0.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "mypy-extensions", requirement: "==0.4.3", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pathspec", requirement: "==0.9.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pep517", requirement: "==0.11.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pip-tools", requirement: "==6.2.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "platformdirs", requirement: "==2.3.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "progress", requirement: "==1.6", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "prompt-toolkit", requirement: "==3.0.20", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "protobuf", requirement: "==3.18.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyasn1", requirement: "==0.4.8", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyasn1-modules", requirement: "==0.2.8", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pyyaml", requirement: "==5.4.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "questionary", requirement: "==1.10.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "regex", requirement: "==2021.8.28", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "requests", requirement: "==2.26.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "rsa", requirement: "==4.7.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "semver", requirement: "==2.13.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "six", requirement: "==1.16.0", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "tomli", requirement: "==1.2.1", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "typing-extensions", requirement: "==3.10.0.2", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "urllib3", requirement: "==1.26.6", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "wcwidth", requirement: "==0.2.5", type: "runtime", source: "requirements.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "wheel", requirement: "==0.37.0", type: "runtime", source: "requirements.txt"),
      ],
                                                                                                                       kind: "lockfile",
                                                                                                                       success: true,
                                                                                                                     })
  end

  it "parses dependencies from pip-resolved-dependencies.txt" do
    expect(described_class.analyse_contents("pip-resolved-dependencies.txt", load_fixture("pip-resolved-dependencies.txt"))).to eq({
                                                                                                                                     platform: "pypi",
                                                                                                                                     path: "pip-resolved-dependencies.txt",
                                                                                                                                     project_name: nil,
                                                                                                                                     dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "asgiref", requirement: "==3.2.7", type: "runtime", source: "pip-resolved-dependencies.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Django", requirement: "==3.0.6", type: "runtime", source: "pip-resolved-dependencies.txt"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "sqlparse", requirement: "==0.3.1", type: "runtime", source: "pip-resolved-dependencies.txt"),
      ],
                                                                                                                                     kind: "lockfile",
                                                                                                                                     success: true,
                                                                                                                                   })
  end

  it "parses dependencies from pip-dependency-graph.json" do
    expect(described_class.analyse_contents("pip-dependency-graph.json", load_fixture("pip-dependency-graph.json"))).to eq({
                                                                                                                             platform: "pypi",
                                                                                                                             path: "pip-dependency-graph.json",
                                                                                                                             project_name: nil,
                                                                                                                             dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "aiohttp", requirement: "3.9.5", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "aiosignal", requirement: "1.3.1", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "async-timeout", requirement: "4.0.3", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "attrs", requirement: "23.2.0", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "black", requirement: "23.12.0", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "click", requirement: "8.1.7", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "frozenlist", requirement: "1.4.1", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "idna", requirement: "3.7", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "multidict", requirement: "6.0.5", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "mypy-extensions", requirement: "1.0.0", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "packaging", requirement: "24.0", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pathspec", requirement: "0.12.1", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "platformdirs", requirement: "4.2.2", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "termcolor", requirement: "2.4.0", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "tomli", requirement: "2.0.1", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "typing_extensions", requirement: "4.12.0", type: "runtime", source: "pip-dependency-graph.json"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "yarl", requirement: "1.9.4", type: "runtime", source: "pip-dependency-graph.json"),
      ],
                                                                                                                             kind: "lockfile",
                                                                                                                             success: true,
                                                                                                                           })
  end

  it "handles duplicate dependencies from pip-dependency-graph.json" do
    # It doesn't seem possible that pipdeptree would output duplicate
    # dependencies, but this ensures we catch it in case that is possible.
    lockfile = <<-JSON
    [
      {
        "package": {
          "key": "aiohttp",
          "package_name": "aiohttp",
          "installed_version": "3.9.5"
        },
        "dependencies": []
      },
      {
        "package": {
          "key": "aiohttp",
          "package_name": "aiohttp",
          "installed_version": "3.9.5"
        },
        "dependencies": []
      }
    ]
    JSON
    expect(described_class.analyse_contents("pip-dependency-graph.json", lockfile)).to eq({
                                                                                            platform: "pypi",
                                                                                            path: "pip-dependency-graph.json",
                                                                                            project_name: nil,
                                                                                            dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "aiohttp", requirement: "3.9.5", type: "runtime", source: "pip-dependency-graph.json"),
      ],
                                                                                            kind: "lockfile",
                                                                                            success: true,
                                                                                          })
  end

  it "parses dependencies from requirements.frozen" do
    expect(described_class.analyse_contents("requirements.frozen", load_fixture("requirements.frozen"))).to eq({
                                                                                                                 platform: "pypi",
                                                                                                                 path: "requirements.frozen",
                                                                                                                 project_name: nil,
                                                                                                                 dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "asgiref", requirement: "==3.2.7", type: "runtime", source: "requirements.frozen"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Django", requirement: "==3.0.6", type: "runtime", source: "requirements.frozen"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "sqlparse", requirement: "==0.3.1", type: "runtime", source: "requirements.frozen"),
      ],
                                                                                                                 kind: "lockfile",
                                                                                                                 success: true,
                                                                                                               })
  end

  it "parses dependencies from Pipfile" do
    results = described_class.analyse_contents("Pipfile", load_fixture("Pipfile"))
    expect(results[:platform]).to eq("pypi")
    expect(results[:path]).to eq("Pipfile")
    expect(results[:kind]).to eq("manifest")
    expect(results[:project_name]).to eq(nil)
    expect(results[:success]).to eq(true)
    expect(results[:dependencies]).to match_array([
        Bibliothecary::Dependency.new(platform: "pypi", name: "requests", requirement: "*", type: "runtime", source: "Pipfile"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Django", requirement: ">1.10", type: "runtime", source: "Pipfile"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pinax", requirement: "git://github.com/pinax/pinax.git#1.4", type: "runtime", source: "Pipfile"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "nose", requirement: "*", type: "develop", source: "Pipfile"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "a-local-dep", requirement: "*", type: "runtime", source: "Pipfile", local: true),
        Bibliothecary::Dependency.new(platform: "pypi", name: "another-local-dep", requirement: "*", type: "develop", source: "Pipfile", local: true),
      ])
  end

  it "parses dependencies from Pipfile.lock" do
    results = described_class.analyse_contents("Pipfile.lock", load_fixture("Pipfile.lock"))
    expect(results[:platform]).to eq("pypi")
    expect(results[:path]).to eq("Pipfile.lock")
    expect(results[:kind]).to eq("lockfile")
    expect(results[:project_name]).to eq(nil)
    expect(results[:success]).to eq(true)
    expect(results[:dependencies]).to match_array([
        Bibliothecary::Dependency.new(platform: "pypi", name: "PySocks", requirement: "==1.6.5", type: "runtime", source: "Pipfile.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "requests", requirement: "==2.13.0", type: "runtime", source: "Pipfile.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "Django", requirement: "==1.10.5", type: "runtime", source: "Pipfile.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pinax", requirement: "git://github.com/pinax/pinax.git#1.4", source: "Pipfile.lock", type: "runtime"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "a-local-dep", requirement: "*", type: "runtime", source: "Pipfile.lock", local: true),
        Bibliothecary::Dependency.new(platform: "pypi", name: "nose", requirement: "==1.3.7", type: "develop", source: "Pipfile.lock"),
      ])
  end

  it "parses dependencies from pylock.toml" do
    result = described_class.analyse_contents("pylock.toml", load_fixture("pylock.toml"))

    expect(result[:platform]).to eq("pypi")
    expect(result[:path]).to eq("pylock.toml")
    expect(result[:kind]).to eq("lockfile")
    expect(result[:project_name]).to eq(nil)
    expect(result[:success]).to eq(true)
    expect(result[:dependencies]).to match_array([
      Bibliothecary::Dependency.new(platform: "pypi", name: "blinker", requirement: "1.9.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "certifi", requirement: "2025.7.14", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "chardet", requirement: "5.0.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "charset-normalizer", requirement: "3.4.2", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "click", requirement: "8.2.1", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "flask", requirement: "3.1.1", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "gunicorn", requirement: "23.0.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "idna", requirement: "3.10", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "itsdangerous", requirement: "2.2.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "jinja2", requirement: "3.1.6", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "joblib", requirement: "1.5.1", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "markupsafe", requirement: "3.0.2", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "numpy", requirement: "2.3.2", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "packaging", requirement: "25.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "requests", requirement: "2.32.4", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "scikit-learn", requirement: "1.7.1", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "scipy", requirement: "1.16.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "threadpoolctl", requirement: "3.6.0", type: "runtime", source: "pylock.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "urllib3", requirement: "*", type: "runtime", source: "pylock.toml", local: true),
      Bibliothecary::Dependency.new(platform: "pypi", name: "werkzeug", requirement: "3.1.3", type: "runtime", source: "pylock.toml"),
      ])
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("requirements.txt")).to be_truthy
    expect(described_class.match?("requirements-dev.txt")).to be_truthy
    expect(described_class.match?("requirements/dev.txt")).to be_truthy
    expect(described_class.match?("requirements.pip")).to be_truthy
    expect(described_class.match?("setup.py")).to be_truthy
    expect(described_class.match?("Pipfile")).to be_truthy
    expect(described_class.match?("Pipfile.lock")).to be_truthy
    expect(described_class.match?("python/pip-requirements.txt")).to be_truthy
  end

  it "fails to match invalid manifest filepaths" do
    expect(described_class.match?("some-random-file.txt")).to be_falsey
    expect(described_class.match?("require/some/other/folder/myhomework.txt")).to be_falsey
    expect(described_class.match?("private/required-for-plugin/gradle-dependencies-q.txt")).to be_falsey
  end

  it "parses dependencies from pyproject.toml" do
    results = described_class.analyse_contents("pyproject.toml", load_fixture("pyproject.toml"))
    expect(results[:platform]).to eq("pypi")
    expect(results[:path]).to eq("pyproject.toml")
    expect(results[:kind]).to eq("manifest")
    expect(results[:project_name]).to eq(nil)
    expect(results[:success]).to eq(true)
    expect(results[:dependencies]).to match_array([
      Bibliothecary::Dependency.new(platform: "pypi", name: "python", requirement: "^3.7", type: "runtime", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "django", requirement: "^3.0.7", type: "runtime", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "pytest", requirement: "^5.2", type: "develop", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "wcwidth", requirement: "*", type: "develop", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "sqlparse", requirement: "0.4.4", type: "test", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "pathlib2", requirement: "2.3.7.post1", type: "runtime", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "pathlib2", requirement: "2.3.6", type: "runtime", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "pathlib2", requirement: "2.3.5", type: "runtime", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "pathlib2", requirement: "https://github.com/jazzband/pathlib2.git#2.3.5", type: "runtime", source: "pyproject.toml"),
      Bibliothecary::Dependency.new(platform: "pypi", name: "zope-interface", original_name: "Zope_interface", requirement: "6.3", type: "runtime", source: "pyproject.toml"),
    ])
  end

  it "handles pyproject.toml with no deps" do
    source = <<~FILE
      [tool.black]
      line-length = 100
    FILE

    expect(described_class.analyse_contents("pyproject.toml", source)).to eq({
                                                                               platform: "pypi",
                                                                               path: "pyproject.toml",
                                                                               project_name: nil,
                                                                               dependencies: [],
                                                                               kind: "manifest",
                                                                               success: true,
                                                                             })
  end

  # https://packaging.python.org/en/latest/specifications/declaring-project-metadata/#declaring-project-metadata
  it "handles pyproject.toml with pep621-style deps" do
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

    results = described_class.analyse_contents("pyproject.toml", source)
    expect(results[:platform]).to eq("pypi")
    expect(results[:path]).to eq("pyproject.toml")
    expect(results[:kind]).to eq("manifest")
    expect(results[:project_name]).to eq(nil)
    expect(results[:success]).to eq(true)
    expect(results[:dependencies]).to eq([
        Bibliothecary::Dependency.new(platform: "pypi", name: "black", requirement: "*", type: "runtime", source: "pyproject.toml"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "isort", requirement: "*", type: "runtime", source: "pyproject.toml"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest", requirement: "== 7.2.1", type: "runtime", source: "pyproject.toml"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "python-gitlab", requirement: "== 3.12.0", type: "runtime", source: "pyproject.toml"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "click", original_name: "Click", requirement: "~=8.1.0", type: "runtime", source: "pyproject.toml"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "marshmallow-dataclass", requirement: "[union]~=8.5.6", type: "runtime", source: "pyproject.toml"),
      ])
  end

  it "parses dependencies from Poetry.lock" do
    expect(described_class.analyse_contents("poetry.lock", load_fixture("poetry.lock"))).to eq({
                                                                                                 platform: "pypi",
                                                                                                 path: "poetry.lock",
                                                                                                 project_name: nil,
                                                                                                 dependencies: [
        Bibliothecary::Dependency.new(platform: "pypi", name: "asgiref", requirement: "3.7.2", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "atomicwrites", requirement: "1.4.1", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "attrs", requirement: "24.2.0", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "colorama", requirement: "0.4.6", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "django", requirement: "3.2.25", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "importlib-metadata", requirement: "6.7.0", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "more-itertools", requirement: "9.1.0", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "packaging", requirement: "24.0", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pathlib2", requirement: "2.3.7.post1", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pluggy", requirement: "0.13.1", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "py", requirement: "1.11.0", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytest", requirement: "5.4.3", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "pytz", requirement: "2025.2", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "setuptools", requirement: "68.0.0", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "six", requirement: "1.17.0", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "sqlparse", requirement: "0.4.4", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "sqlparse", requirement: "0.4.4", type: "test", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "typing-extensions", requirement: "4.7.1", type: "runtime", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "typing-extensions", requirement: "4.7.1", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "wcwidth", requirement: "0.2.13", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "zipp", requirement: "3.15.0", type: "develop", source: "poetry.lock"),
        Bibliothecary::Dependency.new(platform: "pypi", name: "zope-interface", requirement: "6.3", type: "runtime", source: "poetry.lock"),
      ],
                                                                                                 kind: "lockfile",
                                                                                                 success: true,
                                                                                               })
  end
end
