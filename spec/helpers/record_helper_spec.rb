require "spec_helper"

describe RecordHelper do
  let(:empty_field) { OpenStruct.new({label: "test", values: [""] }) }
  describe "mods_display_label" do
    it "should return correct label" do
      expect(helper.mods_display_label("test:")).to_not have_content ":"
      expect(helper.mods_display_label("test:")).to have_css("dt", text: "test")
    end
  end

  describe "mods_display_content" do
    it "should return correct content" do
      expect(helper.mods_display_content("hello, there")).to have_css("dd", text: "hello, there")
    end
    it "should return multiple dd elements when a multi-element array is passed" do
      expect(helper.mods_display_content(["hello", "there"])).to have_css("dd", count: 2)
    end
    it "should handle nil values correctly" do
      expect(helper.mods_display_content(['something', nil])).to have_css("dd", count: 1)
    end
  end

  describe "mods_record_field" do
    let(:mods_field)  { OpenStruct.new({label: "test", values: ["hello, there"]}) }
    let(:url_field)  { OpenStruct.new({label: "test", values: ["http://library.stanford.edu"]}) }
    it "should return correct content" do
      expect(helper.mods_record_field(mods_field)).to have_css("dt", text: "test")
      expect(helper.mods_record_field(mods_field)).to have_css("dd", text: "hello, there")
    end
    it "should link fields with URLs" do
      expect(mods_record_field(url_field)).to have_css("a[href='http://library.stanford.edu']", text: "http://library.stanford.edu")
    end
    it "should not print empty labels" do
      expect(helper.mods_record_field(empty_field)).to_not be_present
    end
  end
  describe "names" do
    let(:name_field) {
      OpenStruct.new(
        label: "Contributor",
        values: [
          OpenStruct.new(name: "Winefrey, Oprah", roles: ["Host", "Producer"]),
          OpenStruct.new(name: "Kittenz, Emergency")
        ]
      )
    }
    describe "#mods_name_field" do
      it "should join the label and values" do
        name = mods_name_field(name_field)
        expect(name).to match /<dt>Contributor<\/dt>/
        expect(name).to match /<dd><a href.*<\/dd>/
      end
      it "should not print empty labels" do
        expect(mods_name_field(empty_field)).to_not be_present
      end
    end
    describe "#mods_primary_names" do
      let(:author_creator) {
        OpenStruct.new(
          label: "Author/Creator",
          values: [
            OpenStruct.new(name: "Jane Lathrop")
          ]
        )
      }
      let(:primary_contributor) {
        OpenStruct.new(
          label: "Contributor",
          values: [
            OpenStruct.new(name: "Jane Lathrop", roles: ["Author"])
          ]
        )
      }
      it "should identify primary authors by label" do
        expect(mods_primary_names([author_creator])).to be_present
      end
      it "should identify primary authors by role" do
        expect(mods_primary_names([primary_contributor])).to be_present
      end
      it "should not include secondary authors" do
        expect(mods_primary_names([name_field])).to_not be_present
      end
    end
    describe "#mods_secondary_names" do
      let(:primary_authors) {
        OpenStruct.new(
          label: "Contributor",
          values: [
            OpenStruct.new(name: "Primary1", roles: ['Author']),
            OpenStruct.new(name: "Primary2", roles: ['Creator'])
          ]
        )
      }
      it "should identify secondary authors" do
        expect(mods_secondary_names([name_field])).to be_present
        expect(mods_secondary_names([name_field]).length).to eq 1
        expect(mods_secondary_names([name_field]).first.values.length).to eq 2
      end
      it "should not include primary authors" do
        expect(mods_secondary_names([primary_authors])).to_not be_present
      end
    end
    describe "#mods_display_name" do
      let(:name) { mods_display_name(name_field.values) }
      it "should link to the name" do
        expect(name).to match /<a href=.*%22Winefrey%2C\+Oprah%22.*>Winefrey, Oprah<\/a>/
        expect(name).to match /<a href=.*%22Kittenz%2C\+Emergency%22.*>Kittenz, Emergency<\/a>/
      end
      it "should link to an author search" do
        expect(name).to match /<a href.*search_field=search_author.*>/
      end
      it "should join the person's roles" do
        expect(name).to match /\(Host, Producer\)/
      end
      it "should not attempt to print empty roles" do
        expect(name).not_to match /\(\)/
      end
    end
  end
  describe "subjects" do
    let(:subjects) { [OpenStruct.new(label: 'Subjects', values: [["Subject1a", "Subject1b"], ["Subject2a", "Subject2b", "Subject2c"]])] }
    let(:name_subjects) { [OpenStruct.new(label: 'Subjects', values: [OpenStruct.new(name: "Person Name", roles: ["Role1", "Role2"])])] }
    let(:genres) { [OpenStruct.new(label: 'Genres', values: ["Genre1", "Genre2", "Genre3"])] }
    describe "#mods_subject_field" do
      it "should join the subject fields in a dd" do
        expect(mods_subject_field(subjects)).to match /<dd><a href=*.*\">Subject1a*.*Subject1b<\/a><\/dd><dd><a/
      end
      it "should join the individual subjects with a '>'" do
        expect(mods_subject_field(subjects)).to match /Subject2b<\/a> &gt; <a href/
      end
      it "should not print empty labels" do
        expect(mods_subject_field(empty_field)).to_not be_present
      end
    end
    describe "#mods_genre_field" do
      it "should join the genre fields with a dd" do
        expect(mods_genre_field(genres)).to match /<dd><a href=*.*>Genre1*.*<\/a><\/dd><dd><a*.*Genre2<\/a><\/dd>/
      end
      it "should not print empty labels" do
        expect(mods_genre_field(empty_field)).to_not be_present
      end
    end
    describe "#link_mods_subjects" do
      let(:linked_subjects) { link_mods_subjects(subjects.first.values.last) }
      it "should return all subjects" do
        expect(linked_subjects.length).to eq 3
      end
      it "should link to the subject hierarchically" do
        expect(linked_subjects[0]).to match /^<a href=.*q=%22Subject2a%22.*>Subject2a<\/a>$/
        expect(linked_subjects[1]).to match /^<a href=.*q=%22Subject2a\+Subject2b%22.*>Subject2b<\/a>$/
        expect(linked_subjects[2]).to match /^<a href=.*q=%22Subject2a\+Subject2b\+Subject2c%22.*>Subject2c<\/a>$/
      end
      it "should link to subject terms search field" do
        linked_subjects.each do |subject|
          expect(subject).to match /search_field=subject_terms/
        end
      end
    end
    describe "#link_mods_genres" do
      let(:linked_genres) { link_mods_genres(genres.first.values.last) }
      it "should return correct link" do
        expect(linked_genres).to match /<a href=*.*Genre3*.*<\/a>/
      end
      it "should link to subject terms search field" do
        expect(linked_genres).to match /search_field=subject_terms/
      end
    end
    describe "#link_to_mods_subject" do
      it "should handle subjects that behave like names" do
        name_subject = link_to_mods_subject(name_subjects.first.values.first, [])
        expect(name_subject).to match /<a href=.*%22Person\+Name%22.*>Person Name<\/a> \(Role1, Role2\)/
      end
    end
  end
  describe "#link_urls_and_email" do
    let(:url) { "This is a field that contains an http://library.stanford.edu URL" }
    let(:email) { "This is a field that contains an email@email.com address" }
    it "should link URLs" do
      expect(link_urls_and_email(url)).to eq "This is a field that contains an <a href='http://library.stanford.edu'>http://library.stanford.edu</a> URL"
    end
    it "should link email addresses" do
      expect(link_urls_and_email(email)).to eq "This is a field that contains an <a href='mailto:email@email.com'>email@email.com</a> address"
    end
  end
end
