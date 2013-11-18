require "spec_helper"

describe Awt::CLI do
  let(:cli) {Awt::CLI.new}

  before do
    ARGV.clear
    ["-H", "host1,host2", "-u", "awt", "-p", "30022", "-i", "/path/to/id_rsa", "-f", "Awtfile", "example"].each do |opt|
      ARGV << opt
    end
  end

  describe "#initialize" do
    it "should call CLI#parse_opt" do
      Awt::CLI.any_instance.should_receive(:parse_opt)
      Awt::CLI.new
    end
  end

  describe "#execute" do
  end

  describe "#parse_opt" do
    it "should set task_name" do
      expect(cli.instance_eval{@task_name}).to eq(:example)
    end

    it "should set hosts" do
      expect(cli.instance_eval{@hosts}).to eq(["host1", "host2"])
    end

    it "should set user" do
      expect(cli.instance_eval{@options[:user]}).to eq("awt")
    end

    it "should set port" do
      expect(cli.instance_eval{@options[:port]}).to eq(30022)
    end

    it "should set port" do
      expect(cli.instance_eval{@options[:key]}).to eq("/path/to/id_rsa")
    end

    it "should set task file" do
      expect(cli.instance_eval{@task_file}).to eq("Awtfile")
    end
  end

  describe "#register_targets" do
    it "should add targets" do
      cli.send(:register_targets, cli.instance_eval{@hosts})
      expect($AWT_TARGETS.size).to eq(2)
    end
  end

  describe ".#start" do
  end
end
