class Puppet_X::Binford2k::Itemize::Runner
  require 'tty-progressbar'

  attr_reader :results
  def initialize(options = {})
    @paths   = expand(Array(options[:manifests]))
    @options = options
    @results = {}
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
    bar = TTY::ProgressBar.new("Itemizing [:bar]", total: @paths.size)
    bar.start
    @paths.each do |path|
      bar.log path if @options[:verbose]

      parser = Puppet_X::Binford2k::Itemize::Parser.new(path, @options).parse!
      parser.results.delete(:errors).each {|err| bar.log "ERROR: #{err}" }
      parser.results.delete(:warnings).each {|wrn| bar.log "WARNING: #{wrn}" }
      parser.results.each do |kind, counts|
        @results[kind] ||= {}

        counts.each do |name, count|
          @results[kind][name] ||= 0
          @results[kind][name]  += count
        end
      end
      bar.advance
    end
    bar.reset
    self
  end

  def dump!
    require 'json'
    puts JSON.pretty_generate(@results)
  end

end