require 'puppet/parser'

class Puppet_X::Binford2k::Itemize::Parser
  class Walker < Puppet::Pops::Model::ModelTreeDumper
    def initialize(filename)
      @filename = filename
      @parser   = evaluating_parser = Puppet::Pops::Parser::EvaluatingParser.new
      @visitor  = Puppet::Pops::Visitor.new(self,"dump",0,0)
      @dumper   = Puppet::Pops::Model::ModelTreeDumper.new
      super
    end

    def parse!
      source = Puppet::FileSystem.read(@filename)
      result = @parser.parse_string(source, @filename)
      @visitor.visit_this_0(self, result)
      nil
    end

    def dump!
      source = Puppet::FileSystem.read(@filename)
      result = @parser.parse_string(source, @filename)
      @dumper.dump(result)
      nil
    end

    def method_missing(meth)
      puts meth.id2name
    end

  end
end

class Puppet::Pops::Model::TreeDumper

  def format(x)
    puts x
  end

end
