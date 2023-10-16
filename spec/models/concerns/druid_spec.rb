require 'rails_helper'

RSpec.describe Druid do
  let(:explicit_druid) do
    SolrDocument.new(
      druid: '321cba'
    )
  end

  let(:managed_purl) do
    SolrDocument.new(
      marc_links_struct: [{ href: 'https://purl.stanford.edu/abc123', managed_purl: true, druid: 'abc123' }]
    )
  end

  let(:no_druid) do
    SolrDocument.new(
      marc_links_struct: [{ href: 'https://www.library.edu/something', fulltext: true }]
    )
  end

  it 'returns the druid from the druid field if available' do
    expect(explicit_druid.druid).to eq '321cba'
  end

  it 'returns a druid from a managed purl link' do
    expect(managed_purl.druid).to eq 'abc123'
  end

  it 'returns nil if there is neither a druid on the document nor a druid in the link' do
    expect(no_druid.druid).to be_nil
  end
end
