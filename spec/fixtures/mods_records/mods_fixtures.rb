# encoding: UTF-8
# frozen_string_literal: true

module ModsFixtures
  def mods_001
    <<-xml
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>Reproduction from the Official Map of San Francisco, Showing the District Swept...</title>
        </titleInfo>
        <titleInfo type="alternative">
          <title>San Francisco District Swept by Fire, 1906 (reproduction)</title>
        </titleInfo>
        <name>
          <namePart>B. Smith</namePart>
          <role>
            <roleTerm authority="marcrelator" type="text">Producer</roleTerm>
          </role>
        </name>
        <typeOfResource>still image</typeOfResource>
        <originInfo>
          <dateIssued>copyright 1906</dateIssued>
        </originInfo>
        <subject>
          <topic authority="lcsh">1906 Earthquake</topic>
        </subject>
        <genre authority="lcsh">Photographs</genre>
        <physicalDescription>
          <form>offset lithograph on paper</form>
          <note displayLabel="Dimensions">13-1/4 x 10 inches</note>
          <note displayLabel="Condition">good</note>
        </physicalDescription>
        <abstract displayLabel="Description">Topographical and street map of the western part of the city of San Francisco, with red indicating fire area. Annotations: “Area, approximately 4 square miles”; entire title reads: “Reproduction from the Official Map of San Francisco, Showing the District Swept by Fire of April 18, 19, 20, 1906.”</abstract>
        <tableOfContents>This is an amazing table of contents!</contents>
        <identifier type="local">rd-412</identifier>
        <relatedItem type="host">
          <titleInfo>
            <title>Reid W. Dennis collection of California lithographs, 1850-1906</title>
          </titleInfo>
          <identifier type="uri">https://purl.stanford.edu/sg213ph2100</identifier>
          <typeOfResource collection="yes" />
        </relatedItem>
        <accessCondition type="useAndReproduction">Property rights reside with the repository. Literary rights reside with the creators of the documents or their heirs. To obtain permission to publish or reproduce, please contact the Special Collections Public Services Librarian at speccollref@stanford.edu.</accessCondition>
        <accessCondition type="copyright">Copyright © Stanford University. All Rights Reserved.</accessCondition>
      </mods>
    xml
  end

  def mods_only_title
    <<-xml
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>Reproduction from the Official Map of San Francisco, Showing the District Swept...</title>
        </titleInfo>
        <titleInfo type="alternative">
          <title>San Francisco District Swept by Fire, 1906 (reproduction)</title>
        </titleInfo>
      </mods>
    xml
  end

  def mods_everything
    <<-xml
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>A record with everything</title>
        </titleInfo>
        <titleInfo type="alternative">
          <title>A record</title>
        </titleInfo>
        <name>
          <namePart>J. Smith</namePart>
          <role>
            <roleTerm authority="marcrelator" type="text">Author</roleTerm>
          </role>
        </name>
        <name>
          <namePart>B. Smith</namePart>
          <role>
            <roleTerm authority="marcrelator" type="text">Producer</roleTerm>
          </role>
        </name>
        <typeOfResource>still image</typeOfResource>
        <originInfo>
          <dateIssued>copyright 2014</dateIssued>
        </originInfo>
        <language displayLabel="Lang">
          <languageTerm type="text">Esperanza</languageTerm>
        </language>
        <physicalDescription>
          <note displayLabel="Condition">amazing</note>
        </physicalDescription>
        <subject>
          <topic authority="lcsh">Cats</topic>
          <topic authority="lcsh">Rules</topic>
          <topic authority="lcsh">Everything</topic>
        </subject>
        <abstract>Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet</abstract>
        <targetAudience displayLabel="Who?">Cat loverz</targetAudience>
        <note>Pick up milk</note>
        <note displayLabel="Notez">Pick up milkz</note>
        <relatedItem>
          <titleInfo>
            <title>The collection of everything</title>
          </titleInfo>
          <identifier type="uri">http://fakeurl.stanford.edu/abc123</identifier>
          <typeOfResource collection="yes" />
        </relatedItem>
        <identifier type="uri">http://www.myspace.com/myband</identifier>
        <location>
          <physicalLocation displayLabel="Secret Location">NorCal</physicalLocation>
        </location>
        <accessCondition type="copyright">Copyright © Stanford University. All Rights Reserved.</accessCondition>
      </mods>
    xml
  end

  def mods_file
    <<-xml
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
      <titleInfo>
        <title>This is a file</title>
      </titleInfo>
      <titleInfo type="alternative">
        <title>A file</title>
      </titleInfo>
      <abstract>Nunc venenatis et odio ac elementum. Nulla ornare faucibus laoreet</abstract>
      <typeOfResource>stuff</typeOfResource>
      <name>
        <namePart>J. Smith</namePart>
        <role>
          <roleTerm authority="marcrelator" type="text">Author</roleTerm>
        </role>
      </name>
      </mods>
    xml
  end

  def mods_preferred_citation
    <<-xml
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>This is a document with a preferred citation</title>
        </titleInfo>
        <note displayLabel="Preferred Citation">This is the preferred citation data</note>
      </mods>
    xml
  end
end
