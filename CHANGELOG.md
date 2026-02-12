# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Removed

## [15.2.0]

### Changed

- Exclude sub-projects in gradle-dependencies-q.txt unless keep_subprojects_in_maven_tree is true.
- The format of Gradle sub-project GAVs that were found in a dependency tree has changed from "internal:my-subproject:1.0.0" to ":my-subproject:*".
- Gradle dependencies in gradle-dependencies-q.txt with "(n)" suffix will be ignored in favor of their resolved dependencies, so the full dependency list could now be smaller but still correct.

### Added

- Added support for another project name pattern in gradle-dependencies-q.txt lockfiles.

## [15.1.3]

### Added

- Start collecting "project_name" from gradle-dependencies-q.txt lockfiles.
- Start collecting "project_name" from package.json manifests.

### Changed

- Bibliothecary::Parsers::Maven's GRADLE_PROJECT_REGEXP constant was renamed to GRADLE_DEPENDENCY_PROJECT_REGEXP.

### Removed

- Remove "go.sum" as a lockfile for Golang because it is not a lockfile.

## [15.1.2]

### Changed

- Make SPDX and CycloneDX filename matchers case-insensitive.

## [15.1.1]

### Changed

- Fix support for parsing conanfile.txt

## [15.1.0]

### Added

- Add initial support for SPDX 3.0 JSON files

### Changed

- Treat "cyclonedx.json" and "cyclonedx.xml" matchers as suffixes instead of filenames.
- Fix Nuget parser so it returns all target frameworks' dependencies from packages.lock.json instead of an arbitrary target framework's dependencies.

## [15.0.0]

15.0.0 includes some breaking changes, so please see UPGRADING_TO_15_0_0.md to migrate your code.

### Changed

- Make the MultiParsers (CycloneDX, Spdx, DependenciesCSV) classes instead of modules.
- Moved the two parser mixins, JSONRuntime and BundlerLikeManifest, into their own Bibliothecary::ParserMixins namespace.
- Return all dependencies from SPDX and CycloneDX files regardless of platform

### Removed

- Removed MultiManifestFilter, since it's no longer necessary 

## [14.4.0]

### Added

- Add suppport for vcpkg parsing

## [14.3.0]

### Added

- Add suppport for conan parsing

## [14.2.0]

### Added

### Changed

- Dependencies from yarn.lock will return a nil "type" instead of assuming "runtime".
- In Nuget .csproj files, ignored <Reference> tags that don't have a version.

### Removed

## [14.1.0] - 2025-10-01

### Added

### Changed

- Dependencies from pom.xml without a scope will now return a "type" of nil instead of guessing "runtime".

### Removed

## [14.0.2] - 2025-07-29

### Added

- Add support in Pypi parser for PEP-751's newly official "pylock.toml" lockfile

### Changed

- Added a regression test to ensure "file" entries in Pipfile/Pipfile.lock are considered local.

### Removed

## [14.0.1] - 2025-07-24

### Changed

- Bugfix: implement Bibliothecary::ParserResult in SPDX parser too, and add an integration test.

## [14.0.0] - 2025-07-24

### Added

- Added Bibliothecary::ParserResult class, which wraps the parsed dependencies along with the project name, if it was found in the manifest. 

### Changed

- Breaking: parser methods now return Bibliothecary::ParserResult instead of an Array of Bibliothecary::Dependency
- Return project_name for maven-dependency-tree.txt and maven-dependency-tree.dot results
- Breaking: require the "platform" argument to be passed to Bibliothecary::Dependency, and update the parsers to do so.

### Removed

- Removed unused generic parser code.

## [13.0.2] - 2025-07-21

### Changed

- Handle scoped dependencies in PNPM lockfiles.

## [13.0.1] - 2025-07-03

### Changed

- Handle windows-style newlines in v1 yarn lockfiles.

## [13.0.0] - 2025-06-17

### Removed

- Removed parsing of environment.yml from Pypi parsing

## [12.3.1] - 2025-06-06

### Changed

- Handle .csproj files that begin with an <?xml> tag

## [12.3.0] - 2025-06-06

### Added

- Nuget support for <Reference> tag in \*.csproj manifests.

## [12.2.0] - 2025-05-30

