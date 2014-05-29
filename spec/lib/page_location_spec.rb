require 'spec_helper'
require 'page_location'

describe SearchWorks::PageLocation do
  let(:base_database_params) { {controller: 'catalog', action: 'index', f: {format: ["Database"]}} }
  it "should be nil when no relevant params are available" do
    expect(subject.access_point.to_s).to be_blank
  end
  it "should have a '?' accessor" do
    expect(subject.access_point?).to be_false
    expect(SearchWorks::PageLocation.new(base_database_params).access_point?).to be_true
  end
  describe "AccessPoints" do
    describe "*? accessor" do
      it "should return false for method that are not the current access point" do
        expect(SearchWorks::PageLocation::AccessPoints.new.any_method?).to be_false
      end
      it "should return true if on the current access point" do
        expect(SearchWorks::PageLocation::AccessPoints.new(base_database_params).databases?).to be_true
      end
    end
    describe "#to_s" do
      it "should return the point as a string" do
        expect(subject.access_point.to_s).to be_blank
        database_access_point = SearchWorks::PageLocation::AccessPoints.new(base_database_params)
        expect(database_access_point.to_s).to eq "databases"
      end
    end
    describe "for CatalogController" do
      let(:base_params) { {controller: 'catalog'} }
      describe "#index action" do
        before { base_params[:action] = 'index' }
        describe "databases" do
          describe "old format facet" do
            before { base_params[:f] = {format: ["Database"]} }
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
              base_params[:f] = {access: "Online"}
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
            end
          end
          describe "new resource type facet" do
            before { base_params[:f] = {format_main_ssim: ["Database"]} }
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
              base_params[:f] = {access: "Online"}
              expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
            end
          end
        end
        describe "course reserve" do
          before { base_params[:f] = {course: ["SOULSTEEP-101"], instructor: ["Winfrey, Oprah"] }}
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
          before { base_params[:f] = {collection: ["29"] }}
          it "should be defined when collection is present" do
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :collection
          end
          it "should not be defined when collection is not present" do
            base_params[:f] = {}
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
          it "should not be defined when collection is present and is sirsi" do
            base_params[:f] = {collection: ["sirsi"]}
            expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to be_nil
          end
        end
      end
    end
    describe "for SelectedDatabasesController#index" do
      let(:base_params) { { controller: 'selected_databases', action: 'index' } }
      it "should be defined" do
        expect(SearchWorks::PageLocation::AccessPoints.new(base_params).point).to eq :selected_databases
      end
    end
  end
end
