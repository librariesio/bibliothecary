# Upgrading to Bibliothecary 15.0.0

Bibliothecary 15.0.0 includes several breaking changes related to how parsers are structured and how analysis results are returned. This guide will help you upgrade your code.

## Breaking Changes

### 1. Analysis Results Now Use `parser` Instead of `platform`

**What Changed:**
- Analysis result hashes now use the key `parser:` instead of `platform:`
- `Bibliothecary::Analyser.create_analysis()` returns `parser:` instead of `platform:`
- `Bibliothecary::Analyser.create_error_analysis()` returns `parser:` instead of `platform:`

**Before (14.x):**
```ruby
analysis = Bibliothecary.analyse('path/to/project')
# => [{
#   platform: "npm",
#   path: "package.json",
#   dependencies: [...],
#   kind: "manifest",
#   success: true
# }]

analysis.first[:platform]  # => "npm"
```

**After (15.0):**
```ruby
analysis = Bibliothecary.analyse('path/to/project')
# => [{
#   parser: "npm",
#   path: "package.json",
#   dependencies: [...],
#   kind: "manifest",
#   success: true
# }]

analysis.first[:parser]  # => "npm"
```

**Migration:**
- Replace all references to `analysis[:platform]` with `analysis[:parser]`
- Update any code that expects the `platform` key in analysis results
- Note: `Dependency` objects still use `platform:` as this refers to the ecosystem, not the parser

### 2. SBOM Files Now Return Single Parser Results

**What Changed:**
- SBOM files (CycloneDX, SPDX, dependencies.csv) are now parsed as standalone parser results
- Previously, multi-parsers would distribute dependencies across multiple platform-specific results
- Now, all dependencies from an SBOM file are returned in a single result with the SBOM parser name

**Before (14.x):**
```ruby
# A cyclonedx.json file containing npm and maven dependencies would return:
[
  {
    platform: "npm",
    path: "cyclonedx.json",
    dependencies: [<npm deps>],
    ...
  },
  {
    platform: "maven",
    path: "cyclonedx.json", 
    dependencies: [<maven deps>],
    ...
  }
]
```

**After (15.0):**
```ruby
# The same cyclonedx.json file now returns a single result:
[
  {
    parser: "cyclonedx",
    path: "cyclonedx.json",
    dependencies: [<all deps with their platform: field set>],
    kind: "lockfile",
    success: true
  }
]

# Each dependency still knows its platform:
dependencies.first.platform  # => "npm"
dependencies.last.platform   # => "maven"
```

**Migration:**
- Update code that expects SBOM files to return multiple platform-specific results
- Instead of filtering results by `platform`, check `result[:parser]` for "cyclonedx", "spdx", or "dependenciescsv"
- Group dependencies by their `Dependency#platform` field if you need platform-specific grouping

**Affected Parsers:**
- `cyclonedx` (cyclonedx.json, cyclonedx.xml, *.cdx.json, *.cdx.xml)
- `spdx` (*.spdx, *.spdx.json)
- `dependenciescsv` (dependencies.csv)

### 3. SBOM Files Now Return ALL Dependencies Regardless of Platform

**What Changed:**
- CycloneDX and SPDX parsers now return ALL dependencies from SBOM files
- Previously, only dependencies with PURL types mapped in `PURL_TYPE_MAPPING` were returned
- Now, unmapped PURL types (e.g., `alpine`, `apk`, `deb`, `rpm`) are included with the PURL type used as the platform name

**Before (14.x):**
```ruby
# An SBOM with npm, maven, and alpine packages would only return npm and maven
result = Bibliothecary.analyse('cyclonedx.json')
# => [{
#   parser: "cyclonedx",
#   dependencies: [
#     { name: "express", platform: "npm", ... },      # included
#     { name: "junit", platform: "maven", ... },      # included
#     # alpine packages were silently filtered out
#   ]
# }]
```

**After (15.0):**
```ruby
# The same SBOM now returns ALL packages
result = Bibliothecary.analyse('cyclonedx.json')
# => [{
#   parser: "cyclonedx",
#   dependencies: [
#     { name: "express", platform: "npm", ... },           # included (mapped)
#     { name: "junit", platform: "maven", ... },           # included (mapped)
#     { name: "alpine-base", platform: "alpine", ... },    # included (unmapped, uses PURL type)
#     { name: "curl", platform: "apk", ... }               # included (unmapped, uses PURL type)
#   ]
# }]
```

