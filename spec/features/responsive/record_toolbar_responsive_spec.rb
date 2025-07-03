# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Record toolbar", :feature, :js do
  let(:citation) { instance_double(Citation) }

  before do
    allow(Citation).to receive(:new).and_return(citation)
    allow(citation).to receive_messages(all_citations: { 'mla' => '<p class="citation_style_MLA">MLA Citation</p>' }, citable?: true)
  end

  describe " - tablet view (768px - 980px) - " do
    before { visit search_catalog_path f: { format: ['Book'] } }

    context 'a citable item' do
      before { page.find('a', text: 'An object').click }

      it 'displays a cite this link toolbar items' do
        within '#content .record-toolbar .navbar' do
          expect(page).to have_link('Cite')
        end
      end
    end

    context 'when coming from the second items in a search' do
      before do
        # Specifically trying to not get the first item in the results
        within '.document-position-2' do
          page.find('h3 a').click
        end
      end

      it "displays all toolbar items" do
        within "#content" do
          within ".record-toolbar" do
            expect(page).to have_no_css("button.navbar-toggler", visible: true)
            expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Search results", visible: true)
            expect(page).to have_css("a.previous", visible: true)
            expect(page).to have_css("a.next", visible: true)

            within ".navbar" do
              expect(page).to have_css("form label", text: "Bookmark")
              expect(page).to have_link('Cite')
              expect(page).to have_link('Email')
              expect(page).to have_button('Copy link')
              expect(page).to have_button('Print')
            end
          end
        end
      end
    end
  end
end
