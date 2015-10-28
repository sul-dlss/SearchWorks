module DigitalImage

  # Check for digital image object
  # TODO: Once index fields are finalized, remove additional check
  def has_image_behavior?
    self[:display_type].present? && self[:display_type].include?('image') && file_ids.present?
  end


  # Get stacks urls for a document using file ids
  # @return [Array]
  def image_urls(size=:default)
    return nil unless has_image_behavior?
    file_ids.map do |image_id|
      craft_image_url(druid, image_id, size)
    end
  end

  ##
  # Generates a Stacks image url using given arguments
  # @param [String] druid
  # @param [String] image_id
  # @param [Symbol] size
  # @return [String]
  def craft_image_url(druid, image_id, size)
    image_id = image_id.gsub(/\.jp2$/, '')
    "#{Settings.STACKS_URL}/#{druid}/#{image_id}#{image_dimensions[size]}"
  end

  # Size definitions for stacks urls
  def image_dimensions(size=:default)
    {
      :thumbnail => "_square",
      :default   => "?w=80&h=80",
      :medium    => "?w=125&h=125",
      :large     => "_thumb"
    }
  end

end