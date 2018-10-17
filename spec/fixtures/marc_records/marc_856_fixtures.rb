module Marc856Fixtures
  def simple_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>Link text 1</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text 2</subfield>
          <subfield code='z'>Title text1</subfield>
          <subfield code='z'>Title text2</subfield>
        </datafield>
      </record>
    xml
  end
  def labelless_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://library.stanford.edu</subfield>
        </datafield>
      </record>
    xml
  end
  def casalini_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>Link text</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='x'>CasaliniTOC</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text1</subfield>
          <subfield code='z'>Title text2</subfield>
        </datafield>
      </record>
    xml
  end
  def stanford_only_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Available to stanford affiliated users at:4 at one time</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Available-to-stanford-affiliated-users-at:</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>Available to stanford affiliated users at</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Available to stanford affiliated users</subfield>
        </datafield>
      </record>
    xml
  end
  def fulltext_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='1'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2=''>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
      </record>
    xml
  end
  def supplemental_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='3'>Before text</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text1</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>this is the table of contents</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>this is sample text</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='1'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>this is the abstract</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2=''>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>this is the description</subfield>
        </datafield>
      </record>
    xml
  end
  def finding_aid_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='3'>FINDING AID:</subfield>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text1</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>This is a finding aid</subfield>
        </datafield>
      </record>
    xml
  end
  def ez_proxy_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://stanford.idm.oclc.org/?url=https://library.stanford.edu</subfield>
        </datafield>
      </record>
    xml
  end

  def ez_proxy_with_spaces_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://stanford.idm.oclc.org/?url=https://library.stanford.edu/url%20that has+spaces</subfield>
        </datafield>
      </record>
    xml
  end

  def no_url_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='y'>Some text</subfield>
        </datafield>
      </record>
    xml
  end

  def managed_purl_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://library.stanford.edu</subfield>
          <subfield code='x'>SDR-PURL</subfield>
          <subfield code='x'>file:abc123</subfield>
          <subfield code='y'>Link text 2</subfield>
        </datafield>
      </record>
    xml
  end

  def many_managed_purl_856
    <<-xml
      <record>
      <datafield tag="245" ind1=" " ind2=" ">
        <subfield code="a">Many PURLs for One CKey</subfield>
      </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://purl.stanford.edu/ct493wg6431</subfield>
          <subfield code='x'>SDR-PURL</subfield>
          <subfield code='x'>file:ct493wg6431%252Fct493wg6431_00_0001.jp2</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>https://purl.stanford.edu/zg338xh5248</subfield>
          <subfield code='x'>SDR-PURL</subfield>
          <subfield code='x'>file:zg338xh5248%252Fzg338xh5248_00_0001.jp2</subfield>
        </datafield>
      </record>
    xml
  end

end
