# frozen_string_literal: true

class BookplateFundComponent < ViewComponent::Base
  def initialize(bookplate:)
    super

    @bookplate = bookplate
  end

  attr_reader :bookplate

  delegate :text, :thumbnail_url, to: :bookplate

  def render?
    bookplate.present?
  end
end
