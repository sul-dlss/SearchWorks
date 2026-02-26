# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::CocinaDocumentComponent, type: :component do
  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document: ShowDocumentPresenter.new(document, view_context)) }
  let(:view_context) { ActionController::Base.helpers }
  let(:document) { SolrDocument.from_fixture("#{druid}.yml") }
  let(:druid) { 'bc798xr9549' }

  before do
    allow(view_context).to receive_messages(blacklight_config: CatalogController.blacklight_config, action_name: 'show')
  end

  describe "Description section" do
    it "does not duplicate the title" do
      expect(page).to have_no_css("dt", text: "Title")
    end

    it "displays the form data" do
      expect(page).to have_css("dt", text: "Extent")
      expect(page).to have_css("dd", text: "1 video file and 1 PDF")
    end

    it "displays the publication place" do
      expect(page).to have_css("dt", text: "Place")
      expect(page).to have_css("dd", text: "Seattle (Wash.)")
    end

    it "displays the event dates" do
      expect(page).to have_css("dt", text: "Creation date")
      expect(page).to have_css("dd", text: "November 15, 2014")
    end

    it "displays the languages" do
      expect(page).to have_css("dt", text: "Language")
      expect(page).to have_css("dd", text: "English")
    end
  end

  describe "Contributors section" do
    it "displays the contributors" do
      expect(page).to have_css("dt", text: "Interviewee")
      expect(page).to have_css("dd", text: "Kalsang Yulgial")
    end

    it "links the contributor names to searches" do
      expect(page).to have_link("Kalsang Yulgial", href: "/catalog?q=%22Kalsang+Yulgial%22&search_field=search_author")
    end
  end

  describe "Abstract section" do
    it "displays the abstract" do
      expect(page).to have_css("dt", text: "Abstract")
      expect(page).to have_text("Kalsang Yulgial was born in Phari bordering Sikkim in India.")
    end
  end

  describe "Subjects section" do
    it "displays the subjects" do
      expect(page).to have_css("dt", text: "Region")
      expect(page).to have_css("dd", text: "Utsang")
      expect(page).to have_css("dt", text: "Main topics")
      expect(page).to have_css("dd", text: "Invasion and Occupation")
      expect(page).to have_css("dt", text: "Subject")
      expect(page).to have_css("dd", text: "Oral history > China > Tibet Autonomous Region")
      expect(page).to have_css("dd", text: "Tibet Autonomous Region > History")
    end

    it "displays the genres" do
      expect(page).to have_css("dt", text: "Genre")
      expect(page).to have_css("dd", text: "Filmed interviews")
      expect(page).to have_css("dd", text: "Interview transcripts")
    end

    it "links the subject names to searches" do
      expect(page).to have_link("Oral history", href: "/catalog?q=%22Oral+history%22&search_field=subject_terms")
    end

    it "links structured subjects to combined searches for all terms" do
      expect(page).to have_link("Tibet Autonomous Region", href: "/catalog?q=%22Oral+history%22+%22China%22+%22Tibet+Autonomous+Region%22&search_field=subject_terms")
    end
  end

  describe "Bibliographic section" do
    it "displays the general notes" do
      expect(page).to have_css("dt", text: "Age")
      expect(page).to have_css("dd", text: "67")
      expect(page).to have_css("dt", text: "Gender")
      expect(page).to have_css("dd", text: "Male")
      expect(page).to have_css("dt", text: "Keywords")
    end

    it "displays the identifiers" do
      expect(page).to have_css("dt", text: "Source ID")
      expect(page).to have_css("dd", text: "30C_Kalsang_Yulgial.mov")
    end

    it "does not display the purl URL" do
      expect(page).to have_no_css("dd", text: "https://purl.stanford.edu/bc798xr9549")
    end
  end
end
