# frozen_string_literal: true

require "rails_helper"

RSpec.describe TocAndSummaryComponent, type: :component do
  let(:document) { SolrDocument.new(summary_struct: summary_struct, toc_struct: toc_struct) }
  let(:summary_struct) { [] }
  let(:toc_struct) { [] }

  before do
    render_inline(described_class.new(document: document))
  end

  context "with no TOCs or summaries" do
    it "renders nothing" do
      expect(page).to have_no_css("ul")
    end
  end

  context "with a TOC" do
    let(:toc_struct) do
      [
        {
          label: "Table of Contents",
          fields: [
            [
              "Chapter 1",
              "Chapter 2",
              "Chapter 3"
            ]
          ]
        }
      ]
    end

    it "renders the TOC as a list" do
      expect(page).to have_css("ul li", text: "Chapter 1")
      expect(page).to have_css("ul li", text: "Chapter 2")
      expect(page).to have_css("ul li", text: "Chapter 3")
    end
  end

  context "with a TOC spanning multiple volumes" do
    let(:toc_struct) do
      [
        {
          label: "Table of Contents",
          fields: [
            [
              "Volume 1: Chapter 1",
              "Volume 1: Chapter 2"
            ],
            [
              "Volume 2: Chapter 1",
              "Volume 2: Chapter 2"
            ]
          ]
        }
      ]
    end

    it "renders both volumes" do
      expect(page).to have_css("ul li", text: "Volume 1: Chapter 1")
      expect(page).to have_css("ul li", text: "Volume 1: Chapter 2")
      expect(page).to have_css("ul li", text: "Volume 2: Chapter 1")
      expect(page).to have_css("ul li", text: "Volume 2: Chapter 2")
    end
  end

  context "with a summary with source" do
    let(:summary_struct) do
      [
        {
          label: "Summary",
          fields: [
            { field: ["This is a summary of the document."] },
            { field: ["This is another paragraph of the summary.", { source: '(source: the publisher)' }] }
          ]
        }
      ]
    end

    it "renders the summary as paragraphs" do
      expect(page).to have_text("This is a summary of the document.")
      expect(page).to have_text("This is another paragraph of the summary.")
    end

    it "renders the source separately" do
      expect(page).to have_css("span.source", text: "source: the publisher")
    end
  end
end
