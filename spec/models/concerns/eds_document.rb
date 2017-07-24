require "spec_helper"

describe EdsDocument do
  let(:document) do
    SolrDocument.new(id: '123', eds_html_fulltext: '<anid>09dfa;</anid><p>This Journal</p>, 10(1)')
  end
  let(:empty_document) do
    SolrDocument.new(id: '456', eds_html_fulltext: '')
  end

  describe '#html_fulltext_available' do
    it 'should return true when fulltext is present' do
      expect(document.html_fulltext_available?).to be true
    end

    it 'returns nil when fulltext is not available' do
      expect(empty_document.html_fulltext_available?).to be_falsey
    end
  end
end
