# frozen_string_literal: true

require 'rails_helper'

# Testing Blacklight's RecordMailer because we override sms_record.text.erb
RSpec.describe RecordMailer do
  let(:documents) { [SolrDocument.new(id: 'abc')] }
  let(:url_gen_params) { { host: 'example.com' } }

  describe 'SMS' do
    subject(:mailer) do
      described_class.sms_record(documents, {}, url_gen_params)
    end

    context 'when an item is an article' do
      before { url_gen_params[:_recall] = { controller: 'articles' } }

      it 'links to /articles/:id' do
        expect(mailer.body.to_s).to match(%r{/articles/abc})
      end
    end

    context 'when the item is from the catalog' do
      before { url_gen_params[:_recall] = { controller: 'catalog' } }

      it 'links to /view/:id' do
        expect(mailer.body.to_s).to match(%r{/view/abc})
      end
    end
  end
end
