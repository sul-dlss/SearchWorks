require 'spec_helper'

describe MarcSeries do
  subject { SolrDocument.new }

  it 'includes the linked_series method' do
    expect(subject).to respond_to :linked_series
  end

  it 'includes the unlinked_series method' do
    expect(subject).to respond_to :unlinked_series
  end
end
