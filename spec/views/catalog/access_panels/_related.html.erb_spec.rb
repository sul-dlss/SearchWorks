require "spec_helper"

describe "catalog/access_panels/_related" do
  it 'should be hidden by default' do
    assign(:document, SolrDocument.new)
    render
    expect(rendered).to have_css('div.panel-related', visible: false)
  end
  describe 'WorldCat Link' do
    before do
      assign(:document, SolrDocument.new(
        oclc: ["12345"]
      ))
      render
    end

    it 'should render an OCLC link' do
      expect(rendered).to have_css('div.panel-related', visible: true)
      expect(rendered).to have_css('li.worldcat a', text: "Find it at other libraries via WorldCat")
    end
  end
end
