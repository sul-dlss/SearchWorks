# frozen_string_literal: true

module DigitalImage
  # Get stacks urls for a document using file ids
  # @return [Array]
  def image_urls(size = :default)
    image_ids.map do |image_id|
      craft_image_url(image_id:, size:)
    end
  end

  private

  def image_ids
    file_ids.select do |file_id|
      file_id =~ /\.jp2$/
    end
  end
end
