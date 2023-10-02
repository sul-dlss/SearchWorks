require 'spec_helper'

RSpec.describe AccessPanels::LibraryComponent, type: :component do
  subject(:component) { described_class.new(library:, document:) }
  let(:document) { SolrDocument.new }
  let(:library) { Holdings::Library.new('GREEN') }

  it "returns the image tag for the thumbnail for the specified library" do
    render_inline(component)
    expect(page).to have_selector('img[src^="/assets/GREEN"][srcset^="/assets/GREEN@2x"]')
  end

  context 'with a ZOMBIE library' do
    let(:library) { Holdings::Library.new('ZOMBIE') }

    it "returns the image tag (w/ png extension) for the ZOMBIE library" do
      render_inline(component)

      expect(page).to have_selector('img[src^="/assets/ZOMBIE"][srcset^="/assets/ZOMBIE@2x"]')
    end
  end

  context 'with an unknown library' do
    let(:library) { Holdings::Library.new('no-such-library') }

    it "returns a placeholder panel" do
      render_inline(component)

      expect(page).to have_selector('h3', text: 'Stanford Libraries')
    end
  end
end
