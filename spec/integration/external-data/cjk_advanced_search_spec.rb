# encoding: utf-8

require "spec_helper"

describe "CJK Advanced Search", js: true, feature: true, "data-integration": true  do
  before do
    visit blacklight_advanced_search_engine.advanced_search_path
  end

  describe "fielded search" do
    before do
      fill_in field, with: query
      click_on "advanced-search-submit"
    end

    describe "all fields" do
      let(:query) { '舊小說' }
      let(:field) { 'search' }

      it "should return results from all fields" do
        expect((60..80)).to include total_results
      end
    end

    describe "publisher" do
      let(:field) { 'pub_search' }

      describe "Akatsuki Shobō 曉書房" do
        let(:query) { '曉書房' }

        it "should return less than 10 results containing particular records" do
          expect((3..10)).to include total_results
          expect(results_all_on_page(['6321193', '6355327', '6668315'])).to be_truthy
        end
      end

      describe "Mineruba Shobō ミネルヴァ 書房" do
        let(:query) { 'ミネルヴァ 書房' }

        it "should return more that 900 results with a 8 particular records on the first page" do
          expect(total_results).to be > 900
          expect(results_all_on_page([
            "4196577", "4203788", "4199853", "4198109", "4203994", "4197487", "10365584", "10412633"
          ])).to be_truthy
        end
      end

      describe "Okinawa-ken Ginowan-shi 沖縄県宜野湾市" do
        let(:query) { '沖縄県宜野湾市' }

        it "should return at least 17 results with 3 particular records on the first page" do
          expect(total_results).to be <= 17
          expect(results_all_on_page(["9392905", "9350464", "8630944"]))
        end
      end

      describe "Tsu (津) - Unigram" do
        let(:query) { 'tsu 津' }

        it "should get between 30 - 50 results" do
          expect((30..50)).to include total_results
        end
      end

      describe "津 (no term)" do
        let(:query) { '津' }

        it "should get between 30 - 3500 results" do
          expect((30..3500)).to include total_results
        end
      end
    end
  end

  describe "title AND author" do
    before do
      fill_in "search_title", with: title
      fill_in "search_author", with: author
      click_on "advanced-search-submit"
    end

    describe "title Nihon seishin seisei shiron (日本精神生成史論) AND author Shigeo Suzuki (鈴木重雄)" do
      let(:title) { '日本精神生成史論' }
      let(:author) { '鈴木重雄' }

      it "should return at least 5 results" do
        expect(total_results).to be <= 5
      end
    end

    describe "title Ji cu zhan shu (基礎戰術) AND author Mao, Zedong (毛澤東)" do
      let(:title) { '基礎戰術' }
      let(:author) { '毛澤東' }

      it "should return between 2 and 5 results" do
        expect((2..5)).to include total_results
      end
    end
  end

  describe "title OR author" do
    before do
      fill_in "search_title", with: title
      fill_in "search_author", with: author
      select 'any', from: 'op'
      click_on "advanced-search-submit"
    end

    describe "title Nihon seishin seisei shiron (日本精神生成史論) OR author Shigeo Suzuki (鈴木重雄)" do
      let(:title) { '日本精神生成史論' }
      let(:author) { '鈴木重雄' }

      it "should return at between 5 and 20 results" do
        expect((5..20)).to include total_results
      end
    end

    describe "title Ji cu zhan shu (基礎戰術) OR author Mao, Zedong (毛澤東)" do
      let(:title) { '基礎戰術' }
      let(:author) { '毛澤東' }

      it "should return between 350 and 525 results" do
        expect((350..525)).to include total_results
      end
    end
  end

  describe "title AND pub info" do
    before do
      fill_in "search_title", with: title
      fill_in "pub_search", with: pub
      click_on "advanced-search-submit"
    end

    describe "title Daily Report (日報) AND place Jinan (濟南) SW-974" do
      let(:title) { '日報' }
      let(:pub) { '濟南' }

      it "should return between 5 and 15 results" do
        expect((5..15)).to include total_results
        expect(results_all_on_page(["9617331", "5175639", "4822276"])).to be_truthy
      end
    end

    describe "unigram title Float (飄) AND place Shanghai (上海)" do
      let(:title) { '飄' }
      let(:pub) { '上海' }

      it "should return between 10 and 20 results" do
        expect((10..20)).to include total_results
      end
    end
  end

  describe "title OR pub info" do
    before do
      fill_in "search_title", with: title
      fill_in "pub_search", with: pub
      select 'any', from: 'op'
      click_on "advanced-search-submit"
    end

    describe "title Daily Report (日報) OR place Jinan (濟南) SW-974" do
      let(:title) { '日報' }
      let(:pub) { '濟南' }

      it "should return between 5000 and 10000 results" do
        expect((5000..10000)).to include total_results
        expect(results_all_on_page(["9617331", "5175639", "4822276"])).to be_truthy
      end
    end

    describe "unigram title Float (飄) OR place Shanghai (上海)" do
      let(:title) { '飄' }
      let(:pub) { '上海' }

      it "should return between 40000 and 50000 results" do
        expect((40000..50000)).to include total_results
      end
    end
  end
end
