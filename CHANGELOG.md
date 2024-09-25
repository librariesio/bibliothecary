# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Removed

## [10.2.2] - 2024-09-25

### Added

- Support parsing *.spdx.json files

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
