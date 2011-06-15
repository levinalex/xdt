gem 'minitest'

require 'minitest/spec'
require 'minitest/autorun'

require 'date'
require 'json'
require 'erb'

require 'xdt'


def array_to_xdt(arr)
  arr.map { |l| "#{"%03d" % (l.length+5)}#{l}\r\n" }.join
end
