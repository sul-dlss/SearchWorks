# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::ModsDocumentComponent, type: :component do
  include ModsFixtures

  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document: ShowDocumentPresenter.new(document, view_context)) }
  let(:view_context) { ActionController::Base.helpers }

  before do
    allow(view_context).to receive_messages(blacklight_config: CatalogController.blacklight_config, action_name: 'show')
  end

  context 'when a document has a druid' do
    context 'with published content' do
      let(:document) do
        SolrDocument.new(id: 'abc213', druid: 'abc123', dor_resource_count_isi: 1, modsxml: mods_001)
      end

      it 'includes the embed viewer' do
        expect(page).to have_css('div[data-controller="purl-embed"]')
      end
    end

    context 'without published content' do
      let(:document) do
        SolrDocument.new(id: 'abc213', druid: 'abc123', dor_resource_count_isi: 0, modsxml: mods_001)
      end

      it 'does not include the purl-embed-viewer element' do
        expect(page).to have_no_css('div[data-controller="purl-embed"]')
      end
    end

    context 'without dor_resource_count_isi' do
      let(:document) { SolrDocument.new(id: 'abc213', druid: 'abc123', modsxml: mods_001) }

      it 'includes the purl-embed-viewer element' do
        expect(page).to have_css('div[data-controller="purl-embed"]')
      end
    end
  end

  context 'when a document does not have a druid' do
    let(:document) { SolrDocument.new(id: 'abc213', modsxml: mods_001) }

    it 'does not include the purl-embed-viewer element' do
      expect(page).to have_no_css('div[data-controller="purl-embed"]')
    end
  end

  describe "Object abstract/contents" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    it "displays abstract" do
      expect(page).to have_css("dd", text: "Topographical and street map of the")
      expect(page).to have_css("dd", text: "This is an amazing table of contents!")
    end
  end

  describe "Contributors section" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }

    it 'displays primary authors' do
      expect(page).to have_css('dt', text: 'Author')
      expect(page).to have_css('dd', text: 'J. Smith')
    end

    it "displays secondary authors" do
      expect(page).to have_css("dt", text: "Producer")
      expect(page).to have_css("dd a", text: "B. Smith")
    end
  end

  context "when metadata sections are all available" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    it "displays correct sections" do
      expect(page).to have_css('h2', text: "Contributors")
      expect(page).to have_css('h2', text: "Abstract/Contents")
      expect(page).to have_css('h2', text: "Subjects")
      expect(page).to have_css('h2', text: "Bibliographic information")
    end
  end

  context "when no metadata sections are available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }

    it "displays correct sections" do
      expect(page).to have_no_css('h2', text: "Abstract/Contents")
      expect(page).to have_no_css('h2', text: "Subjects")
      expect(page).to have_no_css('h2', text: "Access conditions")
    end
  end

  describe "Object subjects" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    it "displays subjects if available" do
      expect(page).to have_css("dt", text: "Subject")
      expect(page).to have_css("a", text: '1906 Earthquake')
    end
  end

  context 'without subjects or genres' do
    let(:document) { SolrDocument.new(modsxml: mods_file) }

    it "shoulds not render subjects or genres when a document has no subjects" do
      expect(page).to have_no_text("Subject")
      expect(page).to have_no_text("Gentre")
    end
  end

  describe "Object genres" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    it "displays genres if available" do
      expect(page).to have_css("dt", text: "Genre")
      expect(page).to have_css("a", text: 'Photographs')
    end
  end

  describe 'Upper metadata' do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }

    it "displays fields" do
      expect(page).to have_css("dt", text: "Type of resource")
      expect(page).to have_css("dd", text: "still image")

      expect(page).to have_css("dt", text: "Imprint")
      expect(page).to have_css("dd", text: "copyright 2014")

      expect(page).to have_css("dt", text: "Condition")
      expect(page).to have_css("dd", text: "amazing")
    end
  end
end
