require "spec_helper"

describe "MARC Metadata in search results" do
  describe "uniform title" do
    before do
      visit root_path
      fill_in 'q', with: '18'
      click_button 'search'
    end
    it "should link the uniform title" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li', text: 'Instrumental music. Selections')
          expect(page).to have_css('li a', text: 'Instrumental music.')
        end
      end
    end
  end
  describe "characteristics" do
    before do
      visit root_path
      fill_in 'q', with: '4'
      click_button 'search'
    end
    it "should join the characteristics with the physical statement" do
      within(first('.document')) do
        expect(page).to have_css('dt', text: 'Video')
        expect(page).to have_css('dd', text: 'The physical statement Sound: digital; optical; surround; stereo; Dolby. Video: NTSC. Digital: video file; DVD video; Region 1.')
      end
    end
  end
  describe "author/creator" do
    before do
      visit root_path
      fill_in 'q', with: '14'
      click_button 'search'
    end
    it "should link the author/creator, corporate author, and meeting" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li a', text: 'Arbitrary, Stewart.')
        end
      end
    end
  end
  describe "corporate author" do
    before do
      visit root_path
      fill_in 'q', with: '15'
      click_button 'search'
    end
    skip "should link the corporate author" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li a', text: 'Scientific Council for Africa South of the Sahara.')
        end
      end
    end
  end
  describe "meeting author" do
    before do
      visit root_path
      fill_in 'q', with: '16'
      click_button 'search'
    end
    skip "should link the meeting author" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li a', text: 'Most Excellent Meeting')
        end
      end
    end
  end
end
