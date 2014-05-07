require 'spec_helper'
require 'page_location'

describe ApplicationController do
  describe "#page_location" do
    it "should be a SearchWorks::PageLocation" do
      expect(controller.send(:page_location)).to be_a SearchWorks::PageLocation
    end
  end
end
