class ModelfileParser
  def initialize(file_contents)
    @file_contents = file_contents
  end

  def parse
    fromlines = @file_contents.split("\n").select { |line| line.strip =~ /^FROM/i }

    fromlines.map do |line|
      line = line.strip.split

      # Remove the FROM keyword
      line.shift

      # Remove any flags
      line.reject! { |l| l =~ /^--/ }

      # Remove any comments
      line.reject! { |l| l =~ /^#/ }

      # Parse the model reference
      # Can be: model_name:tag, ./path/to/model.gguf, or /absolute/path
      model_ref = line[0]

      # Check if it's a file path (local GGUF or directory)
      if model_ref =~ /\.(gguf|safetensors)$/i || model_ref.start_with?("./", "/")
        {
          name: File.basename(model_ref),
          requirement: "local",
          type: "runtime",
        }
      else
        # It's a registry model (e.g., llama3.2 or llama3.2:latest)
        parts = model_ref.split(":")
        {
          name: parts[0],
          requirement: parts[1] || "latest",
          type: "runtime",
        }
      end
    end
  end
end
