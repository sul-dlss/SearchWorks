class PagesController < ApplicationController
  def home
    @search_form_placeholder = I18n.t "defaults_search.search_form_placeholder"
    @page_title = I18n.t "defaults_search.display_name"
    @module_callout = I18n.t "defaults_search.module_callout"
    @query = ''
  end
end
