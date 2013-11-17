module Awt
  class Printer
    attr_accessor :host

    def initialize(host)
      @host = host
    end

    def method_missing(action, *args)
      if action.to_s =~ /print_(.+)/
        puts "[#{@host}] #{$1}: #{args.first}"
      else
        super
      end
    end
  end
end
