require "spec_helper"

describe "catalog/record/_marc_subjects.html.erb" do
  include MarcMetadataFixtures

  describe "subjects" do
    before do
      assign(:document, SolrDocument.new(
        marcxml: marc_mixed_subject_fixture
      ))
      render
    end
    it "should render non-marc 655 subjects under 'Subject'" do
      expect(rendered).to have_css('dt', text: "Subject")
      expect(rendered).to have_css('dd a', text: "Subject A1")
    end
    it "should render non-marc 655 subjects under 'Genre'" do
      expect(rendered).to have_css('dt', text: "Genre")
      expect(rendered).to have_css('dd a', text: "Subject A1")
    end
  end

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
      allow(document).to receive(:is_a_database?).and_return(true)
      render
      expect(rendered).to have_css("dd a", text: "DB Subject1")
      expect(rendered).to have_css("dd a", text: "DB Subject2")
    end
    it "should not display for non-databases" do
      allow(document).to receive(:is_a_database?).and_return(false)
      render
      expect(rendered).to_not have_css("dd a", text: "DB Subject1")
      expect(rendered).to_not have_css("dd a", text: "DB Subject2")
    end
  end
end
