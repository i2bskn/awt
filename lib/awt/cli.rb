require "optparse"

require "awt"
require "awt/dsl"

include Awt::DSL

module Awt
  class CLI
    def initialize
      parse_opt
    end

    def register_tagets(hosts)
      hosts.each do |host|
        server host, @options
      end
    end

    def execute
      register_tagets(@hosts)
      unless @task_file.nil?
        load @task_file
        $AWT_TASKS[@task_name].exec($AWT_TARGETS)
      end
    end

    class << self
      def start
        cli = self.new
        cli.execute
      end
    end

    private
    def parse_opt
      @options = {}
      OptionParser.new do |opt|
        opt.version = VERSION
        opt.banner = "Usage: awt [options] TASK_NAME"
        opt.on("-H HOSTNAME", "target host names.") {|v| @options[:hosts] = v.split(",")}
        opt.on("-u USER", "login user.") {|v| @options[:user] = v}
        opt.on("-p PORT", "ssh port number.") {|v| @options[:port] = v.to_i}
        opt.on("-i IDENTITY_FILE", "SSH private key file.") {|v| @options[:key] = v}
        opt.on("-f Awtfile", "Task file.") {|v| @options[:task_file] = v}

        begin
          opt.parse!(ARGV)
        rescue => e
          puts e
          exit 1
        end
      end

      @task_name = ARGV.first.to_sym
      @hosts = @options.delete(:hosts) || []
      @task_file = @options.delete(:task_file) || task_find
    end
  end
end
