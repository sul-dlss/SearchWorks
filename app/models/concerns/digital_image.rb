module DigitalImage

  # Check for digital image object
  # TODO: Once index fields are finalized, remove additional check
  def has_image_behavior?
    self[:display_type].present? && self[:display_type].include?('image') && file_ids.present?
  end


  # Get stacks urls for a document using file ids
  def image_urls(size=:default)
    return nil unless has_image_behavior?

    stacks_url = Settings.STACKS_URL

    file_ids.map do |image_id|
      image_id = image_id.gsub(/\.jp2$/, '')

      "#{stacks_url}/#{self.druid}/#{image_id}#{image_dimensions[size]}"
    end
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