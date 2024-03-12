# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Language do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: marc, format_main_ssim: formats) }

  subject(:language) { described_class.new(document) }

  describe 'label' do
    context 'when the format includes "Music score"' do
      let(:formats) { ['Music score'] }

      context 'when there are subfields other that $b' do
        let(:marc) { language_fixture }

        it 'is "Language"' do
          expect(language.label).to eq 'Language'
        end
      end

      context 'when there are only subfield $b present' do
        let(:marc) { notation_fixture }

        it 'is "Notation"' do
          expect(language.label).to eq 'Notation'
        end
      end
    end

    context 'when the format does not include "Music score"' do
      let(:formats) { ['Not a Music score'] }
      let(:marc) { notation_fixture }

      it 'is "Language" regardless of subfield' do
        expect(language.label).to eq 'Language'
      end
    end
  end

  describe 'values' do
    let(:document) do
      SolrDocument.new(marc_json_struct: marc, language: ['English'], language_vern: ['English in another language'])
    end
    let(:marc) { language_fixture }

    it 'appends language index fields with marc fields' do
      expect(language.values.length).to eq 1
      expect(language.values.first).to eq('English, English in another language. Language $a Language $b')
    end
  end
end
