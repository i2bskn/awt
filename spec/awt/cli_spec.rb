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
    before do
      Awt::Server.any_instance.stub(:run)
      Awt::CLI.any_instance.stub(:load)
      cli.instance_eval do
        task :example do
          run "something"
        end
      end
    end

    after do
      $AWT_TASKS.clear
      $AWT_TARGETS.clear
    end

    it "should call #register_targets" do
      Awt::CLI.any_instance.should_receive(:register_targets).with(["host1", "host2"])
      cli.execute
    end

    it "should throw exception if @task_file is nil" do
      cli.instance_eval {@task_file = nil}
      expect {
        cli.execute
        }.to raise_error
    end

    it "should load task file" do
      Awt::CLI.any_instance.should_receive(:load)
      cli.execute
    end

    it "should call Awt::Task#exec" do
      mock = double("Awt::Task mock").as_null_object
      mock.should_receive(:exec)
      $AWT_TASKS.store(:example, mock)
      cli.execute
    end
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
    before {$AWT_TARGETS.clear}

    it "should add targets" do
      cli.send(:register_targets, cli.instance_eval{@hosts})
      expect($AWT_TARGETS.size).to eq(2)
    end
  end

  describe ".#start" do
    it "should call Awt::CLI#execute" do
      Awt::CLI.any_instance.should_receive(:execute)
      Awt::CLI.start
    end

    it "should print error message if raise error" do
      Awt::CLI.any_instance.should_receive(:execute).and_raise("error")
      expect(
        capture(:stdout){
          Awt::CLI.start
        }.chomp
      ).to eq("error")
    end
  end
end
