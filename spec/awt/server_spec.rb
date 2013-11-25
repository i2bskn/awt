require "spec_helper"

describe Awt::Server do
  let(:server) {Awt::Server.new}
  let(:ssh) {double("Net::SSH mock").as_null_object}
  let(:scp) {double("Net::SCP mock").as_null_object}
  let(:local) {"/local/file"}
  let(:remote) {"/remote/file"}

  describe "#initialize" do
    context "with default params" do
      it "should set default host" do
        expect(server.host).to eq("localhost")
      end

      it "should set default port" do
        expect(server.options[:port]).to eq(22)
      end

      it "should set default user" do
        expect(server.user).to eq(ENV["USER"])
      end

      it "should set default key" do
        expect(server.options[:keys]).to eq(File.expand_path("~/.ssh/id_rsa"))
      end

      it "should set printer" do
        expect(server.instance_eval{@printer}.is_a? Awt::Printer).to be_true
      end
    end

    context "with specified params" do
      it "should set specified host" do
        server = Awt::Server.new(host: "example.com")
        expect(server.host).to eq("example.com")
      end

      it "should set specified port" do
        server = Awt::Server.new(port: 30022)
        expect(server.options[:port]).to eq(30022)
      end

      it "should set specified user" do
        server = Awt::Server.new(user: "awt")
        expect(server.user).to eq("awt")
      end

      it "should set specified key" do
        server = Awt::Server.new(key: "/path/to/id_rsa")
        expect(server.options[:keys]).to eq("/path/to/id_rsa")
      end
    end
  end

  describe "#run" do
    let(:channel) {double.as_null_object}

    before do
      channel.stub(:exec).with("example").and_yield(double, double)
      ssh.stub(:open_channel).and_yield(channel)
      Net::SSH.stub(:start).and_yield(ssh)
      Awt::Printer.any_instance.stub(:print_run)
      Awt::Printer.any_instance.stub(:print_out)
      Awt::Printer.any_instance.stub(:print_ext)
    end

    after {server.run("example")}

    it "should call Awt::Printer#print_*" do
      Awt::Printer.any_instance.should_receive(:print_run)
    end

    it "should call #on_data" do
      channel.should_receive(:on_data).and_yield(double, double)
      Awt::Printer.any_instance.should_receive(:print_out)
    end

    it "should call #on_extended_data" do
      channel.should_receive(:on_extended_data).and_yield(double, double, double)
      Awt::Printer.any_instance.should_receive(:print_ext)
    end

    it "should call #on_request" do
      channel.should_receive(:on_request).with("exit-status").and_yield(double, double.as_null_object)
    end

    it "should call #loop" do
      ssh.should_receive(:loop)
    end

    it "should call #reset_printer_host" do
      Awt::Server.any_instance.should_receive(:reset_printer_host)
    end
  end

  describe "#put" do
    before do
      ssh.stub(:scp).and_return(scp)
      Net::SSH.stub(:start).and_yield(ssh)
      Awt::Printer.any_instance.stub(:print_upload)
    end

    after {server.put(local, remote)}

    it "should call Awt::Printer#print_*" do
      Awt::Printer.any_instance.should_receive(:print_upload)
    end

    it "should call #upload! of Net::SCP" do
      scp.should_receive(:upload!)
    end

    it "should call #reset_printer_host" do
      Awt::Server.any_instance.should_receive(:reset_printer_host)
    end
  end

  describe "#get" do
    before do
      ssh.stub(:scp).and_return(scp)
      Net::SSH.stub(:start).and_yield(ssh)
      Awt::Printer.any_instance.stub(:print_download)
    end

    after {server.get(remote, local)}

    it "should call Awt::Printer#print_*" do
      Awt::Printer.any_instance.should_receive(:print_download)
    end

    it "should call #download! of Net::SCP" do
      scp.should_receive(:download!)
    end

    it "should call #reset_printer_host" do
      Awt::Server.any_instance.should_receive(:reset_printer_host)
    end
  end

  describe "#reset_printer_host" do
    after {server.send(:reset_printer_host)}

    it "should re-set host of Printer if changed host" do
      Awt::Printer.any_instance.should_receive(:host=)
      server.host = "example.com"
    end

    it "should not re-set host of Printer" do
      Awt::Printer.any_instance.should_not_receive(:host=)
    end
  end
end
