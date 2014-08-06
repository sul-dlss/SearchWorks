require "spec_helper"

number_pattern = /[1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0/

describe "Legacy Advanced Search Tests", js: true, feature: true, :"data-integration" => true do
  before do
    visit advanced_search_path
  end
  describe "Single author title" do
    it "search matches Socrates results" do
      fill_in "search_author", with: "McRae"
      fill_in "search_title", with: "Jazz"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("7637875")).to_not be_nil
      expect(docs.index("336046")).to_not be_nil
      expect(docs.index("9512303")).to_not be_nil
      expect(docs.index("2130330")).to_not be_nil
    end
    it "Advanced search for author Zukofsky and title 'A' (SW-501)" do
      fill_in "search_author", with: "Zukofsky"
      fill_in "search_title", with: "A"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("9082824")).to_not be_nil
      expect(docs.index("1398728")).to_not be_nil
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
    it "should return more than 4,000,000 results for only facets" do
      click_on "Access"
      check "f_inclusive_access_facet_at-the-library"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_book"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 4000000)).to be_true
      end
    end
  end
  describe "No facet searching" do
    it "should return at least 500 results" do
      fill_in "search_title", with: "something"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 500)).to be_true
      end
    end
  end
  describe "All fields ANDed filled in plus facets" do
    it "should return a few results" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "Potter"
      fill_in "subject_terms", with: "Wizards"
      fill_in "search", with: "Hogwarts"
      fill_in "pub_search", with: "London"
      fill_in "isbn_search", with: "0747591059"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_book"
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
      fill_in "search", with: "Hogwarts"
      fill_in "pub_search", with: "London"
      fill_in "isbn_search", with: "0747591059"
      select "any", from: "op"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_book"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 100000)).to be_true
      end
    end
  end
  describe "Publisher search" do
    it "should return results only if there is a match in the publisher" do
      fill_in "pub_search", with: "NEW MEXICO"
      click_on 'advanced-search-submit'
      expect(greater_than_integer(page.find("h2", text: number_pattern).text, 8000)).to be_true
      expect(less_than_integer(page.find("h2", text: number_pattern).text, 9000)).to be_true
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
    it "should get at most 2,000,000" do
      fill_in "search", with: "NOT p"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 2000000)).to be_true
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
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 1520000)).to be_true
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
    it "should get at most 1500 total results" do
      fill_in "search", with: "IEEE Xplore"
      fill_in "subject_terms", with: "-Congresses"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 1500)).to be_true
      end
    end
  end
  describe "OR query" do
    # Test fails because of timeout, can't return 100 records quick enough
    it "should get at least 225 results and ckeys 6746743, 6747313 in first 100 results" do
      fill_in "search_author", with: "John Steinbeck"
      fill_in "search_title", with: "Pearl OR Grapes"
      click_on "advanced-search-submit"
      click_button "20 per page"
      click_link "100"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 225)).to be_true
      end
      expect(docs.index("6746743")).to_not be_nil
      expect(docs.index("6747313")).to_not be_nil
    end
  end
  describe "nossa OR nuestra america (SW-939)" do
    it "should return at least 400 results" do
      fill_in "search_title", with: "nossa OR nuestra america"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 400)).to be_true
      end
    end
  end
  describe "color OR colour photography (SW-939)" do
    it "should return at least 80 results" do
      fill_in "search_title", with: "color OR colour photography"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 80)).to be_true
      end
    end
  end
  describe "AND query" do
    it "should return at least 50 results and these keys in first 5 results" do
      fill_in "search_title", with: "Hello AND Goodbye"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 50)).to be_true
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
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 4)).to be_true
      end
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("4076380")).to_not be_nil
    end
  end
  describe "AND and OR query hofstadter OR nabokov AND pushkin" do
    pending "should return at most 3 results and not this key" do
      fill_in "search_author", with: "hofstadter OR nabokov AND pushkin"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 3)).to be_true
      end
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      # TODO: Fails and actually is returned as first result
      expect(docs.index("4076380")).to be_nil
    end
  end
  describe "AND and OR  (nabokov OR hofstadter) AND pushkin" do
    it "should get between 5 and 7 results" do
      fill_in "search_author", with: "(nabokov OR hofstadter) AND pushkin"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 5)).to be_true
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 7)).to be_true
      end
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("4076380")).to_not be_nil
    end
  end
  describe "parenthesis  (Dutch OR Netherlands) AND painting  (VUF-1879)" do
    it "should get between 8 and 12 results" do
      fill_in "subject_terms", with: "(Dutch OR Netherlands) AND painting"
      fill_in "search", with: "trade OR commerce"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 8)).to be_true
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 12)).to be_true
      end
    end
  end
  describe "(trade OR commerce) AND painting  (VUF-1879)" do
    it "should return at least 15 results" do
      fill_in "subject_terms", with: "Dutch OR Netherlands"
      fill_in "search", with: "(trade OR commerce) AND painting"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 15)).to be_true
      end
    end
  end
  describe "Description Plus Building Facet Value" do
    it "should return at most 1 result" do
      fill_in "search", with: "Sally Ride"
      click_on "Library"
      check "f_inclusive_building_facet_art-architecture"
      click_on "advanced-search-submit"
      expect(page).to have_css(".search_num_of_results", text: "1 result")
    end
  end
  describe "Title Plus Format Facet Value (SW-326)" do
    it "should get ckey 365647 in the results" do
      fill_in "search_title", with: "Jewish book annual"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_journal-periodical"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("365647")).to_not be_nil
    end
  end
  describe "Subject China History Women and language English" do
    it "should return at least 100 results" do
      fill_in "subject_terms", with: "china women history"
      click_on "Language"
      check "f_inclusive_language_english"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 100)).to be_true
      end
    end
  end
  describe "Multi-Facet Query" do
    it "should return zero results" do
      fill_in "search", with: "African Maps"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_map"
      click_on "Library"
      check "f_inclusive_building_facet_music"
      click_on "advanced-search-submit"
      expect(page).to have_css("h2", text: "No results found in catalog")
    end
  end
  describe "Author Title Plus Format Book" do
    it "should get ckey 5680298 and not 8303176 in the results" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "Potter"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_book"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("5680298")).to_not be_nil
      expect(docs.index("8303176")).to be_nil
    end
  end
  describe "Author Title Plus Format Video" do
    it "should get ckey 8303176 and not 5680298 in the results" do
      fill_in "search_author", with: "Rowling"
      fill_in "search_title", with: "Potter"
      click_on "Resource type"
      check "f_inclusive_format_main_ssim_video"
      click_on "advanced-search-submit"
      docs = page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
      expect(docs.index("8303176")).to_not be_nil
      expect(docs.index("5680298")).to be_nil
    end
  end
  describe "Phrase search: subject 'Home Schooling' and Keyword Socialization VUF-1352" do
    it "should get at most 150 results" do
      fill_in "subject_terms", with: '"Home Schooling"'
      fill_in "search", with: "Socialization"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 150)).to be_true
      end
    end
  end
  describe "Searches with date ranges" do
    it "should see Date: 1900 - 2000" do
      fill_in "search_author", with: "Rowling"
      fill_in "range_pub_year_tisim_begin", with: "1900"
      fill_in "range_pub_year_tisim_end", with: "2000"
      click_on "advanced-search-submit"
      expect(page).to have_css("span", text: "1900 to 2000")
    end
  end
  describe "Searches without date ranges" do
    it "should not see date facet open" do
      fill_in "search_author", with: "Rowling"
      click_on "advanced-search-submit"
      expect(page).to have_css("div.collapsed.collapse-toggle.panel-heading", text: "Date")
    end
  end
  describe "Faceting on advanced searches with date ranges" do
    it "should get between 5000 and 6000 results" do
      fill_in "search", with: "France"
      fill_in "range_pub_year_tisim_begin", with: "1789"
      fill_in "range_pub_year_tisim_end", with: "1800"
      click_on "advanced-search-submit"
      within ".search_num_of_results" do
        expect(less_than_integer(page.find("h2", text: number_pattern).text, 5000)).to be_true
        expect(greater_than_integer(page.find("h2", text: number_pattern).text, 6000)).to be_true
      end
    end
  end
end
