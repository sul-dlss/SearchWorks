require 'rails_helper'

RSpec.describe BookmarksHelper do
  # From BL /spec/helpers/catalog_helper_spec.rb
  def mock_response args
    current_page = args[:current_page] || 1
    per_page = args[:rows] || args[:per_page] || 10
    total = args[:total]
    start = (current_page - 1) * per_page

    mock_docs = (1..total).to_a.map { {}.with_indifferent_access }

    mock_response = Kaminari.paginate_array(mock_docs).page(current_page).per(per_page)

    allow(mock_response).to receive(:docs).and_return(mock_docs.slice(start, per_page))
    mock_response
  end

  describe "bookmarks?" do
    it "should return true if bookmarks controller" do
      params[:controller] = "bookmarks"
      expect(helper.bookmarks?).to be_truthy
    end

    it 'should return true if in the article_selections controller' do
      params[:controller] = 'article_selections'
      expect(helper.bookmarks?).to be_truthy
    end

    it "should return false if not bookmarks controller" do
      params[:controller] = "catalog"
      expect(helper.bookmarks?).to be_falsey
    end
  end

  describe "current_entries_info" do
    it "with no results" do
      @response = mock_response total: 0
      expect(current_entries_info(@response)).to eq '0 - 0'
    end
    it "with one result" do
      @response = mock_response total: 1
      expect(current_entries_info(@response)).to eq '1 - 1'
    end
    it "with one page of results" do
      @response = mock_response total: 8
      expect(current_entries_info(@response)).to eq '1 - 8'
    end
    it "first page of multiple results" do
      @response = mock_response total: 15, per_page: 10
      expect(current_entries_info(@response)).to eq '1 - 10'
    end
    it "second page of multiple results" do
      @response = mock_response total: 47, per_page: 10, current_page: 2
      expect(current_entries_info(@response)).to eq '11 - 20'
    end
    it "last page of multiple results" do
      @response = mock_response total: 47, per_page: 10, current_page: 5
      expect(current_entries_info(@response)).to eq '41 - 47'
    end
  end
end
