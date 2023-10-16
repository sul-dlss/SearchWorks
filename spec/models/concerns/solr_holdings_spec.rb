require 'rails_helper'

RSpec.describe SolrHoldings do
  let(:document) { SolrDocument.new }

  it "should provide a holdings method" do
    expect(document).to respond_to(:holdings)
    expect(document.holdings).to be_a Holdings
  end

  describe '#preferred_barcode' do
    let(:preferred) {
      SolrDocument.new(
        preferred_barcode: '12345',
        item_display_struct: [
          { barcode: '54321', library: 'GREEN', home_location: 'STACKS', callnumber: 'callnumber1', full_shelfkey: '1' },
          { barcode: '12345', library: 'GREEN', home_location: 'STACKS', callnumber: 'callnumber2', full_shelfkey: '2' }
        ]
      )
    }
    let(:bad_preferred) {
      SolrDocument.new(
        preferred_barcode: 'does-not-exist',
        item_display_struct: [
          { barcode: '54321', library: 'GREEN', home_location: 'STACKS', callnumber: 'callnumber1', full_shelfkey: '1' },
          { barcode: '12345', library: 'GREEN', home_location: 'STACKS', callnumber: 'callnumber2', full_shelfkey: '2' }
        ]
      )
    }
    let(:no_preferred) {
      SolrDocument.new(
        item_display_struct: [
          { barcode: '54321', library: 'GREEN', home_location: 'STACKS', callnumber: 'callnumber1', full_shelfkey: '1' },
          { barcode: '12345', library: 'GREEN', home_location: 'STACKS', callnumber: 'callnumber2', full_shelfkey: '2' }
        ]
      )
    }

    it 'should return the item based on preferred barcode' do
      expect(preferred.preferred_item.barcode).to eq '12345'
    end
    it 'should return the first item when the preferred barcode does not exist in the holdings' do
      expect(bad_preferred.preferred_item.barcode).to eq '54321'
    end
    it 'should return the first item if there is no preferred barcode available' do
      expect(no_preferred.preferred_item.barcode).to eq '54321'
    end
  end

  context 'with holdings_json_struct' do
    let(:holdings_json_struct) do
      <<~JSON
        {
          "holdings": [{
            "id": "33ad0ba1-e0ff-52c3-9c31-91b0f17dfa12",
            "hrid": "ah14127680_1",
            "notes": [],
            "_version": 1,
            "location": {
              "effectiveLocation": {
                "id": "4573e824-9273-4f13-972f-cff7bf504217",
                "code": "GRE-STACKS",
                "name": "Green Library Stacks",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": {},
                "library": {
                  "id": "f6b5519e-88d9-413e-924d-9ed96255f72e",
                  "code": "GREEN",
                  "name": "Cecil H. Green"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "permanentLocation": {
                "id": "4573e824-9273-4f13-972f-cff7bf504217",
                "code": "GRE-STACKS",
                "name": "Green Library Stacks",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": {},
                "library": {
                  "id": "f6b5519e-88d9-413e-924d-9ed96255f72e",
                  "code": "GREEN",
                  "name": "Cecil H. Green"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "temporaryLocation": null
            },
            "metadata": {
              "createdDate": "2023-05-07T15:32:47.271Z",
              "updatedDate": "2023-05-07T15:32:47.271Z",
              "createdByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2",
              "updatedByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2"
            },
            "sourceId": "f32d531e-df79-46b3-8932-cdd35f7a2264",
            "formerIds": [],
            "illPolicy": null,
            "callNumber": "QH104.5 .S54 N48 2022",
            "instanceId": "53c919d4-6f05-5259-93c5-60b2acf67f58",
            "holdingsType": {
              "id": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
              "name": "Monograph",
              "source": "folio"
            },
            "holdingsItems": [],
            "callNumberType": {
              "id": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "name": "Library of Congress classification",
              "source": "folio"
            },
            "holdingsTypeId": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
            "callNumberTypeId": "95467209-6d7b-468b-94df-0f5d7ad2747d",
            "electronicAccess": [],
            "bareHoldingsItems": [],
            "holdingsStatements": [],
            "statisticalCodeIds": [],
            "administrativeNotes": [],
            "effectiveLocationId": "4573e824-9273-4f13-972f-cff7bf504217",
            "permanentLocationId": "4573e824-9273-4f13-972f-cff7bf504217",
            "suppressFromDiscovery": false,
            "holdingsStatementsForIndexes": [],
            "holdingsStatementsForSupplements": []
          }, {
            "id": "705b4d1c-73c0-5ff8-a3d1-e47e32a9aa9e",
            "hrid": "ah14127680_2",
            "notes": [],
            "_version": 1,
            "location": {
              "effectiveLocation": {
                "id": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
                "code": "EAR-ATCIRCDESK",
                "name": "Earth Sciences Circ Desk",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": null,
                "library": {
                  "id": "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                  "code": "EARTH-SCI",
                  "name": "Branner Earth Sciences"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "permanentLocation": {
                "id": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
                "code": "EAR-ATCIRCDESK",
                "name": "Earth Sciences Circ Desk",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": null,
                "library": {
                  "id": "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                  "code": "EARTH-SCI",
                  "name": "Branner Earth Sciences"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "temporaryLocation": null
            },
            "metadata": {
              "createdDate": "2023-05-07T15:32:47.271Z",
              "updatedDate": "2023-05-07T15:32:47.271Z",
              "createdByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2",
              "updatedByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2"
            },
            "sourceId": "f32d531e-df79-46b3-8932-cdd35f7a2264",
            "formerIds": [],
            "illPolicy": null,
            "callNumber": "QH104.5 .S54 N48 2022",
            "instanceId": "53c919d4-6f05-5259-93c5-60b2acf67f58",
            "holdingsType": {
              "id": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
              "name": "Monograph",
              "source": "folio"
            },
            "holdingsItems": [],
            "callNumberType": {
              "id": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "name": "Library of Congress classification",
              "source": "folio"
            },
            "holdingsTypeId": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
            "callNumberTypeId": "95467209-6d7b-468b-94df-0f5d7ad2747d",
            "electronicAccess": [],
            "bareHoldingsItems": [],
            "holdingsStatements": [],
            "statisticalCodeIds": [],
            "administrativeNotes": [],
            "effectiveLocationId": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
            "permanentLocationId": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
            "suppressFromDiscovery": false,
            "holdingsStatementsForIndexes": [],
            "holdingsStatementsForSupplements": []
          }],
          "items": [{
            "id": "3b1135cb-696d-57df-b0f2-4b7c586f8a09",
            "hrid": "ai14127680_1_1",
            "notes": [],
            "status": "Available",
            "barcode": "36105232559851",
            "_version": 1,
            "location": {
              "effectiveLocation": {
                "id": "4573e824-9273-4f13-972f-cff7bf504217",
                "code": "GRE-STACKS",
                "name": "Green Library Stacks",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": {},
                "library": {
                  "id": "f6b5519e-88d9-413e-924d-9ed96255f72e",
                  "code": "GREEN",
                  "name": "Cecil H. Green"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "permanentLocation": {
                "id": "4573e824-9273-4f13-972f-cff7bf504217",
                "code": "GRE-STACKS",
                "name": "Green Library Stacks",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": {},
                "library": {
                  "id": "f6b5519e-88d9-413e-924d-9ed96255f72e",
                  "code": "GREEN",
                  "name": "Cecil H. Green"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "temporaryLocation": null
            },
            "metadata": {
              "createdDate": "2023-05-07T15:34:53.226Z",
              "updatedDate": "2023-05-07T15:34:53.226Z",
              "createdByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2",
              "updatedByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2"
            },
            "formerIds": [],
            "callNumber": {
              "typeId": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "typeName": "Library of Congress classification",
              "callNumber": "QH104.5 .S54 N48 2022"
            },
            "copyNumber": "1",
            "yearCaption": [],
            "materialType": "book",
            "callNumberType": {
              "id": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "name": "Library of Congress classification",
              "source": "folio"
            },
            "materialTypeId": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
            "numberOfPieces": "1",
            "circulationNotes": [],
            "electronicAccess": [],
            "holdingsRecordId": "33ad0ba1-e0ff-52c3-9c31-91b0f17dfa12",
            "itemDamagedStatus": null,
            "permanentLoanType": "Can circulate",
            "temporaryLoanType": null,
            "statisticalCodeIds": [],
            "administrativeNotes": [],
            "effectiveLocationId": "4573e824-9273-4f13-972f-cff7bf504217",
            "permanentLoanTypeId": "2b94c631-fca9-4892-a730-03ee529ffe27",
            "permanentLocationId": "4573e824-9273-4f13-972f-cff7bf504217",
            "suppressFromDiscovery": false,
            "effectiveShelvingOrder": "QH 3104.5 S54 N48 42022 11",
            "effectiveCallNumberComponents": {
              "typeId": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "callNumber": "QH104.5 .S54 N48 2022"
            }
          }, {
            "id": "b2a2b214-1014-5108-ad9c-d9094e43024a",
            "hrid": "ai14127680_2_1",
            "notes": [{
              "note": "POPULAR SCIENCE",
              "itemNoteTypeName": "Public"
            }],
            "status": "Available",
            "barcode": "36105232674379",
            "_version": 1,
            "location": {
              "effectiveLocation": {
                "id": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
                "code": "EAR-ATCIRCDESK",
                "name": "Earth Sciences Circ Desk",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": null,
                "library": {
                  "id": "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                  "code": "EARTH-SCI",
                  "name": "Branner Earth Sciences"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "permanentLocation": {
                "id": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
                "code": "EAR-ATCIRCDESK",
                "name": "Earth Sciences Circ Desk",
                "campus": {
                  "id": "c365047a-51f2-45ce-8601-e421ca3615c5",
                  "code": "SUL",
                  "name": "Stanford Libraries"
                },
                "details": null,
                "library": {
                  "id": "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                  "code": "EARTH-SCI",
                  "name": "Branner Earth Sciences"
                },
                "institution": {
                  "id": "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                  "code": "SU",
                  "name": "Stanford University"
                }
              },
              "temporaryLocation": null
            },
            "metadata": {
              "createdDate": "2023-05-07T15:34:53.226Z",
              "updatedDate": "2023-05-07T15:34:53.226Z",
              "createdByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2",
              "updatedByUserId": "3e2ed889-52f2-45ce-8a30-8767266f07d2"
            },
            "formerIds": [],
            "callNumber": {
              "typeId": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "typeName": "Library of Congress classification",
              "callNumber": "QH104.5 .S54 N48 2022"
            },
            "copyNumber": "1",
            "yearCaption": [],
            "materialType": "book",
            "callNumberType": {
              "id": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "name": "Library of Congress classification",
              "source": "folio"
            },
            "materialTypeId": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
            "numberOfPieces": "1",
            "circulationNotes": [],
            "electronicAccess": [],
            "holdingsRecordId": "705b4d1c-73c0-5ff8-a3d1-e47e32a9aa9e",
            "itemDamagedStatus": null,
            "permanentLoanType": "Can circulate",
            "temporaryLoanType": null,
            "statisticalCodeIds": [],
            "administrativeNotes": [],
            "effectiveLocationId": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
            "permanentLoanTypeId": "2b94c631-fca9-4892-a730-03ee529ffe27",
            "permanentLocationId": "cfe97d28-bd5c-48ce-a2d9-00c1ef96cf49",
            "suppressFromDiscovery": false,
            "effectiveShelvingOrder": "QH 3104.5 S54 N48 42022 11",
            "effectiveCallNumberComponents": {
              "typeId": "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "callNumber": "QH104.5 .S54 N48 2022"
            }
          }]
        }
      JSON
    end

    let(:document) { SolrDocument.new(holdings_json_struct: [JSON.parse(holdings_json_struct)]) }

    describe '#find_holding' do
      subject(:holding) { document.find_holding(library_code: 'EARTH-SCI', location: 'ATCIRCDESK') }

      it "finds by location" do
        expect(holding.id).to eq '705b4d1c-73c0-5ff8-a3d1-e47e32a9aa9e'
      end
    end

    describe '#find_item' do
      subject(:item) { document.find_item(barcode: '36105232674379') }

      it "finds by barcode" do
        expect(item.id).to eq 'b2a2b214-1014-5108-ad9c-d9094e43024a'
      end
    end
  end
end
