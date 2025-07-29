# frozen_string_literal: true

module ApplicationHelper
  def from_advanced_search?
    params[:search_field] == 'advanced' || params[:clause].present?
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
