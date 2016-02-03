# encoding: UTF-8
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
          <subfield code="c">Most responsible person ever</subfield>
          <subfield code="f">1979-2010.</subfield>
        </datafield>
        <datafield tag="260" ind1=" " ind2=" ">
          <subfield code="a">Imprint Statement</subfield>
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
        <datafield tag="592" ind1=" " ind2=" ">
          <subfield code="a">A local note</subfield>
          <subfield code="b">added to subjects only</subfield>
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
  def metadata2
    <<-xml
      <record>
        <datafield tag="050" ind1="0" ind2="0">
          <subfield code="a">PK2788.9.A9</subfield>
          <subfield code="b">F55 1998</subfield>
        </datafield>
        <datafield tag="100" ind1="1" ind2=" ">
          <subfield code="a">Ayaz, Shaikh,</subfield>
          <subfield code="d">1923-1997.</subfield>
        </datafield>
        <datafield tag="245" ind1="1" ind2="0">
          <subfield code="a">Fikr-i Ayāz /</subfield>
          <subfield code="c">murattibīn, Āṣif Farruk̲h̲ī, Shāh Muḥammad Pīrzādah.</subfield>
        </datafield>
        <datafield tag="260" ind1=" " ind2=" ">
          <subfield code="a">Karācī :</subfield>
          <subfield code="b">Dāniyāl,</subfield>
          <subfield code="c">[1998]</subfield>
        </datafield>
        <datafield tag="300" ind1=" " ind2=" ">
          <subfield code="a">375 p. ;</subfield>
          <subfield code="c">23 cm.</subfield>
        </datafield>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="a">1.First Chapter -- 2.Second Chapter -- </subfield>
        </datafield>
        <datafield tag="541" ind1="0" ind2=" ">
          <subfield code="6">880-01</subfield>
          <subfield code="a">541 that shouldn't show</subfield>
        </datafield>
        <datafield tag="546" ind1=" " ind2=" ">
          <subfield code="a">In Urdu.</subfield>
        </datafield>
        <datafield tag="520" ind1=" " ind2=" ">
          <subfield code="a">Selected poems and articles from the works of renowned Sindhi poet; chiefly translated from Sindhi.</subfield>
        </datafield>
        <datafield tag="650" ind1="1" ind2=" ">
          <subfield code="a">Subject1</subfield>
          <subfield code="d">Subject2</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Farruk̲h̲ī, Āṣif,</subfield>
          <subfield code="d">1959-</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Pīrzādah, Shāh Muḥammad.</subfield>
        </datafield>
        <datafield tag="760" ind1="1" ind2=" ">
          <subfield code="6">880-00</subfield>
          <subfield code="a">Item that should not show</subfield>
        </datafield>
        <datafield tag="880" ind1="1" ind2=" ">
          <subfield code="6">760-00</subfield>
          <subfield code="a">Vern that should not display</subfield>
        </datafield>
        <datafield tag="880" ind1="0" ind2=" ">
          <subfield code="6">541-00</subfield>
          <subfield code="a">541 Vern that should not display</subfield>
        </datafield>
      </record>
    xml
  end
  def matched_vernacular_fixture
    <<-xml
      <record>
        <datafield tag="245" ind1=" " ind2=" ">
          <subfield code="6">880-01</subfield>
          <subfield code="a">This is not Vernacular</subfield>
        </datafield>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="6">880-02</subfield>
          <subfield code="a">1.This is not Vernacular -- 2.This is also not Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">245-01</subfield>
          <subfield code="a">This is Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">505-02</subfield>
          <subfield code="a">1.This is Vernacular -- 2.This is also Vernacular</subfield>
        </datafield>
      </record>
    xml
  end
  def unmatched_vernacular_fixture
    <<-xml
      <record>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">245-00</subfield>
          <subfield code="a">This is Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">505-00</subfield>
          <subfield code="a">1.This is Vernacular -- 2.This is also Vernacular</subfield>
        </datafield>
      </record>
    xml
  end
  def matched_vernacular_rtl_fixture
    <<-xml
      <record>
        <datafield tag="245" ind1=" " ind2=" ">
          <subfield code="6">880-01</subfield>
          <subfield code="a">This is NOT Right-to-Left Vernacular</subfield>
        </datafield>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="6">880-02</subfield>
          <subfield code="a">1.This is not Vernacular -- 2.This is also not Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">245-01//r</subfield>
          <subfield code="a">This is Right-to-Left Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">505-02</subfield>
          <subfield code="a">1.This is Vernacular -- 2.This is also Vernacular</subfield>
        </datafield>
      </record>
    xml
  end
  def unmatched_vernacular_rtl_fixture
    <<-xml
      <record>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">245-00//r</subfield>
          <subfield code="a">This is Right-to-Left Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">505-00</subfield>
          <subfield code="a">1.This is Vernacular -- 2.This is also Vernacular</subfield>
        </datafield>
      </record>
    xml
  end
  def bad_vernacular_fixture
    <<-xml
      <record>
        <datafield tag="245" ind1=" " ind2=" ">
          <subfield code="6">880-01</subfield>
          <subfield code="a">This is not Vernacular</subfield>
        </datafield>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="6">880-02</subfield>
          <subfield code="a">1.This is not Vernacular -- 2.This is also not Vernacular</subfield>
        </datafield>
        <datafield tag="600" ind1=" " ind2=" ">
          <subfield code="6">880-03</subfield>
          <subfield code="a">This is not Vernacular</subfield>
        </datafield>
        <datafield tag="700" ind1=" " ind2=" ">
          <subfield code="6">880-04</subfield>
          <subfield code="a">This is not Vernacular</subfield>
        </datafield>
        <datafield tag="710" ind1=" " ind2=" ">
          <subfield code="6">880-05</subfield>
          <subfield code="a">This is not Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="a">245-01</subfield>
          <subfield code="6">This is Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="a">505-02</subfield>
          <subfield code="a">1.This is Vernacular -- 2.This is also Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="a">600-03</subfield>
          <subfield code="b">This is Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="a">700-04</subfield>
          <subfield code="b">This is Vernacular</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="a">710-05</subfield>
          <subfield code="6">This is Vernacular</subfield>
        </datafield>
      </record>
    xml
  end
  def linking_fields_fixture
    <<-xml
      <record>
        <datafield tag="519" ind1=" " ind2=" ">
          <subfield code="u">http://socrates.stanford.edu</subfield>
        </datafield>
        <datafield tag="520" ind1=" " ind2=" ">
          <subfield code="u">http://searchworks.stanford.edu</subfield>
        </datafield>
        <datafield tag="530" ind1=" " ind2=" ">
          <subfield code="u">library.stanford.edu</subfield>
        </datafield>
      </record>
    xml
  end
  def nielsen_fixture
    <<-xml
      <record>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="a">ContentNote1 -- ContentNote2</subfield>
        </datafield>
        <datafield tag="520" ind1=" " ind2=" ">
          <subfield code="a">Note Field</subfield>
        </datafield>
        <datafield tag="905" ind1=" " ind2=" ">
          <subfield code="a">NielsenNote1 -- NielsenNote2</subfield>
          <subfield code="1">Nielsen</subfield>
        </datafield>
        <datafield tag="920" ind1=" " ind2=" ">
          <subfield code="a">Nielsen Field</subfield>
          <subfield code="1">Nielsen</subfield>
        </datafield>
      </record>
    xml
  end
  def tagged_nielsen_fixture
    <<-xml
      <record>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="a">ContentNote1 -- ContentNote2 -- </subfield>
          <subfield code="r">Linked -- Field</subfield>
        </datafield>
        <datafield tag="905" ind1=" " ind2=" ">
          <subfield code="a">NielsenNote1 -- NielsenNote2</subfield>
          <subfield code="1">Nielsen</subfield>
        </datafield>
      </record>
    xml
  end
  def linked_ckey_fixture
    <<-xml
      <record>
        <datafield tag="590" ind1=" " ind2=" ">
          <subfield code="a">Copy 1 bound with v. 140</subfield>
          <subfield code="c">55523 (parent record’s ckey)</subfield>
        </datafield>
      </record>
    xml
  end
  def escape_characters_fixture
    <<-xml
      <record>
        <datafield tag="690" ind1=" " ind2=" ">
          <subfield code="a">Stanford Artists' Books Collection.</subfield>
        </datafield>
        <datafield tag="690" ind1=" " ind2=" ">
          <subfield code="c">Stanford > Berkeley.</subfield>
        </datafield>
      </record>
    xml
  end
  def percent_fixture
    <<-xml
      <record>
        <datafield tag="245" ind1="1" ind2="0">
          <subfield code="a">%Bad Field</subfield>
          <subfield code="c">Good Field</subfield>
        </datafield>
        <datafield tag="650" ind1="1" ind2=" ">
          <subfield code="a">%Subject1</subfield>
          <subfield code="d">Subject2</subfield>
        </datafield>
      </record>
    xml
  end
  def contributor_fixture
    <<-xml
      <record>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor1</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor2</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor3</subfield>
          <subfield code="e">Actor</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
      </record>
    xml
  end
  def contributed_works_fixture
    <<-xml
      <record>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor1</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor2</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
        <datafield tag="700" ind1=" " ind2=" ">
          <subfield code="i">Includes (expression)</subfield>
          <subfield code="a">700 with t</subfield>
          <subfield code="e">700 $e</subfield>
          <subfield code="t">Title.</subfield>
          <subfield code="m">sub m after .</subfield>
          <subfield code="4">700 $4</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor2</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
        <datafield tag="710" ind1=" " ind2="2">
          <subfield code="a">710 with t ind2</subfield>
          <subfield code="t">Title!</subfield>
          <subfield code="n">sub n after t</subfield>
        </datafield>
        <datafield tag="711" ind1=" " ind2="2">
          <subfield code="a">711 with t ind2</subfield>
          <subfield code="t">Title!</subfield>
          <subfield code="u">subu.</subfield>
          <subfield code="n">sub n after .</subfield>
        </datafield>
      </record>
    xml
  end
  def multi_role_contributor_fixture
    <<-xml
      <record>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor1</subfield>
          <subfield code="e">actor.</subfield>
          <subfield code="e">director.</subfield>
        </datafield>
      </record>
    xml
  end
  def bad_toc_fixture
    <<-xml
      <record>
        <datafield tag="505" ind1=" " ind2=" ">
          <subfield code="a">1.First Chapter -- 2.Second Chapter</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">505-00</subfield>
          <subfield code="a">1.Vernacular1 -- 2.Vernacular2</subfield>
        </datafield>
      </record>
    xml
  end
  def multi_a_subject_fixture
    <<-xml
      <record>
        <datafield tag="650" ind1="1" ind2=" ">
          <subfield code="a">Subject A1</subfield>
          <subfield code="a">Subject A2</subfield>
          <subfield code="a">Subject A3</subfield>
          <subfield code="a">Subject A4</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_655_subject_fixture
    <<-xml
      <record>
        <datafield tag="655" ind1="1" ind2=" ">
          <subfield code="a">Subject A1</subfield>
          <subfield code="v">Subject V1</subfield>
          <subfield code="x">Subject X1</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_mixed_subject_fixture
    <<-xml
      <record>
      <datafield tag="650" ind1="1" ind2=" ">
        <subfield code="a">Subject A1</subfield>
      </datafield>
        <datafield tag="655" ind1="1" ind2=" ">
          <subfield code="a">Subject A1</subfield>
        </datafield>
      </record>
    xml
  end
  def multi_vxyz_subject_fixture
    <<-xml
      <record>
        <datafield tag="650" ind1="1" ind2=" ">
          <subfield code="a">Subject A</subfield>
          <subfield code="b">Subject B</subfield>
          <subfield code="c">Subject C</subfield>
          <subfield code="v">Subject V</subfield>
          <subfield code="x">Subject X</subfield>
          <subfield code="y">Subject Y</subfield>
          <subfield code="z">Subject Z</subfield>
        </datafield>
      </record>
    xml
  end
  def collection_690_fixture
    <<-xml
      <record>
        <datafield tag="650" ind1="1" ind2=" ">
          <subfield code="a">Subject1</subfield>
          <subfield code="d">Subject2</subfield>
        </datafield>
        <datafield tag="690" ind1="1" ind2=" ">
          <subfield code="a">Subject Collection 1</subfield>
        </datafield>
      </record>
    xml
  end
  def ordered_subjects_fixture
    <<-xml
      <record>
        <datafield tag="651" ind1="1" ind2=" ">
          <subfield code="a">Subject 651</subfield>
        </datafield>
        <datafield tag="650" ind1="1" ind2=" ">
          <subfield code="a">Subject 650</subfield>
        </datafield>
      </record>
    xml
  end
  def related_works_fixture
    <<-xml
      <record>
        <datafield tag="730" ind1=" " ind2=" ">
          <subfield code="a">Contributor1</subfield>
        </datafield>
        <datafield tag="740" ind1=" " ind2="2">
          <subfield code="a">Contributor1</subfield>
        </datafield>
      </record>
    xml
  end
  def title_change_fixture
    <<-xml
      <record>
        <datafield tag="780" ind1="0" ind2="0">
          <subfield code="t">This is the t subfield for 780</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="0">
          <subfield code="t">This is the t subfield for 785</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
      </record>
    xml
  end
  def title_change_alt_subs_fixture
    <<-xml
      <record>
        <datafield tag="780" ind1="0" ind2="0">
          <subfield code="t">This is the t subfield for 780</subfield>
          <subfield code="z">780 subfield Z</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="0">
          <subfield code="s">785 subfield S</subfield>
          <subfield code="t">This is the t subfield for 785</subfield>
        </datafield>
      </record>
    xml
  end
  def title_change_sub_w_fixture
    <<-xml
      <record>
        <datafield tag="780" ind1="0" ind2="0">
          <subfield code="t">This is the t subfield for 780</subfield>
          <subfield code="w">subfield W</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="0">
          <subfield code="t">This is the t subfield for 785</subfield>
          <subfield code="w">subfield W</subfield>
        </datafield>
      </record>
    xml
  end
  def title_change_ind2_fixture
    <<-xml
      <record>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the t subfield for 785</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the 2nd t subfield for 785</subfield>
          <subfield code="x">second subfield X</subfield>
        </datafield>
      </record>
    xml
  end
  def title_change_3_785_fixture
    <<-xml
      <record>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the t subfield for 785</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the 2nd t subfield for 785</subfield>
          <subfield code="x">second subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the 3rd t subfield for 785</subfield>
          <subfield code="x">third subfield X</subfield>
        </datafield>
      </record>
    xml
  end
  def complex_title_change_fixture
    <<-xml
      <record>
        <datafield tag="785" ind1="0" ind2="2">
          <subfield code="t">This is the t subfield for 785 ind2 = 2</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the t subfield for 785</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="7">
          <subfield code="t">This is the 2nd t subfield for 785</subfield>
          <subfield code="x">second subfield X</subfield>
        </datafield>
        <datafield tag="785" ind1="0" ind2="8">
          <subfield code="t">This is the t subfield for 785 ind2 = 8</subfield>
          <subfield code="x">subfield X</subfield>
        </datafield>
      </record>
    xml
  end
  def single_marc_264_fixture
    <<-xml
      <record>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="3">Subfield3</subfield>
          <subfield code="a">SubfieldA</subfield>
          <subfield code="b">SubfieldB</subfield>
        </datafield>
      </record>
    xml
  end
  def multiple_marc_264_fixture
    <<-xml
      <record>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">SubfieldA</subfield>
          <subfield code="b">SubfieldB</subfield>
        </datafield>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">AnotherSubfieldA</subfield>
          <subfield code="b">AnotherSubfieldB</subfield>
        </datafield>
      </record>
    xml
  end
  def complex_marc_264_fixture
    <<-xml
      <record>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">Production SubfieldA</subfield>
          <subfield code="b">Production SubfieldB</subfield>
        </datafield>
        <datafield tag="264" ind1="3" ind2="1">
          <subfield code="a">SubfieldA</subfield>
          <subfield code="b">SubfieldB</subfield>
        </datafield>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">Another Production SubfieldA</subfield>
          <subfield code="b">Another Production SubfieldB</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_264_copyright_fixture
    <<-xml
      <record>
        <datafield tag="250" ind1=" " ind2="0">
          <subfield code="a">250 SubA</subfield>
        </datafield>
        <datafield tag="264" ind1=" " ind2="4">
          <subfield code="a">copyright</subfield>
        </datafield>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">264 SubA</subfield>
        </datafield>
      </record>
    xml
  end
  def vernacular_marc_264_fixture
    <<-xml
      <record>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">SubfieldA</subfield>
          <subfield code="b">SubfieldB</subfield>
          <subfield code="6">880-01</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2="0">
          <subfield code="a">Vernacular SubfieldA</subfield>
          <subfield code="b">Vernacular SubfieldB</subfield>
          <subfield code="6">264-01</subfield>
        </datafield>
      </record>
    xml
  end
  def unmatched_vernacular_marc_264_fixture
    <<-xml
      <record>
        <datafield tag="880" ind1=" " ind2="0">
          <subfield code="a">Unmatched vernacular SubfieldA</subfield>
          <subfield code="b">Unmatched vernacular SubfieldB</subfield>
          <subfield code="6">264-00</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_592_fixture
    <<-xml
      <record>
        <datafield tag="592" ind1=" " ind2=" ">
          <subfield code="a">A local note</subfield>
          <subfield code="b">added to subjects only</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_single_series_fixture
    <<-xml
      <record>
        <datafield tag="440" ind1=" " ind2=" ">
          <subfield code="a">Name</subfield>
          <subfield code="v">SubV</subfield>
          <subfield code="z">SubZ</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_multi_series_fixture
    <<-xml
      <record>
        <datafield tag="440" ind1=" " ind2=" ">
          <subfield code="a">440 $a</subfield>
          <subfield code="v">440 $v</subfield>
          <subfield code="x">440 $x</subfield>
        </datafield>
        <datafield tag="800" ind1=" " ind2=" ">
          <subfield code="a">Name</subfield>
          <subfield code="v">SubV800</subfield>
          <subfield code="z">SubZ</subfield>
        </datafield>
      </record>
    xml
  end

  def uniform_title_fixture
    <<-xml
      <record>
        <datafield tag="240" ind1=" " ind2=" ">
          <subfield code="a">Instrumental music</subfield>
          <subfield code="b">Selections</subfield>
          <subfield code="h">[print/digital].</subfield>
        </datafield>
      </record>
    xml
  end

  def uniform_title_fixture2
    <<-xml
      <record>
        <datafield tag="240" ind1=" " ind2=" ">
          <subfield code="a">Instrumental music.</subfield>
          <subfield code="b">Selections</subfield>
        </datafield>
      </record>
    xml
  end

  def marc_characteristics_fixture
    <<-xml
      <record>
        <datafield tag="344" ind1=" " ind2=" ">
          <subfield code="a">digital</subfield>
          <subfield code="b">optical</subfield>
          <subfield code="g">surround</subfield>
          <subfield code="g">stereo</subfield>
          <subfield code="h">Dolby</subfield>
          <subfield code="2">rda</subfield>
        </datafield>
        <datafield tag="346" ind1=" " ind2=" ">
          <subfield code="b">NTSC</subfield>
          <subfield code="2">rda</subfield>
        </datafield>
        <datafield tag="347" ind1=" " ind2=" ">
          <subfield code="a">video file</subfield>
          <subfield code="b">DVD video</subfield>
          <subfield code="e">Region 1</subfield>
          <subfield code="2">rda</subfield>
        </datafield>
      </record>
    xml
  end
  def marc_sections_fixture
    <<-xml
      <record>
        <datafield tag="050" ind1="0" ind2="0">
          <subfield code="a">PK2788.9.A9</subfield>
          <subfield code="b">F55 1998</subfield>
        </datafield>
        <datafield tag='856' ind1='0' ind2='2'>
          <subfield code='u'>http://library.stanford.edu</subfield>
          <subfield code='y'>A different finding aid</subfield>
          <subfield code='z'>This is the Finding Aid</subfield>
        </datafield>
        <datafield tag="506" ind1=" " ind2=" ">
          <subfield code="a">Open for research; material must be requested at least 36 hours in advance of intended use. </subfield>
        </datafield>
        <datafield tag="555" ind1=" " ind2=" ">
          <subfield code="a">Unpublished listing available in the department.</subfield>
        </datafield>
        <datafield tag="700" ind1="1" ind2=" ">
          <subfield code="a">Contributor</subfield>
          <subfield code="4">prf</subfield>
        </datafield>
      </record>
    xml
  end
  def edition_imprint_fixture
    <<-xml
      <record>
        <datafield tag="250" ind1=" " ind2=" ">
          <subfield code="a">SubA</subfield>
          <subfield code="b">SubB</subfield>
          <subfield code="z">SubZ</subfield>
        </datafield>
        <datafield tag="260" ind1=" " ind2=" ">
          <subfield code="a">SubA</subfield>
          <subfield code="b">SubB</subfield>
          <subfield code="c">SubC</subfield>
          <subfield code="g">SubG</subfield>
          <subfield code="z">SubZ</subfield>
        </datafield>
      </record>
    xml
  end
  def vernacular_edition_imprint_fixture
    <<-xml
      <record>
        <datafield tag="250" ind1=" " ind2=" ">
          <subfield code="6">880-01</subfield>
          <subfield code="a">Edition Statement</subfield>
        </datafield>
        <datafield tag="260" ind1=" " ind2=" ">
          <subfield code="6">880-02</subfield>
          <subfield code="a">Imprint Statement</subfield>
        </datafield>
        <datafield tag="260" ind1=" " ind2=" ">
          <subfield code="6">880-03</subfield>
          <subfield code="a">Unmatched Imprint Statement</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">250-01</subfield>
          <subfield code="a">Vernacular Edition Statement</subfield>
        </datafield>
        <datafield tag="880" ind1=" " ind2=" ">
          <subfield code="6">260-02/(2</subfield>
          <subfield code="a">Vernacular Imprint Statement</subfield>
        </datafield>
      </record>
    xml
  end
  def no_fields_fixture
    "<record></record>"
  end
  def marc_382_instrumentation
    <<-xml
      <record>
        <datafield tag="432"></datafield>
        <datafield tag="382" ind1="0" ind2="1">
          <subfield code="a">singer</subfield>
          <subfield code="n">1</subfield>
          <subfield code="d">bass guitar</subfield>
          <subfield code="n">2</subfield>
          <subfield code="a">percussion</subfield>
          <subfield code="n">1</subfield>
          <subfield code="a">guitar</subfield>
          <subfield code="n">1</subfield>
          <subfield code="d">electronics</subfield>
          <subfield code="n">1</subfield>
        </datafield>
        <datafield tag="382" ind1="0" ind2=" ">
          <subfield code="a">singer</subfield>
          <subfield code="n">3</subfield>
        </datafield>
        <datafield tag="382" ind1="1" ind2=" ">
          <subfield code="a">cowbell</subfield>
        </datafield>
      </record>
    xml
  end
  def sw_marc_removed
    <<-xml
      <record>
        <controlfield tag="001">control stuff</controlfield>
        <datafield tag="760" ind1="1" ind2="1">should be removed</datafield>
        <datafield tag="541" ind1="0" ind2="1">should be removed</datafield>
      </record>
    xml
  end
  def sw_marc_not_removed
    <<-xml
      <record>
        <controlfield tag="001">control stuff</controlfield>
        <datafield tag="760" ind1="0" ind2="1">should not be removed</datafield>
        <datafield tag="541" ind1="1" ind2="1">should not be removed</datafield>
      </record>
    xml
  end
end
