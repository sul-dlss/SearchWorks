# frozen_string_literal: true

##
# Helpers for the AlternateCatalog feature
module AlternateCatalogHelper
  def show_alternate_catalog?
    return true if params.fetch(:q, nil).present? && current_view != 'gallery'
    false
  end
end
