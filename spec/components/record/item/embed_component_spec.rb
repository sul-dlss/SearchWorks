# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::Item::EmbedComponent, type: :component do
  let(:component) { described_class.new(druid:) }
  let(:druid) { 'druid:1234' }

  before do
    # The test environment points at a locally mounted mock provider; assert against the
    # real provider so this spec documents the URL we build in production.
    allow(Settings).to receive(:PURL_EMBED_PROVIDER).and_return('https://embed.stanford.edu/embed')
    render_inline(component)
  end

  it 'renders the component' do
    expect(page).to have_css('[data-controller="purl-embed"][data-purl-embed-url-value="https://embed.stanford.edu/embed.json?hide_title=true&url=https://purl.stanford.edu/druid:1234"]')
  end
end
