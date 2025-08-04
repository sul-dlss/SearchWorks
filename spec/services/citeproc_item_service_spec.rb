# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CiteprocItemService do
  subject(:item) { described_class.create(document) }

  let(:processor) { CiteProc::Processor.new(style: 'apa', format: 'html') }
  let(:citation) do
    processor.tap { it.import item }.render(:bibliography, id:).first
  end

  let(:id) { document.id }

  context 'when MLA and item has angle brackets in the 260$b' do
    # Sanitizing is needed until https://github.com/inukshuk/citeproc-ruby/issues/89 is resolved.
    let(:document) { SolrDocument.new(id: '2469268', marc_json_struct:) }
    let(:marc_json_struct) do
      ["{\"leader\":\"01152nam a2200337u  4500\",\"fields\":[{\"001\":\"a1311451\"},{\"003\":\"SIRSI\"},{\"005\":\"19910716000000.0\"},{\"008\":\"880923s1969    yu a          000 0 slv  \"},{\"010\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"   70975348\"}]}},{\"035\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"(Sirsi) AGC4746\"}]}},{\"035\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"(CStRLIN)CSUG88-B65780\"}]}},{\"035\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"(OCoLC-M)16745266\"}]}},{\"035\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"(OCoLC-I)273485131\"}]}},{\"040\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"c\":\"CSt\"},{\"d\":\"OrLoB\"}]}},{\"041\":{\"ind1\":\"0\",\"ind2\":\" \",\"subfields\":[{\"a\":\"slvger\"}]}},{\"043\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"e-yu---\"}]}},{\"050\":{\"ind1\":\"0\",\"ind2\":\" \",\"subfields\":[{\"a\":\"GN786.Y8\"},{\"b\":\"K6\"}]}},{\"100\":{\"ind1\":\"1\",\"ind2\":\" \",\"subfields\":[{\"a\":\"Korošec, Paola.\"}]}},{\"245\":{\"ind1\":\"1\",\"ind2\":\"0\",\"subfields\":[{\"a\":\"Najdbe s koliščarskih naselbin pri Igu na Ljubljanskem barju.\"},{\"b\":\"Fundgut der Pfahlbausiedlungen bei Ig am Laibacher Moor.\"},{\"c\":\"<Prevod v nemščino: Adela Žgur>.\"}]}},{\"260\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"Ljubljana,\"},{\"b\":\"<Narodni muzej>,\"},{\"c\":\"1969.\"}]}},{\"300\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"164, [5] p.,\"},{\"b\":\"146 p. of illus.\"},{\"c\":\"33 cm.\"}]}},{\"490\":{\"ind1\":\"0\",\"ind2\":\" \",\"subfields\":[{\"a\":\"Arheološki katalogi Slovenije,\"},{\"v\":\"zv. 3\"}]}},{\"500\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"Slovenian and German.\"}]}},{\"500\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"Zbirka Kultura.\"}]}},{\"500\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"At head of title: Paola Korošec -- Josip Korošec.\"}]}},{\"596\":{\"ind1\":\" \",\"ind2\":\" \",\"subfields\":[{\"a\":\"31\"}]}},{\"650\":{\"ind1\":\" \",\"ind2\":\"0\",\"subfields\":[{\"a\":\"Lake-dwellers and lake-dwellings\"},{\"z\":\"Slovenia\"},{\"z\":\"Ig.\"}]}},{\"651\":{\"ind1\":\" \",\"ind2\":\"0\",\"subfields\":[{\"a\":\"Slovenia\"},{\"x\":\"Antiquities.\"}]}},{\"700\":{\"ind1\":\"1\",\"ind2\":\" \",\"subfields\":[{\"a\":\"Korošec, Josip.\"}]}},{\"999\":{\"ind1\":\"f\",\"ind2\":\"f\",\"subfields\":[{\"i\":\"ed3529bc-b26f-5ac6-b588-973e096a397a\"},{\"s\":\"ce800a10-eaee-579a-ad84-63d0fcce785e\"}]}}]}"] # rubocop:disable Layout/LineLength
    end

    let(:processor) { CiteProc::Processor.new(style: 'modern-language-association', format: 'html') }

    it 'strips the angle brackets' do
      expect(citation).to eq "Korošec, Paola, and Josip Korošec. " \
                             "<i>Najdbe s Koliščarskih Naselbin Pri Igu Na Ljubljanskem Barju Fundgut Der Pfahlbausiedlungen Bei Ig Am Laibacher Moor</i>. " \
                             "Narodni muzej, 1969."
    end
  end

  context 'with a bound with doc' do
    let(:document) { SolrDocument.find('2279186') }

    it 'makes an item' do
      expect(citation).to eq "Finlow, R. S. (1918). <i>\"Heart damage\" in baled jute</i>. " \
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
      expect(citation).to eq "Great Britain Directorate of Military Survey, Great Britain Ordnance Survey, &amp; Great Britain Army Royal Engineers. (1958). " \
                             "<i>World 1:500,000</i> [Map]. D. Survey, War Office and Air Ministry."
    end
  end

  context 'with a finding aid' do
    let(:document) { SolrDocument.find('4085072') }

    it 'makes an item' do
      expect(citation).to eq "Stanford News Service. " \
                             "(1931). <i>Stanford News Service records</i>."
    end
  end

  context 'with 700 fields, and end range in 008' do
    let(:document) { SolrDocument.find('5488000') }

    it 'makes an item' do
      expect(citation).to eq "Harrison, W. H., Subramania Aiyer, P. A., &amp; New Delhi (India) Imperial Agricultural Research Institute. (1913). " \
                             "<i>The gases of swamp rice soils ...</i> Pub. for the Imperial Dept. of Agriculture in India by Thacker, Spink &amp; Co.; W. Thacker &amp; Co."
    end
  end

  context 'with an 856u (url)' do
    let(:document) { SolrDocument.find('13553090') }

    it 'makes an item' do
      expect(citation).to eq "Skordis, A. (2016). <i>\"......\" : for orchestra : 2010</i>. Donemus. http://www.aspresolver.com/aspresolver.asp?SHM4;3568528"
    end
  end

  context 'with an online resource' do
    let(:document) { SolrDocument.find('14136548') }

    it 'makes an item' do
      expect(citation).to eq "Vaughan, D. (2025). <i>Umiejętności analityczne w pracy z danymi i sztuczną inteligencją </i>. Helion. https://go.oreilly.com/stanford-university/library/view/-/9788328373464/?ar"
    end
  end

  context 'with an corporate name with an authority record control number (710 subfield 0)' do
    let(:document) { SolrDocument.find('L210044') }

    it 'makes an item' do
      expect(citation).to eq "New Jersey State Department of Health. (1877). <i>Annual report of the Department of Health of the State of New Jersey</i>. State Department of Health."
    end
  end

  context 'with an edition (marc 250)' do
    let(:document) { SolrDocument.find('14059621') }

    it 'makes an item' do
      expect(citation).to eq "Strom, D. (2020). <i>Instrument</i> (First edition; First printing). Fonograf Editions."
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
      expect(citation).to eq "Aristotle. <i>Aristotle : topics</i> (A. Schiaparelli, Trans.). Oxford University Press. https://doi.org/10.1093/actrade/9780199609758.book.1"
    end
  end

  context 'with an subordinate unit and a URL' do
    let(:document) { SolrDocument.find('12324130') }

    it 'makes an item' do
      skip '(n.d.) should display. See https://github.com/inukshuk/citeproc-ruby/issues/87'
      today = Time.zone.today.to_fs(:long)
      expect(citation).to eq "United States Arctic Research Commission. (n.d.). <i>Arctic science portal</i>. United States Arctic Research Commission. Retrieved #{today}, from https://purl.fdlp.gov/GPO/gpo88626"
    end
  end

  context 'with editors' do
    let(:document) { SolrDocument.find('10689066') }

    it 'shows editors' do
      expect(citation).to eq "Borghesi, A. (2014). <i>I Sardi e la Resistenza : il contributo dei partigiani di Ardauli alla lotta di Liberazione, 1943-1945</i> " \
                             "(G. Deiana &amp; V. Urru, Eds.). Iskra."
    end
  end

  context 'with duplicate authors' do
    let(:document) { SolrDocument.find('14434124') }

    it 'shows unique values' do
      expect(citation).to eq "Nomberg, H. D. (2021). <i>Between parents</i> (O. Elkus &amp; D. Kennedy, Trans.). Farlag Press."
    end
  end

  context 'with authors on an included work' do
    let(:document) { SolrDocument.find('219330') }

    it 'shows only the primary values' do
      expect(citation).to eq "Irving, W. (1847). <i>The life of Oliver Goldsmith : with selections from his writings</i>. Harper &amp; Brothers."
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
      expect(citation).to eq 'Mutlu, O. C., Wall, D. P., Nishimura, D. G., Pauly, J., Stanford University School of Engineering, ' \
                             '&amp; Stanford University Department of Electrical Engineering. (2025). ' \
                             '<i>Adaptation and regularization of deep neural networks under temporal smoothness assumption</i> ' \
                             '[Dissertation]. [Stanford University]. https://purl.stanford.edu/bp098kt2063'
    end

    context 'when requesting Chicago' do
      let(:processor) { CiteProc::Processor.new(style: 'chicago-author-date', format: 'html') }
      let(:chicago) do
        processor.tap { it.import item }.render(:bibliography, id:).first
      end

      it "has title in quotes" do
        expect(chicago).to eq 'Mutlu, Onur Cezmi, Dennis Paul Wall, Dwight George Nishimura, John Pauly, Stanford University School of Engineering, ' \
                              'and Stanford University Department of Electrical Engineering. 2025. ' \
                              '“Adaptation and Regularization of Deep Neural Networks under Temporal Smoothness Assumption.” ' \
                              'Dissertation. [Stanford, California] : [Stanford University]. https://purl.stanford.edu/bp098kt2063.'
      end
    end
  end
end
