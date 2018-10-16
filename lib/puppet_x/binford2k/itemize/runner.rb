require 'json'

class Puppet_X::Binford2k::Itemize::Runner
  attr_reader :results
  def initialize(options = {})
    @paths     = expand(Array(options[:manifests]))
    @options   = options
    @results   = {}

    if options[:external] and options[:manifests].size == 1
      path = options[:manifests].first.chomp('/')
      if path.end_with? 'manifests'
        metadata   = JSON.parse(File.read(File.expand_path("#{path}/../metadata.json")))
        author     = metadata['author']
        @namespace = metadata['name'].sub(/^#{author}-/, '') + '::'

        @dependencies = metadata['dependencies'].map do |dep|
          dep['name'].split(/-\//).last
        end
      end
    end
  end

  def expand(paths)
    paths.map do |path|
      path = File.expand_path(path)

      if File.file? path
        path
      elsif File.directory? path
        Dir.glob("#{path}/**/*.pp")
      else
        raise "Path '#{path}' doesn't appear to be a file or directory"
      end
    end.flatten
  end

  def run!
    @paths.each do |path|
      parser = Puppet_X::Binford2k::Itemize::Parser.new(path, @options).parse!
      parser.results.each do |kind, counts|
        @results[kind] ||= {}

        counts.each do |name, count|
          next if @namespace and name =~ /^#{@namespace}/

          @results[kind][name] ||= 0
          @results[kind][name]  += count
        end
      end
    end
    self
  end

  def dump!
    require 'json'
    puts JSON.pretty_generate(@results)
  end

end