# frozen_string_literal: true

# Overridden from Blacklight
json.response do
  json.document @document.to_h
end
