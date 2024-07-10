# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss(version: "2.0") {
  xml.channel {
    xml.title(t('blacklight.search.page_title.title', constraints: render_search_to_page_title(params), application_name: application_name))
    xml.link(search_action_url(search_state.to_h.merge(only_path: false)))
    xml.description(t('blacklight.search.page_title.title', constraints: render_search_to_page_title(params), application_name: application_name))
    xml.language('en-us')
    @response.documents.each_with_index do |document, document_counter|
      xml << render_xml_partials(document, blacklight_config.view_config(:rss).partials, document_counter: document_counter)
    end
  }
}
