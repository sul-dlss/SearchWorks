require 'spec_helper'

RSpec.describe AccessPanels::LibraryComponent, type: :component do
  subject(:component) { described_class.new(library: library, document: document) }
  let(:document) { SolrDocument.new }
  let(:library) { Holdings::Library.new('GREEN') }

  it "should return the image tag for the thumbnail for the specified library" do
    render_inline(component)
    expect(page).to have_selector('img[src^="/assets/GREEN"][data-hidpi-src^="/assets/GREEN@2x"]')
  end

  context 'with a ZOMBIE library' do
    let(:library) { Holdings::Library.new('ZOMBIE') }

    it "should return the image tag (w/ png extension) for the ZOMBIE library" do
      render_inline(component)
      expect(page).to have_selector('img[src^="/assets/ZOMBIE"][data-hidpi-src^="/assets/ZOMBIE@2x"]')
    end
  end
end