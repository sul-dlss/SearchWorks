# frozen_string_literal: true

require 'spec_helper'

describe 'Subjects' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marcxml: marc) }

  subject(:subjects) { document.subjects('650') }

  context 'with subjects in the $a' do
    let(:marc) do
      <<-XML
        <record>
          <datafield tag="650" ind1="1" ind2=" ">
            <subfield code="a">Barley</subfield>
            <subfield code="a">Malt</subfield>
          </datafield>
        </record>
      XML
    end

    it 'turns each $a into a separate value' do
      expect(subjects.values).to eq [['Barley'], ['Malt']]
    end
  end

  context 'with nomesh subjects' do
    let(:marc) do
      <<-XML
        <record>
          <datafield tag="650" ind1="1" ind2=" ">
            <subfield code="a">nomesh</subfield>
          </datafield>
        </record>
      XML
    end

    it 'suppresses the subjects' do
      expect(subjects.values).to be_empty
    end
  end

  context 'with nomeshx subjects' do
    let(:marc) do
      <<-XML
        <record>
          <datafield tag="650" ind1="1" ind2=" ">
            <subfield code="a">nomeshx</subfield>
          </datafield>
        </record>
      XML
    end

    it 'suppresses the subjects' do
      expect(subjects.values).to be_empty
    end
  end
end
