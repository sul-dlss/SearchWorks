require 'rails_helper'

RSpec.describe "catalog/_index_marc" do
  include MarcMetadataFixtures
  before do
    allow(view).to receive_messages(blacklight_config: Blacklight::Configuration.new, document:)
  end

  let(:document) do
    SolrDocument.new(
      author_struct: [
        {
          creator: [{ link: 'Arbitrary, Stewart.', search: 'Arbitrary, Stewart.', post_text: 'fantastic.' }],
          corporate_author: [{ link: 'Arbitrary, Corporate.', search: 'Arbitrary, Corporate.', post_text: 'fantastic.' }],
          meeting: [{ link: 'Arbitrary Meeting.', search: 'Arbitrary, Meeting.', post_text: 'fantastic.' }],
        }
      ],
      imprint_display: ['Imprint Statement'],
      physical: ["The Physical Extent"],
      format_main_ssim: ['Book']
    )
  end

  describe "physical extent" do
    before do
      render
    end

    it "should link to the author" do
      expect(rendered).to have_css('li a', text: 'Arbitrary, Stewart.')
      expect(rendered).not_to have_css('li a', text: /fantastic/)
      expect(rendered).to have_css('li', text: /fantastic\./)
    end
    it "should link to the corporate author" do
      expect(rendered).to have_css('li a', text: 'Arbitrary, Corporate.')
      expect(rendered).not_to have_css('li a', text: /fantastic/)
      expect(rendered).to have_css('li', text: /fantastic\./)
    end
    it "should link to the meeting" do
      expect(rendered).to have_css('li a', text: 'Arbitrary Meeting.')
      expect(rendered).not_to have_css('li a', text: /fantastic/)
      expect(rendered).to have_css('li', text: /fantastic\./)
    end
    it "should render the imprint" do
      expect(rendered).to have_css('li', text: 'Imprint Statement')
    end
    it "should include the physical extent" do
      expect(rendered).to have_css("dt", text: "Description")
      expect(rendered).to have_css("dd", text: "The Physical Extent")
    end
  end

  describe 'summary' do
    context 'when present' do
      let(:document) do
        SolrDocument.new(
          summary_struct: [{ unmatched_vernacular: ['!'] }]
        )
      end

      before do
        render
      end

      it 'renders the section (that would be truncated by js)' do
        expect(rendered).to have_css('dt', text: 'Summary')
      end
    end

    context 'when not present' do
      let(:document) do
        SolrDocument.new({})
      end

      it 'does not render the heading/section at all' do
        expect(rendered).not_to have_css('dt', text: 'Summary')
      end
    end
  end

  describe "databases" do
    let(:document) do
      SolrDocument.new(
        format_main_ssim: ["Database"],
        summary_display: ["The summary of the object"],
        db_az_subject: ["Subject1", "Subject2"]
      )
    end

    before do
      render
    end

    it "should display the database topics" do
      expect(rendered).to have_css('dt', text: "Database topics")
      expect(rendered).to have_css('dd a', text: "Subject1")
      expect(rendered).to have_css('dd a', text: "Subject2")
    end
  end

  describe 'finding aid' do
    let(:document) do
      SolrDocument.new(
        marc_json_struct: metadata1,
        marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/abc123", finding_aid: true }]
      )
    end

    before do
      render
    end

    it 'should display the finding aid' do
      expect(rendered).to have_css('dt', text: 'Finding aid')
      expect(rendered).to have_css('dd a', text: 'Online Archive of California')
    end
  end

  describe 'collection' do
    let(:document) do
      SolrDocument.new(
        collection_struct: [{ 'title' => 'Robert Creeley Papers Collection', 'source' => 'sirsi' }]
      )
    end

    before do
      render
    end

    it 'should display the collection title and subject search link' do
      expect(rendered).to have_css('dt', text: "Collection")
      expect(rendered).to have_css('dd a', text: "Robert Creeley Papers Collection")
    end
  end
end
