# frozen_string_literal: true

# Home page hero that switches between the catalog search form and the AI chat assistant.
# The selected mode is reflected in the URL as ?mode=chat (see home_mode_controller.js).
class HomeSearchModesComponent < ViewComponent::Base
  MODES = %w[search chat].freeze

  renders_one :search

  # @param mode [String, nil] the initially selected mode, from params[:mode]
  # @param logged_in [Boolean] whether the user can send chat messages
  def initialize(mode:, logged_in:)
    super()
    @mode = MODES.include?(mode) ? mode : 'search'
    @logged_in = logged_in
  end

  attr_reader :mode, :logged_in

  def chat?
    mode == 'chat'
  end

  def tab_attributes(tab_mode)
    selected = tab_mode == mode
    {
      type: 'button',
      role: 'tab',
      id: "home-mode-#{tab_mode}-tab",
      class: 'home-mode-tab',
      aria: { selected: selected, controls: "home-mode-#{tab_mode}" },
      tabindex: selected ? 0 : -1,
      data: { home_mode_target: 'tab', mode: tab_mode, action: 'home-mode#select keydown->home-mode#keydown' }
    }
  end

  def pane_attributes(pane_mode)
    {
      id: "home-mode-#{pane_mode}",
      class: "home-mode-pane home-mode-pane-#{pane_mode}",
      role: 'tabpanel',
      aria: { labelledby: "home-mode-#{pane_mode}-tab" },
      hidden: pane_mode != mode,
      data: { home_mode_target: 'pane', mode: pane_mode }
    }
  end
end
