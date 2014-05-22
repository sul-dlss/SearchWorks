require "spec_helper"

describe "catalog/record/_marc_subjects.html.erb" do
  include MarcMetadataFixtures

  describe "Database subjects" do
    let(:document) {
      SolrDocument.new(
        marcxml: no_fields_fixture,
        db_az_subject: ["DB Subject1", "DB Subject2"]
      )
    }
    before do
      assign(:document, document)
    end
    it "should display for databases" do
      document.stub(:is_a_database?).and_return(true)
      render
      expect(rendered).to have_css("li a", text: "DB Subject1")
      expect(rendered).to have_css("li a", text: "DB Subject2")
    end
    it "should not display for non-databases" do
      document.stub(:is_a_database?).and_return(false)
      render
      expect(rendered).to_not have_css("li a", text: "DB Subject1")
      expect(rendered).to_not have_css("li a", text: "DB Subject2")
    end
  end
end
