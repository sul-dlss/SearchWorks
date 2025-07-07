# frozen_string_literal: true

module Feedback
  class FeedbackFormFieldsComponent < ViewComponent::Base
    def initialize(form:, request_referer:)
      super
      @form = form
      @request_referer = request_referer
    end
  end
end
