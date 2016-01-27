require "spec_helper"

class AdvancedSearchParamsMappingController
  include AdvancedSearchParamsMapping
end

describe AdvancedSearchParamsMapping do
  let(:controller) { AdvancedSearchParamsMappingController.new }
  before do
    allow(controller).to receive(:blacklight_config).and_return(OpenStruct.new(advanced_search: { url_key: "advanced" } ))
  end
  it 'should not touch params when not doing an advanced search' do
    params = { search_field: 'something-else', title: "title param" }
    allow(controller).to receive(:params).and_return(params)
    controller.send(:map_advanced_search_params)
    expect(params[:title]).to be_present
  end
  describe 'params to be mapped' do
    let(:params) { { search_field: 'advanced', title: "Title", author: "Author", subject: "Subject", description: "Description", pub_info: "Pub", number: "Number"} }
    before do
      allow(controller).to receive(:params).and_return(params)
      controller.send(:map_advanced_search_params)
    end
    it 'should modify author' do
      expect(params[:author]).to_not be_present
      expect(params[:search_author]).to eq "Author"
    end
    it 'should modify title' do
      expect(params[:title]).to_not be_present
      expect(params[:search_title]).to eq "Title"
    end
    it 'should modify subject' do
      expect(params[:subject]).to_not be_present
      expect(params[:subject_terms]).to eq "Subject"
    end
    it 'should modify description and pass it as the search' do
      expect(params[:description]).to_not be_present
      expect(params[:search]).to eq "Description"
    end
    it 'should modify pub info' do
      expect(params[:pub_info]).to_not be_present
      expect(params[:pub_search]).to eq "Pub"
    end
    it 'should modify number' do
      expect(params[:number]).to_not be_present
      expect(params[:isbn_search]).to eq "Number"
    end
  end
end
