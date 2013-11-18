require "spec_helper"

describe Awt::Server do
  describe "#initialize" do
    context "with default params" do
      let(:server) {Awt::Server.new}

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
    let(:server) {Awt::Server.new}
    let(:ssh) {double("Net::SSH mock").as_null_object}

    before do
      Net::SSH.stub(:start).and_yield(ssh)
      Awt::Printer.any_instance.stub(:print_run)
      Awt::Printer.any_instance.stub(:print_out)
    end

    after {server.run("example")}

    it "should call Awt::Printer#print_*" do
      Awt::Printer.any_instance.should_receive(:print_run)
      Awt::Printer.any_instance.should_receive(:print_out)
    end

    it "should call Net::SSH::Connection::Session#exec" do
      ssh.should_receive(:exec!)
    end

    it "should re-set host of Printer" do
      Awt::Printer.any_instance.should_receive(:host=)
      server.host = "example.com"
    end
  end
end
