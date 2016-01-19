require "spec_helper"

describe "catalog/thumbnails/_item_thumbnail.html.erb" do
  before do
    allow(view).to receive(:css_class).and_return('')
    allow(view).to receive(:oclc).and_return('')
    allow(view).to receive(:isbn).and_return('')
    allow(view).to receive(:lccn).and_return('')
    allow(view).to receive(:document).and_return(document)
  end

  context 'non SDR object' do
    let(:document) { SolrDocument.new(id: '1234', title_display: 'Title') }
    describe "fake covers" do
      it "should be included on the gallery view" do
        allow(view).to receive(:document_index_view_type).and_return(:gallery)
        render
        expect(rendered).to have_css('.fake-cover', text: "Title")
      end
      it "should not be included on other views" do
        allow(view).to receive(:document_index_view_type).and_return(:list)
        render
        expect(rendered).to have_css('img.cover-image')
        expect(rendered).to_not have_css('.fake-cover')
      end
    end
  end

  context 'SDR object' do
    let(:document) { SolrDocument.new(display_type: ['image'], file_id: ['abc123']) }

    describe 'thumbnail image' do
      it 'should be present from stacks' do
        render
        html = Capybara.string(rendered)
        expect(html).to have_css('img.stacks-image')
        expect(html.all('img.stacks-image').first['src']).to match(%r{iiif/%2Fabc123/full})
      end
    end
  end
end
