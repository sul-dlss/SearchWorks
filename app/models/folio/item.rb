module Folio
  class Item
    def initialize(id:, barcode:)
      @id = id
      @barcode = barcode
    end

    def self.from_dynamic(json)
      new(id: json.fetch('id'),
          barcode: json.fetch('barcode'))
    end
    attr_reader :id, :barcode
  end
end
