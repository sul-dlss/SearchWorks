require 'spec_helper'

describe LinkedAuthor, type: :model do # rubocop: disable Metrics/BlockLength
  include MarcMetadataFixtures

  subject(:instance) { described_class.new(document, target) }
  let(:document) { SolrDocument.new(marcxml: send("linked_author_#{target}_fixture".to_sym)) }
  let(:target) { :corporate_author }

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
      expect(instance.values).to include(
        link: 'Ecuador. Procuraduría General del Estado, A Title ',
        search: 'Ecuador. Procuraduría General del Estado, ',
        post_text: 'author, issuing body. Art copyist '
      )
    end
  end

  context 'meeting' do
    let(:target) { :meeting }

    it '#label' do
      expect(instance.label).to eq 'Meeting'
    end
    it '#values' do
      expect(instance.values).to include(
        link: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria) A title ',
        search: 'Technical Workshop on Organic Agriculture (1st : 2010 : Ogbomoso, Nigeria) ',
        post_text: 'creator. Other '
      )
    end
  end

  context 'creator' do
    let(:target) { :creator }

    it '#label' do
      expect(instance.label).to eq 'Author/Creator'
    end

    it '#values' do
      expect(instance.values).to include(
        link: 'Dodaro, Gene L. ',
        search: 'Dodaro, Gene L. ',
        post_text: 'author. Author '
      )
    end
  end
end
