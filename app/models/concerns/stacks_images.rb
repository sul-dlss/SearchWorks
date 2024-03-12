# frozen_string_literal: true

###
#  Mixin to add methods for crafting Stacks image urls
###
module StacksImages
  ##
  # Generates a Stacks image url using given arguments
  # @param [String] druid
  # @param [String] image_id
  # @param [Symbol] size
  # @return [String]
  def craft_image_url(opts = {})
    druid = opts[:druid]
    image_id = opts[:image_id].gsub(/\.jp2$/, '')
    size = image_dimensions[opts[:size]] || image_dimensions[:default]
    if druid
      "#{Settings.STACKS_URL}/iiif/#{druid}%2F#{ERB::Util.url_encode(image_id)}/#{size}"
    else
      "#{Settings.STACKS_URL}/iiif/#{image_id}/#{size}"
    end
  end

  # Size definitions for stacks IIIF urls
  def image_dimensions
    {
      thumbnail: 'square/100,100/0/default.jpg',
      default: 'full/80,80/0/default.jpg',
      medium: 'full/125,125/0/default.jpg',
      large: 'full/!400,400/0/default.jpg'
    }
  end
end
