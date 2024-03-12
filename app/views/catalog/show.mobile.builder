# frozen_string_literal: true

xml.instruct! :xml, version: "1.0", encoding: "utf-8"
xml.response {
  cover_hash = {}
  cover_hash = get_covers_for_mobile(@document) unless (params.has_key?(:covers) and params[:covers] == "false") or drupal_api?
  xml.LBItem do
    xml << render(partial: "#{params[:controller]}/#{params[:action]}_default", locals: { doc: @document, cover_hash: })
  end # xml.LBItem
}
