require 'spec_helper'

describe 'Image object' do
  let(:image_document) do
    SolrDocument.new(
      id: 4488,
      druid: 4488,
      display_type: ['image'],
      img_info: ['abc123defg']
    )
  end

  it 'should validate digital image object' do
    expect(image_document.has_image_behavior?).to be_truthy
  end

  it 'should return stacks image urls' do
    expect(image_document.image_urls.length).to eq 1
    expect(image_document.image_urls.first).to include('/iiif/4488%2Fabc123defg')
  end

  it 'should return false if there is no display_type' do
    expect(SolrDocument.new.has_image_behavior?).to be_falsey
  end
end
