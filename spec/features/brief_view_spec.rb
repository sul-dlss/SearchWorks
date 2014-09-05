require "spec_helper"

feature "Brief View" do
  scenario "Search results", js: true do
    visit catalog_index_path f: {format: ["Book"]}
    page.find('#view-type-dropdown button.dropdown-toggle').click
    page.find('#view-type-dropdown .dropdown-menu li a.view-type-brief').click
    expect(page).to have_css("i.fa.fa-align-justify")
    within '[data-preview-url="/preview/1"]' do
      expect(page).to have_css(".brief-document h3.index_title", text: "An object")
      expect(page).to have_css('.brief-document ul li', text: 'Earth Sciences Library (Branner) : Stacks : G70.212 .A426 2011')
      expect(page).to have_css(".brief-document button.btn-preview", text: "Preview")
      expect(page).to have_css("form.bookmark_toggle label.toggle_bookmark", text: "Select")
    end
    within '[data-preview-url="/preview/10"]' do
      expect(page).to have_css('.brief-document ul li', text: 'Green Library : Stacks : (no call number)')
      expect(page).to have_css('.brief-document ul li', text: 'Chemistry & ChemEng Library (Swain) : Current Periodicals : (no call number)')
      expect(page).to have_css('.brief-document ul li', text: 'Chemistry & ChemEng Library (Swain) : Stacks : ABC')
    end
  end
  pending 'Brief preview', js: true do
    visit catalog_index_path f: {format: ["Book"]}, view: 'brief'
    page.find("button.btn.docid-1").click
    expect(page).to have_css("h3.preview-title", text: "An object")
    expect(page).to have_css("li", text: "1990")
    expect(page).to have_css(".btn-preview", text: "Close")
  end
  scenario "vernacular title" do
    visit catalog_index_path(q: '11')

    within(first('.document')) do
      expect(page).to have_css('h3', text: "Amet ad & adipisicing ex mollit pariatur minim dolore.")
      within('.document-metadata') do
        expect(page).to have_css('li', text: 'Currently, to obtain more information from the weakness of the resultant pain.')
      end
    end
  end
end
