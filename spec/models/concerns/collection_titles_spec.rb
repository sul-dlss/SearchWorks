# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionTitles do
  let(:document_data) { {} }

  subject(:collection_titles) { SolrDocument.new(document_data).collection_titles }

  context 'when there are no collection titles' do
    it { expect(collection_titles).not_to be_present }
  end

  context 'when there is a collection title' do
    let(:document_data) do
      { collection_struct: [{ "title" => "Robert Creeley Papers Collection", "source" => "sirsi" }] }
    end

    it { expect(collection_titles).to eq [{ "title" => "Robert Creeley Papers Collection" }] }
  end

  context 'when the collection title has a linked vernacular field' do
    let(:document_data) do
      { collection_struct: [{ "title" => "Shao shu min zu she hui li shi diao cha",
                              "source" => "sirsi",
                              "vernacular" => "少数民族社会历史调查" }] }
    end

    it { expect(collection_titles).to eq [{ "title" => "Shao shu min zu she hui li shi diao cha", "vernacular" => "少数民族社会历史调查" }] }
  end

  context 'when the title is nil' do
    let(:document_data) do
      { collection_struct: [{ 'title' => nil,
                              'source' => 'sirsi' }] }
    end

    it { expect(collection_titles).not_to be_present }
  end

  context 'when it is a digital collection' do
    let(:document_data) do
      { collection_struct: [{ 'title' => 'Shao shu min zu she hui li shi diao cha',
                              'source' => 'SDR-PURL' }] }
    end

    it { expect(collection_titles).not_to be_present }
  end
end
