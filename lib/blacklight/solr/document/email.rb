# -*- encoding : utf-8 -*-
# Overridding Blacklight's module to provide our own breif email text
module Blacklight::Solr::Document::Email

  # Return a text string that will be the body of the email
  def to_email_text
    semantics = self.to_semantic_values
    body = []
    body << I18n.t('blacklight.email.text.title', :value => semantics[:title].join(" ")) if semantics[:title].present?
    body << I18n.t('blacklight.email.text.author', :value => semantics[:author].join(" ")) if semantics[:author].present?
    if self.holdings.present?
      holdings.libraries.each do |library|
        library.locations.each do |location|
          body << "#{library.name} - #{location.name}"
          location.items.each do |item|
            body << "\t#{item.callnumber}"
          end
        end
      end
    end
    if self.access_panels.online?
      body << "Online:"
      self.access_panels.online.links.each do |link|
        body << "\t#{link.href}"
      end
    end
    return body.join("\n") unless body.empty?
  end
end
