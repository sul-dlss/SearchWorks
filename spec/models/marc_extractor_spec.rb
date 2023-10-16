require 'rails_helper'

RSpec.describe MarcExtractor do
  include MarcMetadataFixtures

  let(:fixture) { metadata1 }
  let(:marc) { SolrDocument.new(marc_json_struct: fixture).to_marc }

  context 'with a single marc field' do
    subject(:extracted_data) { described_class.new(marc, '100').extract.to_a }

    it 'extracts the values of single marc fields' do
      expect(extracted_data.length).to eq 1
    end

    it 'yields the original marc field data' do
      marc_field, _subfields = extracted_data.first
      expect(marc_field.canonical_tag).to eq '100'
    end

    it 'yields the (non-excluded) subfields' do
      _marc_field, subfields = extracted_data.first
      expect(subfields.map(&:code)).to contain_exactly('a', 'e')
      expect(subfields.map(&:code)).not_to include '='
    end
  end

  context 'with a marc field with subfield codes' do
    subject(:extracted_data) { described_class.new(marc, '541ca').extract.to_a }

    it 'filters the subfield values based on provided subfield tags' do
      marc_field, subfields = extracted_data.first

      expect(marc_field.subfields.map(&:code)).to include 'c', 'a', 'd', 'e'

      expect(subfields.map(&:code)).to include 'c', 'a'
      expect(subfields.map(&:code)).not_to include 'd', 'e'
    end
  end

  context 'with a marc field with subfield codes that do not exist' do
    subject(:extracted_data) { described_class.new(marc, '541xyz').extract.to_a }

    it 'is not yielded' do
      expect(marc['541']).to be_present
      expect(extracted_data.length).to eq 0
    end
  end

  context 'with a field that has indicators that hide the field from display' do
    let(:fixture) { metadata2 }

    subject(:extracted_data) { described_class.new(marc, '541').extract.to_a }

    it 'is not yielded' do
      expect(marc['541']).to be_present
      expect(extracted_data.length).to eq 0
    end
  end

  context 'with vernacular data' do
    let(:fixture) { complex_vernacular_fixture }

    subject(:extracted_data) { described_class.new(marc, '300a').extract.to_a }

    it 'is interfiled with the matched field and unmatched verncular is appended' do
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to eq [
        '300 Unmatched Romanized',
        '300 Matched Romanized',
        '300 Matched Vernacular',
        '300 Unmatched Vernacular'
      ]
    end

    context 'with subfield codes' do
      let(:fixture) { vernacular_marc_264_fixture }

      subject(:extracted_data) { described_class.new(marc, '264a').extract.to_a }

      it 'filters vernacular data' do
        expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to eq [
          'SubfieldA',
          'Vernacular SubfieldA'
        ]
      end
    end
  end

  context 'with multiple MARC tags' do
    subject(:extracted_data) { described_class.new(marc, ['506', '541', '555']).extract.to_a }

    it 'extracts field data in the order they appear in the MARC record' do
      expect(extracted_data.map(&:first).map(&:tag)).to eq ['506', '555', '541']
    end
  end

  context 'with a field that has a 1st indicator of 1' do
    let(:fixture) { metadata2 }

    subject(:extracted_data) { described_class.new(marc, ['760']).extract.to_a }

    it 'is not yielded' do
      expect(marc['760']).to be_present
      expect(extracted_data.length).to eq 0
    end
  end

  context 'without the requested field' do
    let(:fixture) { metadata2 }

    subject(:extracted_data) { described_class.new(marc, ['510']).extract.to_a }

    it 'yields nothing' do
      expect(extracted_data.length).to eq 0
    end
  end

  context 'with a linking field that indicates text direction' do
    let(:fixture) { matched_vernacular_rtl_fixture }
    subject(:extracted_data) { described_class.new(marc, ['245']).extract.to_a }

    it 'links the fields as per the spec' do
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to eq [
        'This is NOT Right-to-Left Vernacular',
        'This is Right-to-Left Vernacular'
      ]
    end
  end

  context 'with a linking field that indicates text direction that is unmatched' do
    let(:fixture) { unmatched_vernacular_rtl_fixture }

    subject(:extracted_data) { described_class.new(marc, ['245']).extract.to_a }

    it 'links the fields as per the spec' do
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to eq [
        'This is Right-to-Left Vernacular'
      ]
    end
  end

  context 'with relator terms' do
    let(:fixture) { marc_sections_fixture }

    subject(:extracted_data) { described_class.new(marc, ['700']).extract.to_a }

    it 'does not include the relator terms in the subfield list' do
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to eq [
        'Contributor Performer',
        'Vernacular Contributor'
      ]
    end
  end

  context 'with bad vernacular fields (whatever that means)' do
    let(:fixture) { bad_vernacular_fixture }

    subject(:extracted_data) { described_class.new(marc, ['600']).extract.to_a }

    it 'does the right thing, whatever that is' do
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).not_to include(/This is Vernacular/)
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to include(/This is not Vernacular/)
    end
  end

  context 'with special characters' do
    let(:fixture) { escape_characters_fixture }

    subject(:extracted_data) { described_class.new(marc, ['690']).extract.to_a }

    it 'handles them correctly' do
      expect(extracted_data.map { |_, subfields| subfields.map(&:value).join(' ') }).to eq [
        "Stanford Artists' Books Collection.",
        'Stanford > Berkeley.'
      ]
    end
  end
end
