# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::LibraryComponent, type: :component do
  subject(:component) { described_class.new(library:, document:) }
  let(:document) { SolrDocument.new }
  let(:library) { Holdings::Library.new('GREEN') }

  context 'with an unknown library' do
    let(:library) { Holdings::Library.new('no-such-library') }

    it "returns a placeholder panel" do
      render_inline(component)

      expect(page).to have_css('h3', text: 'Stanford Libraries')
    end
  end
end
