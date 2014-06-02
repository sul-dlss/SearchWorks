require "spec_helper"

describe "Image object" do

  let(:image_document) { SolrDocument.new(id: 4488, druid: 4488, display_type: ['image'], img_info: ['abc123defg']) }

  it "should return default size" do
    expect(image_document.image_dimensions[:large]).to eq "_thumb"
  end

  it "should validate digital image object" do
    expect(image_document.has_image_behavior?).to be_true
  end

  it "should return stacks image urls" do
    expect(image_document.image_urls.length).to eq 1
    expect(image_document.image_urls.first).to include("/4488/abc123defg")
  end

end
