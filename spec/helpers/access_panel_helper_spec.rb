require 'spec_helper'

describe AccessPanelHelper do
  let(:library) { Holdings::Library.new("GREEN") }

  describe "link_to_library_header" do
    it "should return a header with a link to library about page" do
      expect(helper.link_to_library_header(library)).to include "<h3 class=\"\">Green Library</h3>"
    end
  end

  describe "thumb_for_library" do
    it "should return the image tag for the thumbnail for the specified library" do
      img = helper.thumb_for_library(library)
      expect(img).to have_css('img[src^="/assets/GREEN"][data-hidpi-src^="/assets/GREEN@2x"]')
    end
    it "should return the image tag (w/ png extension) for the ZOMBIE library" do
      library = Holdings::Library.new("ZOMBIE")
      img = helper.thumb_for_library(library)
      expect(img).to have_css('img[src^="/assets/ZOMBIE"][data-hidpi-src^="/assets/ZOMBIE@2x"]')
    end
  end
end
