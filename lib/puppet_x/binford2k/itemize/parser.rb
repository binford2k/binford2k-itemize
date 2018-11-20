require 'puppet'
require 'puppet/parser'
require 'puppet/util/logging'
# require 'puppet_x/binford2k/itemize/monkeypatch'

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
    resource_name = value_of(o.type_name)
    case resource_name
    when 'class'
      # for classes declared as resource-style, we have to traverse back up the
      # tree to see if this resource body was declared by a class resource.
      o.bodies.each do |klass|
        case klass.title
        when Puppet::Pops::Model::LiteralList
          klass.title.values.each do |item|
            record(:classes, value_of(item))
          end
        else
          record(:classes, value_of(klass.title))
        end
      end
    else
      record(:types, resource_name)
    end
  end

  # postfix functions
  def count_CallMethodExpression(o)
    record_function(o, o.functor_expr.right_expr.value)
  end

  # prefix functions
  def count_CallNamedFunctionExpression(o)
    record_function(o, o.functor_expr.value)
  end

  def record_function(o, function_name)
    case function_name
    when 'include', 'contain', 'require'
      o.arguments.each do |klass|
        record(:classes, value_of(klass))
      end

    when 'create_resources'
      Puppet.warn_once(:dependency, 'create_resources', 'create_resources detected. Please update to use iteration instead.', :default, :default)
      record(:functions, function_name)
      record(:types, value_of(o.arguments.first))

    else
      record(:functions, function_name)
    end
  end

  def value_of(obj)
    case obj
    when Puppet::Pops::Model::ConcatenatedString
      obj.segments.map {|t| t.value rescue nil }.join('<??>')
    when Puppet::Pops::Model::VariableExpression,
         Puppet::Pops::Model::CallMethodExpression,
         Puppet::Pops::Model::LiteralDefault
      '<??>'
    when Puppet::Pops::Model::CallMethodExpression
      obj.functor_expr.right_expr.value
    when Puppet::Pops::Model::AccessExpression
      obj.keys.map {|t| t.value rescue nil }.join
    when Puppet::Pops::Model::ArithmeticExpression
      obj.left_expr.value + obj.operator + obj.right_expr.value
    when Puppet::Pops::Model::CallNamedFunctionExpression
      "#{obj.functor_expr.value}(#{obj.arguments.map {|a| a.value rescue nil }.join(',')})"
    else
      obj.value
    end
  end

  def dump!
    require 'json'
    puts JSON.pretty_generate(@results)
  end

end
