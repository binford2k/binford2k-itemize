class Puppet_X::Binford2k::Itemize::Parser
  # Cribbed from https://gist.github.com/fogus/1686917
  class SExpressionParser
    def initialize(expression)
      @tokens = expression.scan /[()]|\w+|".*?"|'.*?'/
    end

    def peek
      @tokens.first
    end

    def next_token
      @tokens.shift
    end

    def parse
      if (token = next_token) == '('
        parse_list
      elsif token =~ /['"].*/
        token[1..-2]
      elsif token =~ /\d+/
        token.to_i
      else
        token.to_sym
      end
    end

    def parse_list
      list = []
      list << parse until peek == ')'
      next_token
      list
    end
  end
end