# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelectedDatabase do
  describe "SelectedDatabase" do
    let(:selected_database) { SolrDocument.new(id: "6494821") }

    it "should match configured databases with the matching documents" do
      expect(selected_database.selected_database_description).to eq "Bibliographic database on art and related disciplines; also indexes art reproductions. Coverage begins in 1984, but full-text starts in 1997; a related database, Art Retrospective, indexes articles from 1929-1984"
      expect(selected_database.selected_database_subjects).to eq ["Art"]
      expect(selected_database.selected_database_see_also.id).to eq "6666306"
      expect(selected_database.selected_database_see_also.text).to eq "Art Retrospective"
    end
  end
end
