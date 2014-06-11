require 'holdings/callnumber'

class Holdings
  def initialize(document)
    @item_display = document[:item_display]
  end
  def find_by_barcode(barcode)
    callnumbers.find do |callnumber|
      callnumber.barcode == barcode
    end
  end
  def unique_callnumbers
    callnumbers.sort_by(&:full_shelfkey).uniq(&:truncated_callnumber)
  end
  def callnumbers
    return [] unless @item_display.present?
    @callnumbers ||= @item_display.map do |item_display|
      Holdings::Callnumber.new(item_display)
    end
  end
end
