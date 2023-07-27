# -*- encoding : utf-8 -*-

# This module provides the body of an email export based on the document's semantic values
module Searchworks::Document::Sms
  include Blacklight::Document::Sms

  # Return a text string that will be the body of the email
  def to_sms_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.sms.text.title', value: semantics[:title].first) unless semantics[:title].blank?
    body << I18n.t('blacklight.sms.text.author', value: semantics[:author].first) unless semantics[:author].blank?

    if self.holdings.present?
      item = preferred_item
      library = Holdings::Library.new(item.library).name
      folio_code = Folio::LocationsMap.for(library_code: item.library, location_code: item.home_location)
      location = Folio::Locations.label(code: folio_code)

      body << I18n.t('blacklight.sms.text.library_location', library:, location:)
      body << I18n.t('blacklight.sms.text.callnumber', value: item.callnumber)
    end

    return body.join("\n") unless body.empty?
  end
end
