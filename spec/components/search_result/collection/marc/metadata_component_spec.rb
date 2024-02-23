require 'rails_helper'

RSpec.describe SearchResult::Collection::Marc::MetadataComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(
      id: 10,
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

  it "renders the metadata with only the expected fields" do
    expect(page).to have_css('li', text: 'Arbitrary, Stewart.')

    expect(page).to have_css("dt", text: "Description")
    expect(page).to have_css("dd", text: "The Physical Extent")

    expect(page).to have_no_content "Finding aid"
    expect(page).to have_no_content "Digital collection"
  end

  describe 'summary' do
    context 'when no fields are present' do
      let(:document) do
        SolrDocument.new({ id: 10 })
      end

      it 'does not render dl class' do
        expect(page).to have_no_css('dl')
      end
    end
  end
end
