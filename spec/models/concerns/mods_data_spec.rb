# frozen_string_literal: true

require 'rails_helper'

class ModsDataTestClass
  include ModsData
end

RSpec.describe ModsData do
  include ModsFixtures
  let(:document) { SolrDocument.new(modsxml: mods_everything) }

  describe "#mods" do
    it "should be nil if no modsxml" do
      expect(SolrDocument.new().mods).to be_nil
    end

    it "should be a ModsDisplay" do
      expect(document.mods).to be_a ModsDisplay::HTML
    end
  end

  describe "#prettified_mods" do
    it "should be nil if no modsxml" do
      expect(SolrDocument.new().prettified_mods).to be_nil
    end

    it "should return prettified mods" do
      expect(document.prettified_mods).to be_a String
      expect(document.prettified_mods).to match /<div class="CodeRay">/
      expect(document.prettified_mods).to match />A record with everything</
    end
  end

  describe '#mods_abstract' do
    let(:document) { SolrDocument.new(summary_display: ['The Abstract']) }

    it 'is fetched from the index' do
      expect(document.mods_abstract).to eq ['The Abstract']
    end

    context 'when the index data has duplicate content' do
      let(:document) { SolrDocument.new(summary_display: ['The Abstract', 'The Abstract']) }

      it 'de-duplicates it' do
        expect(document.mods_abstract).to eq ['The Abstract']
      end
    end
  end
end
