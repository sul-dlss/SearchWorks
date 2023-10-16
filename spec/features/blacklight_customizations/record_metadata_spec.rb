require 'rails_helper'

RSpec.feature 'Record view' do
  before do
    visit('/view/10')
  end

  scenario 'should have correct cover image attributes', js: true do
    within 'div.document' do
      expect(page).to have_css('img.cover-image', visible: true)
      expect(page).to have_css(
        'img.cover-image.ISBN0393040801.ISBN9780393040807.OCLC36024029.LCCN96049953', visible: true
      )
      expect(page).to have_css("img.cover-image[data-isbn='ISBN0393040801,ISBN9780393040807']", visible: true)
      expect(page).to have_css("img.cover-image[data-lccn='LCCN96049953']", visible: true)
      expect(page).to have_css("img.cover-image[data-oclc='OCLC36024029']", visible: true)
      expect(find('img.cover-image')['src']).to match(/books\.google\.com.*[?&]id=3xmDzzNiwiUC(&|$)/)
    end
  end

  it 'has schema.org markup' do
    expect(page).to have_css('script[type="application/ld+json"]', text: %r{http://schema.org}, visible: false)
  end
end
