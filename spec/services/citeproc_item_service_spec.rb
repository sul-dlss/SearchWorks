# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CiteprocItemService do
  subject(:item) { described_class.create(document) }

  let(:apa) {
    CiteProc::Processor.new(style: 'apa', format: 'html').tap { it.import item }.render(:bibliography, id:).first
  }

  let(:id) { document.id }

  context 'with an 856u (url)' do
    let(:document) { SolrDocument.find('13553090') }

    it 'makes an item' do
      expect(apa).to eq "Skordis, Andys. (2016). <i>\"......\" : for orchestra : 2010</i>. Donemus. http://www.aspresolver.com/aspresolver.asp?SHM4;3568528"
    end
  end

  context 'with a bound with doc' do
    let(:document) { SolrDocument.find('2279186') }

    it 'makes an item' do
      expect(apa).to eq "Finlow, Robert Steel. (1918). <i>\"Heart damage\" in baled jute</i>. Published for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
    end
  end

  context 'with a map' do
    let(:document) { SolrDocument.find('2472159') }

    it 'makes an item' do
      expect(apa).to eq "Great Britain, Great Britain Ordnance Survey, &amp; Great Britain Army Royal Engineers. (1958). <i>World 1:500,000</i> [Map]. D. Survey, War Office and Air Ministry."
    end
  end

  context 'with a finding aid' do
    let(:document) { SolrDocument.find('4085072') }

    it 'makes an item' do
      expect(apa).to eq "Stanford University News Service, &amp; Stanford University Office of Public Affairs News and Publications Service. (1891). <i>Stanford News Service records</i>."
    end
  end

  context 'with 700 fields, and end range in 008' do
    let(:document) { SolrDocument.find('5488000') }

    it 'makes an item' do
      expect(apa).to eq "Harrison, William Hudson, Subramania Aiyer, P. A., &amp; New Delhi (India) Imperial Agricultural Research Institute. (1920). <i>The gases of swamp rice soils ...</i>. Published for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
    end
  end
end
