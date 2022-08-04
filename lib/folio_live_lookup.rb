# frozen_string_literal: true

class FolioLiveLookup
  delegate :as_json, to: :records

  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  def records
    @records ||= folio_rtac_request.fetch('holdings', []).flat_map do |holding|
      holding.fetch('holdings', []).flat_map do |item|
        {
          item_id: item.fetch('id', nil),
          due_date: due_date(item),
          current_location: folio_status(item) # TODO: Do I need to find a "At bindery example?"
        }
      end
    end
  end

  private

  def folio_client
    @folio_client ||= FolioClient.new
  end

  def folio_rtac_request
    @folio_rtac_request ||= folio_client.rtac({ instanceIds: @ids, fullPeriodicals: 'false' }.to_json)
  end

  # Sirsi returns nil as the location if the item is available
  # Doing the same here to keep the response consistent for now
  def folio_status(item)
    status = item.fetch('status', nil)
    return status unless status == 'Available'
  end

  def due_date(item)
    date = item.fetch('dueDate', nil)
    Date.parse(date).strftime('%m/%d/%Y') if date
  end
end
