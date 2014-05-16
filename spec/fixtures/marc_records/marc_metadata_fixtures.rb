module MarcMetadataFixtures
  def metadata1
    <<-xml
      <record>
        <datafield tag="100" ind1="1" ind2=" ">
          <subfield code="a">Arbitrary, Stewart.</subfield>
          <subfield code="=">^A170662</subfield>
        </datafield>
        <datafield tag="245" ind1="1" ind2="0">
          <subfield code="a">Some intersting papers,</subfield>
          <subfield code="f">1979-2010.</subfield>
        </datafield>
        <datafield tag="300" ind1=" " ind2=" ">
          <subfield code="a">53 linear feet (12 manuscript boxes, 6 seven-inch reels, 9 8-track cassettes, 1 micro-cassette, 16 hard disk cartridges)</subfield>
        </datafield>
        <datafield tag="351" ind1=" " ind2=" ">
          <subfield code="a">Boxes 1-3 correspondence; boxes 4-12 media;</subfield>
        </datafield>
        <datafield tag="506" ind1=" " ind2=" ">
          <subfield code="a">Open for research; material must be requested at least 36 hours in advance of intended use. </subfield>
        </datafield>
        <datafield tag="555" ind1=" " ind2=" ">
          <subfield code="a">Unpublished listing available in the department.</subfield>
        </datafield>
        <datafield tag="541" ind1=" " ind2=" ">
          <subfield code="c">Gift of</subfield>
          <subfield code="a">Interesting Papers Intl.,</subfield>
          <subfield code="d">2014.</subfield>
          <subfield code="e">Accession 2014-1.</subfield>
        </datafield>
        <datafield tag="600" ind1="1" ind2="0">
          <subfield code="a">Arbitrary, Gregory</subfield>
          <subfield code="d">1904-1980.</subfield>
          <subfield code="=">^A145706</subfield>
        </datafield>
        <datafield tag="600" ind1="1" ind2="0">
          <subfield code="a">Arbirtrary, Lois.</subfield>
          <subfield code="?">UNAUTHORIZED</subfield>
        </datafield>
        <datafield tag="600" ind1="1" ind2="0">
          <subfield code="a">Arbitrary, Stewart.</subfield>
          <subfield code="=">^A170662</subfield>
        </datafield>
        <datafield tag="650" ind1=" " ind2="0">
          <subfield code="a">Computer networks</subfield>
          <subfield code="x">Stanford.</subfield>
          <subfield code="=">^A2097035</subfield>
        </datafield>
        <datafield tag="650" ind1=" " ind2="0">
          <subfield code="a">Computers and civilization.</subfield>
          <subfield code="=">^A1006791</subfield>
        </datafield>
        <datafield tag="650" ind1=" " ind2="0">
          <subfield code="a">Information technology</subfield>
          <subfield code="x">History</subfield>
          <subfield code="y">20th century.</subfield>
        </datafield>
        <datafield tag="740" ind1="0" ind2=" ">
          <subfield code="a">A quartely publication.</subfield>
        </datafield>
        <datafield tag="740" ind1="0" ind2=" ">
          <subfield code="a">Another catalog.</subfield>
        </datafield>
        <datafield tag="740" ind1="0" ind2=" ">
          <subfield code="a">A catalog</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='3'>Finding aid at:</subfield>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='z'>Link title</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>A different finding aid</subfield>
          <subfield code='z'>This is the Finding Aid</subfield>
        </datafield>
        <datafield tag="035" ind1=" " ind2=" ">
          <subfield code="a">(OCoLC-M)12345678</subfield>
        </datafield>
        <datafield tag="035" ind1=" " ind2=" ">
          <subfield code="a">(OCoLC-I)87654321</subfield>
        </datafield>
      </record>
    xml
  end
end
