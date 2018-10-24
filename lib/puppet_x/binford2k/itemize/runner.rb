require 'puppet'
require 'puppet/util/logging'
require 'json'

class Puppet_X::Binford2k::Itemize::Runner
  attr_reader :results
  def initialize(options = {})
    Puppet::Util::Log.newdestination(:console)

    @paths     = expand(Array(options[:manifests]))
    @options   = options
    @results   = {}

    if options[:manifests].size == 1
      root = options[:manifests].first
      path = [File.expand_path("#{root}/metadata.json"),
              File.expand_path("#{root}/../metadata.json")].select { |p| File.exist? p }.first

      if path
        @metadata  = JSON.parse(File.read(File.expand_path("#{path}/../metadata.json")))
        author     = @metadata['author']
        @namespace = @metadata['name'].sub(/^#{author}-/, '')

        # we can only use the module name part of this, not the user namespace
        @dependencies = @metadata['dependencies'].map do |dep|
          dep['name'].split(/[-\/]/).last
        end
        # inject a few mocked dependencies that we can assume will always exist
        @dependencies << @namespace
        @dependencies << 'puppet_enterprise'
      else
        # what error to display here?
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
          segments = name.split('::')
          if @dependencies and segments.size > 1
            Puppet.warn_once(:dependency, name, "Undeclared module dependancy: #{name}", :default, :default) unless @dependencies.include? segments.first
          end
          next if @options[:external] and segments.first == @namespace

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