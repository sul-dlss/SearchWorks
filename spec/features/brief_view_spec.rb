require 'rails_helper'

RSpec.describe "Brief View" do
  it "displays catalog search results", :js do
    visit search_catalog_path f: { format: ["Book"] }

    within '#view-type-dropdown' do
      click_button 'View'
      click_link 'brief'
    end
    expect(page).to have_css("i.fa.fa-align-justify")

    within '[data-preview-brief-url-value="/preview/1"]' do
      expect(page).to have_css(".brief-document h3.index_title", text: "An object")
      expect(page).to have_css('.brief-document ul li', text: 'Earth Sciences Library (Branner) : Stacks : G70.212 .A426 2011')
      expect(page).to have_css(".brief-document button.btn-preview", text: "Preview")
      expect(page).to have_css("form.bookmark-toggle label.toggle-bookmark", text: "Select")
    end
    within '[data-preview-brief-url-value="/preview/10"]' do
      expect(page).to have_css('.brief-document ul li', text: 'Green Library : Stacks : HF1604 .G368 2024')
      expect(page).to have_css('.brief-document ul li', text: 'Engineering Library (Terman) : Current periodicals : (no call number)')
      expect(page).to have_css('.brief-document ul li', text: 'Engineering Library (Terman) : Stacks : CBA')
    end
  end

  skip 'Brief preview', :js do
    visit search_catalog_path f: { format: ["Book"] }, view: 'brief'
    page.find("button.btn.docid-1").click
    expect(page).to have_css("h3.preview-title", text: "An object")
    expect(page).to have_css("li", text: "1990")
    expect(page).to have_css(".btn-preview", text: "Close")
  end

  scenario "vernacular title" do
    # TODO: This test has nothing to do with the brief view
    visit search_catalog_path(q: '11')

    within(first('.document')) do
      expect(page).to have_css('h3', text: "Amet ad & adipisicing ex mollit pariatur minim dolore.")
      within('.document-metadata') do
        expect(page).to have_css('li', text: 'Currently, to obtain more information from the weakness of the resultant pain.')
      end
    end
  end

  scenario "Articles search brief view", :js do
    stub_article_service(type: :single, docs: [StubArticleService::SAMPLE_RESULTS.first])
    article_search_for('kittens')
    within '#view-type-dropdown' do
      click_button 'View'
      click_link 'brief'
    end
    expect(page).to have_css("i.fa.fa-align-justify")
    expect(page).to have_css("form.bookmark-toggle label.toggle-bookmark", text: "Select")
  end
end
