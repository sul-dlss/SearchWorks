require 'rails_helper'

RSpec.describe SchemaDotOrg do
  context 'with data serialized into the solr document' do
    let(:document) { SolrDocument.new(schema_dot_org_struct: [{ schema: '.org' }]) }

    it 'uses that data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to eq 'schema' => '.org'
    end
  end

  context 'a book with a person-author' do
    let(:document) do
      SolrDocument.new(
        title_display: 'My book title',
        author_person_display: 'S. author',
        format_main_ssim: 'Book'
      )
    end

    it 'fabricates schema.org data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to include '@type': 'Book',
                                                    name: 'My book title',
                                                    author: { '@type': 'Person', name: 'S. author' }
    end
  end

  context 'a map with a corporate author' do
    let(:document) do
      SolrDocument.new(
        title_display: 'Map title',
        author_corp_display: 'USGS',
        format_main_ssim: 'Map'
      )
    end

    it 'fabricates schema.org data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to include '@type': 'Map',
                                                    name: 'Map title',
                                                    author: { '@type': 'Organization', name: 'USGS' }
    end
  end

  context 'a journal with a meeting author' do
    let(:document) do
      SolrDocument.new(
        title_display: 'Code4Lib Journal',
        author_meeting_display: 'code4lib',
        format_main_ssim: 'Journal/Periodical'
      )
    end

    it 'fabricates schema.org data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to include '@type': 'Periodical',
                                                    name: 'Code4Lib Journal',
                                                    author: { '@type': 'Organization', name: 'code4lib' }
    end
  end

  context 'a thesis/disertation' do
    let(:document) do
      SolrDocument.new(
        genre_ssim: ['Thesis/Dissertation']
      )
    end

    it 'fabricates schema.org data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to include '@type': 'Thesis'
    end
  end

  context 'a equipment' do
    let(:document) do
      SolrDocument.new(
        format_main_ssim: ['Equipment']
      )
    end

    it 'fabricates schema.org data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to eq(:@context => "http://schema.org", :@type => "Thing")
    end
  end

  context 'a video game' do
    let(:document) do
      SolrDocument.new(
        genre_ssim: ['Video games']
      )
    end

    it 'fabricates schema.org data' do
      expect(document).to be_schema_dot_org
      expect(document.as_schema_dot_org).to include '@type': 'VideoGame'
    end
  end
end
