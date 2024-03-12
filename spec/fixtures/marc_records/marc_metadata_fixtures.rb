# encoding: UTF-8
# frozen_string_literal: true

module MarcMetadataFixtures
  def metadata1
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "100": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Arbitrary, Stewart."
                },
                {
                  "e": "fantastic."
                },
                {
                  "=": "^A170662"
                }
              ]
            }
          },
          {
            "110": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Arbitrary, Corporate."
                },
                {
                  "e": "fantastic."
                }
              ]
            }
          },
          {
            "111": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Arbitrary Meeting."
                },
                {
                  "j": "fantastic."
                }
              ]
            }
          },
          {
            "245": {
              "ind1": "1",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Some intersting papers,"
                },
                {
                  "c": "Most responsible person ever"
                },
                {
                  "f": "1979-2010."
                }
              ]
            }
          },
          {
            "260": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Imprint Statement"
                }
              ]
            }
          },
          {
            "300": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "53 linear feet (12 manuscript boxes, 6 seven-inch reels, 9 8-track cassettes, 1 micro-cassette, 16 hard disk cartridges)"
                }
              ]
            }
          },
          {
            "351": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Boxes 1-3 correspondence; boxes 4-12 media;"
                }
              ]
            }
          },
          {
            "506": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Open for research; material must be requested at least 36 hours in advance of intended use. "
                }
              ]
            }
          },
          {
            "555": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Unpublished listing available in the department."
                }
              ]
            }
          },
          {
            "541": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "c": "Gift of"
                },
                {
                  "a": "Interesting Papers Intl.,"
                },
                {
                  "d": "2014."
                },
                {
                  "e": "Accession 2014-1."
                }
              ]
            }
          },
          {
            "592": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "A local note"
                },
                {
                  "b": "added to subjects only"
                }
              ]
            }
          },
          {
            "600": {
              "ind1": "1",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Arbitrary, Gregory"
                },
                {
                  "d": "1904-1980."
                },
                {
                  "=": "^A145706"
                }
              ]
            }
          },
          {
            "600": {
              "ind1": "1",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Arbirtrary, Lois."
                },
                {
                  "?": "UNAUTHORIZED"
                }
              ]
            }
          },
          {
            "600": {
              "ind1": "1",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Arbitrary, Stewart."
                },
                {
                  "=": "^A170662"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Computer networks"
                },
                {
                  "x": "Stanford."
                },
                {
                  "=": "^A2097035"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Computers and civilization."
                },
                {
                  "=": "^A1006791"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Information technology"
                },
                {
                  "x": "History"
                },
                {
                  "y": "20th century."
                }
              ]
            }
          },
          {
            "740": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "a": "A quartely publication."
                }
              ]
            }
          },
          {
            "740": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Another catalog."
                }
              ]
            }
          },
          {
            "740": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "a": "A catalog"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "2",
              "subfields": [
                {
                  "3": "Finding aid at:"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "z": "Link title"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "2",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "A different finding aid"
                },
                {
                  "z": "This is the Finding Aid"
                }
              ]
            }
          },
          {
            "035": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "(OCoLC-M)12345678"
                }
              ]
            }
          },
          {
            "035": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "(OCoLC-I)87654321"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def metadata2
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "050": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "a": "PK2788.9.A9"
                },
                {
                  "b": "F55 1998"
                }
              ]
            }
          },
          {
            "100": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Ayaz, Shaikh,"
                },
                {
                  "d": "1923-1997."
                }
              ]
            }
          },
          {
            "245": {
              "ind1": "1",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Fikr-i Ayāz /"
                },
                {
                  "c": "murattibīn, Āṣif Farruk̲h̲ī, Shāh Muḥammad Pīrzādah."
                }
              ]
            }
          },
          {
            "260": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Karācī :"
                },
                {
                  "b": "Dāniyāl,"
                },
                {
                  "c": "[1998]"
                }
              ]
            }
          },
          {
            "300": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "375 p. ;"
                },
                {
                  "c": "23 cm."
                }
              ]
            }
          },
          {
            "505": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "1.First Chapter -- 2.Second Chapter -- "
                }
              ]
            }
          },
          {
            "541": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "541 that shouldn't show"
                }
              ]
            }
          },
          {
            "546": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "In Urdu."
                }
              ]
            }
          },
          {
            "520": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Selected poems and articles from the works of renowned Sindhi poet; chiefly translated from Sindhi."
                }
              ]
            }
          },
          {
            "650": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Subject1"
                },
                {
                  "d": "Subject2"
                }
              ]
            }
          },
          {
            "700": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-04"
                },
                {
                  "a": "Farruk̲h̲ī, Āṣif,"
                },
                {
                  "d": "1959-"
                }
              ]
            }
          },
          {
            "700": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Pīrzādah, Shāh Muḥammad."
                }
              ]
            }
          },
          {
            "760": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "Item that should not show"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "6": "760-01"
                },
                {
                  "a": "Vern that should not display"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "6": "541-01"
                },
                {
                  "a": "541 Vern that should not display"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def matched_vernacular_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "245": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "This is not Vernacular"
                }
              ]
            }
          },
          {
            "505": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-02"
                },
                {
                  "a": "1.This is not Vernacular -- 2.This is also not Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "245-01"
                },
                {
                  "a": "This is Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "505-02"
                },
                {
                  "a": "1.This is Vernacular -- 2.This is also Vernacular"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def unmatched_vernacular_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "245-00"
                },
                {
                  "a": "This is Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "505-00"
                },
                {
                  "a": "1.This is Vernacular -- 2.This is also Vernacular"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def matched_vernacular_rtl_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "245": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "This is NOT Right-to-Left Vernacular"
                }
              ]
            }
          },
          {
            "505": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-02"
                },
                {
                  "a": "1.This is not Vernacular -- 2.This is also not Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "245-01//r"
                },
                {
                  "a": "This is Right-to-Left Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "505-02"
                },
                {
                  "a": "1.This is Vernacular -- 2.This is also Vernacular"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def unmatched_vernacular_rtl_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "245-00//r"
                },
                {
                  "a": "This is Right-to-Left Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "505-00"
                },
                {
                  "a": "1.This is Vernacular -- 2.This is also Vernacular"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def complex_vernacular_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "245": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "245 Matched Romanized"
                }
              ]
            }
          },
          {
            "300": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "300 Unmatched Romanized"
                }
              ]
            }
          },
          {
            "300": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-02"
                },
                {
                  "a": "300 Matched Romanized"
                }
              ]
            }
          },
          {
            "350": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-03"
                },
                {
                  "a": "350 Matched Romanized"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "245-01"
                },
                {
                  "a": "245 Matched Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "300-02"
                },
                {
                  "a": "300 Matched Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "300-00"
                },
                {
                  "a": "300 Unmatched Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "350-03"
                },
                {
                  "a": "350 Matched Vernacular"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def bad_vernacular_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "245": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "This is not Vernacular"
                }
              ]
            }
          },
          {
            "505": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-02"
                },
                {
                  "a": "1.This is not Vernacular -- 2.This is also not Vernacular"
                }
              ]
            }
          },
          {
            "600": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-03"
                },
                {
                  "a": "This is not Vernacular"
                }
              ]
            }
          },
          {
            "610": {
              "ind1": "1",
              "ind2": "0",
              "subfields": [
                {
                  "6": "610-00"
                },
                {
                  "a": "Bad Venacular Matcher"
                }
              ]
            }
          },
          {
            "700": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-04"
                },
                {
                  "a": "This is not Vernacular"
                }
              ]
            }
          },
          {
            "710": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-05"
                },
                {
                  "a": "This is not Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "245-01"
                },
                {
                  "6": "This is Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "505-02"
                },
                {
                  "a": "1.This is Vernacular -- 2.This is also Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "600-03"
                },
                {
                  "b": "This is Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "700-04"
                },
                {
                  "b": "This is Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "710-05"
                },
                {
                  "6": "This is Vernacular"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-00"
                },
                {
                  "6": "This is A vernacular matching field that does not point to a valid field"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def linked_ckey_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "590": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Copy 1 bound with v. 140"
                },
                {
                  "c": "55523 (parent record’s ckey)"
                }
              ]
            }
          },
          {
            "590": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "A 590 that does not have $c"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def unlinked_ckey_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "590": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Electronic reproduction. "
                },
                {
                  "b": "Chicago, Illinois : "
                },
                {
                  "c": "McGraw Hill Education, "
                }
              ]
            }
          }
        ]
      }
    json
  end

  def escape_characters_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "690": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Stanford Artists' Books Collection."
                }
              ]
            }
          },
          {
            "690": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "c": "Stanford > Berkeley."
                }
              ]
            }
          }
        ]
      }
    json
  end

  def relator_code_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "100": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "100 $a"
                },
                {
                  "4": "prf"
                }
              ]
            }
          },
          {
            "100": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "100 $a"
                },
                {
                  "4": "bad-relator"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def language_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "546": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Language $a"
                },
                {
                  "b": "Language $b"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def notation_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "546": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "b": "Notation $b"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def contributed_works_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "700": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Contributor1"
                },
                {
                  "4": "prf"
                }
              ]
            }
          },
          {
            "700": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Contributor2"
                },
                {
                  "4": "prf"
                }
              ]
            }
          },
          {
            "700": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "i": "Includes (expression)"
                },
                {
                  "a": "700 with t"
                },
                {
                  "e": "700 $e"
                },
                {
                  "t": "Title."
                },
                {
                  "m": "sub m after ."
                },
                {
                  "4": "700 $4"
                }
              ]
            }
          },
          {
            "700": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Contributor2"
                },
                {
                  "4": "prf"
                }
              ]
            }
          },
          {
            "710": {
              "ind1": " ",
              "ind2": "2",
              "subfields": [
                {
                  "a": "710 with t ind2"
                },
                {
                  "t": "Title!"
                },
                {
                  "n": "sub n after t"
                }
              ]
            }
          },
          {
            "711": {
              "ind1": " ",
              "ind2": "2",
              "subfields": [
                {
                  "a": "711 with t ind2"
                },
                {
                  "j": "middle"
                },
                {
                  "t": "Title!"
                },
                {
                  "u": "subu."
                },
                {
                  "n": "sub n after ."
                }
              ]
            }
          }
        ]
      }
    json
  end

  def place_name_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "752": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Florida"
                },
                {
                  "d": "Tampa"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def marc_mixed_subject_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "650": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Subject A1"
                }
              ]
            }
          },
          {
            "655": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Subject A1"
                }
              ]
            }
          },
          {
            "690": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Local Subject A1"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def marc_duplicate_subject_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Piano music."
                },
                {
                  "=": "^A1049172"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Waltzes."
                },
                {
                  "=": "^A1328649"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Canons, fugues, etc. (Piano)"
                },
                {
                  "=": "^A1000979"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Marches."
                },
                {
                  "=": "^A1037033"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "6",
              "subfields": [
                {
                  "a": "Piano, Musique de."
                },
                {
                  "v": "Sound recordings."
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "7",
              "subfields": [
                {
                  "a": "Canons, fugues, etc. (Piano)"
                },
                {
                  "2": "fast"
                },
                {
                  "0": "(OCoLC)fst00846007"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "7",
              "subfields": [
                {
                  "a": "Marches."
                },
                {
                  "2": "fast"
                },
                {
                  "0": "(OCoLC)fst01009043"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "7",
              "subfields": [
                {
                  "a": "Piano music."
                },
                {
                  "2": "fast"
                },
                {
                  "0": "(OCoLC)fst01063403"
                }
              ]
            }
          },
          {
            "650": {
              "ind1": " ",
              "ind2": "7",
              "subfields": [
                {
                  "a": "Waltzes."
                },
                {
                  "2": "fast"
                },
                {
                  "0": "(OCoLC)fst01170245"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def related_works_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "740": {
              "ind1": " ",
              "ind2": "2",
              "subfields": [
                {
                  "a": "Contributor1"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def title_change_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "780": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "t": "This is the t subfield for 780"
                },
                {
                  "x": "subfield X"
                }
              ]
            }
          },
          {
            "785": {
              "ind1": "0",
              "ind2": "5",
              "subfields": [
                {
                  "t": "This is the t subfield for 785"
                },
                {
                  "x": "subfield X"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def main_entry_and_title_serial_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "780": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Serial Main Entry"
                },
                {
                  "t": "Serial Title"
                },
                {
                  "s": "Serial Uniform Title"
                }
              ]
            }
          },
          {
            "774": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "i": "Some text:"
                },
                {
                  "z": "Serial ISBN"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def main_entry_and_title_serial_fixture_with_issn
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "780": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Serial Main Entry"
                },
                {
                  "t": "Serial Title"
                },
                {
                  "s": "Serial Uniform Title"
                }
              ]
            }
          },
          {
            "774": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "i": "Some text:"
                },
                {
                  "x": "Serial ISSN"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def only_title_serial_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "780": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "i": "Other Data:"
                },
                {
                  "t": "Serial Title"
                },
                {
                  "s": "Serial Uniform Title"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def merged_with_serial_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "785": {
              "ind1": "0",
              "ind2": "7",
              "subfields": [
                {
                  "a": "Serial Main Entry1"
                }
              ]
            }
          },
          {
            "785": {
              "ind1": "0",
              "ind2": "7",
              "subfields": [
                {
                  "a": "Serial Main Entry2"
                }
              ]
            }
          },
          {
            "785": {
              "ind1": "0",
              "ind2": "7",
              "subfields": [
                {
                  "z": "Serial Main Entry3"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def vernacular_serial_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "780": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "i": "Other Data:"
                },
                {
                  "t": "Serial Title"
                },
                {
                  "s": "Serial Uniform Title"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "6": "780-01"
                },
                {
                  "t": "Vernacular Serial Title"
                },
                {
                  "s": "Vernacular Serial Uniform Title"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def single_marc_264_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "264": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "3": "Subfield3"
                },
                {
                  "a": "SubfieldA"
                },
                {
                  "b": "SubfieldB"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def vernacular_marc_264_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "264": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "SubfieldA"
                },
                {
                  "b": "SubfieldB"
                },
                {
                  "6": "880-01"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": " ",
              "ind2": "0",
              "subfields": [
                {
                  "a": "Vernacular SubfieldA"
                },
                {
                  "b": "Vernacular SubfieldB"
                },
                {
                  "6": "264-01"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def marc_592_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "592": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "A local note"
                },
                {
                  "b": "added to subjects only"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def marc_multi_series_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "440": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "440 $a"
                },
                {
                  "v": "440 $v"
                },
                {
                  "x": "440 $x"
                }
              ]
            }
          },
          {
            "800": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Name"
                },
                {
                  "v": "SubV800"
                },
                {
                  "z": "SubZ"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def complex_series_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "440": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "440 $a"
                },
                {
                  "v": "440 $v"
                },
                {
                  "x": "440 $x"
                }
              ]
            }
          },
          {
            "490": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Linkable 490"
                },
                {
                  "b": "490 $b"
                },
                {
                  "4": "$4 should not display"
                }
              ]
            }
          },
          {
            "490": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Non-linkable 490"
                },
                {
                  "4": "$4 should not display"
                }
              ]
            }
          },
          {
            "800": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Name"
                },
                {
                  "v": "SubV800"
                },
                {
                  "z": "SubZ"
                }
              ]
            }
          },
          {
            "800": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Sub $a 1"
                },
                {
                  "a": "Sub $a 2"
                },
                {
                  "b": "Non-linkable 800"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def uniform_title_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "240": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Instrumental music"
                },
                {
                  "b": "Selections"
                },
                {
                  "h": "[print/digital]."
                }
              ]
            }
          }
        ]
      }
    json
  end

  def marc_characteristics_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "344": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "digital"
                },
                {
                  "b": "optical"
                },
                {
                  "g": "surround"
                },
                {
                  "g": "stereo"
                },
                {
                  "h": "Dolby"
                },
                {
                  "2": "rda"
                }
              ]
            }
          },
          {
            "346": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "b": "NTSC"
                },
                {
                  "2": "rda"
                }
              ]
            }
          },
          {
            "347": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "video file"
                },
                {
                  "b": "DVD video"
                },
                {
                  "e": "Region 1"
                },
                {
                  "2": "rda"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def marc_sections_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "050": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "a": "PK2788.9.A9"
                },
                {
                  "b": "F55 1998"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "2",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "A different finding aid"
                },
                {
                  "z": "This is the Finding Aid"
                }
              ]
            }
          },
          {
            "506": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Open for research; material must be requested at least 36 hours in advance of intended use. "
                }
              ]
            }
          },
          {
            "555": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "Unpublished listing available in the department."
                }
              ]
            }
          },
          {
            "700": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "Contributor"
                },
                {
                  "4": "prf"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "6": "700-01"
                },
                {
                  "a": "Vernacular Contributor"
                },
                {
                  "4": "prf"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def edition_imprint_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "250": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "SubA"
                },
                {
                  "b": "SubB"
                },
                {
                  "z": "SubZ"
                }
              ]
            }
          },
          {
            "260": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "SubA"
                },
                {
                  "b": "SubB"
                },
                {
                  "c": "SubC"
                },
                {
                  "g": "SubG"
                },
                {
                  "z": "SubZ"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def no_fields_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [

        ]
      }
    json
  end

  def marc_382_instrumentation
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "382": {
              "ind1": "0",
              "ind2": "1",
              "subfields": [
                {
                  "a": "singer"
                },
                {
                  "n": "1"
                },
                {
                  "p": "bass guitar"
                },
                {
                  "n": "2"
                },
                {
                  "a": "percussion"
                },
                {
                  "n": "1"
                },
                {
                  "v": "4 hands"
                },
                {
                  "a": "guitar"
                },
                {
                  "n": "1"
                },
                {
                  "d": "electronics"
                },
                {
                  "n": "1"
                },
                {
                  "b": "flute"
                },
                {
                  "n": "1"
                },
                {
                  "s": "8"
                }
              ]
            }
          },
          {
            "382": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "a": "singer"
                },
                {
                  "n": "3"
                }
              ]
            }
          },
          {
            "382": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "cowbell"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def organization_and_arrangement_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "351": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "3": "351 $3"
                },
                {
                  "c": "351 $c"
                },
                {
                  "a": "351 $a"
                },
                {
                  "b": "351 $b"
                },
                {
                  "z": "351 $z"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def linked_author_meeting_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "111": {
              "ind1": "2",
              "ind2": " ",
              "subfields": [
                {
                  "6": "880-01"
                },
                {
                  "a": "Technical Workshop on Organic Agriculture"
                },
                {
                  "n": "(1st :"
                },
                {
                  "d": "2010 :"
                },
                {
                  "c": "Ogbomoso, Nigeria)"
                },
                {
                  "t": "A title"
                },
                {
                  "j": "creator."
                },
                {
                  "4": "oth"
                }
              ]
            }
          },
          {
            "880": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "6": "111-01"
                },
                {
                  "t": "Vernacular Title"
                },
                {
                  "s": "Vernacular Uniform Title"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def physical_medium_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "340": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "a"
                },
                {
                  "c": "c"
                },
                {
                  "d": "d1"
                },
                {
                  "d": "d2"
                },
                {
                  "m": "m"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def linked_related_works_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "730": {
              "ind1": "0",
              "ind2": " ",
              "subfields": [
                {
                  "i": "i1_subfield_text:"
                },
                {
                  "i": "i2_subfield_text:"
                },
                {
                  "a": "a_subfield_text."
                },
                {
                  "d": "d_subfield_text."
                },
                {
                  "f": "f_subfield_text."
                },
                {
                  "k": "k_subfield_text."
                },
                {
                  "l": "l_subfield_text."
                },
                {
                  "h": "h_subfield_text."
                },
                {
                  "m": "m_subfield_text."
                },
                {
                  "n": "n_subfield_text."
                },
                {
                  "o": "o_subfield_text."
                },
                {
                  "p": "p_subfield_text."
                },
                {
                  "r": "r_subfield_text."
                },
                {
                  "s": "s_subfield_text."
                },
                {
                  "t": "t_subfield_text."
                },
                {
                  "x": "x1_subfield_text."
                },
                {
                  "x": "x2_subfield_text."
                },
                {
                  "0": "0_subfield_text."
                },
                {
                  "3": "3_subfield_text."
                },
                {
                  "5": "5_subfield_text."
                },
                {
                  "8": "8_subfield_text."
                }
              ]
            }
          },
          {
            "700": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "700_a_subfield_text"
                },
                {
                  "t": "t_subfield_text."
                }
              ]
            }
          },
          {
            "700": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "700_a_subfield_text"
                }
              ]
            }
          },
          {
            "710": {
              "ind1": " ",
              "ind2": "1",
              "subfields": [
                {
                  "a": "710_with_ind2_1"
                },
                {
                  "t": "t_subfield_text."
                }
              ]
            }
          },
          {
            "710": {
              "ind1": " ",
              "ind2": "2",
              "subfields": [
                {
                  "a": "710_with_ind2_2"
                },
                {
                  "t": "t_subfield_text."
                }
              ]
            }
          },
          {
            "711": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "711_a_subfield_text"
                },
                {
                  "t": "t_subfield_text."
                }
              ]
            }
          },
          {
            "720": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "720_a_subfield_text"
                },
                {
                  "t": "t_subfield_text."
                }
              ]
            }
          }
        ]
      }
    json
  end

  def hoover_request_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "100": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "100 Subfield $a"
                }
              ]
            }
          },
          {
            "245": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "f": "245 Subfield $f"
                }
              ]
            }
          },
          {
            "250": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "250 Subfield $a"
                }
              ]
            }
          },
          {
            "260": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "260 Subfield $a"
                },
                {
                  "b": "260 Subfield $b"
                },
                {
                  "c": "260 Subfield $c"
                }
              ]
            }
          },
          {
            "264": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "c": "264 Subfield $c"
                }
              ]
            }
          },
          {
            "506": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "3": "506 Subfield $3"
                },
                {
                  "a": "506 Subfield $a"
                }
              ]
            }
          },
          {
            "540": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "3": "540 Subfield $3"
                },
                {
                  "a": "540 Subfield $a"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def managed_purl_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "4",
              "ind2": "1",
              "subfields": [
                {
                  "u": "http://purl.stanford.edu/gg853cy1667"
                },
                {
                  "x": "SDR-PURL"
                },
                {
                  "x": "item"
                },
                {
                  "x": "file:gg853cy1667%2Fgg853cy1667_0001.jp2"
                },
                {
                  "x": "label:Some Part Label"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "4",
              "ind2": "1",
              "subfields": [
                {
                  "u": "http://purl.stanford.edu/rw779rf3064"
                },
                {
                  "x": "SDR-PURL"
                },
                {
                  "x": "item"
                },
                {
                  "x": "file:rw779rf3064%2Frw779rf3064_0001.jp2"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def issn_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "022": {
              "ind1": " ",
              "ind2": " ",
              "subfields": [
                {
                  "a": "0041-4034"
                },
                {
                  "z": "1234-1230"
                },
                {
                  "z": "5678-567X any old text"
                },
                {
                  "z": "invalid ISSN"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def doi_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "024": {
              "ind1": "7",
              "ind2": " ",
              "subfields": [
                {
                  "a": "10.1111/j.1600-0447.1938.tb03723.x"
                },
                {
                  "q": "Preface"
                },
                {
                  "2": "doi"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def other_024_fixture
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "024": {
              "ind1": "1",
              "ind2": " ",
              "subfields": [
                {
                  "a": "12345"
                }
              ]
            }
          }
        ]
      }
    json
  end
end
