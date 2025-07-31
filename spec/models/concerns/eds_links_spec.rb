# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EdsLinks do
  let(:document) do
    EdsDocument.new({
                      'FullText' => {
                        'CustomLinks' => [{
                          'Text' => 'HTML full text',
                          'Url' => 'http://example.com'
                        }]
                      }
                    })
  end

  context '#eds_links' do
    it '#all returns an array of Links:link' do
      expect(document.eds_links.all).to be_present

      document.eds_links.all.each do |link|
        expect(link).to be_a Links::Link
      end
    end

    it 'is present when it has a label' do
      expect(document.eds_links.fulltext).to be_present
    end

    context 'with a link without a label' do
      let(:document) do
        EdsDocument.new({
                          'FullText' => {
                            'CustomLinks' => [{
                              'Url' => 'http://example.com'
                            }]
                          }
                        })
      end

      it 'is not a fulltext link' do
        expect(document.eds_links.fulltext).not_to be_present
      end
    end

    context 'with a cataloglink' do
      let(:document) do
        EdsDocument.new({
                          'Item' => [{
                            'Group' => 'URL',
                            'Data' => 'whatever',
                            'Label' => 'Something'
                          }]
                        })
      end

      it 'is not a fulltext link' do
        expect(document.eds_links.fulltext).not_to be_present
      end
    end
  end

  context 'with a "smart" link with a URL' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'Links' => [
                            {
                              'Type' => 'other',
                              'Url' => 'https://some.ebsco.url/'
                            }
                          ]
                        }
                      })
    end

    it 'has a fulltext link prefixed by ezproxy' do
      expect(document.eds_links.all.first).to have_attributes(href: 'https://stanford.idm.oclc.org/login?qurl=https%3A%2F%2Fsome.ebsco.url%2F', text: 'View on content provider&#39;s site',
                                                              stanford_only?: true)
    end
  end

  context 'with a "smart" link without a URL' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'Links' => [
                            {
                              'Type' => 'other'
                            }
                          ]
                        }
                      })
    end

    it 'has a fulltext link' do
      expect(document.eds_links.all.first).to have_attributes(href: 'detail', text: 'View on content provider&#39;s site', stanford_only?: true)
    end
  end

  context 'with a HTML full text link' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'CustomLinks' => [{
                            'Text' => 'HTML full text',
                            'Url' => 'http://example.com'
                          }]
                        }
                      })
    end

    it 'relabels it to "View full text"' do
      expect(document.eds_links.all.first).to have_attributes(text: 'View full text', stanford_only?: false)
    end
  end

  context 'with a PDF full text link' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'Links' => [
                            {
                              'Type' => 'pdflink'
                            }
                          ]
                        }
                      })
    end

    it 'handles PDF full text variants' do
      expect(document.eds_links.all.first).to have_attributes(text: 'View/download PDF', stanford_only?: true)
    end
  end

  context 'with a PDF ebook link' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'Links' => [
                            {
                              'Type' => 'ebook-pdf'
                            }
                          ]
                        }
                      })
    end

    it 'handles PDF full text variants' do
      expect(document.eds_links.all.first).to have_attributes(text: 'View/download PDF', stanford_only?: true)
    end
  end

  context 'with an epub ebook link' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'Links' => [
                            {
                              'Type' => 'ebook-epub'
                            }
                          ]
                        }
                      })
    end

    it 'handles PDF full text variants' do
      expect(document.eds_links.all.first).to have_attributes(text: 'ePub eBook Full Text')
    end
  end

  context 'with a SFX link' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'CustomLinks' => [{
                            'Text' => 'Check SFX for full text',
                            'Url' => 'http://sfx.example.com'
                          }]
                        }
                      })
    end

    it 'relabels it to "View full text"' do
      expect(document.eds_links.all.first).to have_attributes(text: 'View on content provider&#39;s site', stanford_only?: false)
    end
  end

  context 'with a "View request options" link' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'CustomLinks' => [{
                            'Text' => 'View request options',
                            'Url' => 'http://example.com'
                          }]
                        }
                      })
    end

    it 'relabels it to "Find full text"' do
      expect(document.eds_links.all.first.text).to eq('Find full text or request')
    end

    context 'with some other label without special handling' do
      let(:document) do
        EdsDocument.new({
                          'FullText' => {
                            'CustomLinks' => [{
                              'Text' => 'View in HathiTrust Open Access',
                              'Url' => 'http://example.com'
                            }]
                          }
                        })
      end

      it 'uses the original label' do
        expect(document.eds_links.all.first.text).to eq('View in HathiTrust Open Access')
      end
    end

    context 'omits unwanted links' do
      let(:link_text) { '' }
      let(:document) do
        EdsDocument.new({
                          'FullText' => {
                            'CustomLinks' => [{
                              'Text' => link_text,
                              'Url' => 'http://example.com'
                            }]
                          }
                        })
      end

      context 'with "Access URL"' do
        let(:link_text) { 'Access URL' }

        it 'skips the link' do
          expect(document.eds_links.fulltext).to be_blank
        end
      end

      context 'with "AVAILABILITY"' do
        let(:link_text) { 'AVAILABILITY' }

        it 'skips the link' do
          expect(document.eds_links.fulltext).to be_blank
        end
      end
    end
  end

  context 'prioritizing links' do
    let(:document) do
      EdsDocument.new({
                        'FullText' => {
                          'CustomLinks' => links
                        }
                      })
    end
    let(:all_custom_links) do
      [
        { 'Text' => 'HTML FULL TEXT',          'Url' => 'http://example.com/1' },
        { 'Text' => 'PDF FULL TEXT',           'Url' => 'http://example.com/2' },
        { 'Text' => 'EDS FULL TEXT',           'Url' => 'http://example.com/3' },
        { 'Text' => 'OPEN ACCESS',             'Url' => 'http://example.com/4' },
        { 'Text' => 'VIEW REQUEST OPTIONS',    'Url' => 'http://example.com/5' },
        { 'Text' => 'ACCESS URL',              'Url' => 'http://example.com/6' } # ignored
      ]
    end

    context 'categories 1 and 2' do
      let(:links) { all_custom_links }

      it 'shows 1 and 2 only' do
        expect(document.eds_links.fulltext.length).to eq 2
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/1')
        expect(document.eds_links.fulltext.last.href).to eq('http://example.com/2')
      end
    end

    context 'category 3' do
      let(:links) { all_custom_links[2..4] }

      it 'shows 3 only' do
        expect(document.eds_links.fulltext.length).to eq 1
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/3')
      end
    end

    context 'category 4' do
      let(:links) { all_custom_links[3..4] }

      it 'shows 4 only' do
        expect(document.eds_links.fulltext.length).to eq 1
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/4')
      end
    end

    context 'category 5' do
      let(:links) { all_custom_links[4..4] }

      it 'shows 5 only' do
        expect(document.eds_links.fulltext.length).to eq 1
        expect(document.eds_links.fulltext.first.href).to eq('http://example.com/5')
        expect(document.eds_links.fulltext.first.ill?).to be_truthy
      end
    end
  end
end
