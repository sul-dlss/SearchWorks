# frozen_string_literal: true

require 'spec_helper'

describe CollectionTitles do
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
      { "source" => "SDR-PURL",
        "item_type" => "item",
        "type" => "file:jx525pn5438%2Fjx525pn5438_img_1.jp2",
        "druid" => "collection:sz746mt0652::ARS Disc Collection - LP",
        "id" => nil,
        "title" => nil }
    end

    it { expect(collection_titles).not_to be_present }
  end
end
