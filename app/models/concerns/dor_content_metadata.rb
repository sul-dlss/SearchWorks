# frozen_string_literal: true

module DorContentMetadata
  # Document has (or could have) published content if:
  #   dor_resource_count_isi field is present and positive (resource has published content)
  #   OR if dor_resource_count_isi field is not present (could have published content --
  #   for records that have not been re-indexed)
  def published_content?
    self['dor_resource_count_isi']&.positive? || !key?('dor_resource_count_isi')
  end
end
