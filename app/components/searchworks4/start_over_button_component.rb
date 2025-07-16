# frozen_string_literal: true

# Overrides the default Blacklight StartOverButtonComponent in order to
# update btn class to btn-outline-primary
module Searchworks4
  class StartOverButtonComponent < Blacklight::StartOverButtonComponent
    def call
      link_to t('blacklight.search.start_over'), start_over_path, class: 'btn btn-outline-primary btn-reset'
    end

    private

    # Omit view to avoid being stuck in gallery mode from book funds/full page browse nearby.
    def start_over_path
      helpers.search_action_path({})
    end
  end
end
