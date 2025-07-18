# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Links::Ezproxy do
  subject(:ezproxy) do
    Links::Ezproxy.new(url:, link_title:, document:)
  end

  describe '#to_proxied_url' do
    context 'SUL record' do
      let(:document) { SolrDocument.new(holdings_library_code_ssim: ['SUL']) }

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'http://ch.ucpress.edu/whatever' }

        context 'link title is a SUL restriction note' do
          let(:link_title) { 'Available to Stanford Affiliated users' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'link title is NOT a SUL restriction note' do
          let(:link_title) { 'Some other link note' }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url matching a LAW proxied host' do
        let(:url) { 'https://www.iareporter.com/whatever' }
        let(:link_title) { 'Available to Stanford Affiliated users' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url matching a LANE proxied host' do
        let(:url) { 'https://www.who.int/whatever' }
        let(:link_title) { 'Access restricted to Stanford community' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url NOT matching a SUL proxied host' do
        let(:url) { 'https://stanford.idm.oclc.org/login?url=https://library.stanford.edu' }
        let(:link_title) { 'Available to Stanford Affiliated users' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end
    end

    context 'LAW record' do
      let(:document) { SolrDocument.new(holdings_library_code_ssim: ['LAW']) }

      context 'with a url matching a LAW proxied host' do
        let(:url) { 'https://www.iareporter.com/whatever' }
        let(:link_title) { 'Some other link note' }

        it 'adds the proxy prefix' do
          expect(ezproxy.to_proxied_url).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
        end
      end

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'http://ch.ucpress.edu/whatever' }

        context 'link title is a SUL restriction note' do
          let(:link_title) { 'Available to Stanford Affiliated users' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'link title is NOT a SUL restriction note' do
          let(:link_title) { 'Some other link note' }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url NOT matching any proxied host' do
        let(:url) { 'https://stanford.idm.oclc.org/login?url=https://library.stanford.edu' }
        let(:link_title) { 'Available to Stanford Affiliated users' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url that has a trailing space' do
        let(:url) { 'https://www.iareporter.com/whatever ' }
        let(:link_title) { 'Some other link note' }

        it 'adds the proxy prefix' do
          expect(ezproxy.to_proxied_url).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
        end
      end
    end

    context 'LANE record' do
      let(:document) { SolrDocument.new(holdings_library_code_ssim: ['LANE']) }

      context 'with a url matching a LANE proxied host' do
        let(:url) { 'https://www.who.int/whatever' }

        context 'link title is a LANE restriction note' do
          let(:link_title) { 'Access restricted to Stanford community' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwww.who.int%2Fwhatever'
          end
        end

        context 'link title is a SUL restriction note' do
          let(:link_title) { 'Available to Stanford-affiliated users only' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwww.who.int%2Fwhatever'
          end
        end

        context 'link title is NOT a LANE restriction note' do
          let(:link_title) { 'Some other link note' }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'http://ch.ucpress.edu/whatever' }

        context 'link title is a SUL restriction note' do
          let(:link_title) { 'Available to Stanford Affiliated users' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'link title is NOT a SUL restriction note' do
          let(:link_title) { 'Some other link note' }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url NOT matching any proxied host' do
        let(:url) { 'https://www.a-link-not-on-the-proxy-list.edu' }
        let(:link_title) { 'Available to Stanford Affiliated users' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end
    end

    context 'Database link' do
      let(:document) { nil }

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'https://research.ebsco.com/whatever' }

        context 'link title is a SUL restriction note' do
          let(:link_title) { 'Available to Stanford Affiliated users' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=https%3A%2F%2Fresearch.ebsco.com%2Fwhatever'
          end
        end

        context 'link title is NOT a SUL restriction note' do
          let(:link_title) { 'Some other link note' }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url NOT matching a SUL proxied host' do
        let(:url) { 'https://stanford.idm.oclc.org/login?url=https://library.stanford.edu' }
        let(:link_title) { 'Available to Stanford Affiliated users' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end
    end
  end
end
