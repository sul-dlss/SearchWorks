require 'spec_helper'

describe 'Isbn' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marcxml: isbn_fixture) }

  let(:isbn_fixture) do
    <<-XML
      <record>
        <datafield tag="020">
          <subfield code="a">0802142176</subfield>
          <subfield code="c">$7.50</subfield>
        </datafield>
      </record>
    XML
  end

  subject(:instance) { document.marc_field(:isbn) }

  it '#label' do
    expect(instance.label).to eq 'ISBN'
  end

  it '#values ignores subfield c' do
    expect(instance.values.length).to eq 1
    expect(instance.values).to include '0802142176'
  end

  context 'with only a $c' do
    let(:isbn_fixture) do
      <<-XML
        <record>
          <datafield tag="020">
            <subfield code="c">$7.50</subfield>
          </datafield>
        </record>
      XML
    end

    describe '#values' do
      it 'is empty' do
        expect(instance.values).to be_blank
      end
    end
  end
end
