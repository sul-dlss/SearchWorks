require "spec_helper"

describe MarcHelper do
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
