# frozen_string_literal: true

module Articles
  class LoginBannerComponent < ViewComponent::Base
    delegate :new_user_session_path, to: :helpers

    def classes
      'alert d-inline-block alert-dismissible rounded-0 fade show eds-restricted'
    end
  end
end
