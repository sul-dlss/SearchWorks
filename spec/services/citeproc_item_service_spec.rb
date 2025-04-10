# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CiteprocItemService do
  subject(:item) { described_class.create(document) }

  let(:processor) { CiteProc::Processor.new(style: 'apa', format: 'html') }
  let(:apa) {
    # node = processor.engine.style.macros['date-bib']
    # item2 = CiteProc::Item.new(id: 1, type: 'book')
    # ci = CiteProc::CitationItem.new(id: item2.id)
    # ci.data = item2
    # processor.engine.renderer.locale.translate('no date', form: 'short')
    # processor.engine.renderer.render(ci, node)

    processor.tap { it.import item }.render(:bibliography, id:).first
  }

  let(:id) { document.id }

  context 'with a bound with doc' do
    let(:document) { SolrDocument.find('2279186') }

    it 'makes an item' do
      expect(apa).to eq "Finlow, R. S. (1918). <i>\"Heart damage\" in baled jute</i>. " \
                        "Published for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
    end
  end

  context 'with a map' do
    let(:document) { SolrDocument.find('2472159') }

    it 'makes an item' do
      expect(apa).to eq "Great Britain Directorate of Military Survey, Great Britain Ordnance Survey, &amp; Great Britain Army Royal Engineers. (1958). " \
                        "<i>World 1:500,000</i> [Map]. D. Survey, War Office and Air Ministry."
    end
  end

  context 'with a finding aid' do
    let(:document) { SolrDocument.find('4085072') }

    it 'makes an item' do
      expect(apa).to eq "Stanford News Service. " \
                        "(2013). <i>Stanford News Service records</i>."
    end
  end

  context 'with 700 fields, and end range in 008' do
    let(:document) { SolrDocument.find('5488000') }

    it 'makes an item' do
      expect(apa).to eq "Harrison, W. H., Subramania Aiyer, P. A., &amp; New Delhi (India) Imperial Agricultural Research Institute. (1920). " \
                        "<i>The gases of swamp rice soils ...</i> Pub. for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
    end
  end

  context 'with an 856u (url)' do
    let(:document) { SolrDocument.find('13553090') }

    it 'makes an item' do
      expect(apa).to eq "Skordis, A. (2016). <i>\"......\" : for orchestra : 2010</i>. Donemus. http://www.aspresolver.com/aspresolver.asp?SHM4;3568528"
    end
  end

  context 'with an online resource' do
    let(:document) { SolrDocument.find('14136548') }

    it 'makes an item' do
      expect(apa).to eq "Vaughan, D. (2025). <i>Umiejętności analityczne w pracy z danymi i sztuczną inteligencją </i>. Helion. https://go.oreilly.com/stanford-university/library/view/-/9788328373464/?ar"
    end
  end

  context 'with an corporate name with an authority record control number (710 subfield 0)' do
    let(:document) { SolrDocument.find('L210044') }

    it 'makes an item' do
      expect(apa).to eq "New Jersey State Department of Health. (1877). <i>Annual report of the Department of Health of the State of New Jersey</i>. State Dept. of Health."
    end
  end

  context 'with an edition (marc 250)' do
    let(:document) { SolrDocument.find('14059621') }

    it 'makes an item' do
      expect(apa).to eq "Strom, D. (2020). <i>Instrument</i> (First edition; First printing). Fonograf Editions."
    end
  end

  context 'with an translator and a DOI' do
    let(:document) { SolrDocument.find('in00000149820') }

    it 'makes an item' do
      expect(apa).to eq "Aristotle. <i>Aristotle : topics</i> (A. Schiaparelli, Trans.). Oxford University Press. https://doi.org/10.1093/actrade/9780199609758.book.1"
    end
  end

  context 'with an subordinate unit and a URL' do
    let(:document) { SolrDocument.find('12324130') }

    it 'makes an item' do
      skip '(n.d.) should display. See https://github.com/inukshuk/citeproc-ruby/issues/87'
      today = Time.zone.today.to_fs(:long)
      expect(apa).to eq "United States Arctic Research Commission. (n.d.). <i>Arctic science portal</i>. United States Arctic Research Commission. Retrieved #{today}, from https://purl.fdlp.gov/GPO/gpo88626"
    end
  end

  context 'with editors' do
    let(:document) { SolrDocument.find('10689066') }

    it 'shows editors' do
      expect(apa).to eq "Borghesi, A. (2014). <i>I Sardi e la Resistenza : il contributo dei partigiani di Ardauli alla lotta di Liberazione, 1943-1945</i> " \
                        "(G. Deiana &amp; V. Urru, Eds.). Iskra."
    end
  end

  context 'with duplicate authors' do
    let(:document) { SolrDocument.find('14434124') }

    it 'shows unique values' do
      expect(apa).to eq "Nomberg, H. D. (2021). <i>Between parents</i> (O. Elkus &amp; D. Kennedy, Trans.). Farlag Press."
    end
  end
end
