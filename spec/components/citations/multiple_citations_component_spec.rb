# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::MultipleCitationsComponent, type: :component do
  let(:component) { described_class.new(documents:) }
  let(:documents) { [SolrDocument.find('in00000053236'), SolrDocument.find('14434124')] }

  before do
    with_request_url "/view/citation?id%5B%5D=in00000053236&id%5B%5D=14434124" do
      with_controller_class BookmarksController do
        allow(vc_test_controller).to receive_messages(current_user: User.new, encrypt_user_id: 123)
        render_inline(component)
      end
    end
  end

  it 'renders the citations to the page' do
    expect(page).to have_css 'h3', text: 'Copy citations'

    expect(page).to have_css 'h4', text: 'APA'
    expect(page).to have_button 'Copy'
    expect(page).to have_content '100 years of radio in South Africa'
    expect(page).to have_content 'Between parents'

    expect(page).to have_css 'h4', text: 'MLA', visible: :hidden

    expect(page).to have_link 'In RIS format (Zotero)'
    expect(page).to have_link 'To RefWorks'
    expect(page).to have_link 'To EndNote'
  end
end
