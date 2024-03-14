# frozen_string_literal: true

# We may want to remove this after the BL6/Rails5.1 upgrade
Deprecation.default_deprecation_behavior = :silence if Rails.env.production?
