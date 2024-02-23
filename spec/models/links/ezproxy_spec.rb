require 'rails_helper'

RSpec.describe Links::Ezproxy do
  subject(:ezproxy) do
    Links::Ezproxy.new(url:, link_title:, document:)
  end

  describe '#to_proxied_url' do
    let(:document) do
      SolrDocument.new({
                         holdings_json_struct: [
                           {
                             holdings: [
                               {
                                 id: "f274792f-ad5f-5783-b86b-616a358b524d",
                                 location: {
                                   effectiveLocation: location
                                 }
                               }
                             ],
                             items: []
                           }
                         ]
                       })
    end

    context 'SUL record' do
      let(:location) do
        {
          id: "ce250ebb-807f-460a-9afa-b2087645e4a8",
          name: "Digital: Document",
          code: "SUL-EDOC",
          library: {
            id: "5b2c8449-eed6-4bd3-bcef-af1e5a225400",
            code: "SUL"
          },
          campus: {
            id: "40b76104-95ea-4360-a2be-5fd887222e2d",
            code: "MED",
            name: "Medical Center"
          },
          institution: {
            id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
            code: "SU",
            name: "Stanford University"
          }
        }
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

      context 'with a url matching a LAW proxied host' do
        let(:url) { 'https://www.iareporter.com/whatever' }
        let(:link_title) { 'Available to Stanford Affiliated users' }

        it { expect(ezproxy.to_proxied_url).to be_nil }
      end

      context 'with a url matching a LANE proxied host' do
        let(:url) { 'https://who.int/whatever' }
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
      let(:location) do
        {
          id: "c6ce7052-e365-47d5-a98d-41daf68e7a1f",
          name: "Online resource",
          code: "LAW-ELECTRONIC",
          campus: {
            id: "7003123d-ef65-45f6-b469-d2b9839e1bb3",
            code: "LAW",
            name: "Law School"
          },
          library: {
            id: "7e4c05e3-1ce6-427d-b9ce-03464245cd78",
            code: "LAW",
            name: "Law Library (Crown)"
          },
          institution: {
            id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
            code: "SU",
            name: "Stanford University"
          }
        }
      end

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
    end

    context 'LANE record' do
      let(:location) do
        {
          id: "ce250ebb-807f-460a-9afa-b2087645e4a8",
          name: "Digital: Document",
          code: "LANE-EDOC",
          library: {
            id: "5b2c8449-eed6-4bd3-bcef-af1e5a225400",
            code: "LANE",
            name: "Lane Medical Library"
          },
          campus: {
            id: "40b76104-95ea-4360-a2be-5fd887222e2d",
            code: "MED",
            name: "Medical Center"
          },
          institution: {
            id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
            code: "SU",
            name: "Stanford University"
          }
        }
      end

      context 'with a url matching a LANE proxied host' do
        let(:url) { 'https://who.int/whatever' }

        context 'link title is a LANE restriction note' do
          let(:link_title) { 'Access restricted to Stanford community' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwho.int%2Fwhatever'
          end
        end

        context 'link title is a SUL restriction note' do
          let(:link_title) { 'Available to Stanford-affiliated users only' }

          it 'adds the proxy prefix' do
            expect(ezproxy.to_proxied_url).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwho.int%2Fwhatever'
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
  end
end
