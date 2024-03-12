# frozen_string_literal: true

##
# Module that provides SolrDocument IIIF specific methods
module IiifConcern
  def iiif_manifest
    fetch(:iiif_manifest_url_ssim, []).first
  end
end
