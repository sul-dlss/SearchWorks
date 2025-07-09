# frozen_string_literal: true

module Searchworks4
  class DigitalCollectionsFacetHeaderComponent < ViewComponent::Base
    delegate :page_location, :sdr_path, :digital_collection_path, to: :helpers
  end
end
