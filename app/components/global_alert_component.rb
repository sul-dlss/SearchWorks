# frozen_string_literal: true

class GlobalAlertComponent < ViewComponent::Base
  def initialize(alert)
    @alert = alert
    super
  end

  def render?
    @alert.present?
  end
end
