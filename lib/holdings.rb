require 'holdings/append_mhld'
require 'holdings/callnumber'
require 'holdings/library'
require 'holdings/location'
require 'holdings/mhld'
require 'holdings/requestable'
require 'holdings/status'

class Holdings
  include AppendMHLD
  def initialize(document)
    @item_display = document[:item_display]
    @mhld_display = document[:mhld_display]
  end
  def find_by_barcode(barcode)
    callnumbers.find do |callnumber|
      callnumber.barcode == barcode
    end
  end
  def present?
    libraries.select(&:is_viewable?).any? do |library|
      library.items.any? do |callnumber|
        callnumber.callnumber.present?
      end || library.mhld.present?
    end
  end
  def unique_callnumbers
    callnumbers.uniq(&:truncated_callnumber)
  end
  def libraries
    unless @libraries
      @libraries = callnumbers.group_by(&:library).map do |library, items|
        Holdings::Library.new(library, items)
      end
      append_mhld(:library, @libraries, Holdings::Library)
    end
    @libraries
  end
  def callnumbers
    return [] unless @item_display.present?
    @callnumbers ||= @item_display.map do |item_display|
      Holdings::Callnumber.new(item_display)
    end.sort_by(&:full_shelfkey)
  end
  def mhld
    return [] unless @mhld_display.present?
    @mhld ||= @mhld_display.map do |mhld_display|
      Holdings::MHLD.new(mhld_display)
    end
  end
end
