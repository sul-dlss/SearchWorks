# frozen_string_literal: true

class MainContainerComponent < ViewComponent::Base
  FLASH_TYPES_WITH_LEVEL =
    [[:success, 'success'],
     [:notice, 'info'],
     [:alert, 'warning'],
     [:error, 'danger'],
     [:recaptcha_error, 'danger']].freeze
end
