# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::AccessLinkComponent, type: :component do
  let(:link) do
    Links::Link.new(
      href: 'http://link.edu', link_text: 'Link Text', fulltext: true, stanford_only: true, finding_aid: true, sfx: true, managed_purl: true
    )
  end

  before do
    render_inline(described_class.new(link: link))
  end

  it 'assembles the html link' do
    expect(page).to have_link 'Link Text', href: 'http://link.edu', class: 'sfx'
  end
end
