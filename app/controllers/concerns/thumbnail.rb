module Thumbnail
  extend ActiveSupport::Concern
  included do
    if self.respond_to?(:helper_method)
      helper_method :thumbnail
    end
  end

  def thumbnail(document, options = {})
    view_context.render_cover_image(document, options)
  end
end
