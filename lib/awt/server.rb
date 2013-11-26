module Awt
  class Server
    attr_accessor :host, :user, :options, :envs

    def initialize(host: "localhost", port: 22, user: nil, key: "~/.ssh/id_rsa")
      @host = host
      @user = user.nil? ? ENV["USER"] : user
      @options = {port: port, keys: File.expand_path(key)}
      @printer = Printer.new(@host)
    end

    def with_env(envs, &block)
      env = []
      envs.each {|k,v| env << "export #{k.to_s.upcase}=\"#{v}\""}
      @envs = env.join(";") unless env.empty?
      self.instance_eval &block
      @envs = nil
    end

    def run(cmd)
      reset_printer_host
      cmd = "#{@envs};#{cmd}" if @envs
      result = OpenStruct.new

      Net::SSH.start(@host, @user, @options) do |ssh|
        @printer.print_run cmd
        ssh.open_channel do |channel|
          channel.exec cmd do |ch, success|
            channel.on_data {|ch,data| result.data = data}
            channel.on_extended_data {|ch,type,data| result.extended_data = data}
            channel.on_request("exit-status") {|ch,data| result.status = data.read_long}
          end
        end
        ssh.loop
      end

      @printer.print_out result.data if result.data
      @printer.print_ext result.extended_data if result.extended_data
      result
    end

    def put(local, remote)
      reset_printer_host
      Net::SSH.start(@host, @user, @options) do |ssh|
        @printer.print_upload local
        ssh.scp.upload! local, remote
      end
    end

    def get(remote, local)
      reset_printer_host
      Net::SSH.start(@host, @user, @options) do |ssh|
        @printer.print_download remote
        ssh.scp.download! remote, local
      end
    end

    private
    def reset_printer_host
      @printer.host = @host if @printer.host != @host
    end
  end
end
