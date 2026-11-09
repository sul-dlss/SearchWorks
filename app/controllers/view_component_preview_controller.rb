# frozen_string_literal: true

class ViewComponentPreviewController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include ViewComponent::PreviewActions

  # Adds a few additional behaviors into the application controller
  helper_method :controller_tracking_method, :blacklight_config, :blacklight_configuration_context, :search_session, :current_search_session, :search_state, :turnstile_ok?, :bookmarked?

  def controller_tracking_method
    'track_catalog_path'
  end

  def blacklight_configuration_context
    Blacklight::Configuration::Context.new(self)
  end

  delegate :blacklight_config, to: :CatalogController

  def search_session
    {}
  end

  def current_search_session
    nil
  end

  def search_state
    Blacklight::SearchState.new(params, blacklight_config)
  end

  def turnstile_ok?
    true
  end

  def render_bookmarks_control?
    true
  end

  # Blacklight's helper looks bookmarks up from the search response and the
  # current user, neither of which exist in a preview, so show nothing bookmarked.
  def bookmarked?(_document)
    false
  end
end
