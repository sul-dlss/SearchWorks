# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacetsHelper do
  describe "#render_resource_icon" do
    it "does not render anything if format_main_ssim field is not present" do
      expect(helper.render_resource_icon(nil)).to be_nil
    end
    it "renders a book before a database" do
      expect(helper.render_resource_icon(['Database', 'Book'])).to have_css('.sul-icon.blacklight-icons-book1')
    end
    it "renders an image before a book" do
      expect(helper.render_resource_icon(['Book', 'Image'])).to have_css('.sul-icon.blacklight-icons-photos1')
    end
    it "renders the first resource type icon" do
      expect(helper.render_resource_icon(['Video', 'Image'])).to have_css('.sul-icon.blacklight-icons-film2')
    end
    it "renders an icon that is in Constants::SUL_ICON" do
      expect(helper.render_resource_icon(['Book'])).to have_css('.sul-icon.blacklight-icons-book1')
    end
    it "does not render anything for something not in Constants::SUL_ICON" do
      expect(helper.render_resource_icon(['iPad'])).to be_nil
    end
  end
end
