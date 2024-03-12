# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacetsHelper do
  describe "#render_resource_icon" do
    it "should not render anything if format_main_ssim field is not present" do
      expect(helper.render_resource_icon(nil)).to be_nil
    end
    it "should render a book before a database" do
      expect(helper.render_resource_icon(['Database', 'Book'])).to eq '<span class="sul-icon sul-icon-book-1"></span>'
    end
    it "should render an image before a book" do
      expect(helper.render_resource_icon(['Book', 'Image'])).to eq '<span class="sul-icon sul-icon-photos-1"></span>'
    end
    it "should render the first resource type icon" do
      expect(helper.render_resource_icon(['Video', 'Image'])).to eq '<span class="sul-icon sul-icon-film-2"></span>'
    end
    it "should render an icon that is in Constants::SUL_ICON" do
      expect(helper.render_resource_icon(['Book'])).to eq '<span class="sul-icon sul-icon-book-1"></span>'
    end
    it "should not render anything for something not in Constants::SUL_ICON" do
      expect(helper.render_resource_icon(['iPad'])).to be_nil
    end
  end
end
