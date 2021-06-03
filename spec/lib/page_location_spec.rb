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
    describe "#to_s" do
      it "should return the point as a string" do
        expect(subject.access_point.to_s).to be_blank
        database_access_point = SearchWorks::PageLocation.new(base_database_params).access_point
        expect(database_access_point.to_s).to eq "databases"
      end
    end

    describe "for CatalogController" do
      subject(:access_point) { SearchWorks::PageLocation.new(base_params).access_point }

      let(:base_params) { { action: 'index', controller: 'catalog' } }

      describe "databases" do
        describe "old format facet" do
          before { base_params[:f] = { format: ["Database"] } }

          it "should be defined when a facet is selected" do
            expect(access_point).to eq :databases
          end
          it "should be defined when an additional format facet is selected" do
            base_params[:f][:format] << "Book"
            expect(access_point).to eq :databases
          end
          it "should be defined when searching within selected" do
            base_params[:q] = "My Query"
            expect(access_point).to eq :databases
          end
          it "should not be defined when a non-database format facet is selected" do
            base_params[:f] = { access: "Online" }
            expect(access_point).to be_nil
          end
        end

        describe "new resource type facet" do
          before { base_params[:f] = { format_main_ssim: ["Database"] } }

          it "should be defined when a facet is selected" do
            expect(access_point).to eq :databases
          end
          it "should be defined when an additional format facet is selected" do
            base_params[:f][:format_main_ssim] << "Book"
            expect(access_point).to eq :databases
          end
          it "should be defined when searching within selected" do
            base_params[:q] = "My Query"
            expect(access_point).to eq :databases
          end
          it "should not be defined when a non-database format facet is selected" do
            base_params[:f] = { access: "Online" }
            expect(access_point).to be_nil
          end

          describe '#databases?' do
            it 'is true' do
              expect(SearchWorks::PageLocation.new(base_params).databases?).to eq true
            end
          end
        end
      end

      describe "course reserve" do
        before { base_params[:f] = { course: ["SOULSTEEP-101"], instructor: ["Winfrey, Oprah"] } }

        it "should be defined when course and instructor facets are selected" do
          expect(access_point).to eq :course_reserve
        end
        it "should be defined when an another facet is selected" do
          base_params[:f][:format] = "Book"
          expect(access_point).to eq :course_reserve
        end
        it "should be defined when searching with course reserve" do
          base_params[:q] = "My Query"
          expect(access_point).to eq :course_reserve
        end
        it "should not be defined when only one of course or instructor are selected" do
          base_params[:f] = { course: ["CATZ-101"] }
          expect(access_point).to be_nil
        end
        it "should not be defined when only one of course or instructor are selected" do
          base_params[:f] = { instructor: ["Winfrey, Oprah"] }
          expect(access_point).to be_nil
        end
        it "should not be defined when neither course nor instructor are selected" do
          base_params[:f] = { access: "Online" }
          expect(access_point).to be_nil
        end
      end

      describe "collection" do
        before { base_params[:f] = { collection: ["29"] } }

        it "should be defined when collection is present" do
          expect(access_point).to eq :collection
        end
        it "should not be defined when collection is not present" do
          base_params[:f] = {}
          expect(access_point).to be_nil
        end
        it "should not be defined when collection is present and is sirsi" do
          base_params[:f] = { collection: ["sirsi"] }
          expect(access_point).to be_nil
        end

        describe '#collection?' do
          it 'is true' do
            expect(SearchWorks::PageLocation.new(base_params).collection?).to eq true
          end
        end
      end

      describe 'digital_collections' do
        before { base_params[:f] = { collection_type: ["Digital Collection"] } }

        it 'should be defined when the collection_type is digital collection' do
          expect(access_point).to eq :digital_collections
        end
        it "should not be defined when digital_collection is not present" do
          base_params[:f] = {}
          expect(access_point).to be_nil
        end
        it "should not be defined when digital_collection is a different value" do
          base_params[:f] = { collection_type: ["Something Else"] }
          expect(access_point).to be_nil
        end
      end

      describe 'sdr' do
        before { base_params[:f] = { building_facet: ["Stanford Digital Repository"] } }

        it 'should be defined when the building facet is Stanford Digital Repository' do
          expect(access_point).to eq :sdr
        end
        it "should not be defined when Stanford Digital Repository is not present" do
          base_params[:f] = {}
          expect(access_point).to be_nil
        end
        it "should not be defined when building_facet is a different value" do
          base_params[:f] = { building_facet: ["Green Library"] }
          expect(access_point).to be_nil
        end

        describe '#sdr?' do
          it 'is true' do
            expect(SearchWorks::PageLocation.new(base_params).sdr?).to eq true
          end
        end
      end

      describe 'dissertation_theses' do
        before { base_params[:f] = { genre_ssim: ['Thesis/Dissertation'] } }

        it 'should be defined when genre facet is "Thesis/Dissertation"' do
          expect(access_point).to eq :dissertation_theses
        end
        it 'should not be defined when Thesis/Dissertation is not present' do
          base_params[:f] = {}
          expect(access_point).to be_nil
        end
        it 'should not be defined when genre_ssim is another value' do
          base_params[:f] = { genre_ssim: ['Cat Tricks'] }
          expect(access_point).to be_nil
        end
      end

      describe 'bookplate_fund' do
        before { base_params[:f] = { fund_facet: ['ABC123'] } }

        it 'is defined when the fund_facet is present' do
          expect(access_point).to eq :bookplate_fund
        end

        it 'is defined when the fund_facet is empty' do
          base_params[:f] = { fund_facet: [] }
          expect(access_point).to be_nil
        end
      end

      describe 'government_documents' do
        before { base_params[:f] = { genre_ssim: ['Government document', 'Something else'] } }

        it 'is deined when the genre_ssim includes "Government document"' do
          expect(access_point).to eq :government_documents
        end

        it 'is nil when the genre_ssim is something else' do
          base_params[:f][:genre_ssim] = ['Something else']
          expect(access_point).to be_nil
        end
      end

      describe 'iiif_resources' do
        before { base_params[:f] = { iiif_resources: ['available'] } }

        it 'is defined when the iiif_resources includes "available"' do
          expect(access_point).to eq :iiif_resources
        end

        it 'is nil when the iiif_resources is something else' do
          base_params[:f][:iiif_resources] = ['Something else']
          expect(access_point).to be_nil
        end
      end
    end
  end
end
