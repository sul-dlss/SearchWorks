# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#active_class_for_current_page" do
    let(:advanced_page) { "advanced" }

    it "is active" do
      helper.request.path = "advanced"
      expect(helper.active_class_for_current_page(advanced_page)).to eq "active"
    end
    it "is not active" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(advanced_page)).to be_nil
    end
  end

  describe "#from_advanced_search" do
    it "indicates if we are coming from the advanced search form" do
      params[:search_field] = 'advanced'
      expect(helper.from_advanced_search?).to be_truthy
    end
  end
end
