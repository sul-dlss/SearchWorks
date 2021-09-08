# frozen_string_literal: true

module RequestLinks
  class HopkinsRequestLink < RequestLink
    def present?
      super && !available_online? && only_available_at_hopkins?
    end

    private

    def available_online?
      # This is similar to the code in the online access panel with the exception
      # of us checking the index for fultext links instead of the MARC record (and ignoring EDS data)
      document&.index_links&.sfx&.present? ||
        document&.index_links&.fulltext&.present? ||
        document.hathi_links.all.reject(&:stanford_only?).any?
    end

    def only_available_at_hopkins?
      document&.holdings&.libraries&.one?
    end
  end
end
