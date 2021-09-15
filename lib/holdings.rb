require 'holdings/callnumber'
require 'holdings/in_process'
require 'holdings/library'
require 'holdings/location'
require 'holdings/mhld'
require 'holdings/status'

class Holdings
  attr_reader :live

  def initialize(document, live: false)
    @document = document
    @live = live
    @item_display = @document[:item_display]
    @mhld_display = @document[:mhld_display]
  end

  def with_live_location_data
    self.class.new(@document, live: true)
  end

  def find_by_barcode(barcode)
    callnumbers.find do |callnumber|
      callnumber.barcode == barcode
    end
  end

  def preferred_callnumber
    @preferred_callnumber ||= begin
      if @document[:preferred_barcode] &&
         (found_callnumber = find_by_barcode(@document[:preferred_barcode])).present?
        found_callnumber
      else
        callnumbers.first
      end
    end
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
        Holdings::Library.new(library, @document, items, mhlds)
      end

      @libraries += mhld.reject { |x| items_by_library.key? x.library }.group_by(&:library).map do |code, mhlds|
        Holdings::Library.new(code, @document, [], mhlds)
      end

      @libraries.sort_by!(&:sort)
    end
    @libraries
  end

  def callnumbers
    return [] unless @item_display.present?

    @callnumbers ||= @item_display.map do |item_display|
      item = Holdings::Callnumber.new(item_display, document: @document)

      if live
        data = live_data_for_barcode(item.barcode)

        if data.present?
          item.current_location = Holdings::Location.new(data['current_location'])
          item.due_date = data['due_date'] if data['due_date']
          item.status = Holdings::Status.new(item)
        end
      end

      item
    end.sort_by(&:full_shelfkey)
  end

  def mhld
    return [] unless @mhld_display.present?

    @mhld ||= @mhld_display.map do |mhld_display|
      Holdings::MHLD.new(mhld_display)
    end
  end

  def as_json
    libraries.select(&:present?).map(&:as_json)
  end

  private

  def live_data
    @live_data ||= JSON.parse(LiveLookup.new(@document[:id]).to_json).map do |item|
      JSON.parse(item)
    end
  end

  def live_data_for_barcode(barcode)
    live_data.find do |item|
      item['barcode'] == barcode
    end
  end
end
