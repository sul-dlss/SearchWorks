require 'spec_helper'

describe "catalog/record/_marc_contents_summary.html.erb" do
  include MarcMetadataFixtures
  include Marc856Fixtures

  describe 'Organization & arrangement' do
    context 'when present' do
      before do
        assign(:document, SolrDocument.new(marcxml: organization_and_arrangement_fixture) )
        render
      end

      it 'is rendered when present' do
        expect(rendered).to have_css('dt', text: 'Organization & arrangement')
        expect(rendered).to have_css('dd', text: '351 $3 351 $c 351 $a 351 $b')
      end
    end

    context 'when not present' do
      before do
        assign(:document, SolrDocument.new(marcxml: finding_aid_856) )
        render
      end

      it 'is not renedered' do
        expect(rendered).to_not have_css('dt', text: 'Organization & arrangement')
      end
    end
  end

  describe "finding aids" do
    before do
      assign(:document, SolrDocument.new(marcxml: finding_aid_856, marc_links_struct: [{ finding_aid: true, html: '<a href="...">FINDING AID: Link text</a>' }]) )
    end
    it "should be displayed when present" do
      render
      expect(rendered).to have_css("dt", text: "Finding aid")
      expect(rendered).to have_css("dd", text: "FINDING AID:")
      expect(rendered).to have_css("dd a", text: "Link text")
    end
  end
  it "should be blank if the document has not fields" do
    assign(:document, SolrDocument.new(marcxml: no_fields_fixture))
    render
    expect(rendered).to be_blank
  end
  describe 'included works' do
    before do
      assign(:document, SolrDocument.new(marcxml: contributed_works_fixture))
      render
    end
    it 'should include the included works section' do
      expect(rendered).to have_css('dt', text: 'Included Work')
      expect(rendered).to have_css('dd a', count: 2)
      expect(rendered).to have_css('dd a', text: '710 with t ind2 Title! sub n after t')
      expect(rendered).to_not have_css('dt', text: 'Related Work')
      expect(rendered).to_not have_css('dt', text: 'Contributor')
    end
  end
end
