require "spec_helper"

RSpec.describe Holdings::Status do
  let(:status) { Holdings::Status.new(item) }
  let(:item) { Holdings::Item.new('barcode -|- GREEN -|- STACKS -|- -|-', document:) }
  let(:document) { SolrDocument.new }

  describe "::Available" do
    before do
      allow_any_instance_of(Holdings::Status::Available).to receive(:available?).and_return(true)
    end

    it "should have the available class" do
      expect(status.availability_class).to eq 'available'
    end
    it "should have the available status text" do
      expect(status.status_text).to eq 'Available'
    end
    it "should be available" do
      expect(status).to be_available
    end
  end

  describe "::Noncirc" do
    before do
      allow_any_instance_of(Holdings::Status::Noncirc).to receive(:noncirc?).and_return(true)
    end

    it "should have the noncirc class" do
      expect(status.availability_class).to eq 'noncirc'
    end
    it "should have the noncirc status text" do
      expect(status.status_text).to eq 'In-library use'
    end
    it "should be noncirc" do
      expect(status).to be_noncirc
    end
  end

  describe "::NoncircPage" do
    before do
      allow_any_instance_of(Holdings::Status::NoncircPage).to receive(:noncirc_page?).and_return(true)
    end

    it "should have the noncirc_page class" do
      expect(status.availability_class).to eq 'noncirc_page'
    end
    it "should have the noncirc_page status text" do
      expect(status.status_text).to eq 'In-library use'
    end
    it "should be noncirc_page" do
      expect(status).to be_noncirc_page
    end
  end

  describe "::Pageable" do
    before do
      allow_any_instance_of(Holdings::Status::Pageable).to receive(:pageable?).and_return(true)
    end

    it "should have the page class" do
      expect(status.availability_class).to eq 'page'
    end
    it "should have the page status text" do
      expect(status.status_text).to eq 'Available'
    end
    it "should be pageable" do
      expect(status).to be_pageable
    end
  end

  describe "CDL" do
    let(:status) { Holdings::Status.new(OpenStruct.new(home_location: 'CDL')) }

    it "should have the unavailable class" do
      expect(status.availability_class).to eq 'unavailable cdl'
    end
    it "should have the unavailable status text" do
      expect(status.status_text).to eq 'Physical copy unavailable'
    end
    it "should be cdl" do
      expect(status).to be_cdl
    end
  end

  describe "::Unavailable" do
    before do
      allow_any_instance_of(Holdings::Status::Unavailable).to receive(:unavailable?).and_return(true)
    end

    it "should have the unavailable class" do
      expect(status.availability_class).to eq 'unavailable'
    end
    it "should have the unavailable status text" do
      expect(status.status_text).to eq 'Unavailable'
    end
    it "should be unavailable" do
      expect(status).to be_unavailable
    end
  end

  describe "::Unknown" do
    before do
      allow_any_instance_of(Holdings::Status::Unknown).to receive(:unknown?).and_return(true)
    end

    it "should have the unavailable class" do
      expect(status.availability_class).to eq 'unknown'
    end
    it "should have the unknown status text" do
      expect(status.status_text).to eq 'Unknown'
    end
    it "should be unavailable" do
      expect(status).to be_unknown
    end
  end

  describe "unknown" do
    it "defaults to an unknown availability class" do
      expect(status.availability_class).to eq 'unknown'
    end
  end

  context 'when using Folio' do
    let(:item) { Holdings::Item.new('36105231525416 -|- GREEN -|- STACKS -|- -|-', document:) }
    let(:document) { SolrDocument.new(holdings_json_struct:) }
    let(:holdings_json_struct) do
      [{ "holdings" =>
        [{ "id" => "b139b4cc-daf2-5b5b-ad1b-8ad4b8911577",
           "hrid" => "ah13849343_1",
           "_version" => 1,
           "location" =>
           { "effectiveLocation" =>
             { "id" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
               "code" => "SAL3-STACKS",
               "name" => "Off-campus storage",
               "campus" =>
               { "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                 "code" => "SUL",
                 "name" => "Stanford Libraries" },
               "details" => nil,
               "library" =>
               { "id" => "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                 "code" => "SAL3",
                 "name" => "Stanford Auxiliary Library 3" },
               "isActive" => true,
               "institution" =>
               { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                 "code" => "SU",
                 "name" => "Stanford University" } },
             "permanentLocation" =>
             { "id" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
               "code" => "SAL3-STACKS",
               "name" => "Off-campus storage",
               "campus" =>
               { "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                 "code" => "SUL",
                 "name" => "Stanford Libraries" },
               "details" => nil,
               "library" =>
               { "id" => "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                 "code" => "SAL3",
                 "name" => "Stanford Auxiliary Library 3" },
               "isActive" => true,
               "institution" =>
               { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                 "code" => "SU",
                 "name" => "Stanford University" } },
             "temporaryLocation" => nil },
           "metadata" =>
           { "createdDate" => "2023-05-07T14:37:29.310Z",
             "updatedDate" => "2023-05-07T14:37:29.310Z",
             "createdByUserId" => "3e2ed889-52f2-45ce-8a30-8767266f07d2",
             "updatedByUserId" => "3e2ed889-52f2-45ce-8a30-8767266f07d2" },
           "sourceId" => "f32d531e-df79-46b3-8932-cdd35f7a2264",
           "callNumber" => "GT2918 .L45 2020",
           "instanceId" => "1a5b1d83-1ac9-5e72-bd6d-b58aee23306c",
           "holdingsType" =>
           { "id" => "03c9c400-b9e3-4a07-ac0e-05ab470233ed", "name" => "Monograph", "source" => "folio" },
           "callNumberType" =>
           { "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
             "name" => "Library of Congress classification",
             "source" => "folio" },
           "effectiveLocationId" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
           "permanentLocationId" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
           "suppressFromDiscovery" => false }],
         "items" =>
        [{ "id" => "59ecf566-5789-588e-b68c-43e023bce67f",
           "hrid" => "ai13849343_1_1",
           "status" => "Available",
           "barcode" => "36105231525416",
           "location" =>
           { "effectiveLocation" =>
             { "id" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
               "code" => "SAL3-STACKS",
               "name" => "Off-campus storage",
               "campus" =>
               { "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                 "code" => "SUL",
                 "name" => "Stanford Libraries" },
               "details" => nil,
               "library" =>
               { "id" => "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                 "code" => "SAL3",
                 "name" => "Stanford Auxiliary Library 3" },
               "isActive" => true,
               "institution" =>
               { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                 "code" => "SU",
                 "name" => "Stanford University" } },
             "permanentLocation" =>
             { "id" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
               "code" => "SAL3-STACKS",
               "name" => "Off-campus storage",
               "campus" =>
               { "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                 "code" => "SUL",
                 "name" => "Stanford Libraries" },
               "details" => nil,
               "library" =>
               { "id" => "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                 "code" => "SAL3",
                 "name" => "Stanford Auxiliary Library 3" },
               "isActive" => true,
               "institution" =>
               { "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                 "code" => "SU",
                 "name" => "Stanford University" } },
             "temporaryLocation" => nil },
           "materialType" => "book",
           "materialTypeId" => "1a54b431-2e4f-452d-9cae-9cee66c9a892",
           "permanentLoanType" => "Can circulate",
           "effectiveLocationId" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
           "permanentLoanTypeId" => "2b94c631-fca9-4892-a730-03ee529ffe27",
           "permanentLocationId" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2" }] }]
    end

    before do
      allow(Settings.features).to receive(:folio).and_return(true)
    end

    describe '#availability_class' do
      subject { status.availability_class }

      context 'when it is pageable' do
        it { is_expected.to eq 'page' }
      end
    end
  end

  describe 'precedence' do
    subject { Holdings::Status.new(callnumber) }

    describe 'unavailable' do
      let(:callnumber) do
        double(
          'Call number',
          library: 'SAL3',
          home_location: 'STACKS',
          current_location: double('Location', code: 'LOST-ASSUM'),
          type: 'STACKS'
        )
      end

      it 'takes precedence over things like page' do
        expect(subject.availability_class).to eq 'unavailable'
      end
    end
  end

  describe '#as_json' do
    let(:as_json) { status.as_json }

    it 'should return a json hash with the availability class and status text' do
      expect(as_json).to have_key :availability_class
      expect(as_json).to have_key :status_text
    end
  end
end
