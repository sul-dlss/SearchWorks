# frozen_string_literal: true

##
# A class to model a set of IP ranges.  The default IPAddr library in ruby
# can define broad IP ranges (e.g. 172.12.0.0/16 would define 172.12.*.*)
# but doesn't handle custom ranges as well (e.g. 172.22.24.* - 172.22.255.*)
# This class allows you to check if a given IP is in a network of IP ranges.
#
# There is a network of IP ranges injected by default, but an object can be
# injected that provides an array of singleton IP addresses (or ranges defined
# by the slash prefixes) and an mutli-dimensional array of custom IP ranges.
# Example network definition:
# example_network = OpenStruct.new(
#   singletons: ['172.12.0.0/16'],
#   ranges: [['172.12.12.0', '172.12.56.255']]
# )
#
# Example Usage:
# IPRange.includes?('172.12.52.21')
# => false
# IPRange.new('172.12.52.21', example_network).includes?
# => true
class IPRange
  attr_reader :ip_to_check, :network

  def initialize(ip, network_definition = self.class.default_network)
    @ip_to_check = IPAddr.new(ip)
    @network = network_definition
  end

  def included?
    singletons_include_ip? || ranges_include_ip?
  end

  class << self
    def includes?(ip_to_check)
      new(ip_to_check).included?
    end

    def default_network
      Settings.STANFORD_NETWORK
    end
  end

  private

  delegate :ranges, :singletons, to: :network

  def singletons_include_ip?
    singletons.any? do |singleton|
      IPAddr.new(singleton).include?(ip_to_check)
    end
  end

  def ranges_include_ip?
    ranges.any? do |range|
      (IPAddr.new(range.first)..IPAddr.new(range.last)).cover?(ip_to_check)
    end
  end
end
