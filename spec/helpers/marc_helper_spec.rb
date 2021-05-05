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
