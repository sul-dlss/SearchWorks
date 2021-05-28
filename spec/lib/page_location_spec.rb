require 'spec_helper'
require 'page_location'

describe SearchWorks::PageLocation do
  let(:base_database_params) { { controller: 'catalog', action: 'index', f: { format: ["Database"] } } }

  it "should be nil when no relevant params are available" do
    expect(subject.access_point.to_s).to be_blank
  end
  it "should have a '?' accessor" do
    expect(subject.access_point?).to be_falsey
    expect(SearchWorks::PageLocation.new(base_database_params).access_point?).to be_truthy
  end
  describe "AccessPoints" do
    describe "*? accessor" do
      it "should return false for method that are not the current access point" do
        expect(SearchWorks::PageLocation::AccessPoints.new.any_method?).to be_falsey
      end
      it "should return true if on the current access point" do
        expect(SearchWorks::PageLocation::AccessPoints.new(base_database_params).databases?).to be_truthy
      end
    end

    describe "#to_s" do
      it "should return the point as a string" do
        expect(subject.access_point.to_s).to be_blank
        database_access_point = SearchWorks::PageLocation::AccessPoints.new(base_database_params)
        expect(database_access_point.to_s).to eq "databases"
      end
    end

    describe "#name" do
      it "should return a formatted name as a string" do
        expect(SearchWorks::PageLocation::AccessPoints.new(base_database_params).name).to eq "Databases"
        course_reserve_params = base_database_params
        course_reserve_params[:f] = { course: ["SOULSTEEP-101"], instructor: ["Winfrey, Oprah"] }
        expect(SearchWorks::PageLocation::AccessPoints.new(course_reserve_params).name).to eq "Course reserves"
      end
    end

    describe "for CatalogController" do
      let(:base_params) { { controller: 'catalog' } }

      describe "#index action" do
        before { base_params[:action] = 'index' }

        describe "databases" do
          describe "old format facet" do
            before { base_params[:f] = { format: ["Database"] } }

            it "should be defined when a facet is selected" do
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :databases
            end
            it "should be defined when an additional format facet is selected" do
              base_params[:f][:format] << "Book"
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :databases
            end
            it "should be defined when searching within selected" do
              base_params[:q] = "My Query"
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :databases
            end
            it "should not be defined when a non-database format facet is selected" do
              base_params[:f] = { access: "Online" }
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
            end
          end

          describe "new resource type facet" do
            before { base_params[:f] = { format_main_ssim: ["Database"] } }

            it "should be defined when a facet is selected" do
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :databases
            end
            it "should be defined when an additional format facet is selected" do
              base_params[:f][:format_main_ssim] << "Book"
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :databases
            end
            it "should be defined when searching within selected" do
              base_params[:q] = "My Query"
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :databases
            end
            it "should not be defined when a non-database format facet is selected" do
              base_params[:f] = { access: "Online" }
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
            end
          end
        end

        describe "course reserve" do
          before { base_params[:f] = { course: ["SOULSTEEP-101"], instructor: ["Winfrey, Oprah"] } }

          it "should be defined when course and instructor facets are selected" do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :course_reserve
          end
          it "should be defined when an another facet is selected" do
            base_params[:f][:format] = "Book"
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :course_reserve
          end
          it "should be defined when searching with course reserve" do
            base_params[:q] = "My Query"
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :course_reserve
          end
          it "should not be defined when only one of course or instructor are selected" do
            base_params[:f] = { course: ["CATZ-101"] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it "should not be defined when only one of course or instructor are selected" do
            base_params[:f] = { instructor: ["Winfrey, Oprah"] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it "should not be defined when neither course nor instructor are selected" do
            base_params[:f] = { access: "Online" }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe "collection" do
          before { base_params[:f] = { collection: ["29"] } }

          it "should be defined when collection is present" do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :collection
          end
          it "should not be defined when collection is not present" do
            base_params[:f] = {}
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it "should not be defined when collection is present and is sirsi" do
            base_params[:f] = { collection: ["sirsi"] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe 'digital_collections' do
          before { base_params[:f] = { collection_type: ["Digital Collection"] } }

          it 'should be defined when the collection_type is digital collection' do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :digital_collections
          end
          it "should not be defined when digital_collection is not present" do
            base_params[:f] = {}
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it "should not be defined when digital_collection is a different value" do
            base_params[:f] = { collection_type: ["Something Else"] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe 'sdr' do
          before { base_params[:f] = { building_facet: ["Stanford Digital Repository"] } }

          it 'should be defined when the building facet is Stanford Digital Repository' do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :sdr
          end
          it "should not be defined when Stanford Digital Repository is not present" do
            base_params[:f] = {}
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it "should not be defined when building_facet is a different value" do
            base_params[:f] = { building_facet: ["Green Library"] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe 'dissertation_theses' do
          before { base_params[:f] = { genre_ssim: ['Thesis/Dissertation'] } }

          it 'should be defined when genre facet is "Thesis/Dissertation"' do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :dissertation_theses
          end
          it 'should not be defined when Thesis/Dissertation is not present' do
            base_params[:f] = {}
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it 'should not be defined when genre_ssim is another value' do
            base_params[:f] = { genre_ssim: ['Cat Tricks'] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe 'bookplate_fund' do
          before { base_params[:f] = { fund_facet: ['ABC123'] } }

          it 'is defined when the fund_facet is present' do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :bookplate_fund
          end

          it 'is defined when the fund_facet is empty' do
            base_params[:f] = { fund_facet: [] }
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe 'government_documents' do
          before { base_params[:f] = { genre_ssim: ['Government document', 'Something else'] } }

          it 'is deined when the genre_ssim includes "Government document"' do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :government_documents
          end

          it 'is nil when the genre_ssim is something else' do
            base_params[:f][:genre_ssim] = ['Something else']
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end

        describe 'iiif_resources' do
          before { base_params[:f] = { iiif_resources: ['available'] } }

          it 'is defined when the iiif_resources includes "available"' do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :iiif_resources
          end

          it 'is nil when the iiif_resources is something else' do
            base_params[:f][:iiif_resources] = ['Something else']
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end
      end
    end

    describe 'for CourseReservesController#index' do
      let(:base_params) { { controller: 'course_reserves', action: 'index' } }

      it "should be defined" do
        expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :course_reserves
      end
    end

    describe "for BrowseController#index" do
      let(:base_params) { { controller: 'browse', action: 'index', start: '123' } }
      let(:no_start_params) { base_params.merge(start: nil) }

      it "should be defined when there is a start parameter" do
        expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :callnumber_browse
      end
      it "should not be defined when there isn't a start parameter" do
        expect(SearchWorks::PageLocation::AccessPoints.new(no_start_params).point).to be_nil
      end
    end
  end
end
