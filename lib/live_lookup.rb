class LiveLookup
  HIDE_DUE_DATE_LIBS = ['RUMSEYMAP'].freeze

  delegate :as_json, :to_json, to: :items

  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  def items
    @items ||= responses.flat_map do |response|
      (response.dig('fields', 'callList') || {}).flat_map do |call|
        (call.dig('fields', 'itemList') || {}).flat_map do |item|
          Item.new(item).as_json
        end
      end
    end
  end

  def responses
    SymphonyClient.new.bib_status(@ids)
  end

  class Item
    def initialize(item)
      @item = item
    end

    def as_json
      {
        barcode: barcode,
        due_date: due_date,
        current_location: current_location
      }
    end

    def barcode
      @item.dig('fields', 'barcode')
    end

    def due_date
      return unless valid_due_date?

      Date.parse(due_date_value).strftime('%-m/%-d/%Y')
    end

    def due_date_value
      @item.dig('fields', 'circRecord', 'fields', 'dueDate') ||
        @item.dig('fields', 'circRecord', 'fields', 'recallDueDate')
    end

    def current_location
      return unless valid_current_location?

      Holdings::Location.new(current_location_code).name
    end

    def current_location_code
      @item.dig('fields', 'currentLocation', 'key')
    end

    private

    def library_code
      @item.dig('fields', 'library', 'key')
    end

    def home_location_code
      @item.dig('fields', 'homeLocation', 'key')
    end

    def valid_current_location?
      return false if current_location_code.blank? ||
                      current_location_code == 'CHECKEDOUT' ||
                      current_location_same_as_home_location?

      true
    end

    def current_location_same_as_home_location?
      Holdings::Location.new(current_location_code).name == Holdings::Location.new(home_location_code).name ||
        Constants::CURRENT_HOME_LOCS.include?(current_location_code)
    end

    def valid_due_date?
      due_date_value.present? &&
        due_date_value != 'NEVER' &&
        !Constants::HIDE_DUE_DATE_LOCS.include?(home_location_code) &&
        !Constants::HIDE_DUE_DATE_CURRENT_LOCS.include?(current_location_code) &&
        !HIDE_DUE_DATE_LIBS.include?(library_code)
    end
  end
end
