module Marc856Fixtures
  def many_managed_purl_856
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
                  "a": "Many PURLs for One CKey"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://purl.stanford.edu/ct493wg6431"
                },
                {
                  "x": "SDR-PURL"
                },
                {
                  "x": "file:ct493wg6431%252Fct493wg6431_00_0001.jp2"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://purl.stanford.edu/zg338xh5248"
                },
                {
                  "x": "SDR-PURL"
                },
                {
                  "x": "file:zg338xh5248%252Fzg338xh5248_00_0001.jp2"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def stanford_affiliated_managed_purl_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "x": "SDR-PURL"
                },
                {
                  "x": "file:abc123"
                },
                {
                  "z": "Available to stanford affiliated users at"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def simple_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "3": "Link text 1"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text 2"
                },
                {
                  "z": "Title text1"
                },
                {
                  "z": "Title text2"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def labelless_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def casalini_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "3": "Link text"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "x": "CasaliniTOC"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "Title text1"
                },
                {
                  "z": "Title text2"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def stanford_only_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "Available to stanford affiliated users at:4 at one time"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "Available-to-stanford-affiliated-users-at:"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "3": "Available to stanford affiliated users at"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "Available to stanford affiliated users"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def fulltext_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "1",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def supplemental_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "2",
              "subfields": [
                {
                  "3": "Before text"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "Title text1"
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
                  "y": "Link text"
                },
                {
                  "z": "Title text"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "3": "this is the table of contents"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "3": "this is sample text"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "1",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "this is the abstract"
                }
              ]
            }
          },
          {
            "856": {
              "ind1": "0",
              "ind2": "",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "this is the description"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def finding_aid_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "2",
              "subfields": [
                {
                  "3": "FINDING AID:"
                },
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "y": "Link text"
                },
                {
                  "z": "Title text1"
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
                  "y": "Link text"
                },
                {
                  "z": "This is a finding aid"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def ez_proxy_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://stanford.idm.oclc.org/?url=https://library.stanford.edu"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def ez_proxy_with_spaces_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://stanford.idm.oclc.org/?url=https://library.stanford.edu/url%20that has+spaces"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def no_url_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "y": "Some text"
                }
              ]
            }
          }
        ]
      }
    json
  end

  def managed_purl_856
    <<-json
      {
        "leader": "          22        4500",
        "fields": [
          {
            "856": {
              "ind1": "0",
              "ind2": "0",
              "subfields": [
                {
                  "u": "https://library.stanford.edu"
                },
                {
                  "x": "SDR-PURL"
                },
                {
                  "x": "file:abc123"
                },
                {
                  "x": "label:some label"
                },
                {
                  "x": "sort:123"
                },
                {
                  "y": "Link text 2"
                }
              ]
            }
          }
        ]
      }
    json
  end
end
