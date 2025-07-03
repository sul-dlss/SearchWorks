# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EdsDocument do
  let(:document) do
    StubArticleService.full_text_document
  end
  let(:empty_document) do
    StubArticleService.non_fulltext_document
  end

  describe '#html_fulltext_available' do
    it 'returns true when fulltext is present' do
      expect(document.html_fulltext?).to be true
    end

    it 'returns nil when fulltext is not available' do
      expect(empty_document).not_to be_html_fulltext
    end
  end

  context 'when there is an EDS citation' do
    let(:document) do
      EdsDocument.new({
                        'styles' => {
                          'Citations' => [
                            {
                              'Id' => 'apa',
                              'Data' => 'EDS citation content'
                            }
                          ]
                        }
                      })
    end

    it { expect(document).to be_citable }

    it 'returns the EDS citations' do
      expect(document.citations).to eq({ 'apa' => 'EDS citation content' })
    end
  end

  describe '#html_decode_and_sanitize' do
    # For the malformed HTML to have the attributes for the first element recognized, another beginning tag should be included.
    # This format mirrors some of the conditions where the HTML has tags that lead to the parser misidentifying elements and attributes.
    let(:html) { "Dirvi.s.Tutelaribus. <zit #{attributes} •E<I0-3..E*1,3-Z.D3. " }

    context 'when the HTML string has greater than allowed attributes' do
      # Attributes must be unique otherwise they appear to be deduplicated
      let(:attributes) do
        Array.new(3000) do |i|
          " ABC#{i} "
        end.join
      end

      it 'returns an empty string if the HTML throws an error' do
        expect(document.html_decode_and_sanitize(html)).to eq("")
      end
    end

    context 'when the HTML string has fewer than allowed attributes' do
      # Attributes must be unique otherwise they appear to be deduplicated
      let(:attributes) do
        Array.new(2999) do |i|
          " ABC#{i} "
        end.join
      end

      it 'returns an HTML with the first element text without attributes' do
        expect(document.html_decode_and_sanitize(html)).to eq("Dirvi.s.Tutelaribus. ")
      end
    end
  end
end