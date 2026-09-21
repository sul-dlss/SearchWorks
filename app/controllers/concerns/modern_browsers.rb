# frozen_string_literal: true

module ModernBrowsers
  extend ActiveSupport::Concern

  included do
    allow_browser versions: :modern, block: :handle_outdated_browser
  end

  def handle_outdated_browser
    return if Rack::Attack.configuration.safelisted?(request)

    render file: Rails.public_path.join('406-unsupported-browser.html'), layout: false, status: :not_acceptable
  end
end
