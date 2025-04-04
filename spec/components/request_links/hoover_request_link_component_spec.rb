# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestLinks::HooverRequestLinkComponent, type: :component do
  subject(:component) { described_class.for(document:, library_code:, location:) }

  let(:page) { render_inline(component) }

  context 'for FOLIO items' do
    let(:document) { SolrDocument.new(id: '12345') }
    let(:library_code) { 'HILA' }
    let(:location) { instance_double(Holdings::Location, code: 'HILA-STACKS', items:) }

    let(:items) { [instance_double(Holdings::Item, folio_item?: true, allowed_request_types:, effective_location:, permanent_location:, folio_status:)] }
    let(:folio_status) { 'Available' }
    let(:allowed_request_types) { [] }
    let(:permanent_location) { effective_location }
    let(:effective_location) do
      Folio::Location.from_dynamic(
        {
          "id" => "891ca554-5109-419a-bd01-d647944a40ea",
          "name" => "Hoover stacks",
          "code" => "HILA-STACKS",
          'institution' => {
            'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
            'code' => 'SU',
            'name' => 'Stanford University'
          },
          'campus' => {
            'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
            'code' => 'HOOVER',
            'name' => 'Hoover Institution'
          },
          'library' => {
            "id" => "5b61a365-6b39-408c-947d-f8861a7ba8ae",
            "name" => "Hoover",
            "code" => "HILA"
          }
        }
      )
    end

    context 'with a finding aid' do
      let(:document) do
        SolrDocument.new(
          id: '12345',
          marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/abc123", note: 'FINDING AID' }]
        )
      end

      it { expect(page).to have_link 'Request via Finding Aid', href: 'http://oac.cdlib.org/ark:/abc123' }
    end

    context 'without a finding aid' do
      before do
        allow(document).to receive(:to_marc).and_return(MARC::Record.new)
      end

      it {
        expect(page).to have_link 'Request via Aeon', href: %r{^https://hoover.aeon.atlas-sys.com/aeon.dll}
      }
    end

    context 'in a non-requestable location' do
      let(:effective_location) do
        Folio::Location.from_dynamic(
          {
            "id" => "891ca554-5109-419a-bd01-d647944a40ea",
            "name" => "Hoover processing",
            "code" => "HILA-ARCHIVAL-PROCESSING",
            'institution' => {
              'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
              'code' => 'SU',
              'name' => 'Stanford University'
            },
            'campus' => {
              'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
              'code' => 'HOOVER',
              'name' => 'Hoover Institution'
            },
            'library' => {
              "id" => "5b61a365-6b39-408c-947d-f8861a7ba8ae",
              "name" => "Hoover",
              "code" => "HILA"
            }
          }
        )
      end

      before do
        allow(effective_location).to receive(:details).and_return({ 'availabilityClass' => 'In_process_non_requestable' })
      end

      it { expect(page).not_to have_link }
    end
  end
end
