class Puppet_X::Binford2k::Itemize::Cli
  def initialize(options = {})
    @options = options
  end

  def run!
    runner   = Puppet_X::Binford2k::Itemize::Runner.new(@options).run!
    @results = runner.results
    self
  end

  def render!
    run!

    case @options[:render]
    when :human
      puts to_s
    when :json
      puts to_json
    when :yaml
      puts to_yaml
    else
      raise "Invalid render type (#{@options[:render]})."
    end
  end

  def to_s
    require 'tty-table'
    table = TTY::Table.new
    @results.each do |kind, counts|
      table << ["#{kind}:", nil, nil]

      counts.each do |name, count|
        table << ['', {value: name, alignment: :right}, {value: count, alignment: :right}]
      end
    end
    output  = "Resource usage analysis:\n"
    output += '=' * (table.width + 8)
    output += "\n"
    output += table.render padding: [0,1]
    output
  end

  def to_json
    require 'json'
    JSON.pretty_generate(@results)
  end

  def to_yaml
    require 'yaml'
    @results.to_yaml
  end

end
