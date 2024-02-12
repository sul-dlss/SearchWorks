# frozen_string_literal: true

require "rails_helper"

RSpec.describe Librarian::ItemDetails::TableComponent, type: :component do
  let(:component) { described_class.new(document:) }

  let(:document) { SolrDocument.new(item_display_struct:, holdings_json_struct:) }
  let(:item_display_struct) do
    [
      {
        "id" => "502863a5-b53c-58cf-9305-03846673ef14",
        "barcode" => "36105223688552",
        "library" => "EARTH-SCI",
        "home_location" => "EAR-STACKS",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "EAR-STACKS",
        "status" => "Available",
        "effective_location_id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "2b94c631-fca9-4892-a730-03ee529ffe27",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "9773449d-90d7-5108-b73d-c532e69de8cd",
        "barcode" => "36105226059181",
        "library" => "EARTH-SCI",
        "home_location" => "EAR-STACKS",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "EAR-STACKS",
        "status" => "Available",
        "effective_location_id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "2b94c631-fca9-4892-a730-03ee529ffe27",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "99c01199-b248-58a7-a452-d7219c2cb817",
        "barcode" => "36105225598411",
        "library" => "RUMSEY-MAP",
        "home_location" => "RUM-W7-STK-REF",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "RUM-W7-STK-REF",
        "status" => "Available",
        "effective_location_id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "ad35d1a4-067e-522d-99e4-5be7b1358668",
        "barcode" => "36105218665789",
        "library" => "GREEN",
        "home_location" => "GRE-STACKS",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "GRE-STACKS",
        "status" => "Available",
        "effective_location_id" => "4573e824-9273-4f13-972f-cff7bf504217",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "2b94c631-fca9-4892-a730-03ee529ffe27",
        "lopped_callnumber" => "E179 .F84 1990",
        "shelfkey" => "lc e   0179.000000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}zzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179 .F84 1990",
        "full_shelfkey" => "lc e   0179.000000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "be2de21c-e500-5334-862a-e22fcc9d2776",
        "barcode" => "36105226157456",
        "library" => "RUMSEY-MAP",
        "home_location" => "RUM-W7-STK-REF",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "RUM-W7-STK-REF",
        "status" => "Available",
        "effective_location_id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "db5de9be-8e47-540a-b9ce-1f0940e21169",
        "barcode" => "36105226146277",
        "library" => "EARTH-SCI",
        "home_location" => "EAR-STACKS",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "EAR-STACKS",
        "status" => "Available",
        "effective_location_id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "2b94c631-fca9-4892-a730-03ee529ffe27",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "dda764bf-b634-5253-a1b8-00abdc7cd60a",
        "barcode" => "36105225598403",
        "library" => "RUMSEY-MAP",
        "home_location" => "RUM-W7-STK-REF",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "RUM-W7-STK-REF",
        "status" => "Available",
        "effective_location_id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "df0d7b8b-23f8-50a5-97d0-d6ed95173eac",
        "barcode" => "36105225598080",
        "library" => "RUMSEY-MAP",
        "home_location" => "RUM-W7-STK-REF",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "RUM-W7-STK-REF",
        "status" => "Available",
        "effective_location_id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
        "lopped_callnumber" => "E179.5 .F84 1990",
        "shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}uzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179.5 .F84 1990",
        "full_shelfkey" => "lc e   0179.500000 f0.840000 001990",
        "scheme" => "LC"
      },
      {
        "id" => "e4cdaaa5-9ed2-57b3-aede-ba9f69aa9f23",
        "barcode" => "36105005105536",
        "library" => "GREEN",
        "home_location" => "GRE-STACKS",
        "current_location" => nil,
        "type" => "book",
        "note" => nil,
        "instance_id" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
        "instance_hrid" => "a2800276",
        "temporary_location_code" => nil,
        "permanent_location_code" => "GRE-STACKS",
        "status" => "Available",
        "effective_location_id" => "4573e824-9273-4f13-972f-cff7bf504217",
        "material_type_id" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
        "loan_type_id" => "2b94c631-fca9-4892-a730-03ee529ffe27",
        "lopped_callnumber" => "E179 .F84 1990",
        "shelfkey" => "lc e   0179.000000 f0.840000 001990",
        "reverse_shelfkey" => "en~l~~~zysq}zzzzzz~kz}rvzzzz~zzyqqz~~~~~~~~~~~~~~~",
        "callnumber" => "E179 .F84 1990",
        "full_shelfkey" => "lc e   0179.000000 f0.840000 001990",
        "scheme" => "LC"
      }
    ]
  end

  subject(:page) { render_inline(component) }

  context "when the record has items in three locations" do
    let(:holdings_json_struct) do
      [
        {
          "holdings" => [
            {
              "id" => "37144f55-afba-5af8-b9d4-0d3a412cd45c",
              "hrid" => "ah2800276_3",
              "notes" => [],
              "_version" => 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:14:38.544Z",
                "updatedDate" => "2023-08-21T04:14:38.544Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "sourceId" => "f32d531e-df79-46b3-8932-cdd35f7a2264",
              "boundWith" => nil,
              "formerIds" => [],
              "illPolicy" => nil,
              "callNumber" => "E179.5 .F84 1990",
              "instanceId" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
              "holdingsType" => {
                "id" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
                "name" => "Book",
                "source" => "local"
              },
              "holdingsItems" => [],
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "holdingsTypeId" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
              "callNumberTypeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "electronicAccess" => [],
              "bareHoldingsItems" => [],
              discoverySuppress: false,
              "holdingsStatements" => [],
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              "permanentLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              suppressFromDiscovery: false,
              "holdingsStatementsForIndexes" => [],
              "holdingsStatementsForSupplements" => [],
              "location" => {
                "effectiveLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                },
                "permanentLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              }
            },
            {
              "id" => "8e909bd9-aa6e-50e0-9b32-d8d213d16d89",
              "hrid" => "ah2800276_1",
              "notes" => [],
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:14:38.544Z",
                "updatedDate" => "2023-08-21T04:14:38.544Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "sourceId" => "f32d531e-df79-46b3-8932-cdd35f7a2264",
              "boundWith" => nil,
              "formerIds" => [],
              "illPolicy" => nil,
              "callNumber" => "E179 .F84 1990",
              "instanceId" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
              "holdingsType" => {
                "id" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
                "name" => "Book",
                "source" => "local"
              },
              "holdingsItems" => [],
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "holdingsTypeId" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
              "callNumberTypeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "electronicAccess" => [],
              "bareHoldingsItems" => [],
              discoverySuppress: false,
              "holdingsStatements" => [],
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "4573e824-9273-4f13-972f-cff7bf504217",
              "permanentLocationId" => "4573e824-9273-4f13-972f-cff7bf504217",
              suppressFromDiscovery: false,
              "holdingsStatementsForIndexes" => [],
              "holdingsStatementsForSupplements" => [],
              "location" => {
                "effectiveLocation" => {
                  "id" => "4573e824-9273-4f13-972f-cff7bf504217",
                  "code" => "GRE-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "stackmapBaseUrl" => "https://stanford.stackmap.com/json/"
                  },
                  "library" => {
                    "id" => "f6b5519e-88d9-413e-924d-9ed96255f72e",
                    "code" => "GREEN",
                    "name" => "Green Library"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                },
                "permanentLocation" => {
                  "id" => "4573e824-9273-4f13-972f-cff7bf504217",
                  "code" => "GRE-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "stackmapBaseUrl" => "https://stanford.stackmap.com/json/"
                  },
                  "library" => {
                    "id" => "f6b5519e-88d9-413e-924d-9ed96255f72e",
                    "code" => "GREEN",
                    "name" => "Green Library"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              }
            },
            {
              "id" => "c51c74d4-8a6f-52f2-a1c7-006fd0af7734",
              "hrid" => "ah2800276_2",
              "notes" => [],
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:14:38.544Z",
                "updatedDate" => "2023-08-21T04:14:38.544Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "sourceId" => "f32d531e-df79-46b3-8932-cdd35f7a2264",
              "boundWith" => nil,
              "formerIds" => [],
              "illPolicy" => nil,
              "callNumber" => "E179.5 .F84 1990",
              "instanceId" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
              "holdingsType" => {
                "id" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
                "name" => "Book",
                "source" => "local"
              },
              "holdingsItems" => [],
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "holdingsTypeId" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
              "callNumberTypeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "electronicAccess" => [],
              "bareHoldingsItems" => [],
              discoverySuppress: false,
              "holdingsStatements" => [],
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
              "permanentLocationId" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
              suppressFromDiscovery: false,
              "holdingsStatementsForIndexes" => [],
              "holdingsStatementsForSupplements" => [],
              "location" => {
                "effectiveLocation" => {
                  "id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
                  "code" => "EAR-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {},
                  "library" => {
                    "id" => "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                    "code" => "EARTH-SCI",
                    "name" => "Earth Sciences Library (Branner)"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                },
                "permanentLocation" => {
                  "id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
                  "code" => "EAR-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {},
                  "library" => {
                    "id" => "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                    "code" => "EARTH-SCI",
                    "name" => "Earth Sciences Library (Branner)"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              }
            }
          ],
          "items" => [
            {
              "id" => "502863a5-b53c-58cf-9305-03846673ef14",
              "hrid" => "ai2800276_2_5",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105223688552",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "4",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "c51c74d4-8a6f-52f2-a1c7-006fd0af7734",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Can circulate",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
              "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 14",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
                  "code" => "EAR-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {},
                  "library" => {
                    "id" => "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                    "code" => "EARTH-SCI",
                    "name" => "Earth Sciences Library (Branner)"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "9773449d-90d7-5108-b73d-c532e69de8cd",
              "hrid" => "ai2800276_2_1",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105226059181",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "1",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "c51c74d4-8a6f-52f2-a1c7-006fd0af7734",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Can circulate",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
              "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 11",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
                  "code" => "EAR-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {},
                  "library" => {
                    "id" => "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                    "code" => "EARTH-SCI",
                    "name" => "Earth Sciences Library (Branner)"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "99c01199-b248-58a7-a452-d7219c2cb817",
              "hrid" => "ai2800276_3_7",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105225598411",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "4",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "37144f55-afba-5af8-b9d4-0d3a412cd45c",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Non-circulating",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              "permanentLoanTypeId" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 14",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "ad35d1a4-067e-522d-99e4-5be7b1358668",
              "hrid" => "ai2800276_1_3",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105218665789",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179 .F84 1990"
              },
              "copyNumber" => "2",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "8e909bd9-aa6e-50e0-9b32-d8d213d16d89",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Can circulate",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "4573e824-9273-4f13-972f-cff7bf504217",
              "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179 F84 41990 12",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "4573e824-9273-4f13-972f-cff7bf504217",
                  "code" => "GRE-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "stackmapBaseUrl" => "https://stanford.stackmap.com/json/"
                  },
                  "library" => {
                    "id" => "f6b5519e-88d9-413e-924d-9ed96255f72e",
                    "code" => "GREEN",
                    "name" => "Green Library"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "be2de21c-e500-5334-862a-e22fcc9d2776",
              "hrid" => "ai2800276_3_5",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105226157456",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "3",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "37144f55-afba-5af8-b9d4-0d3a412cd45c",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Non-circulating",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              "permanentLoanTypeId" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 13",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "db5de9be-8e47-540a-b9ce-1f0940e21169",
              "hrid" => "ai2800276_2_3",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105226146277",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "2",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "c51c74d4-8a6f-52f2-a1c7-006fd0af7734",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Can circulate",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
              "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 12",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "13c2ee3e-5d88-453e-bb64-890e2936bebf",
                  "code" => "EAR-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {},
                  "library" => {
                    "id" => "96630997-201d-49b3-b8d5-e4ba43a6cde8",
                    "code" => "EARTH-SCI",
                    "name" => "Earth Sciences Library (Branner)"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "dda764bf-b634-5253-a1b8-00abdc7cd60a",
              "hrid" => "ai2800276_3_1",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105225598403",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "1",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "37144f55-afba-5af8-b9d4-0d3a412cd45c",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Non-circulating",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              "permanentLoanTypeId" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 11",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "df0d7b8b-23f8-50a5-97d0-d6ed95173eac",
              "hrid" => "ai2800276_3_3",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105225598080",
              "request" => nil,
              _version: 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-08-21T04:16:06.255Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179.5 .F84 1990"
              },
              "copyNumber" => "2",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "37144f55-afba-5af8-b9d4-0d3a412cd45c",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Non-circulating",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              "permanentLoanTypeId" => "52d7b849-b6d8-4fb3-b2ab-a9b0eb41b6fd",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179.5 F84 41990 12",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179.5 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            },
            {
              "id" => "e4cdaaa5-9ed2-57b3-aede-ba9f69aa9f23",
              "hrid" => "ai2800276_1_1",
              "notes" => [],
              "status" => "Available",
              "barcode" => "36105005105536",
              "request" => nil,
              _version: 2,
              "metadata" => {
                "createdDate" => "2023-08-21T04:16:06.255Z",
                "updatedDate" => "2023-09-29T20:49:04.124Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "formerIds" => [],
              "callNumber" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "typeName" => "Library of Congress classification",
                "callNumber" => "E179 .F84 1990"
              },
              "copyNumber" => "1",
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "numberOfPieces" => "1",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "8e909bd9-aa6e-50e0-9b32-d8d213d16d89",
              discoverySuppress: false,
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Can circulate",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "4573e824-9273-4f13-972f-cff7bf504217",
              "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
              suppressFromDiscovery: false,
              "effectiveShelvingOrder" => "E 3179 F84 41990 11",
              "effectiveCallNumberComponents" => {
                "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "callNumber" => "E179 .F84 1990"
              },
              "location" => {
                "effectiveLocation" => {
                  "id" => "4573e824-9273-4f13-972f-cff7bf504217",
                  "code" => "GRE-STACKS",
                  "name" => "Stacks",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "stackmapBaseUrl" => "https://stanford.stackmap.com/json/"
                  },
                  "library" => {
                    "id" => "f6b5519e-88d9-413e-924d-9ed96255f72e",
                    "code" => "GREEN",
                    "name" => "Green Library"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              },
              "courses" => []
            }
          ]
        }
      ]
    end

    it 'has three tables' do
      # within('table:first-of-type do # https://github.com/ViewComponent/view_component/issues/1910
      expect(page).to have_content '36105218665789'
      expect(page).to have_content '36105005105536'
      # end
      # within('table:nth-of-type(2)') do # https://github.com/ViewComponent/view_component/issues/1910
      expect(page).to have_content '36105225598411'
      expect(page).to have_content '36105225598403'
      expect(page).to have_content '36105225598080'
      expect(page).to have_content '36105226157456'
      # end

      # within('table:nth-of-type(3)') do # https://github.com/ViewComponent/view_component/issues/1910
      expect(page).to have_content '36105223688552'
      expect(page).to have_content '36105226146277'
      expect(page).to have_content '36105226059181'
      # end
    end
  end

  context "when the record has no items" do
    let(:holdings_json_struct) do
      [
        {
          "holdings" => [
            {
              "id" => "37144f55-afba-5af8-b9d4-0d3a412cd45c",
              "hrid" => "ah2800276_3",
              "notes" => [],
              "_version" => 1,
              "metadata" => {
                "createdDate" => "2023-08-21T04:14:38.544Z",
                "updatedDate" => "2023-08-21T04:14:38.544Z",
                "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
                "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766"
              },
              "sourceId" => "f32d531e-df79-46b3-8932-cdd35f7a2264",
              "boundWith" => nil,
              "formerIds" => [],
              "illPolicy" => nil,
              "callNumber" => "E179.5 .F84 1990",
              "instanceId" => "3e6a2511-5b6b-5c2e-aa91-57cd3c6f3392",
              "holdingsType" => {
                "id" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
                "name" => "Book",
                "source" => "local"
              },
              "holdingsItems" => [],
              "callNumberType" => {
                "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                "name" => "Library of Congress classification",
                "source" => "folio"
              },
              "holdingsTypeId" => "5684e4a3-9279-4463-b6ee-20ae21bbec07",
              "callNumberTypeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
              "electronicAccess" => [],
              "bareHoldingsItems" => [],
              discoverySuppress: false,
              "holdingsStatements" => [],
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              "permanentLocationId" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
              suppressFromDiscovery: false,
              "holdingsStatementsForIndexes" => [],
              "holdingsStatementsForSupplements" => [],
              "location" => {
                "effectiveLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                },
                "permanentLocation" => {
                  "id" => "a480fa70-db7a-4e4d-b4fd-ab986e388d50",
                  "code" => "RUM-W7-STK-REF",
                  "name" => "Map Center (W7 reference)",
                  "campus" => {
                    "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                    "code" => "SUL",
                    "name" => "Stanford Libraries"
                  },
                  "details" => {
                    "pageAeonSite" => "RUMSEY"
                  },
                  "library" => {
                    "id" => "05241c96-6541-41ed-b2ad-61a126d62c2d",
                    "code" => "RUMSEY-MAP",
                    "name" => "David Rumsey Map Center"
                  },
                  "isActive" => true,
                  "institution" => {
                    "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    "code" => "SU",
                    "name" => "Stanford University"
                  }
                }
              }
            }
          ],
          "items" => []
        }
      ]
    end

    it "doesn't render" do
      expect(page).to have_no_selector("body")
    end
  end

  context "when the items have no call number or barcodes (On order)" do
    let(:holdings_json_struct) do
      [
        {
          "holdings" => [
            { "id" => "034911a3-10f0-4605-8278-7ddb498fb446",
              "hrid" => "ho00000072427",
              "notes" => [],
              "_version" => 2,
              "metadata" =>
             { "createdDate" => "2024-02-14T20:14:01.361Z",
               "updatedDate" => "2024-02-14T20:14:02.068Z",
               "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
               "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766" },
              "sourceId" => "f32d531e-df79-46b3-8932-cdd35f7a2264",
              "boundWith" => nil,
              "formerIds" => [],
              "illPolicy" => nil,
              "instanceId" => "9e6e95cd-2d8e-46fa-a05a-9721638ba530",
              "holdingsType" => { "id" => "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5", "name" => "Physical", "source" => "folio" },
              "holdingsItems" => [],
              "callNumberType" => nil,
              "holdingsTypeId" => "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5",
              "electronicAccess" => [],
              "bareHoldingsItems" => [],
              "holdingsStatements" => [],
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "0edeef57-074a-4f07-aee2-9f09d55e65c3",
              "permanentLocationId" => "0edeef57-074a-4f07-aee2-9f09d55e65c3",
              "suppressFromDiscovery" => false,
              "holdingsStatementsForIndexes" => [],
              "holdingsStatementsForSupplements" => [],
              "location" =>
             { "effectiveLocation" =>
               { "id" => "0edeef57-074a-4f07-aee2-9f09d55e65c3",
                 "code" => "LAW-BASEMENT",
                 "name" => "Basement",
                 "campus" => { "id" => "7003123d-ef65-45f6-b469-d2b9839e1bb3", "code" => "LAW", "name" => "Law School" },
                 "details" => {},
                 "library" => { "id" => "7e4c05e3-1ce6-427d-b9ce-03464245cd78", "code" => "LAW", "name" => "Law Library (Crown)" },
                 "isActive" => true,
                 "institution" => { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929", "code" => "SU", "name" => "Stanford University" } },
               "permanentLocation" =>
               { "id" => "0edeef57-074a-4f07-aee2-9f09d55e65c3",
                 "code" => "LAW-BASEMENT",
                 "name" => "Basement",
                 "campus" => { "id" => "7003123d-ef65-45f6-b469-d2b9839e1bb3", "code" => "LAW", "name" => "Law School" },
                 "details" => {},
                 "library" => { "id" => "7e4c05e3-1ce6-427d-b9ce-03464245cd78", "code" => "LAW", "name" => "Law Library (Crown)" },
                 "isActive" => true,
                 "institution" => { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929", "code" => "SU", "name" => "Stanford University" } } } }
          ],
          "items" => [
            { "id" => "2597aac2-ff7c-489d-bd12-04b595e4f990",
              "hrid" => "it00000071081",
              "tags" => { "tagList" => [] },
              "notes" => [],
              "status" => "On order",
              "request" => nil,
              "_version" => 4,
              "metadata" =>
     { "createdDate" => "2024-02-14T20:14:01.404Z",
       "updatedDate" => "2024-02-14T20:14:02.235Z",
       "createdByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766",
       "updatedByUserId" => "58d0aaf6-dcda-4d5e-92da-012e6b7dd766" },
              "formerIds" => [],
              "callNumber" => { "typeName" => nil },
              "yearCaption" => [],
              "materialType" => "book",
              "callNumberType" => nil,
              "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
              "circulationNotes" => [],
              "electronicAccess" => [],
              "holdingsRecordId" => "034911a3-10f0-4605-8278-7ddb498fb446",
              "itemDamagedStatus" => nil,
              "permanentLoanType" => "Can circulate",
              "temporaryLoanType" => nil,
              "statisticalCodeIds" => [],
              "administrativeNotes" => [],
              "effectiveLocationId" => "0edeef57-074a-4f07-aee2-9f09d55e65c3",
              "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
              "suppressFromDiscovery" => false,
              "purchaseOrderLineIdentifier" => "8aec77f5-4a3f-40d8-9de5-bf0eae5ec510",
              "effectiveCallNumberComponents" => {},
              "location" =>
     { "effectiveLocation" =>
       { "id" => "0edeef57-074a-4f07-aee2-9f09d55e65c3",
         "code" => "LAW-BASEMENT",
         "name" => "Basement",
         "campus" => { "id" => "7003123d-ef65-45f6-b469-d2b9839e1bb3", "code" => "LAW", "name" => "Law School" },
         "details" => {},
         "library" => { "id" => "7e4c05e3-1ce6-427d-b9ce-03464245cd78", "code" => "LAW", "name" => "Law Library (Crown)" },
         "isActive" => true,
         "institution" => { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929", "code" => "SU", "name" => "Stanford University" } } },
              "courses" => [] }
          ]
        }
      ]
    end

    it "has replacement text" do
      expect(page).to have_content 'No call number'
      expect(page).to have_content 'No barcode'
    end
  end
end
