# frozen_string_literal: true

module DatabaseAccessPoint
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_action)
      before_action :add_database_topic_facet, only: [:index, :facet]
    end
  end

  def add_database_topic_facet
    if action_name == "facet" || PageLocation.new(search_state).databases?
      database_facet = blacklight_config.facet_fields["db_az_subject"]
      database_facet.show = true
      database_facet.if = true
    end
  end
end
