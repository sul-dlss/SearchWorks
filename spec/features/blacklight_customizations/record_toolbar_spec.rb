require 'spec_helper'

feature "Record Toolbar" do
  before do
    visit('/catalog/1')
  end

  scenario "should have record toolbar visible", js: true do
    within "#content" do
      expect(page).to have_css("div.record-toolbar.hidden-xs", visible: true)
      expect(page).to have_css("div.record-toolbar.hidden-sm.hidden-md.hidden-lg", visible: false)

      within "div.record-toolbar.hidden-xs" do
        expect(page).to have_css("a.btn.btn-default", text:"Back to results", visible: true)
        expect(page).to have_css("a.previous.disabled", visible: true)
        expect(page).to have_css("a.previous", visible: true)

        expect(page).to have_css("div.record-toolbar-tools", visible: true)

        within "div.record-toolbar-tools" do
          expect(page).to have_css("button.btn.btn-default", text:"Send to", visible: true)
        end
      end

    end
  end

end
