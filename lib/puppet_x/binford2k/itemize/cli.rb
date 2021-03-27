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
    name_width  = 2
    count_width = 2
    @results.each do |kind, counts|
      counts.each do |name, count|
        name_width  = [name_width, name.size].max
        count_width = [count_width, count.to_s.size].max
      end
    end

    output  = "Resource usage analysis:\n"
    output << '=' * (name_width + count_width + 8)
    output << "\n"
    @results.each do |kind, counts|
      output << ">> #{kind}:\n"

      counts.each do |name, count|
        output << sprintf("    %#{name_width}s | %#{count_width}s\n", name, count)
      end
      output << "\n"

      instances = counts.reduce(0) { |acc, c| acc + c[1] }

      output << sprintf("    %#{name_width}s | %#{count_width}s\n", "Totals: #{counts.count}", instances)
      output << "\n"
    end
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
