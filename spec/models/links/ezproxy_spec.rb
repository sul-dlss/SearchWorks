# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Links::Ezproxy do
  subject(:ezproxy) do
    Links::Ezproxy.new(link:, document:)
  end

  let(:stanford_only) { true }
  let(:link_title) { nil }

  let(:link) { instance_double(Links::Link, href: url, link_title:, stanford_only?: stanford_only) }

  describe '#to_proxied_url' do
    context 'SUL record' do
      let(:document) { SolrDocument.new(holdings_library_code_ssim: ['SUL']) }

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'http://ch.ucpress.edu/whatever' }

        context 'link is SUL restricted' do
          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'is NOT a SUL restriction note' do
          let(:stanford_only) { false }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url matching a LAW proxied host' do
        let(:url) { 'https://www.iareporter.com/whatever' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url matching a LANE proxied host' do
        let(:url) { 'https://www.who.int/whatever' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url NOT matching a SUL proxied host' do
        let(:url) { 'https://stanford.idm.oclc.org/login?url=https://library.stanford.edu' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end
    end

    context 'LAW record' do
      let(:document) { SolrDocument.new(holdings_library_code_ssim: ['LAW']) }

      context 'with a url matching a LAW proxied host' do
        let(:stanford_only) { false }
        let(:url) { 'https://www.iareporter.com/whatever' }

        it 'adds the proxy prefix' do
          expect(ezproxy.to_proxied_url).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
        end
      end

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'http://ch.ucpress.edu/whatever' }

        context 'link title is a SUL restriction note' do
          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'link title is NOT a SUL restriction note' do
          let(:stanford_only) { false }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url NOT matching any proxied host' do
        let(:url) { 'https://stanford.idm.oclc.org/login?url=https://library.stanford.edu' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url that has a trailing space' do
        let(:url) { 'https://www.iareporter.com/whatever ' }
        let(:stanford_only) { false }

        it 'adds the proxy prefix' do
          expect(ezproxy.to_proxied_url).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
        end
      end
    end

    context 'LANE record' do
      let(:document) { SolrDocument.new(holdings_library_code_ssim: ['LANE']) }

      context 'with a url matching a LANE proxied host' do
        let(:url) { 'https://www.who.int/whatever' }

        context 'link is a SUL restricted' do
          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwww.who.int%2Fwhatever'
          end
        end

        context 'link is NOT LANE restricted' do
          let(:link_title) { 'Some other link note' }
          let(:stanford_only) { false }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'http://ch.ucpress.edu/whatever' }

        context 'link title is a SUL restriction note' do
          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'link is NOTSUL restricted' do
          let(:stanford_only) { false }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url NOT matching any proxied host' do
        let(:url) { 'https://www.a-link-not-on-the-proxy-list.edu' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end
    end

    context 'Database link' do
      let(:document) { nil }

      context 'with a url matching a SUL proxied host' do
        let(:url) { 'https://research.ebsco.com/whatever' }

        context 'link is SUL restricted' do
          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://stanford.idm.oclc.org/login?qurl=https%3A%2F%2Fresearch.ebsco.com%2Fwhatever'
          end
        end

        context 'link is NOT SUL restricted' do
          let(:stanford_only) { false }

          it { expect(ezproxy.to_proxied_url).to be_nil }
        end
      end

      context 'with a url NOT matching a SUL proxied host' do
        let(:url) { 'https://stanford.idm.oclc.org/login?url=https://library.stanford.edu' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end
    end
  end
end
