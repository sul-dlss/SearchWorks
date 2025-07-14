# frozen_string_literal: true

module ApplicationHelper
  def active_class_for_current_page(page)
    if current_page?(page)
      "active"
    end
  end

  def disabled_class_for_no_selections(count)
    if count == 0
      "disabled"
    end
  end

  def from_advanced_search?
    params[:search_field] == 'advanced' || params[:clause].present?
  end

  def link_to_catalog_search
    if article_search?
      mapped_params = { q: params[:q] }
      mapped_params[:search_field] = blacklight_config.index.search_field_mapping[params[:search_field].to_sym] if params[:search_field]
    end
    link_to(
      t('searchworks.search_dropdown.catalog.description_html'),
      article_search? ? root_path(mapped_params) : '#',
      class: "dropdown-item #{'highlight' unless article_search?}",
      role: 'menuitem',
      tabindex: '-1',
      'aria-current': !article_search?
    )
  end

  def link_to_article_search
    unless article_search?
      mapped_params = { q: params[:q] }
      mapped_params[:search_field] = blacklight_config.index.search_field_mapping[params[:search_field].to_sym] if params[:search_field]
    end
    link_to(
      t('searchworks.search_dropdown.articles.description_html'),
      article_search? ? '#' : articles_path(mapped_params),
      class: "dropdown-item #{'highlight' if article_search?}",
      role: 'menuitem',
      tabindex: '-1',
      'aria-current': article_search?
    )
  end

  def link_to_bento_search
    query_string = params[:q].present? ? "?#{{ q: params[:q] }.to_query}" : nil
    link_to(
      t('searchworks.search_dropdown.bento.description_html'),
      "https://library.stanford.edu/all/#{query_string}",
      class: 'dropdown-item',
      role: 'menuitem',
      tabindex: '-1'
    )
  end

  def link_to_library_website_search
    link_to(
      t('searchworks.search_dropdown.library_website.description_html'),
      "https://library.stanford.edu/search/all?search=#{params[:q]}"
    )
  end

  def search_type_name
    t("searchworks.search_dropdown.#{controller_name}.label")
  end

  # Return an Ezproxy link for URLs that match a proxied URL
  # If the link does not match a URL that should be proxied, return the link on its own
  def ezproxy_database_link(url, title)
    restricted_title = 'available to stanford affiliated users'
    Links::Ezproxy.new(url: url, link_title: "#{title}(#{restricted_title})", document: nil).to_proxied_url || url
  end
end
