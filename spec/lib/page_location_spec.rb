# frozen_string_literal: true

require 'rails_helper'
require 'page_location'

RSpec.describe PageLocation do
  let(:params) { { f: { format: ["Database"] } } }
  let(:controller) { CatalogController.new }
  let(:action) { 'index' }
  let(:search_state) { Blacklight::SearchState.new(params, controller.blacklight_config, controller) }

  subject(:page_location) { PageLocation.new(search_state) }

  before do
    allow(controller).to receive_messages(action_name: action, params:)
  end

  describe '#access_point?' do
    subject { page_location.access_point? }

    context 'when on the catalog index page' do
      it { is_expected.to be true }
    end

    context 'on another page' do
      let(:action) { 'show' }

      it { is_expected.to be false }
    end
  end

  describe "#access_point" do
    subject(:access_point) { page_location.access_point }

    context 'when not on the catalog controller#index page' do
      let(:action) { 'show' }

      it { is_expected.to be_nil }
    end

    context "when on the CatalogController#index" do
      let(:params) { {} }

      describe "databases" do
        describe "old format facet" do
          before { params[:f] = { format: ["Database"] } }

          it "should be defined when a facet is selected" do
            expect(access_point).to eq :databases
          end

          it "should be defined when an additional format facet is selected" do
            params[:f][:format] << "Book"
            expect(access_point).to eq :databases
          end
          it "should be defined when searching within selected" do
            params[:q] = "My Query"
            expect(access_point).to eq :databases
          end
          it "should not be defined when a non-database format facet is selected" do
            params[:f] = { access: "Online" }
            expect(access_point).to be_nil
          end
        end

        describe "new resource type facet" do
          before { params[:f] = { format_main_ssim: ["Database"] } }

          it "should be defined when a facet is selected" do
            expect(access_point).to eq :databases
          end
          it "should be defined when an additional format facet is selected" do
            params[:f][:format_main_ssim] << "Book"
            expect(access_point).to eq :databases
          end
          it "should be defined when searching within selected" do
            params[:q] = "My Query"
            expect(access_point).to eq :databases
          end
          it "should not be defined when a non-database format facet is selected" do
            params[:f] = { access: "Online" }
            expect(access_point).to be_nil
          end
        end
      end

      describe "course reserve" do
        let(:course) { CourseReserve.all.first }

        before { params[:f] = { courses_folio_id_ssim: [course.id] } }

        context 'when courses_folio_id_ssim facet is selected' do
          it { is_expected.to eq :course_reserve }
        end

        context 'when another facet is selected' do
          before do
            params[:f][:format] = "Book"
          end

          it { is_expected.to eq :course_reserve }
        end

        context 'when searching with course reserve' do
          before do
            params[:q] = "My Query"
          end

          it { is_expected.to eq :course_reserve }
        end

        context 'when courses_folio_id_ssim facet is not selected' do
          before do
            params[:f] = { access: "Online" }
          end

          it { is_expected.to be_nil }
        end
      end

      context "when the collection filter is set" do
        context 'when collection is present' do
          let(:params) { { f: { collection: ['29'] } } }

          it { is_expected.to eq :collection }
        end

        context 'when collection is not present' do
          it { is_expected.to be_nil }
        end

        context 'when collection is present and is sirsi' do
          let(:params) { { f: { collection: ['sirsi'] } } }

          it { is_expected.to be_nil }
        end
      end

      describe 'digital_collections' do
        before { params[:f] = { collection_type: ["Digital Collection"] } }

        it 'should be defined when the collection_type is digital collection' do
          expect(access_point).to eq :digital_collections
        end
        it "should not be defined when digital_collection is not present" do
          params[:f] = {}
          expect(access_point).to be_nil
        end
        it "should not be defined when digital_collection is a different value" do
          params[:f] = { collection_type: ["Something Else"] }
          expect(access_point).to be_nil
        end
      end

      describe 'sdr' do
        before { params[:f] = { building_facet: ["Stanford Digital Repository"] } }

        it 'should be defined when the building facet is Stanford Digital Repository' do
          expect(access_point).to eq :sdr
        end
        it "should not be defined when Stanford Digital Repository is not present" do
          params[:f] = {}
          expect(access_point).to be_nil
        end
        it "should not be defined when building_facet is a different value" do
          params[:f] = { building_facet: ["Green Library"] }
          expect(access_point).to be_nil
        end
      end

      describe 'dissertation_theses' do
        before { params[:f] = { genre_ssim: ['Thesis/Dissertation'] } }

        it 'should be defined when genre facet is "Thesis/Dissertation"' do
          expect(access_point).to eq :dissertation_theses
        end
        it 'should not be defined when Thesis/Dissertation is not present' do
          params[:f] = {}
          expect(access_point).to be_nil
        end
        it 'should not be defined when genre_ssim is another value' do
          params[:f] = { genre_ssim: ['Cat Tricks'] }
          expect(access_point).to be_nil
        end
      end

      describe 'bookplate_fund' do
        before { params[:f] = { fund_facet: ['ABC123'] } }

        it 'is defined when the fund_facet is present' do
          expect(access_point).to eq :bookplate_fund
        end

        it 'is defined when the fund_facet is empty' do
          params[:f] = { fund_facet: [] }
          expect(access_point).to be_nil
        end
      end

      describe 'government_documents' do
        before { params[:f] = { genre_ssim: ['Government document', 'Something else'] } }

        it 'is deined when the genre_ssim includes "Government document"' do
          expect(access_point).to eq :government_documents
        end

        it 'is nil when the genre_ssim is something else' do
          params[:f][:genre_ssim] = ['Something else']
          expect(access_point).to be_nil
        end
      end

      describe 'iiif_resources' do
        before { params[:f] = { iiif_resources: ['available'] } }

        it 'is defined when the iiif_resources includes "available"' do
          expect(access_point).to eq :iiif_resources
        end

        it 'is nil when the iiif_resources is something else' do
          params[:f][:iiif_resources] = ['Something else']
          expect(access_point).to be_nil
        end
      end
    end
  end

  describe '#collection?' do
    subject { page_location.collection? }

    context "when the collection filter is set" do
      let(:params) { { f: { collection: ['29'] } } }

      it { is_expected.to be true }
    end
  end

  describe '#sdr?' do
    subject { page_location.sdr? }

    context "when SDR is selected" do
      let(:params) { { f: { building_facet: ["Stanford Digital Repository"] } } }

      it { is_expected.to be true }
    end
  end

  describe '#databases?' do
    subject { page_location.databases? }

    context "when database format is selected" do
      let(:params) { { f: { format_main_ssim: ["Database"] } } }

      it { is_expected.to be true }
    end
  end
end
