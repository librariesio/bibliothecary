require 'spec_helper'

RSpec.describe Bibliothecary::Parsers::Maven do
  it 'parses specific info from pom.xml' do
    xml = Ox.parse load_fixture('pom.xml')

    cdata = Bibliothecary::Parsers::Maven.extract_pom_info(xml, "project/foo", {})
    expect(cdata).to match("this is some CDATA")
  end

  it_behaves_like 'CycloneDX'
  it_behaves_like 'dependencies.csv'

  it 'parses dependencies from pom.xml' do
    expect(described_class.analyse_contents('pom.xml', load_fixture('pom.xml'))).to eq({
      platform: "maven",
      path: "pom.xml",
      dependencies: [
        { name: "org.accidia:echo-parent",
        requirement: "0.1.23",
        type: "runtime" },
        { name: "org.glassfish.jersey.core:jersey-server",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.containers:jersey-container-servlet",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.containers:jersey-container-servlet-core",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.media:jersey-media-multipart",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.core:jersey-common",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.containers:jersey-container-jetty-http",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.containers:jersey-container-jetty-servlet",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.core:jersey-client",
        requirement: "2.16",
        type: "runtime" },
        { name: "org.glassfish.jersey.media:jersey-media-moxy",
        requirement: "2.16",
        type: "runtime" },
        # version string from <dependencyManagement>, and interpolated from <properties>
        { name: "com.google.guava:guava", requirement: "18.0", type: "runtime" },
        { name: "com.googlecode.protobuf-java-format:protobuf-java-format",
        requirement: "1.2",
        type: "runtime" },
        { name: "mysql:mysql-connector-java",
        requirement: "5.1.9",
        type: "runtime" },
        { name: "org.springframework:spring-jdbc",
        requirement: "4.1.0.RELEASE",
        type: "runtime" },
        { name: "com.mchange:c3p0", requirement: "0.9.2.1", type: "runtime" },
        { name: "org.freemarker:freemarker",
        requirement: "2.3.21",
        type: "runtime" },
        { name: "org.jasypt:jasypt", requirement: "1.9.2", type: "runtime" },
        { name: "com.google.protobuf:protobuf-java",
        requirement: "2.5.0",
        type: "runtime" },
        { name: "redis.clients:jedis", requirement: "2.6.0", type: "runtime" },
        { name: "ch.qos.logback:logback-classic",
        requirement: "1.1.2",
        type: "runtime" },
        { name: "io.dropwizard.metrics:metrics-core",
        requirement: "3.1.0",
        type: "runtime" },
        { name: "net.spy:spymemcached", requirement: "2.11.7", type: "runtime" },
        { name: "io.dropwizard.metrics:metrics-jersey2",
        requirement: "3.1.0",
        type: "runtime" },
        { name: "io.dropwizard.metrics:metrics-annotation",
        requirement: "3.1.0",
        type: "runtime" },
        { name: "com.palominolabs.metrics:metrics-guice",
        requirement: "3.1.0",
        type: "runtime" },
        { name: "com.google.inject:guice", requirement: "3.0", type: "runtime" },
        { name: "commons-io:commons-io", requirement: "2.4", type: "runtime" },
        { name: "org.apache.commons:commons-exec",
        requirement: "1.3",
        type: "runtime" },
        { name: "com.typesafe:config", requirement: "1.2.1", type: "runtime" },
        { name: "org.testng:testng", requirement: "6.8.7", type: "test" },
        { name: "org.mockito:mockito-all", requirement: "1.8.4", type: "test" },
        { name: "io.libraries:bibliothecary", requirement: "${bibliothecary.version}", type: "test" },
        { name: "io.libraries:recursive", requirement: "${recursive.test}", type: "runtime" },
        { name: "io.libraries:optional", requirement: "${optional.test}", type: "runtime", optional: true },
        { name: "io.libraries:not-optional", requirement: "${not-optional.test}", type: "runtime", optional: false },
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'raises FileParsingError on a broken pom.xml' do
    expect {
      described_class.parse_file('pom.xml', load_fixture('broken/pom.xml'))
    }.to raise_error(Bibliothecary::FileParsingError)
  end

  it 'parses dependencies from pom2.xml' do
    expect(described_class.analyse_contents('pom.xml', load_fixture('pom2.xml'))).to eq({
      platform: "maven",
      path: "pom.xml",
      dependencies: [
        { name: "org.apache.maven:maven-plugin-api",
          requirement: "3.3.9",
          type: "runtime" },
         { name: "org.apache.maven:maven-core",
          requirement: "3.3.9",
          type: "runtime" },
         { name: "org.apache.maven.plugin-tools:maven-plugin-annotations",
          requirement: "3.4",
          type: "provided" },
         { name: "org.codehaus.jackson:jackson-core-lgpl",
          requirement: "1.9.13",
          type: "runtime" },
         { name: "org.codehaus.jackson:jackson-mapper-lgpl",
          requirement: "1.9.13",
          type: "runtime" },
         { name: "org.apache.httpcomponents:httpclient",
          requirement: "4.5.2",
          type: "runtime" },
         { name: "org.apache.httpcomponents:httpmime",
          requirement: "4.5.2",
          type: "runtime" },
         { name: "org.testng:testng", requirement: "6.9.12", type: "test" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from ivy.xml' do
    expect(described_class.analyse_contents('ivy.xml', load_fixture('ivy.xml'))).to eq({
      platform: "maven",
      path: "ivy.xml",
      dependencies: [
        { name: "org.htmlparser:htmlparser", requirement: "2.1", type: "runtime" },
        { name: "org.apache.velocity:velocity",
        requirement: "1.7",
        type: "runtime" },
        { name: "commons-lang:commons-lang", requirement: "2.6", type: "runtime" },
        { name: "commons-collections:commons-collections",
        requirement: "3.2.2",
        type: "runtime" },
        { name: "org.json:json", requirement: "20151123", type: "runtime" },
        { name: "org.apache.ant:ant", requirement: "1.9.6", type: "runtime" },
        { name: "com.googlecode.java-diff-utils:diffutils",
        requirement: "1.3.0",
        type: "runtime" },
        { name: "junit:junit", requirement: "4.12", type: "runtime" },
        { name: "org.mockito:mockito-core",
        requirement: "1.10.19",
        type: "runtime" },
        { name: "org.hamcrest:hamcrest-all", requirement: "1.3", type: "runtime" },
        { name: "net.javacrumbs.json-unit:json-unit",
        requirement: "1.1.6",
        type: "runtime" },
        { name: "org.mozilla:rhino", requirement: "1.7.7", type: "runtime" }
      ],
      kind: 'manifest',
      success: true
    })
  end

  context 'gradle' do
    it 'parses various dependency syntax variations' do
      source = <<~FILE
        dependencies {
          compile 'com.whatever:liblib:1.2.3'
          compile 'this.is.a.group:greatlib'
          compile "com.fasterxml.jackson.core:jackson-databind"
          compileOnly "this.thing:neat" // I am a comment
          testCompile "hello.there:im.a.dep:$versionThing" // I am a comment
          compile('this.has:parens')
          compile 'junit:junit:4.13.2', { force = true }
        }
      FILE

      expect(described_class.analyse_contents('build.gradle', source)[:dependencies]).to match_array([
        { name: "com.whatever:liblib", requirement: "1.2.3", type: "compile" },
        { name: "this.is.a.group:greatlib", requirement: "*", type: "compile" },
        { name: "com.fasterxml.jackson.core:jackson-databind", requirement: "*", type: "compile" },
        { name: "this.thing:neat", requirement: "*", type: "compileOnly" },
        { name: "hello.there:im.a.dep", requirement: "$versionThing", type: "testCompile" },
        { name: "this.has:parens", requirement: "*", type: "compile" },
        { name: "junit:junit", requirement: "4.13.2", type: "compile" }
      ])
    end

    it 'parses dependencies from build.gradle' do
      expect(described_class.analyse_contents('build.gradle', load_fixture('build.gradle'))).to eq({
        platform: "maven",
        path: "build.gradle",
        dependencies: [
          { name: "com.squareup.okhttp:okhttp", requirement: "2.1.0", type: "compile" },
          { name: "com.squareup.okhttp:okhttp-urlconnection", requirement: "2.1.0", type: "compile" },
          { name: "com.squareup.picasso:picasso", requirement: "2.4.0", type: "compile" },
          { name: "com.google.android.gms:play-services-wearable", requirement: "8.3.0", type: "compile" },
          { name: "de.greenrobot:eventbus", requirement: "2.4.0", type: "compile" },
          { name: "com.android.support:appcompat-v7", requirement: "23.1.1", type: "compile" },
          { name: "com.android.support:recyclerview-v7", requirement: "23.1.1", type: "compile" },
          { name: "com.android.support:design", requirement: "23.1.1", type: "compile" },
          { name: "com.android.support:customtabs", requirement: "23.1.1", type: "compile" },
          { name: "com.google.guava:guava", requirement: "${guavaVersions['latest']}", type: "implementation" }
        ],
        kind: 'manifest',
        success: true
      })
    end

    it 'parses dependencies from build.gradle.kts' do
      expect(described_class.analyse_contents('build.gradle.kts', load_fixture('build.gradle.kts'))).to eq({
        platform: "maven",
        path: "build.gradle.kts",
        dependencies: [
          { name: "org.jetbrains.kotlin:kotlin-stdlib-jdk8", requirement: "*", type: "implementation" },
          { name: "com.google.guava:guava", requirement: "30.1.1-jre", type: "implementation" },
          { name: "org.jetbrains.kotlin:kotlin-test", requirement: "*", type: "testImplementation" },
          { name: "org.jetbrains.kotlin:kotlin-test-junit", requirement: "1.0.0", type: "testImplementation" },
          { name: "androidx.annotation:annotation", requirement: "${rootProject.extra[\"androidx_annotation_version\"]}", type: "implementation" }
        ],
        kind: 'manifest',
        success: true
      })
    end
  end

  it 'parses dependencies from an ivy report for a root project / type compile' do
    expect(described_class.analyse_contents('com.example-hello_2.12-compile.xml', load_fixture('ivy_reports/com.example-hello_2.12-compile.xml'))).to eq({
      platform: "maven",
      path: "com.example-hello_2.12-compile.xml",
      dependencies: [
        { name: "org.scala-lang:scala-library", requirement: "2.12.5", type: "compile" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'parses dependencies from an ivy report for a subproject / type test' do
    expect(described_class.analyse_contents('com.example-subproject_2.12-test.xml', load_fixture('ivy_reports/com.example-subproject_2.12-test.xml'))).to eq({
      platform: "maven",
      path: "com.example-subproject_2.12-test.xml",
      dependencies: [
        { name: "com.typesafe.akka:akka-stream_2.12", requirement: "2.5.6", type: "test" },
        { name: "com.typesafe:ssl-config-core_2.12", requirement: "0.2.2", type: "test" },
        { name: "org.scala-lang.modules:scala-parser-combinators_2.12", requirement: "1.0.4", type: "test" },
        { name: "org.reactivestreams:reactive-streams", requirement: "1.0.1", type: "test" },
        { name: "com.typesafe.akka:akka-actor_2.12", requirement: "2.5.6", type: "test" },
        { name: "org.scala-lang.modules:scala-java8-compat_2.12", requirement: "0.8.0", type: "test" },
        { name: "com.typesafe:config", requirement: "1.3.1", type: "test" },
        { name: "org.scala-lang:scala-library", requirement: "2.12.5", type: "test" }
      ],
      kind: 'lockfile',
      success: true
    })
  end

  it 'reports success: false on a broken ivy report' do
    expect(described_class.analyse_contents('missing_info.xml', load_fixture('ivy_reports/missing_info.xml'))).to eq({
      platform: "maven",
      path: "missing_info.xml",
      dependencies: nil,
      kind: 'lockfile',
      success: false,
      error_message: "missing_info.xml: ivy-report document lacks <info> element"
    })
  end

  it 'raises FileParsingError on a broken ivy report' do
    expect {
      described_class.parse_file('missing_info.xml', load_fixture('ivy_reports/missing_info.xml'))
    }.to raise_error(Bibliothecary::FileParsingError, "missing_info.xml: ivy-report document lacks <info> element")
  end

  it 'raises FileParsingError on an xml file with no ivy_report' do
    expect {
      described_class.parse_file('non_ivy_report.xml', load_fixture('ivy_reports/non_ivy_report.xml'))
    }.to raise_error(Bibliothecary::FileParsingError, "non_ivy_report.xml: No parser for this file type")
  end

  it 'returns [] on an .xml file with bad syntax' do
    expect {
      described_class.parse_file('invalid_syntax.xml', load_fixture('ivy_reports/invalid_syntax.xml'))
    }.to raise_error(Bibliothecary::FileParsingError, "invalid_syntax.xml: No parser for this file type")
  end

  it 'cannot determine kind on an ivy report with no contents specified' do
    expect(described_class.determine_kind(fixture_path('ivy_reports/com.example-hello_2.12-compile.xml'))).to be(nil)
  end

  it 'cannot determine kind on an ivy report with no contents available' do
    # this file doesn't really exist so we can't know it's an ivy report
    expect(described_class.determine_kind(fixture_path('whatever.xml'))).to be(nil)
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('pom.xml')).to be_truthy
    expect(described_class.match?('ivy.xml')).to be_truthy
    expect(described_class.match?('build.gradle')).to be_truthy
    expect(described_class.match?('build.gradle.kts')).to be_truthy
    # since the file doesn't really exist, we can't say it's a manifest file
    expect(described_class.match?('whatever.xml')).to be_falsey
    # but if it's a real file with contents we should be able to identify it has <ivy-report> in it
    expect(described_class.match?(fixture_path('ivy_reports/com.example-hello_2.12-compile.xml'),
                                  load_fixture('ivy_reports/com.example-hello_2.12-compile.xml'))).to be_truthy
    # but if it's a real file without contents we should not be able to identify it has <ivy-report> in it
    expect(described_class.match?(fixture_path('ivy_reports/com.example-hello_2.12-compile.xml'))).to be_falsey
    # not an ivy-report but ends in xml
    expect(described_class.match?(fixture_path('ivy_reports/non_ivy_report.xml'))).to be_falsey
    # not an ivy-report because bad xml
    expect(described_class.match?(fixture_path('ivy_reports/invalid_syntax.xml'))).to be_falsey
  end

  describe 'parent properties' do
    it 'totally ignores parent props' do
      parent_props = {}
      deps = described_class.parse_pom_manifest(load_fixture('pom.xml'), parent_props)

      jersey_dep = deps.find { |dep| dep[:name] == "io.libraries:bibliothecary" }
      expect(jersey_dep[:requirement]).to eq("${bibliothecary.version}")

      echo_parent_dep = deps.find { |dep| dep[:name] == "org.accidia:echo-parent" }
      expect(echo_parent_dep[:requirement]).to eq("0.1.23")
    end

    it 'uses parent properties during resolve' do
      parent_props = { "bibliothecary.version"=>"9.9.9" }
      deps = described_class.parse_pom_manifest(load_fixture('pom.xml'), parent_props)

      jersey_dep = deps.find { |dep| dep[:name] == "io.libraries:bibliothecary" }
      expect(jersey_dep[:requirement]).to eq("9.9.9")

      echo_parent_dep = deps.find { |dep| dep[:name] == "org.accidia:echo-parent" }
      expect(echo_parent_dep[:requirement]).to eq("0.1.23")
    end

    it 'uses parent properties during resolve when there are no properties in the pom file' do
      parent_props = { "bibliothecary.version"=>"9.9.9" }
      deps = described_class.parse_pom_manifest(load_fixture('pom_no_props.xml'), parent_props)

      bibliothecary_dep = deps.find { |dep| dep[:name] == "io.libraries:bibliothecary" }
      expect(bibliothecary_dep[:requirement]).to eq("9.9.9")
    end

    it "can extract parent properties specified with a lookup prefix during resolve" do
      parent_props = { "scm.url"=>"scm:git:git@github.com:accidia/echo.git" }
      
      # Esnure that all of these lookup variations resolve to the parent's relevant property.
      ["project.parent.scm.url", "project.scm.url", "scm.url"].each do |lookup_var|
        xml = Ox.parse(%Q!
        <?xml version="1.0" encoding="UTF-8"?>
        <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
          <scm><url>${#{lookup_var}}</url></scm>
        </project>!)
        scm_url = described_class.extract_pom_info(xml, "project/scm/url", parent_props)
        expect(scm_url).to eq("scm:git:git@github.com:accidia/echo.git")
      end
    end
  end

  it 'returns property name for missing property values' do
    deps = described_class.parse_pom_manifest(load_fixture('pom_missing_props.xml'))

    testng_dep = deps.find { |dep| dep[:name] == "org.testng:testng" }
    expect(testng_dep[:requirement]).to eq("${missing_property}")
  end

  it 'parses dependencies from maven-dependencies-q.txt' do
    deps = described_class.analyse_contents('maven-resolved-dependencies.txt', load_fixture('maven-resolved-dependencies.txt'))
    expect(deps[:kind]).to eq 'lockfile'
    spring_boot = deps[:dependencies].select {|item| item[:name] == "org.springframework.boot:spring-boot-starter-web" }
    expect(spring_boot.length).to eq 1
    expect(spring_boot.first[:requirement]).to eq '2.0.3.RELEASE'
    expect(spring_boot.first[:type]).to eq 'compile'
  end

  it 'parses dependencies from sbt-update-full.txt' do
    analysis = described_class.analyse_contents('sbt-update-full.txt', load_fixture('sbt-update-full.txt'))
    expect(analysis[:platform]).to eq("maven")
    expect(analysis[:path]).to eq("sbt-update-full.txt")
    expect(analysis[:kind]).to eq("lockfile")
    expect(analysis[:success]).to be true
    deps = analysis[:dependencies]

    # spot check we found a dep we expected
    algebra = deps.select {|item| item[:name] == "org.typelevel:algebra_2.12" }
    expect(algebra.map { |d| d[:requirement] }).to eq ['2.0.0-M2', '2.0.0-M2', '2.0.0-M2', '2.0.0-M2', '2.0.0-M2', '2.0.0-M2']
    expect(algebra.map { |d| d[:type] }.sort).to eq ['compile', 'compile-internal', 'runtime', 'runtime-internal', 'test', 'test-internal']


    # There's a 3.5 and a 3.2, where 3.2 gets evicted; we want to check that we evict 3.2
    commons_maths = deps.select {|item| item[:name] == "org.apache.commons:commons-math3" }
    expect(commons_maths.map { |d| d[:requirement] }).to eq ['3.5', '3.5', '3.5', '3.5', '3.5', '3.5']

    # these are some types that are in the file but shouldn't be used
    expect(deps.select {|item| item[:type] == "plugin" }).to eq []
    expect(deps.select {|item| item[:type] == "pom" }).to eq []
    expect(deps.select {|item| item[:type] == "provided" }).to eq []

    # be sure we can parse a type with a hyphen
    expect((deps.select {|item| item[:type] == "compile-internal" }).length).to eq 40

    # be sure we have no extraneous entries like leaving ":fields" in there
    keys = {}
    deps.each { |d| d.keys.each { |k| keys[k] = true } }
    expect(keys.keys.sort).to eq([:name, :requirement, :type])

    expect(deps.length).to eq 255
  end

  context "gradle" do
    it 'parses dependencies from gradle-dependencies-q.txt' do
      deps = described_class.analyse_contents('gradle-dependencies-q.txt', load_fixture('gradle-dependencies-q.txt'))
      expect(deps[:kind]).to eq 'lockfile'
      guavas = deps[:dependencies].select {|item| item[:name] == "com.google.guava:guava" && item[:type] == "api"}
      expect(guavas.length).to eq 1
      expect(guavas[0][:requirement]).to eq '25.1-jre'
    end

    it 'has the correct sections and dependencies from gradle-dependencies-q.txt' do
      deps = described_class.analyse_contents('gradle-dependencies-q.txt', load_fixture('gradle-dependencies-q.txt'))

      compile_classpath = deps[:dependencies].select {|item| item[:type] == "compileClasspath"}
      expect(compile_classpath.length).to eq 158
      expect(compile_classpath.select {|item| item[:name] == "org.apache.commons:commons-lang3"}.length).to eq 1

      runtime_classpath = deps[:dependencies].select {|item| item[:type] == "runtimeClasspath"}

      expect(runtime_classpath.length).to eq 159
      expect(runtime_classpath.select {|item| item[:name] == "com.google.guava:guava"}.length).to eq 1

      # test rename resolutions
      [
        { name: "commons-io:commons-io", requirement: "2.6", original_name: "apache:commons-io", original_requirement: "1.4" },
        { name: "axis:axis", requirement: "1.4", original_name: "apache:axis", original_requirement: "*" },
        { name: "axis:axis", requirement: "1.4", original_name: "another-alias-group:axis", original_requirement: "*" }
      ].each do |dep|
        renamed_dep = runtime_classpath.select do |d| 
          d.slice(:name, :requirement, :original_name, :original_requirement) == dep.slice(:name, :requirement, :original_name, :original_requirement)
        end
        expect(renamed_dep.length).to eq(1), "couldn't find dep '#{dep[:original_name]}' renamed to '#{dep[:name]}'"
      end
  
      test_runtime_only = deps[:dependencies].select {|item| item[:type] == "testRuntimeOnly"}

      expect(test_runtime_only.length).to eq 0

      test_runtime_classpath = deps[:dependencies].select {|item| item[:type] == "testRuntimeClasspath"}

      expect(test_runtime_classpath.length).to eq 188
      expect(test_runtime_classpath.select {|item| item[:name] == "org.glassfish.jaxb:jaxb-runtime"}.length).to eq 1


      test_compile_classpath = deps[:dependencies].select {|item| item[:type] == "testCompileClasspath"}

      expect(test_compile_classpath.length).to eq 189
      expect(test_compile_classpath.select {|item| item[:name] == "org.slf4j:jul-to-slf4j"}.length).to eq 1
    end

    it "excludes items in resolved deps file with no version" do
      expect(described_class.parse_gradle_resolved("\\--- org.springframework.security:spring-security-test (n)")).to eq []
    end

    it "excludes failed items with no version" do
      expect(described_class.parse_gradle_resolved("+--- org.projectlombok:lombok FAILED")).to eq []
    end

    it "includes local projects as deps with 'internal' group and '1.0.0' requirement" do
      expect(described_class.parse_gradle_resolved("+--- project :api:my-internal-project")).to eq [{
        name: "internal:api-my-internal-project",
        requirement: "1.0.0",
        type: nil
      }]
    end

    it "includes aliases to local projects" do
      expect(described_class.parse_gradle_resolved("|    +--- my-group:common-job-update-gateway-compress:5.0.2 -> project :client (*)")).to eq [{
        name: "internal:client",
        requirement: "1.0.0",
        original_name: "my-group:common-job-update-gateway-compress",
        original_requirement: "5.0.2",
        type: nil
      }]
    end

    it "includes failed items with a version" do
      expect(described_class.parse_gradle_resolved("+--- org.apiguardian:apiguardian-api:1.1.0 FAILED")).to eq [{
        name: "org.apiguardian:apiguardian-api",
        requirement: "1.1.0",
        type: nil
      }]
    end

    it "properly resolves versions with -> syntax" do
      arrow_syntax = "+--- org.springframework:spring-core:5.2.3.RELEASE -> 5.2.5.RELEASE (*)"
      expect(described_class.parse_gradle_resolved(arrow_syntax)).to eq [{
                                                                           name: "org.springframework:spring-core",
                                                                           requirement: "5.2.5.RELEASE",
                                                                           type: nil
                                                                         }]

    end

    it "skips self-referential project lines" do
      gradle_dependencies_out = <<-GRADLE
------------------------------------------------------------
Project ':submodules:test'
------------------------------------------------------------            

compileClasspath - Compile classpath for source set 'main'.
+--- project : (*)
GRADLE

      expect(described_class.parse_gradle_resolved(gradle_dependencies_out)).to eq []
    end

    it "properly handles no version to resolved version syntax" do
      no_version_to_version = "\\--- org.springframework.security:spring-security-test -> 5.2.2.RELEASE"
      expect(described_class
               .parse_gradle_resolved(no_version_to_version))
               .to eq [{
                         name: "org.springframework.security:spring-security-test",
                         requirement: "5.2.2.RELEASE",
                         type: nil
                       }]
    end

    it "parses dependencies from maven-dependency-tree files" do
      contents = load_fixture("maven-dependency-tree.txt")
      output = described_class.parse_maven_tree(contents)
      expect(output.count).to eq 314
      expect(output.find { |item| item[:name] == "org.apache.commons:commons-lang3"}[:requirement]).to eq "3.8.1"
      expect(output.find { |item| item[:name] == "net.sourceforge.pmd:pmd" }).to eq(nil)
    end

    it "parses dependencies with windows line endings" do
      contents = load_fixture("maven-dependency-tree.txt")
      contents = contents.gsub("\n", "\r\n")
      output = described_class.parse_maven_tree(contents)
      expect(output.count).to eq 314
      expect(output.find { |item| item[:name] == "org.apache.commons:commons-lang3"}[:requirement]).to eq "3.8.1"
    end

    it "parses dependencies with variables in version position" do
      output = described_class.parse_maven_tree("[INFO] net.sourceforge.pmd:pmd-scala_2.12:jar:${someVariable}\n")
      expect(output).to eq [{ name: "net.sourceforge.pmd:pmd-scala_2.12", requirement: "${someVariable}", type: "jar" }]
    end

    it "parses dependencies with ansi color codes by stripping the codes" do
      output = described_class.parse_maven_tree(%Q!
[\e[1;34mINFO\e[m] net.sourceforge.pmd:pmd-core:jar:6.32.0-SNAPSHOT
[\e[1;34mINFO\e[m] +- org.apache.ant:ant:jar:1.10.9:provided
[\e[1;34mINFO\e[m] |  +- net.sourceforge.pmd:pmd:pom:6.32.0-SNAPSHOT:provided
[\e[1;34mINFO\e[m] +- net.java.dev.javacc:javacc:jar:5.0:provided!)

      expect(output).to eq [
        { name: "org.apache.ant:ant", requirement: "1.10.9", type: "provided" },
        { name: "net.sourceforge.pmd:pmd", requirement: "6.32.0-SNAPSHOT", type: "provided" },
        { name: "net.java.dev.javacc:javacc", requirement: "5.0", type: "provided" },
      ]
    end

    it 'parses dependencies from gradle-dependencies-q.txt, generated from build.gradle.kts' do
      # This output should be the same format as from build.gradle, but including it just to have a fixture from build.gradle.kts documented.
      deps = described_class.analyse_contents('gradle-dependencies-q.txt', load_fixture('gradle_with_kotlin/gradle-dependencies-q.txt'))
      expect(deps[:kind]).to eq 'lockfile'
      guavas = deps[:dependencies].select {|item| item[:name] == "com.google.guava:guava" && item[:type] == "testCompileClasspath"}
      expect(guavas.length).to eq 1
      expect(guavas[0][:requirement]).to eq '30.1.1-jre'
    end
  end
end
