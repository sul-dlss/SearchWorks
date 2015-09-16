module Marc856Fixtures
  def simple_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>Link text 1</subfield>
          <subfield code='u'>http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://library.stanford.edu</subfield>
        </datafield>
      </record>
    xml
  end
  def casalini_856
    <<-xml
      <record>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>Link text</subfield>
          <subfield code='u'>http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Available to stanford affiliated users at:4 at one time</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Available-to-stanford-affiliated-users-at:</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>Available to stanford affiliated users at</subfield>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='u'>http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='1'>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2=''>
          <subfield code='u'>http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text1</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>this is the table of contents</subfield>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='0'>
          <subfield code='3'>this is sample text</subfield>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='1'>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>this is the abstract</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2=''>
          <subfield code='u'>http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>Link text</subfield>
          <subfield code='z'>Title text1</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='u'>http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://ezproxy.stanford.edu/?url=http://library.stanford.edu</subfield>
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
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='x'>file:abc123</subfield>
          <subfield code='y'>Link text 2</subfield>
        </datafield>
      </record>
    xml
  end
end