**Mapped PURL Types (in PURL_TYPE_MAPPING):**
- `golang` → `go`
- `maven` → `maven`
- `npm` → `npm`
- `cargo` → `cargo`
- `composer` → `packagist`
- `conan` → `conan`
- `conda` → `conda`
- `cran` → `cran`
- `gem` → `rubygems`
- `nuget` → `nuget`
- `pypi` → `pypi`
- `vcpkg` → `vcpkg`

**Unmapped PURL Types (now included as-is):**
- `alpine`, `apk`, `deb`, `rpm`, `bitbucket`, `github`, `docker`, and any other PURL types

**Migration:**
- If your code filters or groups by platform, be aware that new platform values may appear
- System package types (`alpine`, `apk`, `deb`, `rpm`) will now be included in results
- Consider whether your application needs to handle these additional platform types
- The behavior is now more comprehensive and accurate to what's actually in SBOM files

### 4. API Method Renames

**What Changed:**
- Methods containing "package_manager" have been renamed to "parser"
- Old methods now raise errors with upgrade instructions

**Removed Methods:**

| Old Method (14.x) | New Method (15.0) |
|-------------------|-------------------|
| `Bibliothecary.package_managers` | `Bibliothecary.parsers` |
| `Bibliothecary.applicable_package_managers(info)` | `Bibliothecary.applicable_parsers(info)` |
| `Runner#package_managers` | `Runner#parsers` |
| `Runner#applicable_package_managers(info)` | `Runner#applicable_parsers(info)` |
| `FileInfo#package_manager` | `FileInfo#parser` |
| `RelatedFilesInfo#package_manager` | `RelatedFilesInfo#parser` |

**Before (14.x):**
```ruby
Bibliothecary.package_managers
# => [Bibliothecary::Parsers::NPM, Bibliothecary::Parsers::Rubygems, ...]

info = Bibliothecary::FileInfo.new(...)
parsers = Bibliothecary.applicable_package_managers(info)
```

**After (15.0):**
```ruby
Bibliothecary.parsers
# => [Bibliothecary::Parsers::NPM, Bibliothecary::MultiParsers::CycloneDX, ...]

info = Bibliothecary::FileInfo.new(...)
parsers = Bibliothecary.applicable_parsers(info)
```

**Migration:**
- Search and replace `package_managers` with `parsers` in your codebase
- Search and replace `applicable_package_managers` with `applicable_parsers`
- Update any references to `FileInfo#package_manager` to use `FileInfo#parser`

### 4. MultiManifestFilter Removed

**What Changed:**
- The `Bibliothecary::Runner::MultiManifestFilter` class has been removed
- Multi-parsers are now standalone parser classes and don't require special filtering

**Before (14.x):**
```ruby
# MultiManifestFilter was used internally to handle SBOM files
```

**After (15.0):**
```ruby
# Multi-parsers (CycloneDX, SPDX, DependenciesCSV) are regular parser classes
# They are included automatically in Bibliothecary.parsers
```

**Migration:**
- Remove any direct references to `Bibliothecary::Runner::MultiManifestFilter`
- The new behavior handles SBOM files transparently through the regular parser system

### 5. Parser Mixins Moved

**What Changed:**
- `Bibliothecary::MultiParsers::JSONRuntime` moved to `Bibliothecary::ParserMixins::JSONRuntime`
- `Bibliothecary::MultiParsers::BundlerLikeManifest` moved to `Bibliothecary::ParserMixins::BundlerLikeManifest`

**Migration:**
- Update any explicit references to these modules in your code
- Most users won't be affected as these are internal implementation details

### 6. MultiParsers Are Now Classes

**What Changed:**
- Multi-parsers (CycloneDX, SPDX, DependenciesCSV) are now classes instead of modules
- They are no longer mixed into platform-specific parsers
- They are standalone parsers included in `Bibliothecary.parsers`

**Before (14.x):**
```ruby
# Multi-parsers were modules that extended individual parsers
Bibliothecary::Parsers::NPM.ancestors
# => includes Bibliothecary::MultiParsers::CycloneDX
```

**After (15.0):**
```ruby
# Multi-parsers are independent parser classes
Bibliothecary.parsers
# => [
#   Bibliothecary::Parsers::NPM,
#   Bibliothecary::Parsers::Maven,
#   ...,
#   Bibliothecary::MultiParsers::CycloneDX,
#   Bibliothecary::MultiParsers::Spdx,
#   Bibliothecary::MultiParsers::DependenciesCSV
# ]

# They have their own platform_name
Bibliothecary::MultiParsers::CycloneDX.platform_name  # => "cyclonedx"
```

**Migration:**
- Don't rely on multi-parser methods being available on platform-specific parsers
- Treat SBOM parsers as independent parsers in your code
