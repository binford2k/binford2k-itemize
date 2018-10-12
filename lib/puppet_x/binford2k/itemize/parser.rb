require 'puppet'
require 'puppet/parser'

class Puppet_X::Binford2k::Itemize::Parser
  attr_reader :results

  def initialize(filename, options = {})
    @@visitor ||= Puppet::Pops::Visitor.new(nil, "count", 0, 0)
    @filename   = filename
    @options    = options
    @results    = {
      :types     => {},
      :classes   => {},
      :functions => {},
      :errors    => [],
      :warnings  => [],
    }
  end

  def record(kind, thing)
    fail("Unknown kind #{kind}") unless @results.keys.include? kind

    thing = thing.sub(/^::/, '')
    @results[kind][thing] ||= 0
    @results[kind][thing]  += 1
  end

  def parse!
    begin
      parser = Puppet::Pops::Parser::EvaluatingParser.new
      source = Puppet::FileSystem.read(@filename)
      result = parser.parse_string(source, @filename)
      compute(result)
    rescue => e
      @results[:errors] << "Parse error for #{@filename}."
      @results[:errors] << e.message
      @results[:errors].concat e.backtrace if @options[:debug]
    end
    self
  end

  # Computes abc score (1 per assignment)
  def compute(target)
    @path = []
    count(target)
    target._pcore_all_contents(@path) { |element| count(element) }
# Puppet 4.x version
#    target.eAllContents.each {|m|  abc(m) }
    @results
  end

  def count(o)
    @@visitor.visit_this_0(self, o)
  end

  def count_Object(o)
    # nop
  end

  def count_ResourceExpression(o)
    resource_name = o.type_name.value
    case resource_name
    when 'class'
      # for classes declared as resource-style, we have to traverse back up the
      # tree to see if this resource body was declared by a class resource.
      o.bodies.each do |klass|
        record(:classes, klass.title.value)
      end
    else
      record(:types, resource_name)
    end
  end

  def count_CallNamedFunctionExpression(o)
    function_name = o.functor_expr.value
    case function_name
    when 'include'
      o.arguments.each do |klass|
        record(:classes, klass.value)
      end

    when 'create_resources'
      @results[:warnings] << 'create_resources detected. Please update to use iteration instead.'
      record(:types, o.arguments.first.value)

    else
      record(:functions, function_name)
    end
  end

  def dump!
    require 'json'
    puts JSON.pretty_generate(@results)
  end

end
