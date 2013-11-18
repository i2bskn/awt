require "spec_helper"

describe Awt::Printer do
  let(:printer) {Awt::Printer.new("example.com")}

  describe "#initialize" do
    it "should set specified host" do
      expect(printer.host).to eq("example.com")
    end
  end

  describe "#method_missing" do
    context "with print_* method" do
      it "should print message" do
        expect(
          capture(:stdout){
            printer.print_run "command"
          }.chomp
        ).to eq("[example.com] run: command")
      end
    end

    context "with unknown method" do
      it "should throw exception" do
        expect {
          printer.unknown_method "command"
        }.to raise_error
      end
    end
  end
end
