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
    [{:id=>"5749286",
      :subjects=>["General", "Multidisciplinary"],
      :description=>"A multidisciplinary database which provides full-text for over 4,650 scholarly publications. A great place to start your research."
     },
     {:id=>"6631086",
      :subjects=>["Business", "Economics"],
      :description=>"Provides full-text for over 10,000 scholarly business journals and other sources. Excellent resource for business and economics related topics."
     },
     {:id=>"3964904",
      :subjects=>["Education"],
      :description=>"A database that provides users with ready access to an extensive body of education-related literature."
     },
     {:id=>"7630484",
      :subjects=>["Art", "Architecture and Design"],
      :description=>"Provides access to the entire text of The Dictionary of Art (1996) with constant additions of new material and updates to the text, plus extensive image links."
     },
     {:id=>"7626894",
      :subjects=>["Music"],
      :description=>"Includes the full text with ongoing updates of The New Grove Dictionary of Music and Musicians, 2nd ed. Also includes The New Grove Dictionary of Opera, and The New Grove Dictionary of Jazz, 2nd ed."
     },
     {:id=>"6758881",
      :subjects=>["Sciences", "Humanities", "Social Sciences", "Citation Indexes"],
      :description=>"Web of Knowledge contains science, social sciences, and arts and humanities information from nearly 9,300 of the most prestigious, high impact research journals in the world."
     },
     {:id=>"3942381",
      :subjects=>["Multidisciplinary", "Newspaper articles"],
      :description=>"Provides full-text documents from over 5,900 news, business, legal, medical, and reference publications."
     },
     {:id=>"5608954",
      :subjects=>["Literature", "Humanities"],
      :description=>"A fully searchable library of more than 350,000 works of English and American poetry, drama and prose, 202 full-text literature journals, and other key criticism and reference resources."
     },
     {:id=>"497192",
      :subjects=>["Literature", "Humanities"],
      :description=>"A detailed bibliography of journal articles, books and dissertations covering literature, language and linguistics, folklore, literary theory & criticism, dramatic arts, as well as the historical aspects of printing and publishing."
     },
     {:id=>"4291719",
      :subjects=>["Psychology"],
      :description=>"Contains citations and summaries of journal articles, book chapters, books, and technical reports in the field of psychology and psychological aspects of many related disciplines."
     },
     {:id=>"488729",
      :subjects=>["Sociology", "Social Sciences"],
      :description=>"This database provides access to the international literature in sociology and related disciplines in the social and behavioral sciences."
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
    private
    def database_config
      @database_config ||= SelectedDatabases.config.find do |database|
        database[:id] == self[:id]
      end
    end
  end
end
