module DigitalImage
  # Get stacks urls for a document using file ids
  # @return [Array]
  def image_urls(size = :default)
    return unless image_behavior?
    file_ids.map do |image_id| # this should become image_ids.map once we remove #image_behavior?
      craft_image_url(druid, image_id, size)
    end
  end

  private

  # This method should be removed once the indexing code no longer
  # adds display_type to the document. We will instead determine
  # image behavior based on the presence of jp2s in the file ids field.
  # When we do that we can just let image_urls be blank when there are no image ids.
  def image_behavior?
    return unless self[:display_type].present?
    return unless file_ids.present?

    self[:display_type].any? do |display_type|
      %w(book image).include?(display_type)
    end
  end

  # Left commented out for when we remove #image_behavior?
  # def image_ids
  #   return unless image_behavior?
  #   file_ids.select do |file_id|
  #     file_id =~ /\.jp2$/
  #   end
  # end
end
