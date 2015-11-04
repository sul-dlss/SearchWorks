module DigitalImage
  # Check for digital image object
  # TODO: Once index fields are finalized, remove additional check
  def has_image_behavior?
    self[:display_type].present? && self[:display_type].include?('image') && file_ids.present?
  end

  # Get stacks urls for a document using file ids
  # @return [Array]
  def image_urls(size = :default)
    return nil unless has_image_behavior?
    file_ids.map do |image_id|
      craft_image_url(druid, image_id, size)
    end
  end
end
