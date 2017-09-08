require "spec_helper"

describe "Emailing Records", type: :feature, js: true do
  it "should be successful" do
    visit solr_document_path('14')

    within('.record-toolbar') do
      within('li.dropdown') do
        click_button 'Send to'
        within('.dropdown-menu') do
          click_link 'email'
        end
      end
    end

    expect(URI(find('#email_form')['action']).path).to eq(email_solr_document_path('14'))

    within('.modal-dialog') do
      fill_in 'to', with: 'email@example.com'
      find('button[type="submit"]').trigger('click')
    end

    expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)
  end

  context 'article' do
    before { stub_article_service(type: :single, docs: [document]) }
    let(:document) do
      SolrDocument.new(
        id: '123',
        eds_title: 'The title',
        eds_abstract: 'The Abstract',
        eds_subjects_person: '<searchLink fieldCode="SU" term="Person1">Person1</searchLink><br/><searchLink fieldCode="SU" term="Person2">Person2</searchLink>',
        eds_volume: 'The Volumne'
      )
    end

    it 'sends a brief record' do
      visit article_path(document[:id])

      within('.record-toolbar') do
        within('li.dropdown') do
          click_button 'Send to'
          within('.dropdown-menu') do
            click_link 'email'
          end
        end
      end

      expect(URI(find('#email_form')['action']).path).to eq(email_article_path(document))

      within('.modal-dialog') do
        fill_in 'to', with: 'email@example.com'
        find('button[type="submit"]').trigger('click')
      end

      expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)
    end
  end

  context 'emailing a full record' do
    it 'should hide the side-nav-minimap' do
      visit solr_document_path('14')

      within('.record-toolbar') do
        within('li.dropdown') do
          click_button 'Send to'
          within('.dropdown-menu') do
            click_link 'email'
          end
        end
      end

      within('.modal-dialog') do
        fill_in 'to', with: 'email@example.com'
        find('#type_full').trigger('click')

        find('button[type="submit"]').trigger('click')
      end

      # triggers capybara to wait until email is sent
      expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)

      body = Capybara.string(ActionMailer::Base.deliveries.last.body.to_s)

      expect(page).to have_css('.side-nav-minimap', visible: false)
    end
  end
end
