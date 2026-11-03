# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Extent do
  include MarcMetadataFixtures

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
      expect(no_extent.extent_sans_format).not_to be_present
    end
    it "includes a single extent statement" do
      expect(single_extent.extent_sans_format).to eq 'an extent statement'
    end
    it "joins multiple extent statements" do
      expect(multi_extent.extent_sans_format).to eq 'Extent1, Extent2'
    end
    it "joins physical and characteristics statements" do
      expect(marc_extent.extent_sans_format).to eq 'Extent Sound: digital; optical; surround; stereo; Dolby. Video: NTSC. Digital: video file; DVD video; Region 1.'
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
