# frozen_string_literal: true

module ApplicationHelper
  def application_name
    I18n.t "defaults_search.title_name"
  end

  def organization_name
    I18n.t 'organization_name'
  end

  def title(page_title = nil)
    query = @query.blank? ? "" : truncate(@query, length: 40, separator: ' ', escape: false)
    page_title ||= []
    page_title << "#{query} |" unless query.blank?
    page_title << " #{application_name} |" unless application_name.blank?
    page_title << " #{organization_name}" unless organization_name.blank?

    content_for :title, page_title.compact.join
  end

  def visually_hidden_service(service_name)
    tag.span service_name.humanize(capitalize: false), class: 'visually-hidden'
  end
end
