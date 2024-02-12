require 'rails_helper'

RSpec.describe BoundWithNote do
  include MarcMetadataFixtures
  let(:marc) { linked_ckey_fixture }
  let(:document) { SolrDocument.new(marc_json_struct: marc) }

  subject { described_class.new(document, %w(590)) }

  describe '#values' do
    it 'links to the parent ID if there is a ckey in the $c' do
      expect(subject.values.length).to eq 2
      expect(subject.values).to include 'Copy 1 bound with v. 140 <a href="/view/55523">55523</a> (parent record’s ckey)'
      expect(subject.values).to include 'A 590 that does not have $c'
    end

    context 'with a FOLIO hrid in the $c' do
      let(:marc) do
        <<-JSON
          {
            "leader": "          22        4500",
            "fields": [
              {
                "590": {
                  "ind1": " ",
                  "ind2": " ",
                  "subfields": [
                    {
                      "a": "Copy 1 bound with v. 140"
                    },
                    {
                      "c": "in00001 (parent record’s ckey)"
                    }
                  ]
                }
              }
            ]
          }
        JSON
      end

      it 'links to the parent ID' do
        expect(subject.values.length).to eq 1
        expect(subject.values).to include 'Copy 1 bound with v. 140 <a href="/view/in00001">in00001</a> (parent record’s ckey)'
      end
    end

    context 'with a $c that does not start with a ckey' do
      let(:marc) { unlinked_ckey_fixture }

      it 'does not link the $c' do
        expect(subject.values).to include 'Electronic reproduction.  Chicago, Illinois :  McGraw Hill Education, '
      end
    end
  end
end
