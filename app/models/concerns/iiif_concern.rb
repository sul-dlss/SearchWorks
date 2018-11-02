##
# Module that provides SolrDocument IIIF specific methods
module IiifConcern
  def iiif_manifest
    fetch(:iiif_manifest_url_ssim, nil)
  end
end
