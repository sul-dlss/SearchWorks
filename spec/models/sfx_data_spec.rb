# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SfxData do
  let(:sfx_url) { 'http://sul-sfx.stanford.edu/sfx?thing=thing&other_thing=this_other_thing&sid=the_sid_of_the_url' }

  let(:sfx_xml) do
    Nokogiri::XML.parse(
      <<-XML
        <root>
          <target>
            <service_type>getFullTxt</service_type>
            <is_related>no</is_related>
            <target_public_name>TargetName</target_public_name>
            <target_url>http://example.com</target_url>
            <coverage>
              <coverage_statement>Statement 1</coverage_statement>
              <coverage_statement>Statement 2</coverage_statement>
              <coverage_statement></coverage_statement>
            </coverage>
            <note>Fulltext access limited to open access articles only</note>
            <note></note>
            <embargo_text>
             <embargo_statement>Most recent 1 year(s)6 month(s) not available</embargo_statement>
             <embargo_statement></embargo_statement>
            </embargo_text>
          </target>
        </root>
      XML
    )
  end

  subject(:sfx_data) { described_class.new(sfx_url) }

  before do
    allow(sfx_data).to receive(:sfx_xml).at_least(:once).and_return(sfx_xml)
  end

  describe '#url_without_sid' do
    it 'removes the "sid" param from the URL and returns the rest' do
      new_url = described_class.url_without_sid(sfx_url)
      expect(sfx_url).to include 'sid=the_sid_of_the_url'
      expect(new_url).not_to include 'sid=the_sid_of_the_url'
      expect(new_url).to include 'http://sul-sfx.stanford.edu'
    end
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
                <is_related>no</is_related>
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

  context 'when the target is related full-text' do
    let(:sfx_xml) do
      Nokogiri::XML.parse(
        <<-XML
          <root>
            <target>
              <service_type>getFullTxt</service_type>
              <is_related>remote</is_related>
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

    it 'parses the note' do
      expect(target.note).to eq ['Fulltext access limited to open access articles only']
    end

    it 'parses the embargo statements' do
      expect(target.embargo).to eq ['Most recent 1 year(s)6 month(s) not available']
    end
  end
end
