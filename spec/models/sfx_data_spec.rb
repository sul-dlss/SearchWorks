require 'spec_helper'

describe SfxData do
  let(:sfx_url) { 'http://sul-sfx.stanford.edu/sfx?thing=thing&other_thing=this_other_thing' }

  let(:sfx_xml) do
    Nokogiri::XML.parse(
      <<-XML
        <root>
          <target>
            <service_type>getFullTxt</service_type>
            <target_public_name>TargetName</target_public_name>
            <target_url>http://example.com</target_url>
            <coverage>
              <coverage_statement>Statement 1</coverage_statement>
              <coverage_statement>Statement 2</coverage_statement>
            </coverage>
          </target>
        </root>
      XML
    )
  end

  subject(:sfx_data) { described_class.new(sfx_url) }

  before do
    expect(sfx_data).to receive(:sfx_xml).at_least(:once).and_return(sfx_xml)
  end

  describe '#targets' do
    it 'returns an array of SfxData::Target objects' do
      expect(sfx_data.targets).to be_an Array
      expect(sfx_data.targets.length).to eq 1
      expect(sfx_data.targets.first).to be_a SfxData::Target
    end

    context 'when there is no proper xml' do
      let(:sfx_xml) { Nokogiri::XML.parse('') }

      it 'returns an empty array' do
        expect(sfx_data.targets).to eq([])
      end
    end

    context 'when a target is not a full-text source' do
      let(:sfx_xml) do
        Nokogiri::XML.parse(
          <<-XML
            <root>
              <target>
                <service_type>notFullTxt</service_type>
                <target_public_name>TargetName</target_public_name>
                <target_url>http://example.com</target_url>
              </target>
            </root>
          XML
        )
      end

      it 'is not returned' do
        expect(sfx_data.targets).to eq([])
      end
    end
  end

  describe 'SfxData::Target' do
    subject(:target) { sfx_data.targets.first }

    it 'parses the name' do
      expect(target.name).to eq 'TargetName'
    end

    it 'parses the url' do
      expect(target.url).to eq 'http://example.com'
    end

    it 'parses the coverage and returns an array of coverate strings' do
      expect(target.coverage).to eq(['Statement 1', 'Statement 2'])
    end
  end
end
