# frozen_string_literal: true

module ApplicationHelper
  def catalog_home_or_search_url
    return Settings.CATALOG.HOME_URL unless params[:q]

    format(Settings.CATALOG.QUERY_URL, q: params[:q])
  end

  def articles_home_or_search_url
    return Settings.ARTICLE.HOME_URL unless params[:q]

    format(Settings.ARTICLE.QUERY_URL, q: params[:q])
  end

  def application_name
    I18n.t "defaults_search.title_name"
  end

  def organization_name
    I18n.t 'organization_name'
  end

  def body_class
    [controller_name, action_name].join('-')
  end

  def title(page_title = nil)
    query = @query.blank? ? "" : truncate(@query, length: 40, separator: ' ', escape: false)
    page_title ||= []
    page_title << "#{query} |" unless query.blank?
    page_title << " #{application_name} |" unless application_name.blank?
    page_title << " #{organization_name}" unless organization_name.blank?

    content_for :title, page_title.compact.join
  end

  def render_module(searcher, service_name, partial_name = 'module', per_page = 3)
    if searcher
      render partial: partial_name , locals: { module_display_name: t("#{service_name}_search.display_name"), searcher: searcher, search: '', service_name: service_name, per_page: per_page }
    else
      content_tag :div, id: service_name, class: 'module-contents', tabindex: -1 do
        content_tag :p, '', class: 'search-error', data: { 'quicksearch-xhr-url' => xhr_search_path(service_name, q: params[:q]) }
      end
    end
  end
end
