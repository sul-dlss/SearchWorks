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
  end

  describe "contributors, related, and included works" do
    let(:contributor) { SolrDocument.new(marcxml: contributor_fixture) }
    let(:contributed_works) { SolrDocument.new(marcxml: contributed_works_fixture) }
    let(:contributed_works_without_title) { SolrDocument.new(marcxml: contributed_works_without_title_fixture) }
    let(:multi_role_contributor) { SolrDocument.new(marcxml: multi_role_contributor_fixture) }
    let(:related_works) { SolrDocument.new(marcxml: related_works_fixture) }

    it 'should handle included works correctly' do
      included_works = link_to_included_works_from_marc(contributed_works.to_marc)
      expect(included_works).to match(/>Included Work</)
      # no $t punctuation
      expect(included_works).to match(/a href=.*q=%22710\+with\+t\+ind2\+Title%21\+sub\+n\+after\+t%22.*search_field=author_title\">710 with t ind2 Title! sub n after t<\/a></)
      # punctuation after a $t
      expect(included_works).to match(/a href=.*q=%22711\+with\+t\+ind2\+Title%21\+subu\.%22.*search_field=author_title\">711 with t ind2 middle Title! subu\.<\/a> sub n after \.</)
    end

    it 'should not display certain fields' do
      link = contributors_and_works_from_marc(contributor.to_marc)
      link.each do |_, value|
        expect(value).not_to match(/880-00/)
      end
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
