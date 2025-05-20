# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CiteprocItemService do
  subject(:item) { described_class.create(document) }

  let(:processor) { CiteProc::Processor.new(style: 'apa', format: 'html') }
  let(:apa) do
    processor.tap { it.import item }.render(:bibliography, id:).first
  end

  let(:id) { document.id }

  context 'with a bound with doc' do
    let(:document) { SolrDocument.find('2279186') }

    it 'makes an item' do
      expect(apa).to eq "Finlow, R. S. (1918). <i>\"Heart damage\" in baled jute</i>. " \
                        "Published for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
    end

    context 'with chicago' do
      let(:processor) { CiteProc::Processor.new(style: 'chicago-author-date', format: 'html') }
      let(:chicago) do
        processor.tap { it.import item }.render(:bibliography, id:).first
      end

      it 'has place of publication from 260a' do
        expect(chicago).to eq "Finlow, Robert Steel. 1918. <i>\"Heart Damage\" in Baled Jute</i>. Calcutta, London: " \
                              "Published for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
      end
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
                        "(1931). <i>Stanford News Service records</i>."
    end
  end

  context 'with 700 fields, and end range in 008' do
    let(:document) { SolrDocument.find('5488000') }

    it 'makes an item' do
      expect(apa).to eq "Harrison, W. H., Subramania Aiyer, P. A., &amp; New Delhi (India) Imperial Agricultural Research Institute. (1913). " \
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

  context 'with a place of publication (marc 264a)' do
    let(:document) { SolrDocument.find('14059621') }
    let(:processor) { CiteProc::Processor.new(style: 'chicago-author-date', format: 'html') }
    let(:chicago) do
      processor.tap { it.import item }.render(:bibliography, id:).first
    end

    it 'makes an item' do
      expect(chicago).to eq "Strom, Dao. 2020. <i>Instrument</i>. First edition; First printing. Portland, Oregon : Fonograf Editions."
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

  context 'with authors on an included work' do
    let(:document) { SolrDocument.find('219330') }

    it 'shows only the primary values' do
      expect(apa).to eq "Irving, W. (1847). <i>The life of Oliver Goldsmith : with selections from his writings</i>. Harper &amp; Brothers."
    end
  end

  context 'without a title' do
    let(:document) { SolrDocument.find('14434124') }

    before do
      new_data = document.load_marc
      new_data['245'].subfields.shift
      allow(document).to receive(:load_marc).and_return(new_data)
    end

    it "doesn't create an item" do
      expect(item).to be_nil
    end
  end

  context 'with a thesis' do
    let(:document) { SolrDocument.find('in00000382380') }

    it "has dissertation in parenthesis" do
      expect(apa).to eq 'Mutlu, O. C., Wall, D. P., Nishimura, D. G., Pauly, J., Stanford University School of Engineering, ' \
                        '&amp; Stanford University Department of Electrical Engineering. (2025). ' \
                        '<i>Adaptation and regularization of deep neural networks under temporal smoothness assumption</i> ' \
                        '[Dissertation]. [Stanford University]. https://purl.stanford.edu/bp098kt2063'
    end
  end
end
