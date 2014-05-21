require 'spec_helper'
require 'selected_databases'

describe SelectedDatabases do
  let(:documents) { [OpenStruct.new(id: "5749286"), OpenStruct.new(id: "7630484")] }
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
    let(:selected_database) { SelectedDatabases::SelectedDatabase.new(id: "7626894") }
    it "should match configured databases with the matching documents" do
      expect(selected_database.selected_database_description).to eq "Includes the full text with ongoing updates of The New Grove Dictionary of Music and Musicians, 2nd ed. Also includes The New Grove Dictionary of Opera, and The New Grove Dictionary of Jazz, 2nd ed."
      expect(selected_database.selected_database_subjects).to eq ["Music"]
    end
  end
end
