# frozen_string_literal: true

# Business logic for MCP (Model Context Protocol) integration.
module SearchworksMcp
  UNSAFE_CONTROL_CHARACTERS = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/

  def self.report_exception(exception, context: {})
    Rails.logger.error(exception.full_message)
    Honeybadger.notify(exception, context: context)
  end

  def self.internal_tool_error(exception, public_message:)
    report_exception(exception)
    {
      text: public_message,
      structured_content: { error: public_message },
      error: true
    }
  end

  def self.sanitize_output(value)
    case value
    when Hash
      value.transform_values { |nested_value| sanitize_output(nested_value) }
    when Array
      value.map { |nested_value| sanitize_output(nested_value) }
    when String
      ActionController::Base.helpers.strip_tags(value).scrub.gsub(UNSAFE_CONTROL_CHARACTERS, "")
    else
      value
    end
  end
end
