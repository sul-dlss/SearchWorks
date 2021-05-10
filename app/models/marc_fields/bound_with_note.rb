###
#  MarcBoundWith class to return 590 fields that have a $c
###
class BoundWithNote < MarcField
  include ActionView::Helpers::UrlHelper

  private

  def subfield_value(field, subfield)
    return super unless subfield.code == 'c'

    ckey = subfield.value[/^(\d+)/]
    ckey_link = link_to(ckey, Rails.application.routes.url_helpers.solr_document_path(ckey))

    subfield.value.gsub(ckey, ckey_link).html_safe
  end

  def tags
    %w(590)
  end
end
