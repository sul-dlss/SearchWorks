# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::SearchResult::ItemMenuComponent, type: :component do
  before do
    render_inline(described_class.new(document:))
  end

  let(:document) { SolrDocument.new(id: "123") }

  it "renders the menu" do
    expect(page).to have_link 'Cite'
    expect(page).to have_link 'Email'
    expect(page).to have_button 'Copy link to record'
  end
end
