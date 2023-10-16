require 'rails_helper'

RSpec.describe LinkedAuthor do # rubocop: disable Metrics/BlockLength
  include MarcMetadataFixtures

  subject(:instance) { described_class.new(document, target) }

  let(:document) { SolrDocument.new(author_struct: [{ target => [value] }]) }
  let(:target) { :corporate_author }
  let(:value) { double }

  context 'base' do
    it '#to_partial_path is overriden from the base partial path' do
      expect(instance.to_partial_path).to eq 'marc_fields/linked_author'
    end
  end

  context 'corporate_author' do
    it '#label' do
      expect(instance.label).to eq 'Corporate Author'
    end
    it '#values' do
      expect(instance.values).to include value
    end
  end

  context 'meeting' do
    let(:target) { :meeting }

    it '#label' do
      expect(instance.label).to eq 'Meeting'
    end
    it '#values' do
      expect(instance.values).to include value
    end
  end

  context 'creator' do
    let(:target) { :creator }

    it '#label' do
      expect(instance.label).to eq 'Author/Creator'
    end

    it '#values' do
      expect(instance.values).to include value
    end
  end
end
