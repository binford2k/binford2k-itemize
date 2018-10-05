require 'puppet/face'
require 'puppet_x/binford2k/itemize'
require 'puppet_x/binford2k/itemize/cli'

Puppet::Face.define(:parser, '0.0.1') do
  action :itemize do
    summary   "Count the number of types, classes, functions used in manifest(s)"
    arguments "[<manifest>] [<manifest> ...]"
    returns   "Displays count in human readable, json, or yaml format."
    description <<-'EOT'
Run this command with a space separated list of either manifest file paths, or
directories containing manifests. If omitted, it will default to inspecting all
manifests in the manifests directory, so you can just run this in the root of a
Puppet module and it will do the right thing.
    EOT

    option('--shell') do
      summary 'Start a debugging shell (requires Pry).'
    end

    examples <<-'EOT'
      $ puppet parser itemize
      $ puppet parser itemize manifests
      $ puppet parser itemize manifests/init.pp
      $ puppet parser itemize manifests/init.pp manifests/example/path.pp
    EOT

    when_invoked do |*args|
      options = args.pop
      options[:manifests] = args.empty? ? 'manifests' : args
      options[:verbose]   = [:info, :debug].include? Puppet::Util::Log.level
      options[:debug]     = Puppet::Util::Log.level == :debug

      if options[:shell]
        require 'pry'
        binding.pry
      end

      Puppet_X::Binford2k::Itemize::Cli.new(options).run!
    end

    when_rendering :console do |results|
      results.to_s
    end

  end

#   def dump(o)
#     format(do_dump(o))
#   end
#
#   def main
#     Puppet::Util::Log.newdestination(:console)
#     set_log_level
#
#     while (filename = command_line.args.shift)
#       raise "Could not find script file #{filename}" unless Puppet::FileSystem.exist?(filename)
#
#       source       = Puppet::FileSystem.read(filename)
#       parse_result = evaluating_parser.parse_string(source, filename)
#       dump_visitor = Puppet::Pops::Visitor.new(nil,"dump",0,0)
#       dump_visitor.visit_this_0(self, parse_result)
#
#       require 'pry'
#       binding.pry
#
#       validation_environment = Puppet::Node::Environment.create(:production, [])
#       validation_environment.check_for_reparse
#       validation_environment.known_resource_types.clear
#
#     end
#
#   end

end
