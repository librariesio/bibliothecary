# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

- gem's .ruby-version changed from 3.0.7 to 3.2.6

### Removed

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

- Support parsing *.spdx.json files

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
