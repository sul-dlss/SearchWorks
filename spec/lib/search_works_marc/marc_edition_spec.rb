require "spec_helper"

describe MarcEdition do
  include MarcMetadataFixtures
  let(:marc) { SolrDocument.new(marcxml: edition_imprint_fixture).to_marc }
  let(:edition) { MarcEdition.new(marc) }
  it 'should return MARC 250' do
    edition.marc_record.each do |field|
      expect(field.tag).to eq '250'
    end
  end
  it 'should join subfields w/ a space' do
    expect(edition.parse_marc_record.length).to eq 1
    expect(edition.parse_marc_record.first.values.length).to eq 1
    expect(edition.parse_marc_record.first.values.first).to eq "SubA SubB"
  end
  it 'should not include subfields that should not be displayed' do
    expect(edition.parse_marc_record.length).to eq 1
    expect(edition.parse_marc_record.first.values.length).to eq 1
    expect(edition.parse_marc_record.first.values.first).to_not match /SubZ/
  end
  it 'should be labeled "Edition"' do
    expect(edition.parse_marc_record.length).to eq 1
    expect(edition.parse_marc_record.first.label).to eq "Edition"
  end
end
