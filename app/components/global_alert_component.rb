# frozen_string_literal: true

class GlobalAlertComponent < ViewComponent::Base
  delegate :cookies, to: :helpers

  def initialize(alert)
    @alert = alert
    super()
  end

  def render?
    @alert.present? && cookies[alert_id] != 'dismissed'
  end

  def alert_id
    "global_alert_#{@alert.try(:id) || @alert.html.hash}"
  end

  def dismiss_type
    @alert.try(:dismiss)
  end
end
