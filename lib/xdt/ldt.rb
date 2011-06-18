# encoding: utf-8
#
module Xdt
  module Ldt
    class TestIdent < Xdt::Document
      has_field "8410", :test_ident
      has_field "8411", :name
      has_field "8420", :value
      has_field "8421", :unit
      has_field "8460", :normal_range_text

      def id
        "8410"
      end

      def self.parse(string_scanner)
        # scan until the next block
        rx = /
          [^\A]
          (?=
              (?:\r\n\d{3}8410) |
              \Z
           )
          /xm
        block = string_scanner.scan_until(rx)

        super(StringScanner.new(block))
      end


      def initialize(id, name, value, unit)
        super() do
          self.test_ident = id
          self.name = name
          self.value = value
          self.unit = unit
          yield self if block_given?
        end
      end
    end

    class LgReport < Xdt::Section
      has_field "8410", :test_ident, :class => TestIdent
      has_field "8310", :request_id
      has_field "8301", :requested_on, :class => Xdt::Field::DateField
      has_field "8302", :finished_on, :class => Xdt::Field::DateField
      has_field "3000", :patient_id
      has_field "8401", :result_type

      def id
        "80008202"
      end

      def test_idents
        select { |f| f.kind_of?(TestIdent) }
      end

      def each
        yield Xdt::Field.new("8000", "8202")
        yield Xdt::Field.new("8100", nil, 5) { "%05d" % self.length }
        super
      end

      def result(id, name, value, unit, &block)
        ident = TestIdent.new(id, name, value, unit, &block)
        @elements << [:foo, ident]
      end
    end


    class LHeader < Xdt::Section
      has_field "8000", nil, :method => nil
      has_field "8100", nil, :method => nil

      has_field "9212", :ldt_version, :method => :replace_field
      has_field "0201", :provider_id, :method => :replace_field
      has_field "0203", :provider_name, :method => :replace_field
      has_field "0204", :provider_group, :method => :replace_field
      has_field "0205", :provider_street, :method => :replace_field
      has_field "0206", :provider_address, :method => :replace_field
      has_field "8300", :lab, :method => :replace_field
      has_field "9106", :encoding, :method => :replace_field, :class => Xdt::Field::CharsetField
      has_field "8312", :customer_id, :method => :replace_field
      has_field "9103", :created_on, :method => :replace_field, :class => Xdt::Field::DateField

      def id
        "80008220"
      end

      def initialize(*args)
        super() do
          self.ldt_version = "LDT1001.02"
          self.provider_id = "0000000"
          self.provider_name = "Name"
          self.provider_group = "kA"
          self.provider_street = "Street 123"
          self.provider_address = "12345 City"
          self.lab = "LABOR"
          self.encoding = "iso-8859-1"
          self.customer_id = "1"
          self.created_on = Date.new(2011,6,10)

          yield self if block_given?
        end
      end

      def each(&blk)
        header("8220", &blk)
        super
      end
    end

    class LFooter < Xdt::Section
      def initialize(&block)
        super do
          @length_callback = block
        end
      end

      def initialize!
        super
        @length_callback = lambda { 0 }
      end

      def id
        "80008221"
      end

      def each
        yield Field.new("8000", "8221")
        yield Field.new("8100", nil, 5) { "%05d" % self.length }
        yield Field.new("9202", nil, 8) { "%08d" % @length_callback.call }
      end

    end

    class Document < Xdt::Document
      has_field "80008202", :lg_reports, :class => LgReport
      has_field "80008220", :l_header, :class => LHeader, :method => :replace_field
      has_field "80008221", :l_footer, :class => LFooter, :method => nil

      def lg_reports
        select { |f| f.kind_of?(LgReport) }
      end

      def initialize
        super do
          self.l_header = 1
          yield self if block_given?
        end
      end

      def lg_report(*args)
        report = LgReport.new(*args)
        yield report if block_given?
        @elements << ["80008202", report]
        nil
      end

      def each
        super
        yield LFooter.new() { self.length }
      end
    end
  end
end

