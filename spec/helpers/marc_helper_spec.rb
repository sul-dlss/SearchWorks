require "spec_helper"

describe MarcHelper do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marcxml: metadata2) }
  let(:nil_document) { SolrDocument.new(marcxml: no_fields_fixture) }
  let(:matched_vern_doc) { SolrDocument.new(marcxml: matched_vernacular_fixture) }
  let(:unmatched_vern_doc) { SolrDocument.new(marcxml: unmatched_vernacular_fixture) }
  let(:bad_vern_record) { SolrDocument.new(marcxml: bad_vernacular_fixture) }
  let(:nielsen_record) { SolrDocument.new(marcxml: nielsen_fixture) }
  let(:percent_record) { SolrDocument.new(marcxml: percent_fixture) }

  describe "#data_with_label_from_marc" do
    let(:matched_vern_doc_rtl) { SolrDocument.new(marcxml: matched_vernacular_rtl_fixture) }
    let(:unmatched_vern_doc_rtl) { SolrDocument.new(marcxml: unmatched_vernacular_rtl_fixture) }
    let(:standard_linking_doc) { SolrDocument.new(marcxml: linking_fields_fixture) }
    let(:linked_ckey_590_record) { SolrDocument.new(marcxml: linked_ckey_fixture) }
    let(:special_character_record) { SolrDocument.new(marcxml: escape_characters_fixture) }
    let(:relator_vern_record) { SolrDocument.new(marcxml: marc_sections_fixture) }

    describe "get" do
      it "should display a valid definition list row" do
        field = get_data_with_label_from_marc(document.to_marc, "Label:", "520")
        expect(field[:label]).to eq "Label:" and
        expect(field[:fields].length).to eq 1 and
        expect(field[:fields].first[:field]).to match /Selected poems and articles from the works of renowned Sindhi poet; chiefly translated from Sindhi\./
      end
      it "should not display items that have a 1st indicator of 1 for certain MARC fields" do
        expect(get_data_with_label_from_marc(document.to_marc, "Label:", "760")).to be_nil
      end
      it "should not display vernacular items that have a 1st indicator of 1 for certain MARC fields" do
        expect(get_data_with_label_from_marc(document.to_marc, "Label:", "760")).to be_nil
      end
      it "should not display items that have a 1st indicator of 0 for certain MARC fields" do
        expect(get_data_with_label_from_marc(document.to_marc, "Label:", "541")).to be_nil
      end
      it "should not display vernacular items that have a 1st indicator of 1 for certain MARC fields" do
        expect(get_data_with_label_from_marc(document.to_marc, "Label:", "541")).to be_nil
      end
      it "should return nil if the field doesn't exist in the marc record" do
        expect(get_data_with_label_from_marc(document.to_marc, "Label:", "510")).to be_nil
      end
      it "should return the appropriate unmatched vernacular field" do
        expect(get_data_with_label_from_marc(unmatched_vern_doc.to_marc, "Label:", "245")[:unmatched_vernacular]).to eq ["This is Vernacular"]
      end
      it "should remove the '//r' if it is present from the matching field" do
        data = get_data_with_label_from_marc(matched_vern_doc_rtl.to_marc, "Label:", "245")
        expect(data[:fields].length).to eq 1 and
        expect(data[:fields].first[:field]).to match(/This is NOT Right-to-Left Vernacular/) and
        expect(data[:fields].first[:vernacular]).to match(/This is Right-to-Left Vernacular/)
      end
      it "should remove the '//r' if it is present from unmatching fields" do
        data = get_data_with_label_from_marc(unmatched_vern_doc_rtl.to_marc, "Label:", "245")
        expect(data[:unmatched_vernacular]).to eq ["This is Right-to-Left Vernacular"]
      end
      it "should return the approprate matched vernacular field" do
        data = get_data_with_label_from_marc(matched_vern_doc.to_marc, "Label:", "245")
        expect(data[:fields].length).to eq 1 and
        expect(data[:fields].first[:field]).to match(/This is not Vernacular/) and
        expect(data[:fields].first[:vernacular]).to match(/This is Vernacular/)
      end

      it 'should not include relator terms in the vernacular' do
        data = get_data_with_label_from_marc(relator_vern_record.to_marc, 'Label', '700')
        expect(data[:fields].length).to eq 1
        expect(data[:fields].first[:vernacular]).not_to match(/Performer|prf/)
      end

      it "should handle bad vernacular records correctly" do
        bad_600 = get_data_with_label_from_marc(bad_vern_record.to_marc, "Label:", "600")
        bad_245 = get_data_with_label_from_marc(bad_vern_record.to_marc, "Label:", "245")

        expect(bad_600[:fields].first[:field]).not_to match /This is Vernacular/
        expect(bad_600[:fields].first[:field]).to match /This is not Vernacular/

        expect(bad_245[:fields].first[:field]).not_to match /This is Vernacular/
        expect(bad_245[:fields].first[:field]).to match /This is not Vernacular/
      end
      it "should link subfield U for certain fields" do
        linking = get_data_with_label_from_marc(standard_linking_doc.to_marc, "Label:", "520")
        non_linking = get_data_with_label_from_marc(standard_linking_doc.to_marc, "Label:", "519")
        bad_url = get_data_with_label_from_marc(standard_linking_doc.to_marc, "Label:", "530")

        expect(linking[:fields].length).to eq 1
        expect(linking[:fields].first[:field]).to match(/<a href=.*>.*<\/a>/)

        expect(non_linking[:fields].length).to eq 1
        expect(non_linking[:fields].first[:field]).not_to match(/<a href=.*>.*<\/a>/)

        expect(bad_url[:fields].length).to eq 1
        expect(bad_url[:fields].first[:field]).not_to match(/<a href=.*>.*<\/a>/)
      end
      it "should return the approprate subfield when one is requested" do
        data = get_data_with_label_from_marc(document.to_marc, "Label:", "650", { sub_fields: ["d"] })
        expect(data[:fields].first[:field]).to match /Subject2/
        data[:fields].each do |field|
          expect(field[:field]).not_to match /Subject1/
        end
      end
      it "should handle nielsen data correctly" do
        data = get_data_with_label_from_marc(nielsen_record.to_marc, "Label:", "520")
        expect(data[:fields].length).to eq 1
        expect(data[:fields].first[:field]).to match(/Nielsen Field/)
        expect(data[:fields].first[:field]).to match(/source: Nielsen Book Data/)
        expect(data[:fields].to_s).not_to match(/.*Note.*/)
      end
      it "should handle linking to parent ckeys correctly" do
        data = get_data_with_label_from_marc(linked_ckey_590_record.to_marc, "Label:", "590")
        expect(data[:fields].length).to eq 2
        expect(data[:fields].first[:field]).to match(/Copy.*<a href=\"55523\">55523<\/a> \(.*\)/)
        expect(data[:fields].first[:field]).not_to match(/&gt;|&lt;|&quot;/)
      end
      it "should handle special characters correctly" do
        data = get_data_with_label_from_marc(special_character_record.to_marc, "Label:", "690")
        expect(data[:fields].length).to eq 2
        expect(data[:fields].first[:field]).to match(/Artists' Books/)
        expect(data[:fields].last[:field]).to  match(/Stanford > Berkeley/)
      end
    end

    describe "link_to" do
      it "should display a valid and linked definition list row" do
        data = link_to_data_with_label_from_marc(document.to_marc, "Label:", "546", { controller: 'catalog', action: 'index', search_field: 'search_author' })
        expect(data[:label]).to eq "Label:"
        expect(data[:fields].length).to eq 1
        expect(data[:fields].first[:field]).to match(/<a href=.*In\+Urdu.*search_field=search_author.*>In Urdu\.<\/a>/)
      end
      it "should display a valid and linked venacular equivelant" do
        fields = link_to_data_with_label_from_marc(matched_vern_doc.to_marc, "Label:", "245", { controller: 'catalog', action: 'index', search_field: 'search_author' })
        expect(fields[:fields].length).to eq 1
        expect(fields[:fields].first[:field]).to match(/<a href=.*This\+is\+not\+Vernacular.*search_field=search_author.*>This is not Vernacular<\/a>/)
        expect(fields[:fields].first[:vernacular]).to match(/<a href=.*This\+is\+Vernacular.*search_field=search_author.*>This is Vernacular<\/a>/)
      end
      it "should display an unmatched vernacular equivelant" do
        data = link_to_data_with_label_from_marc(unmatched_vern_doc.to_marc, "Label:", "245", { controller: 'catalog', action: 'index', search_field: 'search_author' })
        expect(data[:fields].empty?).to be_truthy
        expect(data[:unmatched_vernacular].length).to eq 1
        expect(data[:unmatched_vernacular].first).to match(/^<a href=.*This\+is\+Vernacular.*search_field=search_author.*>This is Vernacular<\/a>$/)
      end
      it "should handle special characters properly" do
        data = link_to_data_with_label_from_marc(special_character_record.to_marc, "Label:", "690", { controller: 'catalog', action: 'index' })
        expect(data[:fields].length).to eq 2
        expect(data[:fields].first[:field]).to match(/Artists%27\+Books/)
        expect(data[:fields].last[:field]).to  match(/Stanford\+%3E\+Berkeley/)
        expect(data[:fields].last[:field]).to  match(/Stanford &gt; Berkeley/)
      end
      it "should not include fields that start with a % sign" do
        data = link_to_data_with_label_from_marc(percent_record.to_marc, "Label:", "245", { controller: 'catalog', action: 'index', search_field: 'search' })
        expect(data[:fields].length).to eq 1
        expect(data[:fields].first[:field]).not_to match(/%Bad/)
      end
      it "should handle bad vernacular records correctly" do
        bad_600 = link_to_data_with_label_from_marc(bad_vern_record.to_marc, "Label:", "600", { controller: 'catalog', action: 'index', search_field: 'search' })
        bad_245 = link_to_data_with_label_from_marc(bad_vern_record.to_marc, "Label:", "245", { controller: 'catalog', action: 'index', search_field: 'search' })

        expect(bad_600[:fields].length).to eq 1
        expect(bad_600[:fields].first[:field]).not_to match(/This is Vernacular/)
        expect(bad_600[:fields].first[:field]).to match(/This is not Vernacular/)
        expect(bad_600[:fields].first[:vernacular]).to be_nil

        expect(bad_245[:fields].length).to eq 1
        expect(bad_245[:fields].first[:field]).not_to match(/This is Vernacular/)
        expect(bad_245[:fields].first[:field]).to match(/This is not Vernacular/)
        expect(bad_245[:fields].first[:vernacular]).to be_nil
      end
      it "should return nil if the field doesn't exist in the marc record" do
        expect(link_to_data_with_label_from_marc(document.to_marc, "Label:", "510", { controller: 'catalog', action: 'index', search_field: 'search_author' })).to be_nil
      end
    end
  end

  describe "contributors, related, and included works" do
    let(:contributor) { SolrDocument.new(marcxml: contributor_fixture) }
    let(:contributed_works) { SolrDocument.new(marcxml: contributed_works_fixture) }
    let(:contributed_works_without_title) { SolrDocument.new(marcxml: contributed_works_without_title_fixture) }
    let(:multi_role_contributor) { SolrDocument.new(marcxml: multi_role_contributor_fixture) }
    let(:related_works) { SolrDocument.new(marcxml: related_works_fixture) }

    it "should return multiple dd elements when there are multiple values" do
      expect(link_to_contributor_from_marc(contributor.to_marc)).to have_css('dd', count: 3)
    end
    it "should display a fields with translated relator codes and raw RDA correctly" do
      data = link_to_contributor_from_marc(contributor.to_marc)
      expect(data).to match(/>Contributor1<\/a> Performer</)
      expect(data).to match(/>Contributor2<\/a> Performer</)
      # Contributor 3 has an RDA $e
      expect(data).to match(/>Contributor3<\/a> Actor</)
      expect(data).not_to match(/>Contributor3<\/a> Performer</)
      expect(data).not_to match(/act/)
    end
    it 'should handle included works correctly' do
      included_works = link_to_included_works_from_marc(contributed_works.to_marc)
      expect(included_works).to match(/>Included Work</)
      # no $t punctuation
      expect(included_works).to match(/a href=.*q=%22710\+with\+t\+ind2\+Title%21\+sub\+n\+after\+t%22.*search_field=author_title\">710 with t ind2 Title! sub n after t<\/a></)
      # punctuation after a $t
      expect(included_works).to match(/a href=.*q=%22711\+with\+t\+ind2\+Title%21\+subu\.%22.*search_field=author_title\">711 with t ind2 middle Title! subu\.<\/a> sub n after \.</)
    end
    it 'should handle dropping 711$j from the link/search without a title' do
      included_works = link_to_contributor_from_marc(contributed_works_without_title.to_marc)
      expect(included_works).to have_css('dd a', text: '711 with t ind2 subu. sub n after .')
      expect(included_works).to have_css('dd a @href', text: /q=%22711\+with\+t\+ind2\+subu\.\+sub\+n\+after\+\.\+%22/)
      expect(included_works).to have_css('dd a @href', text: /search_field=search_author/)
      expect(included_works).to have_css('dd', text: /last\./)
    end
    it "should handle repeating subfield e" do
       expect(link_to_contributor_from_marc(multi_role_contributor.to_marc)).to match(/\/a> actor\. director\.<\/dd>/)
    end
    it "should not display anything when no contributors are available" do
      expect(link_to_contributor_from_marc(nil_document.to_marc)).to be_nil
    end

    it 'should not display blacklisted fields' do
      link = contributors_and_works_from_marc(contributor.to_marc)
      link.each do |_, value|
        expect(value).not_to match(/880-00/)
      end
    end
  end

  describe "#get_toc" do
    let(:bad_toc) { SolrDocument.new(marcxml: bad_toc_fixture) }
    let(:nielsen_tagged_record) { SolrDocument.new(marcxml: tagged_nielsen_fixture) }

    it "should return the valid table of contents" do
      data = get_toc(document.to_marc)
      expect(data[:label]).to eq("Contents")
      expect(data[:fields].length).to eq(1) and
      expect(data[:fields].first.length).to eq(2)
      expect(data[:fields].first.include?("1.First Chapter")).to be_truthy and
      expect(data[:fields].first.include?("2.Second Chapter")).to be_truthy
      expect(data[:vernacular]).to be_nil
      expect(data[:unmatched_vernacular]).to be_nil
    end
    it "should return the vernacular table of contents if available" do
      data = get_toc(matched_vern_doc.to_marc)
      expect(data[:fields].length).to eq(1) and
      expect(data[:fields].first.length).to eq(2)
      expect(data[:fields].first.include?("1.This is not Vernacular")).to be_truthy and
      expect(data[:fields].first.include?("2.This is also not Vernacular")).to be_truthy

      expect(data[:vernacular].length).to eq(1) and
      expect(data[:vernacular].first.length).to eq(2)
      expect(data[:vernacular].first.include?("1.This is Vernacular")).to be_truthy and
      expect(data[:vernacular].first.include?("2.This is also Vernacular")).to be_truthy
    end
    it "should return an unmatched vernacular TOC if one is available" do
      data = get_toc(unmatched_vern_doc.to_marc)
      expect(data[:fields]).to be_nil and
      expect(data[:vernacular]).to be_nil

      expect(data[:unmatched_vernacular].length).to eq(1) and
      expect(data[:unmatched_vernacular].first.length).to eq(2)
      expect(data[:unmatched_vernacular].first.include?("1.This is Vernacular")).to be_truthy and
      expect(data[:unmatched_vernacular].first.include?("2.This is also Vernacular")).to be_truthy
    end
    it "should handle handle badly formed vernacular TOCs" do
      data = get_toc(bad_toc.to_marc)
      expect(data[:fields].length).to eq(1) and
      expect(data[:fields].first.length).to eq(2)

      expect(data[:vernacular]).to be_nil

      expect(data[:unmatched_vernacular].length).to eq(1) and
      expect(data[:unmatched_vernacular].first.length).to eq(2)
      expect(data[:unmatched_vernacular].first.include?("1.Vernacular1")).to be_truthy and
      expect(data[:unmatched_vernacular].first.include?("2.Vernacular2")).to be_truthy
    end
    it "should deal with ending '--' properly" do
      data = get_toc(document.to_marc)
      expect(data[:fields].length).to eq(1) and
      expect(data[:fields].first.length).not_to eq(3)
    end
    it "should handle Nielsen properly" do
      data = get_toc(nielsen_record.to_marc)
      expect(data[:fields].length).to eq(1) and
      expect(data[:fields].first.length).to eq(2)
      expect(data[:fields].first.first.include?("NielsenNote1")).to be_truthy and
      expect(data[:fields].first.first.include?("NielsenNote2")).to be_truthy
      expect(data[:fields].first.last.include?("source: Nielsen Book Data")).to be_truthy
      expect(data[:fields].to_s).not_to match(/.*ContentNote.*/)
    end
    it "should handle Nielsen linked TOCs correctly" do
      data = get_toc(nielsen_tagged_record.to_marc)
      expect(data[:fields].length).to eq(1)
      expect(data[:fields].flatten.to_s.include?("Nielsen")).to be_falsey
      expect(data[:fields].flatten.to_s.include?("Linked")).to be_truthy
    end
    it "should handle bad vernacular TOC correctly" do
      data = get_toc(bad_vern_record.to_marc)
      expect(data[:vernacular]).to be_nil and
      expect(data[:unmatched_vernacular]).to be_nil
    end
    it "should return nothing if no TOC is available" do
      expect(get_toc(nil_document.to_marc)).to be_nil
    end
  end

  describe "subjects" do
    let(:multi_a_subject) { SolrDocument.new(marcxml: multi_a_subject_fixture) }
    let(:multi_vxyz_subject) { SolrDocument.new(marcxml: multi_vxyz_subject_fixture) }
    let(:collection_690) { SolrDocument.new(marcxml: collection_690_fixture) }
    let(:ordered_subjects) { SolrDocument.new(marcxml: ordered_subjects_fixture) }
    let(:vernacular_subjects) { SolrDocument.new(marcxml: vernacular_subjects_fixture) }
    let(:genre_subjects) { SolrDocument.new(marcxml: marc_655_subject_fixture) }
    let(:local_subjects) { SolrDocument.new(marcxml: collection_690_fixture) }

    describe "#get_genre_subjects" do
      it "should return MARC 655 formatted as hierarchical subjects" do
        subjects = get_genre_subjects(genre_subjects)
        expect(subjects).to be_present
        expect(subjects).to have_css('dt', text: 'Genre')
        expect(subjects).to have_css('dd a', text: 'Subject A1')
        expect(subjects).to have_css('dd a', text: 'Subject V1')
        expect(subjects).to have_css('dd a', text: 'Subject X1')
        expect(subjects).to match /<\/a> &gt. <a/
      end
      it "should be nil for non 655 subjects" do
        expect(get_genre_subjects(multi_a_subject)).to be_nil
      end
    end

    describe '#get_local_subjects' do
      it 'returns the MARC 690 formatted as hierarchical subjects' do
        subjects = get_local_subjects(local_subjects)
        expect(subjects).to be_present
        expect(subjects).to have_css('dt', text: 'Local subject')
        expect(subjects).to have_css('dd a', text: 'Subject Collection 1')
      end
    end

    describe "#get_subjects" do
      it "should return a valid list of linked subjects" do
        subjects = get_subjects(document)
        expect(subjects).to match(/title=\"Search: Subject1 Subject2\"/) and
        expect(subjects).to match(/>Subject1 Subject2</)
      end
      it "should not include subjects where subfield 'a' begins with a % sign" do
        expect(get_subjects(percent_record)).not_to match(/.*%Subject1.*/)
      end
      it "should handle items with several A subfields as separate subjects (separate dd elements)" do
        expect(get_subjects(multi_a_subject)).to match(/.*<dd>.*Subject A1.*<\/dd>.*<dd>.*Subject A2.*<\/dd>.*<dd>.*Subject A3.*<\/dd>.*<dd>.*Subject A4.*<\/dd>.*/)
      end
      it "should concat all subfields except for v x y z" do
        expect(get_subjects(multi_vxyz_subject)).to match(/.*<dd><a.*>Subject A Subject B Subject C<\/a> &gt; <a.*>Subject V<\/a> &gt; <a.*>Subject X<\/a> &gt; <a.*>Subject Y<\/a> &gt; <a.*>Subject Z<\/a>.*/)
      end
      it "should wrap all of the subject terms in quotes" do
        data = get_subjects(multi_vxyz_subject)
        expect(data).to match(/.*href=\".*%22Subject\+A\+Subject\+B\+Subject\+C%22.*\".*/)
        expect(data).to match(/.*href=\".*%22Subject\+A\+Subject\+B\+Subject\+C\+Subject\+V\+Subject\+X%22.*\".*/)
        # should not have any quoted phrases concatinated with a space in the URL
        expect(data).not_to match(/\"\+\"/)
      end
      it "should not display a 690 if the subfield a includes 'collection'" do
        expect(get_subjects(collection_690)).not_to match(/.*Subject Collection 1.*/)
      end
      it "should order the subjects as they are in the original MARC record" do
        expect(get_subjects(ordered_subjects)).to match(/.*<dd>.*Subject 651.*<\/dd>.*<dd>.*Subject 650.*<\/dd>.*/) and
        expect(get_subjects(ordered_subjects)).not_to match(/.*<dd>.*Subject 650.*<\/dd>.*<dd>.*Subject 651.*<\/dd>.*/)
      end
      it "should display vernacular subjects" do
        expect(get_subjects(vernacular_subjects)).to match(/Linked vernacular subject/)
        expect(get_subjects(vernacular_subjects)).to match(/Unlinked vernacular subject/)
      end
      it "should not return anything for 655 genre subjects" do
        expect(get_subjects(genre_subjects)).to be_nil
      end
      it "should return nothing if no subjects are available" do
        expect(get_subjects(nil_document)).to be_nil
      end
    end
  end

  describe "#get_740_works_from_marc" do
    let(:related_works) { SolrDocument.new(marcxml: related_works_fixture) }

    it "should use Included Work for records with a 2nd indicator of 2" do
      expect(get_740_works_from_marc(related_works.to_marc, "Label")[:label]).to eq "Included Work"
    end
    it "should return nil when there is no field" do
      expect(get_740_works_from_marc(document.to_marc, "Label")).to be_nil
    end
  end

  describe "#marc_264" do
    let(:single) { SolrDocument.new(marcxml: single_marc_264_fixture).to_marc }
    let(:multiple) { SolrDocument.new(marcxml: multiple_marc_264_fixture).to_marc }
    let(:vernacular) { SolrDocument.new(marcxml: vernacular_marc_264_fixture).to_marc }
    let(:unmatched_vernacular) { SolrDocument.new(marcxml: unmatched_vernacular_marc_264_fixture).to_marc }
    let(:complex) { SolrDocument.new(marcxml: complex_marc_264_fixture).to_marc }

    it "should handle a simple single 264" do
      data = marc_264(single)
      expect(data).to have_key("Production")
      expect(data["Production"].length).to eq 1
      expect(data["Production"].first).to eq "Subfield3 SubfieldA SubfieldB"
    end
    it "should handle multiple fields under the same label" do
      data = marc_264(multiple)
      expect(data).to have_key("Production")
      expect(data["Production"].length).to eq 2
      expect(data["Production"].first).to eq "SubfieldA SubfieldB"
      expect(data["Production"].last).to eq "AnotherSubfieldA AnotherSubfieldB"
    end
    it "should handle vernacular properly" do
      data = marc_264(vernacular)
      expect(data).to have_key("Production")
      expect(data["Production"].length).to eq 2
      expect(data["Production"].first).to eq "SubfieldA SubfieldB"
      expect(data["Production"].last).to eq "Vernacular SubfieldA Vernacular SubfieldB"
    end
    it "should handle unmatched vernacular properly" do
      data = marc_264(unmatched_vernacular)
      expect(data).to have_key("Production")
      expect(data["Production"].length).to eq 1
      expect(data["Production"].first).to eq "Unmatched vernacular SubfieldA Unmatched vernacular SubfieldB"
    end
    it "should handle complex grouping under labels" do
      data = marc_264(complex)
      expect(data).to have_key("Production")
      expect(data).to have_key("Current publication")
      expect(data["Production"].length).to eq 2
      expect(data["Production"].first).to eq "Production SubfieldA Production SubfieldB"
      expect(data["Production"].last).to eq "Another Production SubfieldA Another Production SubfieldB"
      expect(data["Current publication"].length).to eq 1
      expect(data["Current publication"].first).to eq "SubfieldA SubfieldB"
    end
  end

  describe '#results_imprint_string' do
    let(:document) { SolrDocument.new(imprint_display: ['a', 'b']) }

    it 'returns the first imprint statement from the index' do
      expect(results_imprint_string(document)).to eq 'a'
    end
  end

  describe '#get_uniform_title' do
    it 'assembles the uniform title' do
      doc = SolrDocument.new(uniform_title_display_struct: [{ fields: [{ field: { pre_text: 'xyz', link_text: 'Instrumental music Selections', post_text: '[print/digital]' }, vernacular: { vern: '' } }] }])
      title = get_uniform_title(doc)
      expect(title[:fields].length).to eq 1
      expect(title[:fields].first[:field]).to match(%r{xyz <a href=.*>Instrumental music Selections</a> \[print/digital\]})
    end
  end
end
