require "spec_helper"

describe "catalog/_additional_results_block.html.erb" do
  let(:simple_config) { instance_double(Blacklight::Configuration, default_search_field: instance_double('field', field: 'search') ) }
  let(:facet_config) {
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'fieldA', label: "A field"
      config.add_facet_field 'fieldB', label: 'Another field'
    end
  }
  let(:no_modifier) { SearchQueryModifier.new({}, simple_config) }
  let(:query) { SearchQueryModifier.new({q: "Query of the stopwords"}, simple_config) }
  let(:filter) { SearchQueryModifier.new({f: {fieldA: ["ValueA"], fieldB: ['ValueB']}, q: 'a query'}, facet_config) }
  let(:range) { SearchQueryModifier.new({range: {fieldA: {begin: '1234', end: '4321'}}, q: 'a query'}, facet_config) }
  let(:fielded) { SearchQueryModifier.new({search_field: 'search_title', q: 'a query'}, simple_config) }
  describe "stopwords search" do
    before do
      assign(:search_modifier, query)
      render
    end
    it "should render a link removing stopwords if present" do
      expect(rendered).to have_css('a', text: 'Search without "and" "of" "the"')
    end
  end
  describe "range search" do
    before do
      assign(:search_modifier, range)
      render
    end
    it "should render a link removing filters" do
      expect(rendered).to have_css('a', text: 'Remove limit(s)')
    end
  end
  describe "filtered search" do
    before do
      assign(:search_modifier, filter)
      render
    end
    it "should render a link removing filters" do
      expect(rendered).to have_css('a', text: 'Remove limit(s)')
    end
  end
  describe "fielded search" do
    before do
      assign(:search_modifier, fielded)
      render
    end
    it "should provide a link to remove the fielded search" do
      expect(rendered).to have_css('a', text: 'Search all fields')
    end
  end
  describe "no search modifiers" do
    before do
      assign(:search_modifier, no_modifier)
      render
    end
    it "should not include any of the modifier links" do
      expect(rendered).not_to have_content("Looking for different results?")
      expect(rendered).not_to have_content("Modify your search")
      expect(rendered).not_to have_content("Search elsewhere")
      expect(rendered).not_to have_css('a', text: 'Search without "and" "of" "the"')
      expect(rendered).not_to have_css('a', text: 'Remove limit(s)')
      expect(rendered).not_to have_css('a', text: 'Search all fields')
    end
  end
  describe "other search sources" do
    before do
      assign(:search_modifier, query)
      allow(view).to receive(:params).and_return(q: 'hello')
      render
    end
    it "should include a link to the library website" do
      expect(rendered).to have_css('a', text: 'Search library website')
      expect(rendered).to match /library\.stanford\.edu\/search\/website\?search=hello/
    end
  end
  describe "pages past the first" do
    before do
      assign(:search_modifier, filter)
      allow(view).to receive(:params).and_return(page: 2)
      render
    end
    it "should not render" do
      expect(rendered).to be_blank
    end
  end
end
