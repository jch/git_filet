require "thor"
require "thor/group"

module GitFilet
  class CLI < Thor
    include Thor::Actions
    BANNER = <<-EOL
git-filet - find pass and fail commits for regression testing

EOL

    default_task :exec

    desc "exec", 'find passing and failing commits with COMMAND. Run git bisect.'
    method_option :fail, :type => :string, :default => 'HEAD', :banner => "The initial fail commit to start looking from"
    method_option :pass, :type => :string, :banner => "Last known pass commit. Automatically determined if not specified"
    method_option :command_log, :type => :string, :banner => "Path for logging run command output"
    method_option :bisect_log, :type => :string, :banner => "Path for logging git bisect log"
    argument :command, :optional => true, :type => :string
    def exec
      if command
        GitFilet::Bisect.new(options.merge(:command => command)).exec
      else
        puts BANNER
        help
      end
    end
  end
end
