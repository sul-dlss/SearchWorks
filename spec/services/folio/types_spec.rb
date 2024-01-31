require 'rails_helper'

RSpec.describe Folio::Types do
  describe '.policies' do
    it 'returns a mapping of policy types to policy objects' do
      expect(described_class.policies).to include(:request, :loan, :overdue, :'lost-item', :notice)
    end

    it 'includes key request policies' do
      expect(described_class.policies[:request].values).to include(hash_including('name' => 'Allow All'))
        .and include(hash_including('name' => 'No requests allowed'))
    end
  end

  describe '.circulation_rules' do
    it 'returns the circulation rules text' do
      expect(described_class.circulation_rules).to include('priority:').and include('fallback-policy')
    end
  end

  describe '#sync!' do
    subject(:instance) { described_class.new(cache_dir: Pathname.new(tmpdir), folio_client:) }

    let(:tmpdir) { Dir.mktmpdir }
    let(:folio_client) do
      instance_double(
        FolioClient,
        circulation_rules:,
        **fake_data
      )
    end
    let(:fake_data) do
      {
        request_policies: ['request_policies'],
        loan_policies: ['loan_policies'],
        lost_item_fees_policies: ['lost_item_fees_policies'],
        patron_notice_policies: ['patron_notice_policies'],
        overdue_fines_policies: ['overdue_fines_policies'],
        patron_groups: ['patron_groups'],
        material_types: ['material_types'],
        locations: ['locations'],
        libraries: ['libraries'],
        campuses: ['campuses'],
        institutions: ['institutions'],
        loan_types: ['loan_types'],
        service_points: ['service_points'],
        courses: ['courses']
      }
    end
    let(:circulation_rules) do
      "priority: number-of-criteria, criterium (t,s, c, b, a, g, m), last-line\n"
    end

    after { FileUtils.remove_entry(tmpdir) }

    it 'makes requests to the FOLIO API and caches that information for future requests' do
      instance.sync!

      fake_data.each do |k, v|
        expect(instance.get_type(k.to_s)).to eq v
      end
    end

    it 'writes the circulation rules to a file' do
      instance.sync!

      expect(instance.circulation_rules).to eq circulation_rules
    end
  end
end
