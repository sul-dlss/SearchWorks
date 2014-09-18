require "spec_helper"

describe MarcImprint do
  include MarcMetadataFixtures
  let(:marc) { SolrDocument.new(marcxml: edition_imprint_fixture).to_marc }
  let(:imprint) { MarcImprint.new(marc) }
  it 'should return MARC 260' do
    imprint.fields.each do |field|
      expect(field.tag).to eq '260'
    end
  end
  it 'should join subfields w/ a space' do
    expect(imprint.parse_marc_record.length).to eq 1
    expect(imprint.parse_marc_record.first.values.length).to eq 1
    expect(imprint.parse_marc_record.first.values.first).to eq "SubA SubB SubC SubG"
  end
  it 'should not include subfields that should not be displayed' do
    expect(imprint.parse_marc_record.length).to eq 1
    expect(imprint.parse_marc_record.first.values.length).to eq 1
    expect(imprint.parse_marc_record.first.values.first).to_not match /SubZ/
  end
  it 'should be labeled "Imprint"' do
    expect(imprint.parse_marc_record.length).to eq 1
    expect(imprint.parse_marc_record.first.label).to eq "Imprint"
  end
end
