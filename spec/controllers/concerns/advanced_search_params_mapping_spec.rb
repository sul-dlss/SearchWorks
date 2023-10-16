require 'rails_helper'

class AdvancedSearchParamsMappingController
  include AdvancedSearchParamsMapping
end

RSpec.describe AdvancedSearchParamsMapping do
  let(:controller) { AdvancedSearchParamsMappingController.new }

  describe 'params to be mapped' do
    let(:params) { { author: "Author" } }

    before do
      allow(controller).to receive(:params).and_return(params)
      controller.send(:map_advanced_search_params)
    end

    it 'moves old advanced search queries to the new adv search clauses' do
      expect(params[:author]).not_to be_present
      expect(params[:clause].values).to include(field: 'search_author', query: "Author")
    end
  end
end
