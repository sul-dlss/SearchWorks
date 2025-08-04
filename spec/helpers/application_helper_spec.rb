# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#from_advanced_search" do
    it "indicates if we are coming from the advanced search form" do
      params[:search_field] = 'advanced'
      expect(helper.from_advanced_search?).to be_truthy
    end
  end
end
