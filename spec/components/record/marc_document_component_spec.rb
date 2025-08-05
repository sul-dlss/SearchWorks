# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::MarcDocumentComponent, type: :component do
  include MarcMetadataFixtures

  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document: ShowDocumentPresenter.new(document, view_context)) }
  let(:view_context) { ActionController::Base.helpers }
  let(:document) do
    SolrDocument.new(id: '123', marc_json_struct: managed_purl_fixture,
                     marc_links_struct: [
                       { link_text: 'Some Part Label', managed_purl: true },
                       { managed_purl: true }
                     ])
  end

  before do
    allow(view_context).to receive_messages(blacklight_config: CatalogController.blacklight_config, action_name: 'show')
  end

  it 'includes the managed purl panel and upper metadata elements' do
    expect(page).to have_css('.managed-purl .digital-viewer')
    expect(page).to have_css('.upper-record-metadata')
    expect(page).to have_css('li', text: 'Some Part Label')
    expect(page).to have_css('li', text: 'part 2')
  end

  describe "MARC 592" do
    let(:document) { SolrDocument.new(marc_json_struct: marc_592_fixture) }

    it "displays for databases" do
      allow(document).to receive(:is_a_database?).and_return(true)
      expect(page).to have_css("dt", text: "Note")
      expect(page).to have_css("dd", text: "A local note added to subjects only")
    end

    it "does not display for non-databases" do
      allow(document).to receive(:is_a_database?).and_return(false)
      expect(page).to have_no_css("dt", text: "Note")
      expect(page).to have_no_css("dd", text: "A local note added to subjects only")
    end
  end

  describe "dates from solr" do
    let(:document) { SolrDocument.new(marc_json_struct: metadata1, publication_year_isi: '1234', other_year_isi: '4321', copyright_year_isi: '5678') }

    it "includes dates from solr" do
      expect(page).to have_css('dt', text: 'Publication date')
      expect(page).to have_css('dd', text: '1234')

      expect(page).to have_css('dt', text: 'Date')
      expect(page).to have_css('dd', text: '4321')

      expect(page).to have_css('dt', text: 'Copyright date')
      expect(page).to have_css('dd', text: '5678')
    end
  end

  describe 'Related works' do
    let(:document) do
      SolrDocument.new(marc_json_struct: contributed_works_fixture)
    end

    it 'includes the related works section' do
      expect(page).to have_css('dt', text: 'Related Work')
      expect(page).to have_css('dd a', text: '700 with t 700 $e Title.')
      expect(page).to have_no_css('dt', text: 'Included Work')
      expect(page).to have_no_css('dt', text: 'Contributor')
    end
  end

  describe "Contributors section" do
    let(:document) do
      SolrDocument.new(author_struct: [
        {
          contributors: [
            { link: '<a href="...">Contributor1</a>', search: '...', post_text: 'Performer' },
            { link: '<a href="...">Contributor2</a>', search: '...', post_text: 'Performer' },
            { link: '<a href="...">Contributor3</a>', search: '...', post_text: 'Actor' }
          ]
        }
      ])
    end

    it "displays secondary authors" do
      expect(page).to have_css("dt", text: "Contributor")
      expect(page).to have_css('dd', count: 3)

      expect(page).to have_css("dd a", text: "Contributor1")

      expect(page).to have_css("dd a", text: "Contributor2")
      expect(page).to have_css("dd", text: /Performer/, count: 2)

      expect(page).to have_css("dd a", text: "Contributor3")
      expect(page).to have_css("dd", text: /Actor/)
    end
  end

  describe "Metadata sections all available" do
    let(:document) do
      SolrDocument.new(marc_json_struct: marc_sections_fixture, author_struct: [{ creator: [{ link: '...', search: '...' }] }], marc_links_struct: [{ material_type: 'finding aid' }])
    end

    it "displays correct sections" do
      expect(page).to have_css('h2', text: "Contributors")
      expect(page).to have_css('h2', text: "Bibliographic information")
    end
  end

  describe "subjects" do
    let(:document) do
      SolrDocument.new(
        marc_json_struct: marc_mixed_subject_fixture
      )
    end

    it "renders non-marc 655 subjects under 'Subject'" do
      expect(page).to have_css('dt', text: "Subject")
      expect(page).to have_css('dd a', text: "Subject A1")
    end

    it "includes an aria-label attribute" do
      expect(page).to have_css('dd a[aria-label="Subject A1"]')
    end

    it "renders non-marc 655 subjects under 'Genre'" do
      expect(page).to have_css('dt', text: "Genre")
      expect(page).to have_css('dd a', text: "Subject A1")
    end

    it 'renders the MARC 690 as local subjects' do
      expect(page).to have_css('dt', text: 'Local subject')
      expect(page).to have_css('dd', text: 'Local Subject A1')
    end
  end

  context 'with duplicate subjects' do
    let(:document) do
      SolrDocument.new(
        marc_json_struct: marc_duplicate_subject_fixture
      )
    end

    it 'deduplicates the display' do
      expect(page).to have_css('dd', text: 'Piano music.', count: 1)
      expect(page).to have_css('dd', text: 'Waltzes.', count: 1)
      expect(page).to have_css('dd', text: 'Canons, fugues, etc. (Piano)', count: 1)
      expect(page).to have_css('dd', text: 'Marches.', count: 1)
      expect(page).to have_css('dd', text: /Piano, Musique de\.\s*>\s*Sound recordings\./, count: 1)
    end
  end

  describe "Database subjects" do
    let(:document) do
      SolrDocument.new(
        marc_json_struct: no_fields_fixture,
        db_az_subject: ["DB Subject1", "DB Subject2"]
      )
    end

    it "displays for databases" do
      expect(page).to have_css("dd a", text: "DB Subject1")
      expect(page).to have_css("dd a", text: "DB Subject2")
    end
  end

  describe 'MARC 245C' do
    let(:document) { SolrDocument.new(marc_json_struct: metadata1) }

    it 'displays for for 245C field' do
      expect(page).to have_css('dt', text: 'Responsibility')
      expect(page).to have_css('dd', text: 'Most responsible person ever')
    end
  end

  describe "characteristics" do
    let(:document) { SolrDocument.new(marc_json_struct: marc_characteristics_fixture) }

    it "displays the characteristics with labels" do
      expect(page).to have_css('dt', text: 'Sound')
      expect(page).to have_css('dd', text: 'digital; optical; surround; stereo; Dolby')
      expect(page).to have_css('dt', text: 'Video')
      expect(page).to have_css('dd', text: 'NTSC')
      expect(page).to have_css('dt', text: 'Digital')
      expect(page).to have_css('dd', text: 'video file; DVD video; Region 1')
    end
  end

  describe "series" do
    let(:document) { SolrDocument.new(marc_json_struct: marc_multi_series_fixture) }

    it "link to series" do
      expect(page).to have_css('dt', text: "Series")
      expect(page).to have_css('dd a', text: "440 $a")
      expect(page).to have_css('dd a', text: "Name SubZ")
    end
  end

  describe "Imprint" do
    let(:document) { SolrDocument.new(marc_json_struct: edition_imprint_fixture) }

    it "includes the imprint statement" do
      expect(page).to have_css('dt', text: "Imprint")
      expect(page).to have_css('dd', text: "SubA SubB SubC SubG")
    end
  end

  describe 'Edition' do
    let(:document) { SolrDocument.new(marc_json_struct: edition_imprint_fixture) }

    it "includes the edition statement" do
      expect(page).to have_css('dt', text: "Edition")
      expect(page).to have_css('dd', text: "SubA SubB")
    end
  end

  describe "MARC 264" do
    let(:document) { SolrDocument.new(marc_json_struct: single_marc_264_fixture) }

    it "is page" do
      expect(page).to have_css('dt', text: 'Production')
      expect(page).to have_css('dd', text: 'SubfieldA SubfieldB')
    end
  end

  describe "Instrumentation (Marc 382)" do
    let(:document) { SolrDocument.new(marc_json_struct: marc_382_instrumentation) }

    it "is page and include specific dts/dds" do
      expect(page).to have_css('dt', text: 'Instrumentation')
      expect(page).to have_css('dd', text: 'singer (1) or bass guitar (2), percussion (1) (4 hands), guitar (1) / electronics (1), solo flute (1) (total=8)')
      expect(page).to have_css('dd', text: 'singer (3)')
      expect(page).to have_css('dt', text: 'Partial instrumentation')
      expect(page).to have_css('dd', text: 'cowbell')
    end
  end

  describe 'Linked collection titles' do
    let(:document) do
      SolrDocument.new(marc_json_struct: metadata1,
                       collection_struct: [{ 'title' => 'Bruce & Rachel Jeffer Collection of WPA/Federal Writers Project and related New Deal material',
                                             'source' => 'sirsi' }])
    end

    it 'renders the collection titles as links' do
      expect(page).to have_css('dt', text: 'Collection')
      expect(page).to have_css('dd', text: 'Bruce & Rachel Jeffer Collection of WPA/Federal Writers Project and related New Deal material')
    end
  end
end
