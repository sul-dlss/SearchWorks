require 'spec_helper'
require 'selected_databases'

describe SelectedDatabases do
  let(:documents) { [SolrDocument.new(id: "5749286"), SolrDocument.new(id: "7630484")] }
  let(:selected_databases) { SelectedDatabases.new(documents) }

  describe "#databases" do
    it "should return the same number of databases that are in the original document list" do
      expect(selected_databases.databases.length).to eq documents.length
    end
    it "should return an array of databases" do
      selected_databases.databases.each do |database|
        expect(database).to be_a SelectedDatabases::SelectedDatabase
      end
    end
  end

  describe "#ids" do
    it "should return the list of ids in the databases configuration" do
      expect(SelectedDatabases.ids).to be_an Array
      expect(SelectedDatabases.ids.first).to eq "5749286"
      expect(SelectedDatabases.ids.length).to eq SelectedDatabases.config.length
    end
  end

  describe "SelectedDatabase" do
    let(:selected_database) { SelectedDatabases::SelectedDatabase.new(id: "6494821") }

    it "should match configured databases with the matching documents" do
      expect(selected_database.selected_database_description).to eq "Bibliographic database on art and related disciplines; also indexes art reproductions. Coverage begins in 1984, but full-text starts in 1997; a related database, Art Retrospective, indexes articles from 1929-1984"
      expect(selected_database.selected_database_subjects).to eq ["Art"]
      expect(selected_database.selected_database_see_also.id).to eq "6666306"
      expect(selected_database.selected_database_see_also.text).to eq "Art Retrospective"
    end
  end
end
