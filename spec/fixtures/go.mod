module mod

go 1.24

toolchain go1.24.0

// this is a comment line

require (
  github.com/go-check/check v0.0.0-20180628173108-788fd7840127 // indirect
  github.com/gomodule/redigo v2.0.0+incompatible // indirect
  github.com/jstemmer/go-junit-report v1.0.0 // indirect
  github.com/jstemmer/go-junit-report/v2 v2.1.0 // indirect
  github.com/kr/pretty v0.1.0 // indirect
  github.com/replicon/fast-archiver v0.0.0-20121220195659-060bf9adec25 // indirect
  gopkg.in/yaml.v1 v1.0.0-20140924161607-9f9df34309c0
)

require golang.org/x/net v1.2.3 // this is the single-line require directive

exclude old/thing 1.2.3 // this is the single-line exclude directive

exclude (
  older/thing 4.5.6 // this is the multi-line exclude directive
)

replace bad/thing v1.4.5 => good/thing v1.4.5 // this is the single-line exclude directive

replace (
  golang.org/x/net v1.2.3 => example.com/fork/net v1.4.5
  golang.org/x/net => example.com/fork/net v1.4.5
  golang.org/x/net v1.2.3 => ./fork/net
  golang.org/x/net => ./fork/net
)

retract v1.0.0 // this is the single-line retract directive

retract [v2.0.0, v1.9.9]

retract (
  v1.0.0  // this is the multi-line retract directive
  [v1.0.0, v1.9.9]
)

tool golang.org/x/tools/cmd/stringer

tool (
  github.com/jstemmer/go-junit-report
  github.com/jstemmer/go-junit-report/v2
)
