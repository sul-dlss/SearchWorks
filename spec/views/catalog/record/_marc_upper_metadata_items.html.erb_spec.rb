require 'rails_helper'

RSpec.describe "catalog/record/_marc_upper_metadata_items" do
  include MarcMetadataFixtures

  describe 'MARC 245C' do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: metadata1))
    end

    it 'should display for for 245C field' do
      render
      expect(rendered).to have_css('dt', text: 'Responsibility')
      expect(rendered).to have_css('dd', text: 'Most responsible person ever')
    end
  end

  describe "characteristics" do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: marc_characteristics_fixture))
      render
    end

    it "should display the characteristics with labels" do
      expect(rendered).to have_css('dt', text: 'Sound')
      expect(rendered).to have_css('dd', text: 'digital; optical; surround; stereo; Dolby')
      expect(rendered).to have_css('dt', text: 'Video')
      expect(rendered).to have_css('dd', text: 'NTSC')
      expect(rendered).to have_css('dt', text: 'Digital')
      expect(rendered).to have_css('dd', text: 'video file; DVD video; Region 1')
    end
  end

  describe "series" do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: marc_multi_series_fixture))
      render
    end

    it "link to series" do
      expect(rendered).to have_css('dt', text: "Series")
      expect(rendered).to have_css('dd a', text: "440 $a")
      expect(rendered).to have_css('dd a', text: "Name SubZ")
    end
  end

  describe "Imprint" do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: edition_imprint_fixture))
      render
    end

    it "should include the imprint statement" do
      expect(rendered).to have_css('dt', text: "Imprint")
      expect(rendered).to have_css('dd', text: "SubA SubB SubC SubG")
    end
  end

  describe 'Edition' do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: edition_imprint_fixture))
      render
    end

    it "should include the edition statement" do
      expect(rendered).to have_css('dt', text: "Edition")
      expect(rendered).to have_css('dd', text: "SubA SubB")
    end
  end

  describe "MARC 264" do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: single_marc_264_fixture))
      render
    end

    it "should be rendered" do
      expect(rendered).to have_css('dt', text: 'Production')
      expect(rendered).to have_css('dd', text: 'SubfieldA SubfieldB')
    end
  end

  describe "Instrumentation (Marc 382)" do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: marc_382_instrumentation))
      render
    end

    it "should be rendered and include specific dts/dds" do
      expect(rendered).to have_css('dt', text: 'Instrumentation')
      expect(rendered).to have_css('dd', text: 'singer (1) or bass guitar (2), percussion (1) (4 hands), guitar (1) / electronics (1), solo flute (1) (total=8)')
      expect(rendered).to have_css('dd', text: 'singer (3)')
      expect(rendered).to have_css('dt', text: 'Partial instrumentation')
      expect(rendered).to have_css('dd', text: 'cowbell')
    end
  end

  describe 'Linked collection titles' do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: metadata1,
                                         collection_struct: [{ 'title' => 'Bruce & Rachel Jeffer Collection of WPA/Federal Writers Project and related New Deal material',
                                                               'source' => 'sirsi' }]))
      render
    end

    it 'should render the collection titles as links' do
      expect(rendered).to have_css('dt', text: 'Collection')
      expect(rendered).to have_css('dd', text: 'Bruce & Rachel Jeffer Collection of WPA/Federal Writers Project and related New Deal material')
    end
  end
end
