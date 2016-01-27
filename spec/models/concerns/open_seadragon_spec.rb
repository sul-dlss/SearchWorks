require "spec_helper"

describe OpenSeadragon do
  let(:document) { double('osd_document') }
  before do
    document.extend(OpenSeadragon)
    allow(document).to receive('druid').and_return('12345')
  end
  describe "tile source" do
    before do
      allow(document).to receive('file_ids').and_return(['image-id1', 'image-id2.jp2'])
    end
    it "should have the correct stacks URL" do
      document.open_seadragon_tile_source.each do |tile_source|
        expect(tile_source).to match /^#{Settings.STACKS_URL}/
      end
    end
    it "should link info.json" do
      document.open_seadragon_tile_source.each do |tile_source|
        expect(tile_source).to match /\/info.json$/
      end
    end
    it "should include the file ids" do
      document.open_seadragon_tile_source.each do |tile_source|
        expect(tile_source).to match /12345%2Fimage-id\d/
      end
    end
    it "should not include .jp2 extensions" do
      document.open_seadragon_tile_source.each do |tile_source|
        expect(tile_source).to_not include('.jp2')
      end
    end
  end
  describe "config" do
    it "should have basic OSD configurations" do
      allow(document).to receive('file_ids').and_return(['image-id1'])
      [:crossOriginPolicy, :zoomInButton, :fullPageButton].each do |config|
        expect(document.osd_config.keys).to include(config)
      end
    end
    it "should not include reference strip configurations if there is only one ID" do
      allow(document).to receive('file_ids').and_return(['image-id1'])
      expect(document.osd_config).not_to have_key(:showReferenceStrip)
    end
    it "should include reference strip configurations if there is more than one ID" do
      allow(document).to receive('file_ids').and_return(['image-id1', 'image-id2'])
      expect(document.osd_config).to have_key(:showReferenceStrip)
      expect(document.osd_config[:showReferenceStrip]).to be_truthy
    end
  end
end
