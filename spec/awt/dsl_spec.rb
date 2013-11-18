require "spec_helper"

describe Awt::DSL do
  class Klass
    include Awt::DSL
  end

  let(:klass) {Klass.new}

  describe "#task" do
    before do
      klass.task :example do
        "example"
      end
    end

    after {$AWT_TASKS = {}}

    it "should define $AWT_TASKS" do
      expect($AWT_TASKS).not_to be_nil
    end

    it "should add task" do
      expect($AWT_TASKS).not_to be_empty
    end
  end

  describe "#server" do
    before do
      klass.server "example.com", user: "awt", port: 30022, key: "/path/to/id_rsa"
    end

    after {$AWT_TARGETS = []}

    it "should define $AWT_TARGETS" do
      expect($AWT_TARGETS).not_to be_nil
    end

    it "should add target" do
      expect($AWT_TARGETS).not_to be_empty
    end
  end

  describe "#task_find" do
    let(:path) {klass.task_find("/home/i2bskn")}

    it "returns task file path" do
      File.should_receive(:exists?).and_return(true)
      expect(path).to eq("/home/i2bskn/Awtfile")
    end

    it "returns nil if task file not found" do
      File.should_receive(:exists?).at_least(2).and_return(false)
      expect(path).to be_nil
    end
  end
end
