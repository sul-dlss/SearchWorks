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

  it 'should return default size' do
    expect(image_document.image_dimensions[:large]).to eq '_thumb'
  end

  it 'should validate digital image object' do
    expect(image_document.has_image_behavior?).to be_true
  end

  it 'should return stacks image urls' do
    expect(image_document.image_urls.length).to eq 1
    expect(image_document.image_urls.first).to include('/4488/abc123defg')
  end

  it 'provides a method to craft a stacks image url given parameters (removing the .jp2 extension)' do
    expect(image_document.craft_image_url('abc', '123.jp2', :thumbnail)).to match(
      %r{stanford.edu/image/abc/123_square}
    )
  end

  it 'should return false if there is no display_type' do
    expect(SolrDocument.new.has_image_behavior?).to be_false
  end
end
