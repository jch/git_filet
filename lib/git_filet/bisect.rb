module GitFilet
  class Bisect
    def initialize(opts = {})
      @options = {
        :fail        => commit_for(opts[:fail] || 'HEAD'),
        :pass        => commit_for(opts[:pass] || 'HEAD~1'),
        :command_log => '/dev/null',
        :bisect_log  => '/dev/null'
      }.merge(opts)
      @options.symbolize_keys!
      puts @options.inspect
    end

    def commit_for(pathspec)
      `git log -1 --format=%H #{pathspec}`.chomp
    end

    def oneline_for(pathspec)
      `git log -1 --oneline #{pathspec}`.chomp
    end

    # Find a passing commit with exponential backoff
    #
    # @returns [Hash] params
    # @option params :fail pathspec of failing commit
    # @option params :pass pathspec of passing commit
    def find_pass(command, args={})
      args = {
        :step => 1,
        :fail => @options[:fail],
        :pass => @options[:pass]
      }.merge(args)

      if !system("git reset --hard -q #{@options[:fail]} && git reset --hard -q #{args[:pass]} 2> /dev/null")
        puts "  couldn't find any pass commit, fell off the history"
        args[:pass] = nil
        return args
      end

      print "  looking #{args[:step]} commits back at: #{oneline_for(args[:pass])} ... "
      File.open(@options[:command_log], 'w+') {|fh| fh.puts command}
      success = system("#{command} >>#{@options[:command_log]} 2>&1")
      if success
        puts '  pass!'
        args
      else
        puts 'failing'
        args[:step] = args[:step] * 2
        args[:fail] = commit_for('HEAD')
        args[:pass] = commit_for("HEAD~#{args[:step]}")
        find_pass(command, args)
      end
    end

    def exec(args={})
      at_exit {
        puts
        puts "Reverting back to starting point #{@options[:fail]}"
        `git reset --hard -q #{@options[:fail]}`
      }

      puts "Finding a passing commit for: #{@options[:command]}"
      commits = find_pass(@options[:command])
      return if commits[:pass].nil?

      puts "Starting bisection from #{commits[:step]} commits ago."
      puts "pass: #{oneline_for(commits[:pass])}"
      puts "fail:  #{oneline_for(commits[:fail])}"
      puts

      system("git bisect start #{commits[:fail]} #{commits[:pass]} && git bisect run #{@options[:command]} >> #{@options[:command_log]} 2>&1")
      system("git bisect log > #{@options[:bisect_log]}")
    end
  end
end