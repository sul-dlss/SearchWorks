# frozen_string_literal: true

# Business logic for MCP (Model Context Protocol) integration.
module SearchworksMcp
  UNSAFE_CONTROL_CHARACTERS = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/
  MAX_ID_LENGTH = 255

  # Tool-routing guidance sent to MCP clients as server instructions, and to the SearchWorks chat
  # assistant as part of its system prompt, so both follow the same rules.
  INSTRUCTIONS = "Choose the search tool that matches the requested material; do not call both unless the user " \
                 "asks for both. Use catalog_search_tool for books, journals as whole publications, databases, " \
                 "media, archives, maps, and other catalog materials. Use article_search_tool for individual " \
                 "scholarly, journal, or newspaper articles. Use get_catalog_record or get_article only when " \
                 "detailed metadata is needed. Whenever catalog_search_tool returns exactly one result or you " \
                 "select a specific result from a result set, you must call get_availability with that result's " \
                 "id before answering, even if the user did not ask about availability. Cite the canonical " \
                 "SearchWorks URL returned by tools. When availability includes a request_url, present that " \
                 "direct link to the user so they can request the material."

  def self.report_exception(exception, context: {})
    Rails.logger.error(exception.full_message)
    Honeybadger.notify(exception, context: context)
  end

  def self.sanitize_output(value)
    case value
    when Hash
      value.transform_values { |nested_value| sanitize_output(nested_value) }
    when Array
      value.map { |nested_value| sanitize_output(nested_value) }
    when String
      ActionController::Base.helpers.strip_tags(value).scrub.gsub("&amp;", "&").gsub(UNSAFE_CONTROL_CHARACTERS, "")
    else
      value
    end
  end
end
