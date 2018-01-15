require 'spec_helper'

describe Bibliothecary::Parsers::Maven do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('maven')
  end

  it 'parses dependencies from pom.xml' do
    expect(described_class.analyse_contents('pom.xml', load_fixture('pom.xml'))).to eq({
      :platform=>"maven",
      :path=>"pom.xml",
      :dependencies=>[
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
        {:name=>"org.mockito:mockito-all", :requirement=>"1.8.4", :type=>"test"}
      ],
      kind: 'manifest'
    })
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
      kind: 'manifest'
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
      kind: 'manifest'
    })
  end

  it 'parses dependencies from build.gradle' do
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
        {:name=>"com.android.support:customtabs", :requirement=>"23.1.1", :type=>"compile"},
      ],
      kind: 'manifest'
    })
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('pom.xml')).to be_truthy
    expect(described_class.match?('ivy.xml')).to be_truthy
    expect(described_class.match?('build.gradle')).to be_truthy
  end
end
