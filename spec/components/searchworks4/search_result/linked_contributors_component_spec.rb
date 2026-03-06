# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::SearchResult::LinkedContributorsComponent, type: :component do
  let(:document) { SolrDocument.new(author_struct: author_struct) }
  let(:author_struct) { [] }

  before do
    render_inline(described_class.new(document: document))
  end

  context "with no contributors" do
    it "does not render" do
      expect(page).to have_no_css('ul')
    end
  end

  context "with contributors" do
    let(:author_struct) do
      [
        {
          'creator' => [
            { 'link' => 'Smith, John.', 'search' => 'Smith, John.', 'post_text' => 'editor' }
          ],
          'corporate_author' => [
            { 'link' => 'Acme Corporation', 'search' => 'Acme Corporation', 'post_text' => 'funder.' }
          ],
          'meeting' => [
            { 'link' => 'International Conference on Testing', 'search' => 'International Conference on Testing' }
          ],
          'contributors' => [
            { 'link' => 'Doe, Jane', 'search' => 'Doe, Jane', 'post_text' => ', illustrator.' }
          ]
        }
      ]
    end

    it "renders the names without trailing punctuation" do
      expect(page).to have_css('ul li', text: 'Smith, John, editor')
    end

    it "renders the contributor roles without trailing punctuation" do
      expect(page).to have_css('ul li', text: 'Acme Corporation, funder')
    end

    it "uses a fallback role based on the field type when no explicit role is provided" do
      expect(page).to have_css('ul li', text: 'International Conference on Testing, meeting')
    end

    it "normalizes role text using comma" do
      expect(page).to have_css('ul li', text: 'Doe, Jane, illustrator')
    end

    it "renders a quoted search link for each contributor" do
      expect(page).to have_link('Smith, John', href: /catalog\?q=%22Smith%2C\+John%22&search_field=search_author/)
    end
  end

  context "with contributors with vernacular names" do
    let(:author_struct) do
      [
        {
          'creator' => [
            { 'link' => 'Bondarenko, Sergeĭ,',
              'search' => 'Bondarenko, Sergeĭ,',
              'vern' => {
                'link' => 'Бондаренко, Сергей,',
                'search' => 'Бондаренко, Сергей,'
              } }
          ]
        }
      ]
    end

    it "renders the transliterated name in parentheses" do
      expect(page).to have_css('ul li', text: 'Бондаренко, Сергей (Bondarenko, Sergeĭ), author/creator')
    end

    it "renders a search link for the transliterated name" do
      expect(page).to have_link('Bondarenko, Sergeĭ')
    end

    it "renders a search link for the vernacular name" do
      expect(page).to have_link('Бондаренко, Сергей')
    end
  end
end
