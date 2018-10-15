require 'puppet'
require 'puppet/parser'
require 'puppet/util/logging'

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
    }
    Puppet::Util::Log.newdestination(:console)
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
      Puppet.err "Parse error for #{@filename}."
      Puppet.err e.message
      Puppet.debug e.backtrace.join "\n"
    end
    self
  end

  # Start walking the tree and count each tracked token
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
        case klass
        when Puppet::Pops::Model::ConcatenatedString
          # Because this is pre-compilation, we cannot resolve variables. So just tag w/ a marker
          # TODO: This should go somewhere else, but I'm not entirely sure where just now.
          record(:classes, klass.segments.map {|t| t.value rescue nil }.join('<??>'))
        else
          record(:classes, klass.value)
        end
      end

    when 'create_resources'
      Puppet.warning 'create_resources detected. Please update to use iteration instead.'
      record(:functions, function_name)
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
