# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::MarcContentsSummaryComponent, type: :component do
  include MarcMetadataFixtures
  include Marc856Fixtures

  let(:component) { described_class.new(document:) }
  let(:marc_links_struct) { [] }
  let(:summary_struct) { [] }

  let(:document) do
    SolrDocument.new(id: '123', marc_json_struct:, marc_links_struct:, summary_struct:)
  end

  before { render_inline(component) }

  describe 'Organization & arrangement' do
    context 'when present' do
      let(:marc_json_struct) { organization_and_arrangement_fixture }

      it 'is rendered when present' do
        expect(page).to have_css('dt', text: 'Organization & arrangement')
        expect(page).to have_css('dd', text: '351 $3 351 $c 351 $a 351 $b')
      end
    end

    context 'when not present' do
      let(:marc_json_struct) { finding_aid_856 }

      it 'is not renedered' do
        expect(page).to have_no_css('dt', text: 'Organization & arrangement')
      end
    end
  end

  describe "finding aids" do
    let(:marc_json_struct) { finding_aid_856 }
    let(:marc_links_struct) { [{ material_type: 'finding aid', href: 'http://oac.cdlib.org/findai/ark:/13030/an-ark', link_text: 'FINDING AID: Link text' }] }

    it "is displayed when present" do
      expect(page).to have_css("dt", text: "Finding aid")
      expect(page).to have_css("dd a", text: "Online Archive of California")
    end
  end

  context 'document has no fields' do
    let(:marc_json_struct) { no_fields_fixture }

    it "is blank if the document has not fields" do
      expect(page.native.inner_html.strip).to be_blank
    end
  end

  describe 'included works' do
    let(:marc_json_struct) { contributed_works_fixture }

    it 'includes the included works section' do
      expect(page).to have_css('dt', text: 'Included work')
      expect(page).to have_css('dd a', count: 2)
      expect(page).to have_css('dd a', text: '710 with t ind2 Title! sub n after t')
      expect(page).to have_no_css('dt', text: 'Related Work')
      expect(page).to have_no_css('dt', text: 'Contributor')
    end
  end

  describe 'Contents/Summary' do
    let(:summary_struct) {
      [
        { label: 'Summary', fields: [{ field: 'Summary of content' }] },
        { label: 'Content advice', fields: [{ field: 'Warning about the content' }] }
      ]
    }
    let(:marc_json_struct) { no_fields_fixture }

    it 'displays a Summary if present' do
      expect(page).to have_css('dt', text: /Summary/)
      expect(page).to have_css('dd', text: /Summary of content/)
    end

    it 'does not display Content advice' do
      expect(page).to have_no_css('dt', text: /Content advice/)
      expect(page).to have_no_css('dd', text: /Warning about the content/)
    end
  end
end
