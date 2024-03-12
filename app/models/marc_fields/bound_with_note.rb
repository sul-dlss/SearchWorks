# frozen_string_literal: true

###
# BoundWithNote class to render 590 fields
class BoundWithNote < MarcField
  include ActionView::Helpers::UrlHelper

  private

  def subfield_value(field, subfield)
    return super unless subfield.code == 'c' && subfield.value.match?(ckey_regex)

    ckey = subfield.value[ckey_regex]
    ckey_link = link_to(ckey, Rails.application.routes.url_helpers.solr_document_path(ckey))

    subfield.value.gsub(ckey, ckey_link).html_safe
  end

  def tags
    %w(590)
  end

  def ckey_regex
    /^((a|in|L)?\d+)/
  end
end
