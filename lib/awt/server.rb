module Awt
  class Server
    attr_accessor :host, :user, :options

    def initialize(host: "localhost", port: 22, user: nil, key: "~/.ssh/id_rsa")
      @host = host
      @user = user.nil? ? ENV["USER"] : user
      @options = {port: port, keys: File.expand_path(key)}
      @printer = Printer.new(@host)
    end

    def run(cmd)
      @printer.host = @host if @printer.host != @host
      Net::SSH.start(@host, @user, @options) do |ssh|
        @printer.print_run cmd
        out = ssh.exec!(cmd)
        @printer.print_out out
      end
    end
  end
end
