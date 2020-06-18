# frozen_string_literal: true

module RequestLinks
  class HopkinsRequestLink < RequestLink
    def present?
      super && !available_online? && only_available_at_hopkins?
    end

    private

    def enabled_libraries
      %w[HOPKINS]
    end

    def circulating_item_type_map
      {
        'HOPKINS' => %w[STKS PERI THESIS MEDIA STOR]
      }
    end

    def enabled_locations_map
      {
        'HOPKINS' => %w[MEDIA OVERSIZED POPSCI SERIALS SHELBYSER SHELBYTITL STACKS THESIS]
      }
    end

    def available_online?
      document&.access_panels&.online?
    end

    def only_available_at_hopkins?
      document&.holdings&.libraries&.one?
    end
  end
end
