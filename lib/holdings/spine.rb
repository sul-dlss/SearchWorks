# frozen_string_literal: true

class Holdings
  class Spine
    attr_reader :data, :document

    def initialize(data, document:)
      @data = data
      @document = document
    end

    def document_with_preferred_item
      document.with_preferred_item(item)
    end

    def item
      return unless data[:item_id]

      @item ||= document.items.find { |c| c.id == data[:item_id] }
    end

    # create sorting key for spine
    # shelfkey asc, then by sorting title asc, then by pub date desc
    # note: pub_date must be inverted for descending sort
    def sort_key
      sort_pub_date = if document[:pub_date].blank?
                        '9999'
                      else
                        document[:pub_date].tr('0123456789', '9876543210')
                      end

      [
        shelfkey,
        document[:title_sort].to_s,
        sort_pub_date,
        document[:id].to_s
      ]
    end

    def shelfkey
      data[:shelfkey]
    end

    def reverse_shelfkey
      data[:reverse_shelfkey]
    end

    def callnumber
      data[:callnumber]
    end

    def base_callnumber
      data[:lopped_call_number] || data[:lopped_callnumber]
    end
  end
end
