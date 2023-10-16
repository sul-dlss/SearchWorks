require 'rails_helper'

RSpec.describe IndexAuthors do
  let(:no_authors_document) { SolrDocument.new() }
  let(:document) { SolrDocument.new(
    author_person_full_display: ["Author Person"],
    vern_author_person_full_display: ["Vern Author Person"],
    author_corp_display: ["Author Corp"],
    vern_author_corp_display: ["Vern Author Corp"],
    author_meeting_display: ["Author Meeting", "Author Meeting"],
    vern_author_meeting_display: ["Vern Author Meeting"]
  ) }

  it "should not return anything for a document without authors" do
    expect(no_authors_document.authors_from_index).not_to be_present
  end
  it "should return authors for all supplied types" do
    expect(document.authors_from_index.length).to eq 6
  end
  it "should not have duplicate authors" do
    meeting_text = "Author Meeting"
    author_meeting_display = document[:author_meeting_display]
    meetings = document.authors_from_index.select do |author|
      author == meeting_text
    end
    expect(author_meeting_display).to eq [meeting_text, meeting_text]
    expect(meetings.length).to eq 1
  end
end
