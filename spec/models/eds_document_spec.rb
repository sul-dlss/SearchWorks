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
end
