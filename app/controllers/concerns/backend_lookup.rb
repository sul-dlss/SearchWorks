# frozen_string_literal: true

##
# Simple mixin to share the backend_lookup method between search controllers
module BackendLookup
  def backend_lookup
    (@response, @document_list) = search_service.search_results
    respond_to do |format|
      format.json do
        @presenter = Blacklight::JsonPresenter.new(@response,
                                                   @document_list,
                                                   facets_from_request,
                                                   blacklight_config)
      end
      format.html { render status: :bad_request, layout: false, file: Rails.root.join('public', '500.html') }
    end
  end
end
