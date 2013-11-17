module Awt
  class Task
    def initialize(&block)
      @block = block
    end

    def exec(targets)
      targets.each do |target|
        target.instance_eval &@block
      end
    end
  end
end
