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
      callnumber = preferred_callnumber
      library = Constants::LIB_TRANSLATIONS[callnumber.library]
      location = Constants::LOCS[callnumber.home_location]

      body << I18n.t('blacklight.sms.text.library_location', library: library, location: location)
      body << I18n.t('blacklight.sms.text.callnumber', value: callnumber.callnumber)
    end

    return body.join("\n") unless body.empty?
  end
end