### Added

- Maven parser support for maven-dependency-tree.dot file.

## [12.1.10] - 2025-05-23

### Changed

- Normalize package names in Poetry manifests, storing the original in
  Dependency#original_name if it differs. This is because Poetry normalizes/canoncalizes
  names in its lockfile according to PyPa's rules, but doesn't provide the original name.
  Storing the original_name will provide a connection from manifest to lockfile.

## [12.1.9] - 2025-05-16

### Changed

- Fix 12.1.8 Poetry regression that ignored deps with no category or group.

## [12.1.8] - 2025-05-16

### Added

- Support multiple requirements for a single package in poetry.lock.

## [12.1.7] - 2025-04-29

### Changed

- Include "source" field in Dependency objects from pub files.
- Include "source" field in Dependency objects from pnpm-lock.yaml files.

## [12.1.6] - 2025-04-29

### Changed

- Use JSON.parser.parse() in bun.lock parser to work around overriden JSON.parse() method.
- Don't raise an error in pnpm-lock.yaml v9 parser if devDependencies isn't found.

## [12.1.5] - 2025-03-17

### Added

- Adds alias support for PNPM lockfiles.
- Add support for bun.lock files

## [12.1.4] - 2025-03-14

### Added

- Add support for PNPM lockfiles (lockfile versions 5, 6, and 9).
- Add 'parser_options' arg to Bilbiothecary::Runner constructor.

## [12.1.3] - 2025-02-26

### Added

- Add 'local' property to dependencies from Pipfile and Pipfile.lock

### Changed

- Handle aliases and NPM and Yarn, and ignore patched dependencies.
- Fix a PyPI parser's regex to exclude false positive "require" names.
- Drop all sub-projects from list of deps in a Maven maven-dependency-tree.txt.

## [12.1.2] - 2025-02-26

### Added

- Add 'local' property to dependencies from Pipfile and Pipfile.lock

## [12.1.1] - 2025-02-21

### Added

- Add test coverage for Go 1.24's new "tool" directive.

## [12.1.0] - 2025-01-30

### Added

- Populate Bibliothecary::Dependency#source field in all parsers. This makes the source field useful when consuming
  from Bibliothecary, and removes a step from consumers having to populate this field themselves.

### Changed

- Improved Rubocop rules to make future spec changes easier via Rubocop auto-correcting formatting violations.

## [12.0.0] - 2025-01-27

### Removed

- This is a MAJOR release in that it removes support for hackage, carthage, hex, clojar, and swiftpm
  from Bibliothecary. We are no longer doing any network calls when using Bibliothecary and reimplementing
  parsing for those file types natively is non-trivial. Patches welcome :-)

### Changed

- Rewrote conda and yarn parsers to be in process vs calling out over the network

## [11.0.1] - 2024-12-20

### Changed

- Alow retrieving maven versions from parent poms

## [11.0.0] - 2024-11-22

### Changed

- Removed lockfile_requirement from Bibliothecary::Dependency

## [10.2.4] - 2024-11-06

### Changed

- Fixed parsing of pom files where parent properties within the file are required for dependencies

## [10.2.2] - 2024-09-25

### Added

- Support parsing \*.spdx.json files

### Changed

- `Bibliothecary::PURL_TYPE_MAPPING` has changed to `Bibliothecary::PurlUtil::PURL_TYPE_MAPPING`
- `Bibliothecary::MultiParsers::CycloneDX::ManifestEntries.full_name_for_purl` has changed to `Bibliothecary::PurlUtil.full_name`

## [10.2.0] - 2024-08-27

### Changed

- `Bibliothecary::Dependency#requirement` now defaults to all versions (`"*"`) instead of `nil` if no version range is specified for the dependency.

## [10.1.0] - 2024-07-23

### Changed

- Skip self referencing package entries in yarn v4+ lockfiles.

## [10.0.0] - 2024-07-08

### Added

- Added `CHANGELOG.md`, based on https://keepachangelog.com/en/1.1.0/.
- New `Bibliothecary::Dependency` class.

### Changed

- **Breaking**: `Bibliothecary::Parsers` classes now return lists of `Bibliothecary::Dependency`
  instances instead of `Hash` instances.
