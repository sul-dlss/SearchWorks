# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchResult::Item::Marc::MetadataComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(
      author_struct: [
        {
          creator: [{ link: 'Arbitrary, Stewart.', search: 'Arbitrary, Stewart.', post_text: 'fantastic.' }],
          corporate_author: [{ link: 'Arbitrary, Corporate.', search: 'Arbitrary, Corporate.', post_text: 'fantastic.' }],
          meeting: [{ link: 'Arbitrary Meeting.', search: 'Arbitrary, Meeting.', post_text: 'fantastic.' }]
        }
      ],
      imprint_display: ['Imprint Statement'],
      physical: ["The Physical Extent"],
      format_main_ssim: ['Book']
    )
  end

  subject(:page) { render_inline(component) }

  it "renders the metadata" do
    expect(page).to have_css('li a', text: 'Arbitrary, Stewart.')
    expect(page).to have_no_css('li a', text: /fantastic/)
    expect(page).to have_css('li', text: /fantastic\./)

    expect(page).to have_css('li a', text: 'Arbitrary, Corporate.')
    expect(page).to have_no_css('li a', text: /fantastic/)
    expect(page).to have_css('li', text: /fantastic\./)

    expect(page).to have_css('li a', text: 'Arbitrary Meeting.')
    expect(page).to have_no_css('li a', text: /fantastic/)
    expect(page).to have_css('li', text: /fantastic\./)

    expect(page).to have_css('li', text: 'Imprint Statement')

    expect(page).to have_css("dt", text: "Description")
    expect(page).to have_css("dd", text: "The Physical Extent")
  end

  describe 'summary' do
    context 'when present' do
      let(:document) do
        SolrDocument.new(
          summary_struct: [{ unmatched_vernacular: ['!'] }]
        )
      end

      it 'renders the section (that would be truncated by js)' do
        expect(page).to have_css('dt', text: 'Summary')
      end
    end

    context 'when not present' do
      let(:document) do
        SolrDocument.new({})
      end

      it 'does not render the heading/section at all' do
        expect(page).to have_no_css('dt', text: 'Summary')
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

    it "displays the database topics" do
      expect(page).to have_css('dt', text: "Database topics")
      expect(page).to have_css('dd a', text: "Subject1")
      expect(page).to have_css('dd a', text: "Subject2")
    end
  end

  describe 'finding aid' do
    let(:document) do
      SolrDocument.new(
        marc_json_struct: metadata1,
        marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/abc123", finding_aid: true }]
      )
    end

    it 'displays the finding aid' do
      expect(page).to have_css('dt', text: 'Finding aid')
      expect(page).to have_css('dd a', text: 'Online Archive of California')
    end
  end

  describe 'collection' do
    let(:document) do
      SolrDocument.new(
        collection_struct: [{ 'title' => 'Robert Creeley Papers Collection', 'source' => 'sirsi' }]
      )
    end

    it 'displays the collection title and subject search link' do
      expect(page).to have_css('dt', text: "Collection")
      expect(page).to have_css('dd a', text: "Robert Creeley Papers Collection")
    end
  end
end
