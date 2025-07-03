# frozen_string_literal: true

class AlertComponent < ViewComponent::Base
  def initialize(level:, message:)
    @level = level
    @message = message
    super
  end

  attr_reader :level, :message

  def alert_class
    "alert-#{level}"
  end

  def icon
    case level
    when "success"
      "bi-check-circle-fill"
    when "info"
      "bi-info-circle-fill"
    when "warning", "danger"
      "bi-exclamation-triangle-fill"
    end
  end
end
