# -*- encoding : utf-8 -*-

# This module provides the body of an email export based on the document's semantic values
module Searchworks::Document::Sms
  include Blacklight::Document::Sms

  # Return a text string that will be the body of the email
  def to_sms_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.sms.text.title', value: semantics[:title].first) if semantics[:title].present?
    body << I18n.t('blacklight.sms.text.author', value: semantics[:author].first) if semantics[:author].present?

    if self.holdings.present?
      item = preferred_item
      library = Holdings::Library.new(item.library).name
      location = Folio::Locations.label(code: item.effective_permanent_location_code)

      body << I18n.t('blacklight.sms.text.library_location', library:, location:)
      body << I18n.t('blacklight.sms.text.callnumber', value: item.callnumber)
    end

    body.join("\n") unless body.empty?
  end
end
