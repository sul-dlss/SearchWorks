class SelectedDatabases
  delegate :each, :map, :length, :in_groups, to: :databases

  def initialize(solr_documents)
    @solr_documents = solr_documents
  end

  def databases
    @databases ||= @solr_documents.map do |solr_document|
      SelectedDatabase.new(solr_document)
    end
  end

  def self.ids
    SelectedDatabases.config.map do |database|
      database[:id]
    end
  end

  def self.config
    [{ id: "5749286",
       subjects: ["General", "Multidisciplinary"],
       description: "Multidisciplinary database of over 4,650 mostly scholarly publications, many full-text; a great place to start your research."
     },
     { id: "6494821",
       subjects: ["Art"],
       description: "Bibliographic database on art and related disciplines; also indexes art reproductions. Coverage begins in 1984, but full-text starts in 1997; a related database, Art Retrospective, indexes articles from 1929-1984",
       see_also: { id: "6666306", text: "Art Retrospective" }
     },
     { id: "6631086",
       subjects: ["Business", "Economics"],
       description: "Provides full-text for over 10,000 scholarly business journals and other sources for business and economics related topics."
     },
     { id: "3964904",
       subjects: ["Education"],
       description: "This database provides users with ready access to an extensive body of education-related literature."
     },
     { id: "8666689",
       subjects: ["World history"],
       description: "Covers the history of the world (excluding the U.S. and Canada) from 1450 to the present, 1955-; some full text.",
       see_also: { id: "8666684", text: "America: History and Life" }
     },
     { id: "6758881",
       subjects: ["Sciences", "Humanities", "Social Sciences", "Citation Indexes"],
       description: "Web of Knowledge provides access to information on science, social sciences, and arts and humanities, as well as search and analysis (citation) tools."
     },
     { id: "3942381",
       subjects: ["Multidisciplinary", "Newspaper articles"],
       description: "Provides full-text documents from over 5,900 news, business, legal, medical, and reference publications.",
       see_also: { id: "9688486", text: "ProQuest News & Newspapers" }
     },
     { id: "497192",
       subjects: ["Literature", "Humanities"],
       description: "A bibliography of journal articles, books and dissertations covering literature, language and linguistics, film, folklore, literary theory & criticism, dramatic arts, as well as the historical aspects of printing and publishing."
     },
     { id: "8785205",
       subjects: ["General", "Multidisciplinary"],
       description: "From business and political science to literature and psychology, access to a wide range of popular academic subjects; includes more than 5,000 titles (over 3,500 in full text) from 1971 forward."
     },
     { id: "4291719",
       subjects: ["Psychology"],
       description: "Contains citations and summaries of journal articles, book chapters, books, and technical reports in the field of psychology and psychological aspects of many related disciplines, 1840-present."
     },
     { id: "375121",
       subjects: ["Music"],
       description: "Comprehensive guide to publications on music from all over the world, with abstracts written in English, 1967-present."
     },
     { id: "8545966",
       subjects: ["Science", "Social Sciences"],
       description: "This large abstract and citation database from Elsevier includes international sources in the scientific, technical, medical and social sciences fields and, more recently, the arts and humanities."
     },
     { id: "488729",
       subjects: ["Sociology", "Social Sciences"],
       description: "Access to the international literature in sociology and related disciplines in the social and behavioral sciences, 1953-present."
     }]
  end

  private

  class SelectedDatabase < ::SolrDocument
    def selected_database_subjects
      database_config[:subjects]
    end

    def selected_database_description
      database_config[:description]
    end

    def selected_database_see_also
      return nil unless database_config[:see_also].present?

      OpenStruct.new(id: database_config[:see_also][:id], text: database_config[:see_also][:text])
    end

    private

    def database_config
      @database_config ||= SelectedDatabases.config.find do |database|
        database[:id] == self[:id]
      end
    end
  end
end
