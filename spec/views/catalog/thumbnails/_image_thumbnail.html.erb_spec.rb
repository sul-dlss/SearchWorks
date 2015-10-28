require 'spec_helper'

describe 'catalog/thumbnails/_image_thumbnail.html.erb' do
  before { view.stub(:document).and_return(document) }

  context 'when there is no thumbnail image' do
    let(:document) do
      SolrDocument.new(
        id: '1234',
        display_type: 'image'
      )
    end
    it 'is blank' do
      render
      expect(rendered).to be_blank
    end
  end

  context 'when there is a thumbnail image' do
    let(:document) do
      SolrDocument.new(
        id: '1234',
        display_type: 'image',
        file_id: %w(1234 4321)
      )
    end
    it 'uses the first file id to construct the thumbnail' do
      render
      expect(rendered).to match(%r{src=".*1234/full/!400,400/0/default.jpg"})
    end
  end
end
