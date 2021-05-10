require 'spec_helper'

describe BoundWithNote do
  include MarcMetadataFixtures
  let(:marc) { linked_ckey_fixture }
  let(:document) { SolrDocument.new(marcxml: marc) }

  subject { described_class.new(document, %w(590)) }

  describe '#values' do
    it 'links to the parent ID if there is a $c' do
      expect(subject.values.length).to eq 2
      expect(subject.values).to include 'Copy 1 bound with v. 140 <a href="/view/55523">55523</a> (parent record’s ckey)'
      expect(subject.values).to include 'A 590 that does not have $c'
    end
  end
end
