require "optparse"

require "awt"
require "awt/dsl"

include Awt::DSL

module Awt
  class CLI
    attr_reader :executable

    def initialize
      parse_opt
    end

    def execute
      register_targets(@hosts)
      raise "Awtfile not found." if @task_file.nil?
      load @task_file
      $AWT_TASKS[@task_name].exec($AWT_TARGETS)
    end

    class << self
      def start
        begin
          cli = self.new
          cli.execute
        rescue => e
          puts e
        end
      end
    end

    private
    def parse_opt
      @options = {}
      @hosts = []
      @task_file = task_find
      OptionParser.new do |opt|
        opt.version = VERSION
        opt.banner = "Usage: awt [options] TASK_NAME"
        opt.on("-H HOSTNAME", "target host names.") {|v| @hosts = v.split(",")}
        opt.on("-u USER", "login user.") {|v| @options[:user] = v}
        opt.on("-p PORT", "ssh port number.") {|v| @options[:port] = v.to_i}
        opt.on("-i IDENTITY_FILE", "SSH private key file.") {|v| @options[:key] = v}
        opt.on("-f Awtfile", "Task file.") {|v| @task_file = v}
        opt.parse!(ARGV)
      end

      raise "Task name is not specified." if ARGV.empty?
      @task_name = ARGV.first.to_sym
    end

    def register_targets(hosts)
      hosts.each do |host|
        server host, @options
      end
    end
  end
end
