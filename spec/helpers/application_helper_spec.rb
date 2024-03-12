# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#searchworks_search_action_path' do
    context 'when in an article search' do
      before { expect(helper).to receive_messages(article_search?: true) }

      it { expect(helper.searchworks_search_action_path).to eq articles_path }
    end

    context 'everywhere else' do
      before { expect(helper).to receive_messages(article_search?: false) }

      it { expect(helper.searchworks_search_action_path).to eq search_catalog_path }
    end
  end

  describe "#data_with_label" do
    let(:temp_doc) { { 'key' => 'fudgesicles' } }
    let(:temp_doc_array) { { 'key' => ['fudgesicles1', 'fudgesicles2'] } }
    let(:temp_doc_vern) { { 'key' => 'fudgesicles', 'vern_key' => 'fudgeyzicles' } }
    let(:temp_doc_vern_array) { { 'key' => 'fudgesicles', 'vern_key' => ['fudgeyzicles1', 'fudgeyzicles2'] } }

    describe "get" do
      it "should return a valid label and fields" do
        data = get_data_with_label(temp_doc, "Food:", "key")
        expect(data[:label]).to eq "Food:"
        expect(data[:fields]).to eq ["fudgesicles"]
      end
      it "handle arrays from the index correctly" do
        data = get_data_with_label(temp_doc_array, "Food:", "key")
        expect(data[:fields].length).to eq 2 and
        expect(data[:fields].include?("fudgesicles1")).to be_truthy
        expect(data[:fields].include?("fudgesicles2")).to be_truthy
      end
      it "should display the vernacular equivalent for a field if one exists" do
        expect(get_data_with_label(temp_doc_vern, "Food:", "key")[:vernacular]).to eq ["fudgeyzicles"]
      end
      it "should handle vernacular arrays correctly" do
        data = get_data_with_label(temp_doc_vern_array, "Food:", "key")[:vernacular]
        expect(data.length).to eq 2
        expect(data.include?("fudgeyzicles1")).to be_truthy
        expect(data.include?("fudgeyzicles2")).to be_truthy
      end
      it "should return nil for the vernacular if there is none" do
        expect(get_data_with_label(temp_doc, "Food:", "key")[:vernacular]).to be_nil
      end
      it "should return nil if the field does not exist" do
        expect(get_data_with_label(temp_doc, "Blech:", "not_valid_key")).to be_nil
      end
    end

    describe "link_to" do
      it "should return a valid label and fields" do
        data = link_to_data_with_label(temp_doc, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })
        expect(data[:label]).to eq("Food:") and
        expect(data[:fields].first).to match(/<a href=.*fudgesicles.*search_field=search_author.*>fudgesicles<\/a>/)
      end
      it "should handle data from the index in an array" do
        fields = link_to_data_with_label(temp_doc_array, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })[:fields]
        expect(fields.include?("<a href=\"/?q=%22fudgesicles1%22&amp;search_field=search_author\">fudgesicles1</a>")).to be_truthy and
        expect(fields.include?("<a href=\"/?q=%22fudgesicles2%22&amp;search_field=search_author\">fudgesicles2</a>")).to be_truthy
      end
      it "should display the linked vernacular equivalent for a field if one exists" do
        expect(link_to_data_with_label(temp_doc_vern, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })[:vernacular].first).to match(/<a href=.*fudgeyzicles.*search_field=search_author.*>fudgeyzicles<\/a>/)
      end
      it "should handle vernacular data from the index in an array" do
        vern = link_to_data_with_label(temp_doc_vern_array, "Food:", "key", { controller: 'catalog', action: 'index', search_field: 'search_author' })[:vernacular]
        expect(vern.include?("<a href=\"/?q=%22fudgeyzicles1%22&amp;search_field=search_author\">fudgeyzicles1</a>")).to be_truthy and
        expect(vern.include?("<a href=\"/?q=%22fudgeyzicles2%22&amp;search_field=search_author\">fudgeyzicles2</a>")).to be_truthy
      end
      it "should return nil if the field does not exist" do
        expect(get_data_with_label(temp_doc, "Blech:", "not_valid_key")).to be_nil
      end
    end
  end

  describe "#active_class_for_current_page" do
    let(:advanced_page) { "advanced" }

    it "should be active" do
      helper.request.path = "advanced"
      expect(helper.active_class_for_current_page(advanced_page)).to eq "active"
    end
    it "should not be active" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(advanced_page)).to be_nil
    end
  end

  describe "#disabled_class_for_current_page" do
    let(:selections_page) { "selections" }

    it "should be disabled" do
      helper.request.path = "selections"
      expect(helper.disabled_class_for_current_page(selections_page)).to eq "disabled"
    end
    it "should not be disabled" do
      helper.request.path = "feedback"
      expect(helper.active_class_for_current_page(selections_page)).to be_nil
    end
  end

  describe "#disabled_class_for_no_selections" do
    it "should be disabled" do
      expect(helper.disabled_class_for_no_selections(0)).to eq "disabled"
    end
    it "should not be disabled" do
      expect(helper.disabled_class_for_no_selections(1)).to be_nil
    end
  end

  describe "#from_advanced_search" do
    it "should indicate if we are coming from the advanced search form" do
      params[:search_field] = 'advanced'
      expect(helper.from_advanced_search?).to be_truthy
    end
  end

  describe '#link_to_catalog_search' do
    subject(:result) { Capybara.string(helper.link_to_catalog_search) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(double(index: double(search_field_mapping: { title: :search_title })))
    end

    it 'passes parameters if currently in article search' do
      params[:q] = 'my query'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(true)
      expect(result).to have_link(text: /catalog/, href: '/?q=my+query')
    end
    it 'is an aria-current anchor link if currently in catalog search' do
      expect(helper).to receive(:article_search?).at_least(:once).and_return(false)
      expect(result.find('a[href="#"]', text: /catalog/)['aria-current']).to eq 'true'
    end
    it 'performs a mapping between fielded search' do
      params[:q] = 'my query'
      params[:search_field] = 'title'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(true)
      expect(result).to have_link(text: /catalog/, href: '/?q=my+query&search_field=search_title')
    end
  end

  describe '#link_to_article_search' do
    subject(:result) { Capybara.string(helper.link_to_article_search) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(double(index: double(search_field_mapping: { search_title: :title })))
    end

    it 'passes parameters if currently in catalog search' do
      params[:q] = 'my query'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(false)
      expect(result).to have_link(text: /articles/, href: '/articles?q=my+query')
    end
    it 'does not link if currently in article search' do
      expect(helper).to receive(:article_search?).at_least(:once).and_return(true)
      expect(result.find('a[href="#"]', text: /articles/)['aria-current']).to eq 'true'
    end
    it 'performs a mapping between fielded search' do
      params[:q] = 'my query'
      params[:search_field] = 'search_title'
      expect(helper).to receive(:article_search?).at_least(:once).and_return(false)
      expect(result).to have_link(text: /articles/, href: '/articles?q=my+query&search_field=title')
    end
  end

  describe '#link_to_bento_search' do
    subject(:result) { Capybara.string(helper.link_to_bento_search) }

    it 'passes query to bento search params' do
      controller.params = { q: 'my query' }
      expect(result).to have_link(
        text: /all/,
        href: 'https://library.stanford.edu/all/?q=my+query'
      )
    end
  end

  describe '#link_to_library_search' do
    subject(:result) { Capybara.string(helper.link_to_library_website_search) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(double(index: double(search_field_mapping: { search_title: :title })))
    end

    it 'passes query to library website search params and does not pass search fields' do
      controller.params = { q: 'kittens' }
      expect(result).to have_link(text: /library website/, href: 'https://library.stanford.edu/search/all?search=kittens')
    end
  end
end
