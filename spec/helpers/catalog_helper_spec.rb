require 'spec_helper'

describe CatalogHelper do
  describe 'current_view' do
    it 'if params[:view] present, should return it' do
      params = { view: 'gallery' }
      helper.stub(:params).and_return(params)
      expect(helper.current_view).to eq 'gallery'
    end
    it 'if params is not present, return list' do
      expect(helper.current_view).to eq 'list'
    end
  end
end
