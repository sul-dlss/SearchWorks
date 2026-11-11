# frozen_string_literal: true

# Structured logs for the chat assistant. These record questions' tool inputs and model usage for
# quality review, but deliberately carry no user identity; request_id correlates a turn's events.

ActiveSupport::Notifications.subscribe('request.litellm') do |event|
  payload = event.payload
  error_class, error_message = payload[:exception]
  log_data = {
    event: event.name,
    outcome: error_class ? 'error' : 'success',
    duration_ms: event.duration.round(1),
    first_content_token_ms: payload[:first_content_token_ms],
    model: payload[:model],
    operation: payload[:operation],
    input_count: payload[:input_count],
    input_characters: payload[:input_characters],
    http_status: payload[:http_status],
    request_id: payload[:request_id],
    response_id: payload[:response_id],
    prompt_tokens: payload[:prompt_tokens],
    completion_tokens: payload[:completion_tokens],
    total_tokens: payload[:total_tokens],
    finish_reason: payload[:finish_reason],
    stream_complete: payload[:stream_complete],
    error_class: error_class,
    error_message: error_message
  }.compact

  Rails.logger.public_send(error_class ? :warn : :info, log_data.to_json)
end

ActiveSupport::Notifications.subscribe('start.mcp_tool') do |event|
  payload = event.payload
  Rails.logger.info(
    { event: event.name, tool_name: payload[:tool_name], input: payload[:input], request_id: payload[:request_id] }.compact.to_json
  )
end

ActiveSupport::Notifications.subscribe('call.mcp_tool') do |event|
  payload = event.payload
  error_class = payload[:exception]&.first
  failed = error_class || payload[:tool_error]
  log_data = {
    event: event.name,
    outcome: failed ? 'error' : 'success',
    duration_ms: event.duration.round(1),
    tool_name: payload[:tool_name],
    input: payload[:input],
    results: payload[:results],
    request_id: payload[:request_id],
    error_class: error_class
  }.compact

  Rails.logger.public_send(failed ? :warn : :info, log_data.to_json)
end
