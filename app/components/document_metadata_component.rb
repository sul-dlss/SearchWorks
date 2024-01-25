# frozen_string_literal: true

class DocumentMetadataComponent < Blacklight::Component
  def initialize(document:) # rubocop:disable Lint/MissingSuper
    @document = document
  end

  attr_reader :document
end
