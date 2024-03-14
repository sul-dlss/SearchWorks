# frozen_string_literal: true

###
#  SolrDocument mixing to load the Bookplate class when bookplate data is present
###
module SolrBookplates
  def bookplates
    return [] unless bookplates_present?

    @bookplates ||= bookplates_fields.map do |bookplate_field|
      Bookplate.new(bookplate_field)
    end
  end

  private

  def bookplates_present?
    bookplates_fields.present?
  end

  def bookplates_fields
    self[bookplates_field_key]
  end

  def bookplates_field_key
    :bookplates_display
  end
end
