class DockerfileParser
  def initialize(file_contents)
    @file_contents = file_contents
  end

  def parse
    fromlines = @file_contents.split("\n").select { |line| line.strip =~ /^\FROM/i }
    
    fromlines.map do |line|
      line = line.strip.split(' ')

      # Remove the FROM keyword
      line.shift

      # Remove any flags
      line.reject! { |l| l =~ /^--/ }

      # Remove any comments
      line.reject! { |l| l =~ /^#/ }
      {
        name: line[0].split(':')[0],
        requirement: line[0].split(':')[1] || 'latest',
        type: 'build'
      }
    end
  end
end