require 'spec_helper'

RSpec.describe Bibliothecary::Parsers::Maven do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('maven')
  end

  it 'parses dependencies from pom.xml' do
    expect(described_class.analyse_contents('pom.xml', load_fixture('pom.xml'))).to eq({
      :platform=>"maven",
      :path=>"pom.xml",
      :dependencies=>[
        {:name=>"org.accidia:echo-parent",
        :requirement=>"0.1.23",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.core:jersey-server",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.containers:jersey-container-servlet",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.containers:jersey-container-servlet-core",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.media:jersey-media-multipart",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.core:jersey-common",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.containers:jersey-container-jetty-http",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.containers:jersey-container-jetty-servlet",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.core:jersey-client",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"org.glassfish.jersey.media:jersey-media-moxy",
        :requirement=>"2.16",
        :type=>"runtime"},
        {:name=>"com.google.guava:guava", :requirement=>"18.0", :type=>"runtime"},
        {:name=>"com.googlecode.protobuf-java-format:protobuf-java-format",
        :requirement=>"1.2",
        :type=>"runtime"},
        {:name=>"mysql:mysql-connector-java",
        :requirement=>"5.1.9",
        :type=>"runtime"},
        {:name=>"org.springframework:spring-jdbc",
        :requirement=>"4.1.0.RELEASE",
        :type=>"runtime"},
        {:name=>"com.mchange:c3p0", :requirement=>"0.9.2.1", :type=>"runtime"},
        {:name=>"org.freemarker:freemarker",
        :requirement=>"2.3.21",
        :type=>"runtime"},
        {:name=>"org.jasypt:jasypt", :requirement=>"1.9.2", :type=>"runtime"},
        {:name=>"com.google.protobuf:protobuf-java",
        :requirement=>"2.5.0",
        :type=>"runtime"},
        {:name=>"redis.clients:jedis", :requirement=>"2.6.0", :type=>"runtime"},
        {:name=>"ch.qos.logback:logback-classic",
        :requirement=>"1.1.2",
        :type=>"runtime"},
        {:name=>"io.dropwizard.metrics:metrics-core",
        :requirement=>"3.1.0",
        :type=>"runtime"},
        {:name=>"net.spy:spymemcached", :requirement=>"2.11.7", :type=>"runtime"},
        {:name=>"io.dropwizard.metrics:metrics-jersey2",
        :requirement=>"3.1.0",
        :type=>"runtime"},
        {:name=>"io.dropwizard.metrics:metrics-annotation",
        :requirement=>"3.1.0",
        :type=>"runtime"},
        {:name=>"com.palominolabs.metrics:metrics-guice",
        :requirement=>"3.1.0",
        :type=>"runtime"},
        {:name=>"com.google.inject:guice", :requirement=>"3.0", :type=>"runtime"},
        {:name=>"commons-io:commons-io", :requirement=>"2.4", :type=>"runtime"},
        {:name=>"org.apache.commons:commons-exec",
        :requirement=>"1.3",
        :type=>"runtime"},
        {:name=>"com.typesafe:config", :requirement=>"1.2.1", :type=>"runtime"},
        {:name=>"org.testng:testng", :requirement=>"6.8.7", :type=>"test"},
        {:name=>"org.mockito:mockito-all", :requirement=>"1.8.4", :type=>"test"},
        {:name=>"io.libraries:bibliothecary", :requirement=>"${bibliothecary.version}", :type=>"test"},
        {:name=>"io.libraries:recursive", :requirement=>"${recursive.test}", :type=>"runtime"},
        # From dependencyManagement section
        {:name=>"org.apache.ant:ant", :requirement=>"1.9.2", :type=>"runtime"},
        {:name=>"commons-lang:commons-lang",:requirement=>"2.6", :type=>"runtime"}
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
      :platform=>"maven",
      :path=>"pom.xml",
      :dependencies=>[
        {:name=>"org.apache.maven:maven-plugin-api",
          :requirement=>"3.3.9",
          :type=>"runtime"},
         {:name=>"org.apache.maven:maven-core",
          :requirement=>"3.3.9",
          :type=>"runtime"},
         {:name=>"org.apache.maven.plugin-tools:maven-plugin-annotations",
          :requirement=>"3.4",
          :type=>"provided"},
         {:name=>"org.codehaus.jackson:jackson-core-lgpl",
          :requirement=>"1.9.13",
          :type=>"runtime"},
         {:name=>"org.codehaus.jackson:jackson-mapper-lgpl",
          :requirement=>"1.9.13",
          :type=>"runtime"},
         {:name=>"org.apache.httpcomponents:httpclient",
          :requirement=>"4.5.2",
          :type=>"runtime"},
         {:name=>"org.apache.httpcomponents:httpmime",
          :requirement=>"4.5.2",
          :type=>"runtime"},
         {:name=>"org.testng:testng", :requirement=>"6.9.12", :type=>"test"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from ivy.xml' do
    expect(described_class.analyse_contents('ivy.xml', load_fixture('ivy.xml'))).to eq({
      :platform=>"maven",
      :path=>"ivy.xml",
      :dependencies=>[
        {:name=>"org.htmlparser:htmlparser", :requirement=>"2.1", :type=>"runtime"},
        {:name=>"org.apache.velocity:velocity",
        :requirement=>"1.7",
        :type=>"runtime"},
        {:name=>"commons-lang:commons-lang", :requirement=>"2.6", :type=>"runtime"},
        {:name=>"commons-collections:commons-collections",
        :requirement=>"3.2.2",
        :type=>"runtime"},
        {:name=>"org.json:json", :requirement=>"20151123", :type=>"runtime"},
        {:name=>"org.apache.ant:ant", :requirement=>"1.9.6", :type=>"runtime"},
        {:name=>"com.googlecode.java-diff-utils:diffutils",
        :requirement=>"1.3.0",
        :type=>"runtime"},
        {:name=>"junit:junit", :requirement=>"4.12", :type=>"runtime"},
        {:name=>"org.mockito:mockito-core",
        :requirement=>"1.10.19",
        :type=>"runtime"},
        {:name=>"org.hamcrest:hamcrest-all", :requirement=>"1.3", :type=>"runtime"},
        {:name=>"net.javacrumbs.json-unit:json-unit",
        :requirement=>"1.1.6",
        :type=>"runtime"},
        {:name=>"org.mozilla:rhino", :requirement=>"1.7.7", :type=>"runtime"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from build.gradle', :vcr do
    expect(described_class.analyse_contents('build.gradle', load_fixture('build.gradle'))).to eq({
      :platform=>"maven",
      :path=>"build.gradle",
      :dependencies=>[
        {:name=>"com.squareup.okhttp:okhttp", :requirement=>"2.1.0", :type=>"compile"},
        {:name=>"com.squareup.okhttp:okhttp-urlconnection", :requirement=>"2.1.0", :type=>"compile"},
        {:name=>"com.squareup.picasso:picasso", :requirement=>"2.4.0", :type=>"compile"},
        {:name=>"com.google.android.gms:play-services-wearable", :requirement=>"8.3.0", :type=>"compile"},
        {:name=>"de.greenrobot:eventbus", :requirement=>"2.4.0", :type=>"compile"},
        {:name=>"com.android.support:appcompat-v7", :requirement=>"23.1.1", :type=>"compile"},
        {:name=>"com.android.support:recyclerview-v7", :requirement=>"23.1.1", :type=>"compile"},
        {:name=>"com.android.support:design", :requirement=>"23.1.1", :type=>"compile"},
        {:name=>"com.android.support:customtabs", :requirement=>"23.1.1", :type=>"compile"}
      ],
      kind: 'manifest',
      success: true
    })
  end

  it 'parses dependencies from an ivy report for a root project / type compile' do
    expect(described_class.analyse_contents('com.example-hello_2.12-compile.xml', load_fixture('ivy_reports/com.example-hello_2.12-compile.xml'))).to eq({
      platform: "maven",
      path: "com.example-hello_2.12-compile.xml",
      dependencies: [
        {:name=>"org.scala-lang:scala-library", :requirement=>"2.12.5", :type=>"compile"}
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
        {:name=>"com.typesafe.akka:akka-stream_2.12", :requirement=>"2.5.6", :type=>"test"},
        {:name=>"com.typesafe:ssl-config-core_2.12", :requirement=>"0.2.2", :type=>"test"},
        {:name=>"org.scala-lang.modules:scala-parser-combinators_2.12", :requirement=>"1.0.4", :type=>"test"},
        {:name=>"org.reactivestreams:reactive-streams", :requirement=>"1.0.1", :type=>"test"},
        {:name=>"com.typesafe.akka:akka-actor_2.12", :requirement=>"2.5.6", :type=>"test"},
        {:name=>"org.scala-lang.modules:scala-java8-compat_2.12", :requirement=>"0.8.0", :type=>"test"},
        {:name=>"com.typesafe:config", :requirement=>"1.3.1", :type=>"test"},
        {:name=>"org.scala-lang:scala-library", :requirement=>"2.12.5", :type=>"test"}
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

    expect(runtime_classpath.length).to eq 156
    expect(runtime_classpath.select {|item| item[:name] == "com.google.guava:guava"}.length).to eq 1

    test_runtime_only = deps[:dependencies].select {|item| item[:type] == "testRuntimeOnly"}

    expect(test_runtime_only.length).to eq 0

    test_runtime_classpath = deps[:dependencies].select {|item| item[:type] == "testRuntimeClasspath"}

    expect(test_runtime_classpath.length).to eq 187
    expect(test_runtime_classpath.select {|item| item[:name] == "org.glassfish.jaxb:jaxb-runtime"}.length).to eq 1

    test_compile_classpath = deps[:dependencies].select {|item| item[:type] == "testRuntimeClasspath"}

    expect(test_compile_classpath.length).to eq 187
    expect(test_runtime_classpath.select {|item| item[:name] == "org.slf4j:jul-to-slf4j"}.length).to eq 1
  end

  it 'uses parent properties during resolve' do
    parent_props = {"bibliothecary.version"=>"9.9.9"}
    deps = described_class.parse_pom_manifest(load_fixture('pom.xml'), parent_props)

    jersey_dep = deps.find { |dep| dep[:name] == "io.libraries:bibliothecary" }
    expect(jersey_dep[:requirement]).to eq("9.9.9")

    echo_parent_dep = deps.find { |dep| dep[:name] == "org.accidia:echo-parent" }
    expect(echo_parent_dep[:requirement]).to eq("0.1.23")
  end

  it 'parses dependencies from maven-dependencies-q.txt' do
    deps = described_class.analyse_contents('maven-resolved-dependencies.txt', load_fixture('maven-resolved-dependencies.txt'))
    expect(deps[:kind]).to eq 'lockfile'
    spring_boot = deps[:dependencies].select {|item| item[:name] == "org.springframework.boot:spring-boot-starter-web" }
    expect(spring_boot.length).to eq 1
    expect(spring_boot.first[:requirement]).to eq '2.0.3.RELEASE'
    expect(spring_boot.first[:type]).to eq 'compile'
  end
end
