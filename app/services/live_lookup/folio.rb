# frozen_string_literal: true

# LiveLookup::Folio makes a request to FOLIO's real time availability API
#   with a list of instance uuids and returns a response suitable for updating
#   item availability information displayed on index and show views.
class LiveLookup
  class Folio
    attr_reader :instance_ids

    delegate :as_json, :to_json, to: :records

    def initialize(instance_ids)
      @instance_ids = instance_ids
    end

    # @return [Array] each item's current availability information, translated for display
    def records
      @records ||= real_time_availability_request.fetch('holdings', []).flat_map do |holding|
        holding.fetch('holdings', []).map do |item|
          {
            item_id: item.fetch('id', nil),
            due_date: due_date(item),
            status: status(item),
            is_available: available?(item),
            is_requestable_status: requestable_status?(item)
          }
        end
      end
    end

    private

    def real_time_availability_request
      folio_client.real_time_availability(instance_ids:)
    end

    def folio_client
      @folio_client ||= FolioClient.new
    end

    # Check to see if we can add a request button based on the status in folio
    # and predetermined list of status that can be recalled
    def requestable_status?(item)
      status = item.fetch('status', nil)
      Settings.folio_hold_recall_statuses.include?(status)
    end

    def status(item)
      status = item.fetch('status', nil)
      case status
      when 'Available'
        nil # matches response from Sirsi for available items
      when 'Aged to lost', 'Claimed returned'
        'Checked out'
      when 'Awaiting delivery', 'Awaiting pickup'
        'On hold for a borrower'
      when 'In process (non-requestable)'
        'In process'
      else
        status
      end
    end

    def due_date(item)
      date = item.fetch('dueDate', nil)
      date&.to_time&.in_time_zone&.strftime('%m/%d/%Y')
    end

    def available?(item)
      item.fetch('status', nil) == 'Available'
    end
  end
end
