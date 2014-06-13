require "spec_helper"

describe "Advanced Search", js: true, feature: true, :"data-integration" => true do
  before do
    visit advanced_search_path
  end
  it "Single author title" do
    pending "search matches Socrates results" do
      fill_in "author", with: "McRae"
      fill_in "title", with: "Jazz"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("7637875")).to_not be_nil
      expect(docs.index("336046")).to_not be_nil
      expect(docs.index("9512303")).to_not be_nil
      expect(docs.index("2130330")).to_not be_nil
    end
    it "Advanced search for author Zukofsky and title 'A' (SW-501)" do
      fill_in "author", with: "Zukofsky"
      fill_in "title", with: "A"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("9082824")).to_not be_nil
      expect(docs.index("1398728")).to_not be_nil
      click_link "10 per page"
      click_link "20"
      expect(docs.index("290602")).to_not be_nil
      expect(docs.index("4515607")).to_not be_nil
      expect(docs.index("743649")).to_not be_nil
      expect(docs.index("1209196")).to_not be_nil
      expect(docs.index("2767209")).to_not be_nil
      expect(docs.index("2431848")).to_not be_nil
      expect(docs.index("857890")).to_not be_nil
    end
  end
  describe "Facet searching" do
    # TODO Add book facet click when prod index has format facet
    it "should return more than 4,000,000 results for only facets" do
      click_on "Access"
      check "f_inclusive_access_facet_at-the-library"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.find("strong", text: /^.*,+.*$/).text, 4000000)).to be_true
      end
    end
  end
  describe "No facet searching" do
    it "should return at least 500 results" do
      fill_in "search_title", with: "something"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.find("strong", text: /^.*,+.*$/).text, 500)).to be_true
      end
    end
  end
  describe "All fields ANDed filled in plus facets" do
    it "should return a few results" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "Potter"
      fill_in "subject_terms", with: "Wizards"
      # No description field
      #fill_in "description", with: "Hogwarts"
      fill_in "pub_search", with: "London"
      fill_in "isbn_search", with: "0747591059"
      # TODO add book facet when prod index has format facet
      click_on "advanced-search-submit"
      expect(page).to have_css("div.document", count: 1)
      # NOTE: currently only matches 1 doc same as old sw in prod, but old integration
      # tests incorrectly say to match at least 5 books
    end
  end
  describe "All fields ORed filled in plus facets" do
    it "should return a lot of results" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "Potter"
      fill_in "subject_terms", with: "Wizards"
      # No description field
      #fill_in "description", with: "Hogwarts"
      fill_in "pub_search", with: "London"
      fill_in "isbn_search", with: "0747591059"
      select "any", from: "op"
      # TODO add book facet when prod index has format facet
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.find("strong", text: /^.*,+.*$/).text, 100000)).to be_true
      end
    end
  end
  describe "Advanced search sorting" do
    before do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "Potter"
    end
    it "should return year (old to new)" do
      select "year (old to new)", from: "sort"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("4819125")).to be < 5
    end
    it "should return title" do
      select "title", from: "sort"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("5453649")).to be < 5
    end
    # Question: Duplicate test?
    it "should return title" do
      select "year (old to new)", from: "sort"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("4819125")).to be < 5
    end
  end
  describe "NOT as first word queries" do
    it "should not get Harry Potter as a result" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "NOT Potter"
      click_on "advanced-search-submit"
      within "#documents" do
        expect(page).to_not have_content("Harry Potter")
      end
    end
  end
  describe "Standalone NOT as first word query" do
    pending "should get at most 1,520,000" do
      # Does not have a description field
      fill_in "description", with: "NOT p"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.find("strong", text: /^.*,+.*$/).text, 1520000)).to be_true
      end
    end
  end
  describe "NOT in the middle of query terms" do
    it "should get at most 100 results and not 6865307" do
      fill_in "search_author", with: "John Steinbeck"
      fill_in "search_title", with: "pearl NOT perla"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      # This only checks first page of results
      expect(docs.index("6865307")).to be_nil
      within ".page_entries" do
        expect(less_than_integer(page.all("strong").map{|e| e.text}[2], 1520000)).to be_true
      end
    end
  end
  describe "Hyphen as NOT queries" do
    it "should not get Harry Potter as a result" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "-potter"
      click_on "advanced-search-submit"
      within "#documents" do
        expect(page).to_not have_content("Harry Potter")
      end
    end
  end
  describe "Hyphen as NOT queries (SW-623)" do
    pending "should get at most 1500 total results" do
      # Does not have a description field
      # fill_in "description", with: "IEEE Xplore"
      fill_in "subject_terms", with: "-Congresses"
      click_on "advanced-search-submit"
    end
  end
  describe "OR query" do
    # Test fails because of timeout, can't return 100 records quick enough
    pending "should get at least 225 results and ckeys 6746743, 6747313 in first 100 results" do
      fill_in "search_author", with: "John Steinbeck"
      fill_in "search_title", with: "Pearl OR Grapes"
      click_on "advanced-search-submit"
      click_link "10 per page"
      click_link "100"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(less_than_integer(page.all("strong").map{|e| e.text}[2], 225)).to be_true
      expect(docs.index("6746743")).to_not be_nil
      expect(docs.index("6747313")).to_not be_nil
    end
  end
  describe "nossa OR nuestra america (SW-939)" do
    it "should return at least 400 results" do
      fill_in "search_title", with: "nossa OR nuestra america"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.all("strong").map{|e| e.text}[2], 400)).to be_true
      end
    end
  end
  describe "color OR colour photography (SW-939)" do
    it "should return at least 80 results" do
      fill_in "search_title", with: "color OR colour photography"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.all("strong").map{|e| e.text}[2], 80)).to be_true
      end
    end
  end
  describe "AND query" do
    it "should return at least 50 results and these keys in first 5 results" do
      fill_in "search_title", with: "Hello AND Goodbye"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.all("strong").map{|e| e.text}[2], 50)).to be_true
      end
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("6502314")).to be < 5
      expect(docs.index("8218325")).to be < 5
      expect(docs.index("6314136")).to be < 5
      expect(docs.index("2432242")).to be < 5
    end
  end
  describe "AND and OR query nabokov OR hofstadter AND pushkin" do
    it "should return at most 3 results and this key" do
      fill_in "search_author", with: "nabokov OR hofstadter AND pushkin"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(less_than_integer(page.all("strong").map{|e| e.text}[2], 4)).to be_true
      end
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("4076380")).to_not be_nil
    end
  end
  describe "AND and OR query hofstadter OR nabokov AND pushkin" do
    pending "should return at most 3 results and not this key" do
      fill_in "search_author", with: "hofstadter OR nabokov AND pushkin"
      click_on "advanced-search-submit"
      within ".page_entries" do
        expect(greater_than_integer(page.all("strong").map{|e| e.text}[2], 3)).to be_true
      end
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      # TODO: Fails and actually is returned as first result
      expect(docs.index("4076380")).to be_nil
    end
  end
end
