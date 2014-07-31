require 'spec_helper'

describe AccessPanelHelper do
  let(:library) { Holdings::Library.new("GREEN") }
  describe "link_to_library" do
    it "should return a link to library about page" do
      expect(helper.link_to_library(library)).to eq "<a href=\"http://library.stanford.edu/libraries/green/about\">Green Library</a>"
    end
  end

  describe "thumb_for_library" do
    it "should return the image tag for the thumbnail for the specified library" do
      expect(helper.thumb_for_library(library)).to eq "<img alt=\"\" class=\"pull-left\" data-hidpi-src=\"/assets/GREEN@2x.jpg\" height=\"50\" src=\"/assets/GREEN.jpg\" />"
    end
    it "should reuturn the image tag (w/ png extension) for the ZOMBIE library" do
      library = Holdings::Library.new("ZOMBIE")
      expect(helper.thumb_for_library(library)).to eq "<img alt=\"\" class=\"pull-left\" data-hidpi-src=\"/assets/ZOMBIE@2x.png\" height=\"50\" src=\"/assets/ZOMBIE.png\" />"
    end
  end
end
