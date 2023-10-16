require 'rails_helper'

RSpec.describe "catalog/record/_marc_contributors" do
  include MarcMetadataFixtures

  describe "Contributors section" do
    before do
      assign(:document, SolrDocument.new(author_struct: [
        {
          contributors: [
            { link: '<a href="...">Contributor1</a>', search: '...', post_text: 'Performer' },
            { link: '<a href="...">Contributor2</a>', search: '...', post_text: 'Performer' },
            { link: '<a href="...">Contributor3</a>', search: '...', post_text: 'Actor' }
          ]
        }
      ]))
      render
    end

    it "should display secondary authors" do
      expect(rendered).to have_css("dt", text: "Contributor")
      expect(rendered).to have_css('dd', count: 3)

      expect(rendered).to have_css("dd a", text: "Contributor1")

      expect(rendered).to have_css("dd a", text: "Contributor2")
      expect(rendered).to have_css("dd", text: /Performer/, count: 2)

      expect(rendered).to have_css("dd a", text: "Contributor3")
      expect(rendered).to have_css("dd", text: /Actor/)
    end
  end
end
