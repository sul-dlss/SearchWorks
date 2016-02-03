require 'spec_helper'

describe Citation do
  include ModsFixtures
  subject { described_class.new(document, formats) }
  let(:citations) do
    [
      '<p class="citation_style_MLA">MLA Citation</p>',
      '<p class="citation_style_APA">APA Citation</p>'
    ]
  end
  let(:document) { SolrDocument.new }
  let(:formats) { [] }
  let(:oclc_response) { '' }
  let(:stub_opts) { {} }
  before { stub_oclc_response(oclc_response, stub_opts) }

  describe '#citable?' do
    context 'when there is no OCLC number or MODS citation' do
      it 'is false' do
        expect(subject).to_not be_citable
      end
    end

    context 'when there is an OCLC number' do
      let(:stub_opts) { { for: '12345' } }
      it 'is true' do
        expect(subject).to be_citable
      end
    end

    context 'when there is a MODS citation' do
      let(:document) { SolrDocument.new(modsxml: mods_preferred_citation) }
      it 'is true' do
        expect(subject).to be_citable
      end
    end
  end

  describe '#citations' do
    context 'from OCLC' do
      context 'when there is no OCLC number' do
        it 'returns the NULL citation' do
          expect(subject.citations.keys.length).to eq 1
          expect(subject.citations['NULL']).to eq '<p>No citation available for this record</p>'
        end
      end

      context 'when there is no data returned from OCLC' do
        let(:document) { SolrDocument.new(oclc: '12345') }
        it 'returns the NULL citation' do
          expect(subject.citations.keys.length).to eq 1
          expect(subject.citations['NULL']).to eq '<p>No citation available for this record</p>'
        end
      end

      context 'when all formats are requested' do
        let(:document) { SolrDocument.new(oclc: '12345') }
        let(:formats) { ['ALL'] }
        let(:oclc_response) { citations.join }

        it 'all formats from the OCLC response are returned' do
          expect(subject.citations.keys.length).to eq 2
          expect(subject.citations['MLA']).to match %r{^<p class=.*>MLA Citation</p>$}
          expect(subject.citations['APA']).to match %r{^<p class=.*>APA Citation</p>$}
        end
      end

      context 'when a specific format is requested' do
        let(:document) { SolrDocument.new(oclc: '12345') }
        let(:formats) { ['APA'] }
        let(:oclc_response) { citations.join }

        it 'only the requested format is returned from the OCLC response' do
          expect(subject.citations.keys.length).to eq 1
          expect(subject.citations['APA']).to match %r{^<p class=.*>APA Citation</p>$}
        end
      end
    end

    context 'from MODS' do
      let(:document) { SolrDocument.new(modsxml: mods_preferred_citation) }

      it 'returns the preferred citation note' do
        expect(subject.citations.keys).to eq ['PREFERRED CITATION']
        expect(subject.citations['PREFERRED CITATION']).to eq '<p>This is the preferred citation data</p>'
      end
    end
  end

  describe '#api_url' do
    let(:document) { SolrDocument.new(oclc: '12345') }
    it 'returns a URL with the given document field' do
      expect(subject.send(:api_url)).to match %r{/citations/12345\?cformat=all}
    end
  end

  describe '.grouped_citations' do
    it 'groups the citations based on their format' do
      citations = [
        { 'APA' => 'APA Citation1' },
        { 'MLA' => 'MLA Citation1' },
        { 'APA' => 'APA Citation2' }
      ]

      grouped_citations = described_class.grouped_citations(citations)
      expect(grouped_citations.keys.length).to eq 2
      expect(grouped_citations['APA']).to eq ['APA Citation1', 'APA Citation2']
      expect(grouped_citations['MLA']).to eq ['MLA Citation1']
    end

    it 'assures the preferred citation shows up first' do
      citations = [
        { 'APA' => 'APA Citation1' },
        { 'PREFERRED CITATION' => 'Preferred Citation1' },
        { 'APA' => 'APA Citation2' }
      ]

      grouped_citations = described_class.grouped_citations(citations)
      expect(grouped_citations.keys.length).to eq 2
      expect(grouped_citations.keys.first).to eq 'PREFERRED CITATION'
    end
  end
end
