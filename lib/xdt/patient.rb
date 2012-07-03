module Xdt
  class Patient
    attr_accessor :assigned_id
    attr_accessor :last_name
    attr_accessor :given_name
    attr_accessor :born_on
    attr_accessor :gender

    def initialize
      yield self if block_given?
    end

    def to_hash
      { assigned_id: assigned_id,
        last_name: last_name,
        given_name: given_name,
        born_on: born_on,
        gender: gender }
    end

    def self.from_document(xdt)
      new do |p|
        p.assigned_id = xdt[3000].value
        p.last_name = xdt["3101"].value
        p.given_name = xdt["3102"].value
        p.born_on = Date.strptime(xdt["3103"].value, "%d%m%Y")
        p.gender = xdt["3110"].value =~ /2|f/ ? :female : :male
      end
    end
  end
end
