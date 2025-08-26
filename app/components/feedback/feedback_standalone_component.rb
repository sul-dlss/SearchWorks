# frozen_string_literal: true

module Feedback
  class FeedbackStandaloneComponent < ViewComponent::Base
    def catalog_document_id
      return @catalog_document_id if defined?(@catalog_document_id)
      return unless request.referer

      @catalog_document_id = begin
        referer_params = Rails.application.routes.recognize_path(request.referer)

        referer_params[:id] if referer_params && referer_params[:controller] == 'catalog' && referer_params[:action] == 'show'
      end
    end
  end
end
