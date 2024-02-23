require 'rails_helper'

RSpec.describe SearchWorksRecordMailer do
  include MarcMetadataFixtures
  include ModsFixtures
  let(:documents) {
    [
      SolrDocument.new(
        id: '123',
        title_display: "Title1",
        item_display_struct: [{ barcode: '12345', library: 'GREEN', effective_permanent_location_code: 'SAL3-STACKS', callnumber: 'ABC 123' }],
        marc_links_struct: [{ href: "https://library.stanford.edu", sfx: true }],
        modsxml: mods_everything
      ),
      SolrDocument.new(
        id: '321',
        title_display: "Title2",
        item_display_struct: [{ barcode: '54321', library: 'SAL3', effective_permanent_location_code: 'SAL3-STACKS', callnumber: 'ABC 321' }],
        marc_links_struct: [{ href: "https://stacks.stanford.edu", sfx: true }],
        marc_json_struct: metadata1
      )
    ]
  }
  let(:params) do
    { to: 'email@example.com', message: 'The message', subject: 'The subject', email_from: 'Jane Stanford' }
  end
  let(:url_params) { { host: 'example.com' } }

  describe 'email_record' do
    context 'article' do
      let(:documents) { [SolrDocument.new(id: '123', eds_title: 'Title1', eds_authors: ['Author1'], eds_fulltext_links: [{ 'label' => 'View request options', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
        )]}
      let(:mail) { SearchWorksRecordMailer.article_email_record(documents, params, url_params) }

      it 'should send an HTML email' do
        expect(mail.content_type).to match "text/html; charset=UTF-8"
      end

      it 'has the subject that was passed in via method params' do
        expect(mail.subject).to eq 'The subject'
      end

      it 'has the subject that from the document when none was passed in' do
        skip('Need to update subject_from_details ')
        params[:subject] = nil
        mail = SearchWorksRecordMailer.email_record(documents, params, url_params)
        expect(mail.subject).to eq 'Item Record: N/A'
      end

      it 'includes the Email From text when present' do
        expect(mail.body).to include 'Email from: Jane Stanford'
      end

      it 'should include the provided message' do
        expect(mail.body).to include "The message"
      end

      it 'includes the title' do
        expect(mail.body).to include "Title1"
      end

      it 'links to the record' do
        expect(mail.body).to have_link("Title1", href: "http://example.com/articles/123")
      end

      it 'includes links to fulltext' do
        expect(mail.body).to have_link('Find full text or request', href: "http://example.com")
      end
    end

    context 'catalog' do
      let(:mail) { SearchWorksRecordMailer.email_record(documents, params, url_params) }

      it 'should send an HTML email' do
        expect(mail.content_type).to match "text/html; charset=UTF-8"
      end

      it 'has the subject that was passed in via method params' do
        expect(mail.subject).to eq 'The subject'
      end

      it 'has the subject that from the document when none was passed in' do
        params[:subject] = nil
        mail = SearchWorksRecordMailer.email_record([documents.first], params, url_params)
        expect(mail.subject).to eq 'Item Record: Title1'
      end

      it 'includes the Email From text when present' do
        expect(mail.body).to include 'Email from: Jane Stanford'
      end

      it 'should include the provided message' do
        expect(mail.body).to include "The message"
      end

      it 'should include the titles of all documents' do
        expect(mail.body).to include "Title1"
        expect(mail.body).to include "Title2"
      end

      it 'should include the callnumbers' do
        expect(mail.body).to include "Green Library - Stacks"
        expect(mail.body).to include "ABC 123"

        expect(mail.body).to include "SAL3 (off-campus storage) - Stacks"
        expect(mail.body).to include "ABC 321"
      end

      it 'should include the URLs' do
        expect(mail.body).to include "Online:"
        expect(mail.body).to include "https://library.stanford.edu"
        expect(mail.body).to include "https://stacks.stanford.edu"
      end

      it 'should include the URL to all the documents' do
        expect(mail.body).to have_link("Title1", href: "http://example.com/view/123")
        expect(mail.body).to have_link("Title2", href: "http://example.com/view/321")
      end
    end
  end

  describe 'full_email_record' do
    context 'catalog' do
      let(:mail) { SearchWorksRecordMailer.full_email_record(documents, params, url_params) }

      it 'should send a html email' do
        expect(mail.content_type).to match(/text\/html/)
      end

      it 'should include full HTML markup' do
        expect(mail.body).to have_css('html')
        expect(mail.body).to have_css('body')
      end

      it 'includes the Email From text when present' do
        expect(mail.body).to have_css('dt', text: 'Email from')
        expect(mail.body).to have_css('dd', text: 'Jane Stanford')
      end

      it 'should include the titles of all documents as links' do
        expect(mail.body).to have_css('h1 a', text: 'Title1')
        expect(mail.body).to have_css('h1 a', text: 'Title2')
      end

      it 'should include Subjects and Bibliographic information from both MARC and MODS records' do
        expect(mail.body).to have_css('h3', text: 'Subjects', count: 2)
        expect(mail.body).to have_css('h3', text: 'Bibliographic information', count: 2)
      end

      it 'should include the HTML markup for MARC records' do
        expect(mail.body).to have_css('dt', text: 'Related Work')
        expect(mail.body).to have_css('dd', text: 'A quartely publication.')
      end

      it 'should include the HTML markup for MODS records' do
        expect(mail.body).to have_css('dt', text: 'Producer')
        expect(mail.body).to have_css('dd', text: 'B. Smith')
      end

      it 'should include holdings of all documents' do
        expect(mail.body).to have_css('h2', text: 'At the library', count: documents.length)
        expect(mail.body).to have_css('dt', text: 'Green Library - Stacks')

        expect(mail.body).to have_css('dd', text: 'ABC 123')

        expect(mail.body).to have_css('dt', text: 'SAL3 (off-campus storage) - Stacks')
        expect(mail.body).to have_css('dd', text: 'ABC 321')
      end

      it 'should include links of all the documents' do
        expect(mail.body).to have_css('h2', text: 'Online')
        expect(mail.body).to have_css('a', text: 'Find full text', count: documents.length)
      end

      it 'should separate records w/ a horizontal rule' do
        expect(mail.body).to have_css('hr', count: documents.length)
      end

      context 'when there is bookplate data' do
        let(:bookplate_document) do
          SolrDocument.new(
            id: '123',
            marc_json_struct: metadata1,
            bookplates_display: ['FUND-NAME -|- druid:abc123 -|- file-id-abc123.jp2 -|- BOOKPLATE-TEXT']
          )
        end
        let(:mail) { SearchWorksRecordMailer.full_email_record([bookplate_document], params, url_params) }

        it 'renders the bookplate data successfully' do
          expect(mail.body).to have_css('h3', text: 'Acquired with support from')
          expect(mail.body).to have_css('.media-body', text: /BOOKPLATE-TEXT/)
        end
      end
    end

    context 'article' do
      skip('Todo: article full record email')
    end
  end
end
