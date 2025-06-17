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

  def format_year(date_string)
    return nil if date_string.blank?

    date = Date.parse(date_string)
    year = date.strftime('%Y')
    "(#{year})"
  rescue Date::Error
    nil
  end

  def journal_details(composed_title)
    return '' if composed_title.blank?

    search_link_match = composed_title.match(%r{</searchlink>(.*)}i)
    return search_link_match[1] if search_link_match

    italic_match = composed_title.match(%r{\u003C/i\u003E(.*)}i)
    italic_match ? italic_match[1] : ''
  end

  def visually_hidden_service(service_name)
    tag.span service_name.humanize(capitalize: false), class: 'visually-hidden'
  end

  def enabled_searchers
    @enabled_searchers ||= Settings.enabled_searchers.map do |name|
      Service.new(name)
    end
  end
end
