require "spec_helper"

describe Awt::Task do
  class Target
    def run(cmd)
      cmd
    end
  end

  let(:task) {Awt::Task.new {run "example"}}
  let(:target) {Target.new}

  describe "#initialize" do
    it "should set Proc object" do
      expect(task.instance_eval{@block}.is_a? Proc).to be_true
    end
  end

  describe "#exec" do
    it "should execute target method" do
      target.should_receive(:run)
      task.exec([target])
    end
  end
end
