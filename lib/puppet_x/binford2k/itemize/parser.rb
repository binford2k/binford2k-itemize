class Puppet_X::Binford2k::Itemize::Parser
  require 'open3'
  require 'puppet_x/binford2k/itemize/parser/s_expression_parser'
  attr_reader :results

  def initialize(path, options = {})
    @path    = path
    @options = options
    @results = {
      :types     => {},
      :classes   => {},
      :functions => {},
      :errors    => [],
      :warnings  => [],
    }

    # TODO: replace this with a real parser using the visitor pattern
    output, status = Open3.capture2e('puppet', 'parser', 'dump', path)
    if status.success?
      @ast = SExpressionParser.new(output)
    else
      @results[:errors] << "Parse error for #{path}."
      @results[:errors].concat output.lines if @options[:debug]
      @ast = SExpressionParser.new('')
    end
  end

  def record(kind, thing)
    fail("Unknown kind #{kind}") unless @results.keys.include? kind
    thing.delete!("'")
    thing.gsub!(/(^::|::$)/, '')

    @results[kind][thing] ||= 0
    @results[kind][thing]  += 1
  end

  def parse!
    while (tok = @ast.next_token)
      if tok == 'resource'
        ntok = @ast.next_token
        if ntok == 'class'
          @ast.next_token
          record(:classes, @ast.next_token)
        else
          record(:types, ntok)
        end
      elsif ['invoke', 'call'].include? tok
        ntok = @ast.next_token
        record(:functions, ntok)

        if ntok == 'include'
          while (klass = @ast.next_token) != ')'
            break if klass == '('
            record(:classes, klass)
          end
        elsif ntok == 'create_resources'
          results[:warnings] << 'create_resources detected. Please update to use iteration instead.'
          record(:types, @ast.next_token)
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
