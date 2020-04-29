class AccessPanels
  class TemporaryAccess < ::AccessPanel
    def present?
      @document['hathitrust_info_struct'].present?
    end

    def hathitrust_info
      @hathitrust_info ||= Array.wrap(@document['hathitrust_info_struct']).map do |info|
        JSON.parse(info)
      end
    end
  end
end
