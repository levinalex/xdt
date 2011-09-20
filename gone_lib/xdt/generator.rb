module Xdt
  class Gdt

    def patient

    end

    def self.generate(id, &block)

      obj = new(id)
      yield obj
      obj



    end

  end




end

