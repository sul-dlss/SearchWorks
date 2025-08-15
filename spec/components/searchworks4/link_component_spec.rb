# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::LinkComponent, type: :component do
  let(:link) do
    Links::Link.new(
      href: 'http://link.edu', link_text: 'Link Text', fulltext: true, stanford_only: true, finding_aid: true, managed_purl: true
    )
  end

  let(:document) { SolrDocument.new(id: '123') }

  before do
    render_inline(described_class.new(link: link, document:))
  end

  it 'assembles the html link' do
    expect(page).to have_link 'Link Text', href: 'http://link.edu'
  end

  context 'with a stanford-only link' do
    let(:link) do
      Links::Link.new(
        href: 'https://llmc.com/some-restricted-link', link_text: 'Stanford Only Link', fulltext: true, stanford_only: true
      )
    end

    it 'renders the link through ezproxy' do
      expect(page).to have_link 'Stanford Only Link', href: 'https://stanford.idm.oclc.org/login?qurl=https%3A%2F%2Fllmc.com%2Fsome-restricted-link'
      expect(page).to have_button 'Stanford-only', class: 'stanford-only'
    end
  end

  context 'with a LANE document' do
    let(:document) do
      SolrDocument.new(
        holdings_library_code_ssim: ['LANE']
      )
    end

    let(:link) do
      Links::Link.new(href: 'http://www.who.int/some-link', stanford_only: true)
    end

    it 'renders the link through the Lane ezproxy' do
      expect(page).to have_link 'www.who.int', href: 'https://login.laneproxy.stanford.edu/login?qurl=http%3A%2F%2Fwww.who.int%2Fsome-link'
    end
  end
end
