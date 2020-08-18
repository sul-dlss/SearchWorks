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
end
