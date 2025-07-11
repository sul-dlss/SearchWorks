# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Extent do
  include MarcMetadataFixtures
  let(:no_format) { SolrDocument.new() }
  let(:single_format) {
    SolrDocument.new(
      format_hsim: ['Book']
    )
  }
  let(:multi_format) {
    SolrDocument.new(
      format_hsim: ['Database', 'Book']
    )
  }
  let(:bad_format) {
    SolrDocument.new(
      format_hsim: ['Book', 'Something else']
    )
  }

  describe 'label' do
    it { expect(single_format.extent_label).to eq 'Description' }
  end

  describe "value" do
    let(:no_extent) { SolrDocument.new() }
    let(:single_extent) {
      SolrDocument.new(
        physical: 'an extent statement'
      )
    }
    let(:multi_extent) {
      SolrDocument.new(
        physical: ['Extent1', 'Extent2']
      )
    }
    let(:marc_extent) {
      SolrDocument.new(
        physical: ['Extent'],
        characteristics_ssim: ['Sound: digital; optical; surround; stereo; Dolby.', 'Video: NTSC. Digital: video file; DVD video; Region 1.']
      )
    }

    it "is not present if the appropriate metadata is not available" do
      expect(no_extent.extent).not_to be_present
      expect(no_extent.extent_sans_format).not_to be_present
    end
    it "includes a single extent statement" do
      expect(single_extent.extent).to eq 'an extent statement'
      expect(single_extent.extent_sans_format).to eq 'an extent statement'
    end
    it "joins multiple extent statements" do
      expect(multi_extent.extent).to eq 'Extent1, Extent2'
      expect(multi_extent.extent_sans_format).to eq 'Extent1, Extent2'
    end
    it "joins physical and characteristics statements" do
      expect(marc_extent.extent).to eq 'Extent Sound: digital; optical; surround; stereo; Dolby. Video: NTSC. Digital: video file; DVD video; Region 1.'
      expect(marc_extent.extent_sans_format).to eq 'Extent Sound: digital; optical; surround; stereo; Dolby. Video: NTSC. Digital: video file; DVD video; Region 1.'
    end

    describe 'including format' do
      it 'upcases the given format' do
        expect(single_format.extent).to start_with 'Book'
      end

      it "selects the non-database format (even if it's the first one)" do
        expect(multi_format.extent).to start_with 'Book'
      end

      it 'selects the first format when multiple non-Database formats are present' do
        expect(bad_format.extent).to start_with 'Book'
      end
    end

    describe 'not including format' do
      it 'does not append the format' do
        expect(single_extent.extent_sans_format).to start_with 'an extent statement'
      end

      it 'uses both fields in marc_extent' do
        expect(marc_extent.extent_sans_format).to start_with 'Extent'
      end
    end
  end
end
