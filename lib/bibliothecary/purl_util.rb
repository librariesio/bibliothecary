module Bibliothecary
  # If a purl type (key) exists, it will be used in a manifest for
  # the key's value. If not, it's ignored.
  #
  # https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst
  PURL_TYPE_MAPPING = {
    "golang" => :go,
    "maven" => :maven,
    "npm" => :npm,
    "cargo" => :cargo,
    "composer" => :packagist,
    "conda" => :conda,
    "cran" => :cran,
    "gem" => :rubygems,
    "hackage" => :hackage,
    "hex" => :hex,
    "nuget" => :nuget,
    "pypi" => :pypi,
    "swift" => :swift_pm
  }.freeze
end
