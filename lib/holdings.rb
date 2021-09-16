require 'holdings/callnumber'
require 'holdings/in_process'
require 'holdings/library'
require 'holdings/location'
require 'holdings/mhld'
require 'holdings/status'

class Holdings
  attr_reader :document, :live

  delegate :mhld, to: :document

  def initialize(document, live: false)
    @document = document
    @live = live
  end

  def with_live_location_data
    self.class.new(document, live: true)
  end

  def present?
    libraries.select(&:present?).any? do |library|
      library.locations.any?(&:present?)
    end
  end

  def browsable_callnumbers
    callnumbers.select(&:browsable?).uniq(&:truncated_callnumber)
  end

  def libraries
    unless @libraries
      items_by_library = callnumbers.group_by(&:library)

      @libraries = items_by_library.map do |library, items|
        mhlds = mhld.select { |x| x.library == library }
        Holdings::Library.new(library, items, mhlds)
      end

      @libraries += mhld.reject { |x| items_by_library.key? x.library }.group_by(&:library).map do |code, mhlds|
        Holdings::Library.new(code, [], mhlds)
      end

      @libraries.sort_by!(&:sort)
    end
    @libraries
  end

  def callnumbers
    if live
      document.live_lookup_callnumbers
    else
      document.callnumbers
    end
  end

  def find_by_barcode(barcode)
    callnumbers.find { |item| item.barcode == barcode }
  end

  def as_json
    libraries.select(&:present?).map(&:as_json)
  end
end
