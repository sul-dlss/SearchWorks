require "spec_helper"

describe "Stanford::NearbyOnShelf", "data-integration": true do
  let(:nearby_obj) { NearbyOnShelf.new("ajax", Blacklight::Configuration.new, { start: "na 1234", field: 'reverse_shelfkey', num: 5 }) }
  let(:shelfkey_field) { "shelfkey" }
  let(:reverse_shelfkey_field) { "reverse_shelfkey" }
  let(:doc1) { SolrDocument.new({
    id: '111',
    title_245a_display: 'title2',
    author_corp_display: 'corp2',
    pub_date: '2002',
    title_sort: 'title2',
    shelfkey: ['dk  3400.300000 b0.100000', 'dk  3400.300000 b0.200000'],
    preferred_barcode: "3610521",
    item_display: ["3610521 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- xxx -|- DK340.3 .B1 -|- ignore",
                      "3610522 -|- SAL3 -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B2 -|- dk  3400.300000 b0.200000 -|- www -|- DK340.3 .B2 -|- ignore"]
  }) }
  let(:doc2) { SolrDocument.new({
    id: '222',
    title_245a_display: 'title1',
    author_person_display: 'person1',
    pub_date: '2001',
    title_sort: 'title1',
    shelfkey: ['dk  3400.300000 a0.100000', 'dk  3400.300000 b0.100000'],
    preferred_barcode: "3610511",
    item_display: ["3610511 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .A1 -|- dk  3400.300000 a0.100000 -|- zzz -|- DK340.3 .A1 -|- ignore",
                      "3610512 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- xxx -|- DK340.3 .B1 -|- ignore"]
  }) }
  let(:doc3) { SolrDocument.new({
    id: '333',
    title_245a_display: 'title3',
    author_meeting_display: 'meeting3',
    pub_date: '2003',
    title_sort: 'title3',
    shelfkey: ['dk  3400.300000 a0.200000 c0.400000', 'dk  3400.300000 c0.300000'],
    preferred_barcode: "361032",
    item_display: ["361032 -|- SAL3 -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .A2 C4 -|- dk  3400.300000 a0.200000 c0.400000 -|- yyy -|- DK340.3 .A2 C4 -|- ignore",
                      "3610531 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .C3 -|- dk  3400.300000 c0.300000 -|- vvv -|- DK340.3 .C3 -|- ignore"]
  }) }
  let(:doc4) { SolrDocument.new({
    id: '334',
    title_245a_display: 'title3',
    author_person_display: 'person1',
    title_sort: 'title3',
    shelfkey: ['dk  3400.300000 c0.300000'],
    preferred_barcode: "3610541",
    item_display: ["3610541 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .C3 -|- dk  3400.300000 c0.300000 -|- vvv -|- DK340.3 .C3 -|- ignore"]
  }) }

  describe "parsing for item_display pieces" do
    let(:item_display1) { '36105129852856 -|- CHEMCHMENG -|- STACKS -|- -|- STCKS-MONO -|- GT2850 .P65 -|- gt  2850.000000 p0.650000 002008 -|- J6~~XRUZ~ZZZZZZ~AZ~TUZZZZ~ZZXZZT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -|- GT2850 .P65 2008 V.26 -|- GT  2850.000000 P0.650000 002006' }

    it "(get_shelfkey) should return the shelfkey piece" do
      expect(nearby_obj.send(:get_shelfkey, item_display1)).to eq 'gt  2850.000000 p0.650000 002008'
    end
    it "(get_reverse_shelfkey) should return the reverse shelfkey piece" do
      expect(nearby_obj.send(:get_reverse_shelfkey, item_display1)).to eq 'J6~~XRUZ~ZZZZZZ~AZ~TUZZZZ~ZZXZZT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    end
    it "should return nil if nil passed in" do
      expect(nearby_obj.send(:get_shelfkey, nil)).to be_nil
      expect(nearby_obj.send(:get_reverse_shelfkey, nil)).to be_nil
    end
  end

  describe "get_item_display" do
    let(:doc) { {
      item_display: ["3610521 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- ignore -|- ignore -|- ignore",
                        "3610522 -|- SAL3 -|- STACKS -|- -|- DK340.3 .B2 -|- dk  3400.300000 b0.200000 -|- ignore -|- ignore -|- ignore"]
    } }

    it "should return the item_display field matching the barcode" do
      expect(nearby_obj.send(:get_item_display, doc[:item_display], "3610521")).to match /^3610521/
      expect(nearby_obj.send(:get_item_display, doc[:item_display], "3610522")).to match /^3610522/
    end
    it "should return nil when there is no matching item_display field" do
      expect(nearby_obj.send(:get_item_display, doc[:item_display], "666")).to be_nil
    end
    it "should return nil if the barcode given is nil or empty string" do
      expect(nearby_obj.send(:get_item_display, doc[:item_display], nil)).to be_nil
      expect(nearby_obj.send(:get_item_display, doc[:item_display], '')).to be_nil
    end
  end

  describe "get_next_terms_for_field" do
    let(:terms_array) { nearby_obj.send(:get_next_terms_for_field, "aaa", "foo", 3) }

    before do
      term1 = { "aaa" => 1 }
      term2 = { "bbb" => 2 }
      term3 = { "ccc" => 3 }
      term4 = { "ddd" => 4 }
      allow(nearby_obj).to receive(:get_next_terms).with("aaa", "foo", 4).and_return([term1, term2, term3, term4])
    end

    it "should convert the returned structure from Solr into an array of terms" do
      expect(terms_array).to be_an_instance_of(Array)
      terms_array.each { |e| expect(e).to be_an_instance_of(String) }
    end
    it "should not include starting term in the returned array" do
      expect(terms_array).not_to include("aaa")
      expect(terms_array).to include("bbb")
    end
  end

# TODO:  refactor this code so the test data is in here ONCE!!!!!  Will need tweaking, as test data is slightly different from describe to describe

  describe "get_spine_hash_from_doc" do
    let(:desired_shelf_keys) { ['dk  3400.300000 a0.100000', 'dk  3400.300000 b0.100000', 'dk  3400.300000 b0.200000', 'dk  3400.300000 c0.300000'] }
    let(:spine_hash_doc1) { nearby_obj.send(:get_spine_hash_from_doc, doc1, desired_shelf_keys, shelfkey_field) }
    let(:spine_hash_doc2) { nearby_obj.send(:get_spine_hash_from_doc, doc2, desired_shelf_keys, shelfkey_field) }
    let(:spine_hash_doc3) { nearby_obj.send(:get_spine_hash_from_doc, doc3, desired_shelf_keys, shelfkey_field) }
    let(:spine_hash_doc4) { nearby_obj.send(:get_spine_hash_from_doc, doc4, desired_shelf_keys, shelfkey_field) }
    let(:all) { spine_hash_doc1.merge(spine_hash_doc2.merge(spine_hash_doc3.merge(spine_hash_doc4))) }

    it "should return empty hash if field is not shelfkey or callnum_reverse sort" do
      expect(nearby_obj.send(:get_spine_hash_from_doc, doc1, ['aaa'], "building")).to be_empty
    end

    it "should return empty hash if doc has no relevant item for display" do
      expect(nearby_obj.send(:get_spine_hash_from_doc, doc1, ['aaa'], shelfkey_field)).to be_empty
    end

    it "should retrieve same spine for reverse_shelfkey value as for corresponding shelfkey value" do
      spine_hash_doc3_rev = nearby_obj.send(:get_spine_hash_from_doc, doc3, "vvv", reverse_shelfkey_field)
      expect(spine_hash_doc3_rev).to eq spine_hash_doc3
    end

    describe "spine text (the values for the hash)" do
      it "should only be present when shelfkey matches desired list" do
        spine_hash_doc3.values.each { |spine|
          expect(spine[:holding].callnumber).not_to match /DK340\.3 \.A2 C4/
        }
      end

      it "should always have a call number" do
        all.values.each { |spine|
          expect(spine[:holding].callnumber).to match /DK340\.3 /
        }
      end
      it "should always have a library building" do
        all.values.each { |spine|
          expect(spine[:holding].library).to match /(green|sal3)/i
        }
      end
      it "should always have a location" do
        all.values.each { |spine|
          expect(spine[:holding].home_location).to match /Stacks/i
        }
      end

      it "should have a non-displaying div tag with the lopped shelfkey and lopped reverse_shelfkey" do
        spine_hash_doc1.values.each { |e| expect(e[:holding].shelfkey).to match /dk  3400.3.*/ and expect(e[:holding].reverse_shelfkey).to match /[v-z]{3}/ }
        spine_hash_doc2.values.each { |e| expect(e[:holding].shelfkey).to match /dk  3400.3.*/ and expect(e[:holding].reverse_shelfkey).to match /[v-z]{3}/ }
        spine_hash_doc3.values.each { |e| expect(e[:holding].shelfkey).to match /dk  3400.3.*/ and expect(e[:holding].reverse_shelfkey).to match /[v-z]{3}/ }
        spine_hash_doc4.values.each { |e| expect(e[:holding].shelfkey).to match /dk  3400.3.*/ and expect(e[:holding].reverse_shelfkey).to match /[v-z]{3}/ }
      end
    end

    describe "sort keys for spines (the hash keys)" do
      it "should have multiple keys for multiple desired items (unless key collisions)" do
         expect(spine_hash_doc1.keys.size).to eq 2
         expect(spine_hash_doc2.keys.size).to eq 2
      end
      it "should sort by shelfkey, then by title, then by pub date desc (missing last)" do
        sorted = all.keys.sort
        expect(sorted[0]).to match /^dk  34.*A0\.1/i
        expect(sorted[1]).to match /^dK  34.*B0\.1.*title1/i
        expect(sorted[2]).to match /^dK  34.*B0\.1.*title2/i
        expect(sorted[3]).to match /^dK  34.*B0\.2.*title2/i
        expect(sorted[4]).to match /^dK  34.*C0\.3.*title3.*7996/i
        expect(sorted[5]).to match /^dK  34.*C0\.3.*title3.*9999/i
      end
      it "should start with the shelfkey" do
        all.keys.each { |sortkey|
          expect(sortkey).to match /^DK  3400\.300000 /i
        }
      end
      it "should pad the shelfkey with blanks to a constant length of 100" do
        all.keys.each { |sortkey|
          expect(sortkey).to match /^.{100} -\|- /
        }
      end

      it "should have the sortable title after the shelfkey" do
        all.keys.each { |sortkey|
          expect(sortkey).to match /^.{100} -\|- title\d/
        }
      end
      it "should pad/truncate the sortable title to a length of 100" do
        all.keys.each { |sortkey|
          expect(sortkey).to match(/^.{100} -\|- title\d {94} -\|- /)
        }
      end
      it "should always have a 4 digit inverted pub year string after the sortable title (for date descending order)" do
        all.keys.each { |sortkey|
          expect(sortkey).to match /^.{100} -\|- title\d {94} -\|- \d{4} -\|- /
        }
        expect(spine_hash_doc1.keys[0]).to match /^.{100} -\|- title\d {94} -\|- 7997 -\|- /
        expect(spine_hash_doc2.keys[0]).to match /^.{100} -\|- title\d {94} -\|- 7998 -\|- /
        expect(spine_hash_doc3.keys[0]).to match /^.{100} -\|- title\d {94} -\|- 7996 -\|- /
      end
      it "should have a pub year of 9999 when there is no pub year, so it sorts last" do
        expect(spine_hash_doc4.keys[0]).to match /^.{100} -\|- title3 {94} -\|- 9999 -\|- /
      end
      it "should have ckey after pub year to allow for collapse docs with the same call number, title, pub date, and ckey if they come up" do
        all.keys.each { |sortkey|
          expect(sortkey).to match /^.{100} -\|- .{100} -\|- \d{4} -\|- .{20}/
        }
      end
      it "should pad the library name to a length of 40" do
        all.keys.each { |sortkey|
          expect(sortkey).to match /^.{100} -\|- .{100} -\|- \d{4} -\|-.{20}/
        }
      end
    end

  end # specs for get_spine_hash_from_doc

  describe "get_spines_from_field_values" do
    let(:desired_shelfkeys) { ['dk  3400.300000 a0.100000', 'dk  3400.300000 b0.100000', 'dk  3400.300000 b0.200000', 'dk  3400.300000 c0.300000'] }

    let(:spines) { nearby_obj.send(:get_spines_from_field_values, desired_shelfkeys, shelfkey_field) }

    let(:desired_rev_shelfkeys) { ['xxx', 'vvv', 'yyy'] }

    let(:spines_preceding) { nearby_obj.send(:get_spines_from_field_values, desired_rev_shelfkeys, reverse_shelfkey_field) }

    let(:combined_spines) { (spines + spines_preceding) }
    let(:no_spines) { nearby_obj.send(:get_spines_from_field_values, [], shelfkey_field) }

    before do
      allow(nearby_obj).to receive(:get_docs_for_field_values).with(desired_shelfkeys, shelfkey_field).and_return([doc1, doc2, doc3, doc4])
      allow(nearby_obj).to receive(:get_docs_for_field_values).with(desired_rev_shelfkeys, reverse_shelfkey_field).and_return([doc1, doc2, doc3])
      allow(nearby_obj).to receive(:get_docs_for_field_values).with([], shelfkey_field).and_return([])
    end

    it "should return an Array of Hashs" do
      expect(spines).to be_an_instance_of(Array)
      expect(spines_preceding).to be_an_instance_of(Array)
      combined_spines.each { |spine|
        expect(spine).to be_an_instance_of(Hash)
      }
    end
    it "should not return nil or zero-length list items" do
      combined_spines.each { |spine|
        expect(spine).to be_present
      }
    end
    it "should return populated array when given reverse_shelfkey field" do
      skip('Test ported from old codebase needs to be fixed')
      expect(spines_preceding.length > 0).to be_truthy
    end
    it "should not return duplicate spines" do
      expect(spines.uniq!).to be_nil
      expect(spines_preceding.uniq!).to be_nil
    end
    it "should return spines sorted by shelfkey (then title, then pub date desc)" do
      skip('Test ported from old codebase needs to be fixed')
      expect(spines[0][:holding].callnumber).to match /DK340\.3 \.A1/
      expect(spines[1][:holding].callnumber).to match /DK340\.3 \.B1/
      expect(spines[2][:holding].callnumber).to match /DK340\.3 \.B1/
      expect(spines[3][:holding].callnumber).to match /DK340\.3 \.B2/
      expect(spines[4][:holding].callnumber).to match /DK340\.3 \.C3/
      expect(spines[5][:holding].callnumber).to match /DK340\.3 \.C3/

      expect(spines_preceding[0][:holding].callnumber).to match /DK340\.3 \.A2 C4/
      expect(spines_preceding[1][:holding].callnumber).to match /DK340\.3 \.B1/
      expect(spines_preceding[2][:holding].callnumber).to match /DK340\.3 \.B1/
      # Commented out below because it was failing.  Was getting title3 record
      #@spines_preceding[3].to_s.should =~ /title2.*DK340\.3 \.B2/
    end
    it "should return empty array when there are no nearby items" do
      expect(no_spines).to eq []
    end
    it "should have multiple spines for a shelfkey if they are distinct" do
      skip('Test ported from old codebase needs to be fixed')
      count = 0
      combined_spines.each { |spine|
        if spine[:holding].callnumber =~ /DK340\.3 \.B1/
          count = count + 1
        end
      }
      expect(count > 1).to be_truthy
    end
#    it "should ensure that Solr rows param is large enough to get all the matching docs" do
#      pending ("in code, need to use term occurrence counts and make sure Solr rows param is big enough")
#    end
  end # get_spines_from_field_values


  describe "get_next_spines_from_field" do
    let(:test_doc1) { SolrDocument.new({
      id: '111',
      title_245a_display: 'title2',
      author_corp_display: 'corp2',
      pub_date: '2002',
      title_sort: 'title2',
      shelfkey: ['dk  3400.300000 b0.100000', 'dk  3400.300000 b0.200000'],
      reverse_shelfkey: ['yyy', 'xxx'],
      item_display: ["3610521 -|- SAL3 -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B2 -|- dk  3400.300000 b0.200000 -|- yyy -|- DK340.3 .B2 -|- ignore",
                        "3610522 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- xxx -|- DK340.3 .B1 -|- ignore"]
    }) }
    let(:test_doc2) { SolrDocument.new({
      id: '222',
      title_245a_display: 'title1',
      author_person_display: 'person1',
      pub_date: '2001',
      title_sort: 'title1',
      shelfkey: ['dk  3400.300000 a0.100000', 'dk  3400.300000 b0.100000'],
      reverse_shelfkey: ['xxx', 'www'],
      item_display: ["3610512 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- xxx -|- DK340.3 .B1 -|- ignore",
                        "3610511 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .A1 -|- dk  3400.300000 a0.100000 -|- www -|- DK340.3 .A1 -|- ignore",
                        "3610513 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- xxx -|- DK340.3 .B1 -|- ignore"]
    }) }
    let(:test_doc3) { SolrDocument.new({
      id: '333',
      title_245a_display: 'title3',
      author_meeting_display: 'meeting3',
      pub_date: '2003',
      title_sort: 'title3',
      shelfkey: ['dk  3400.300000 a0.200000 c0.400000', 'dk  3400.300000 c0.300000'],
      reverse_shelfkey: ['vvv', 'zzz'],
      item_display: ["361032 -|- SAL3 -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .A2 C4 -|- dk  3400.300000 a0.200000 c0.400000 -|- vvv -|- DK340.3 .A2 C4 -|- ignore",
                        "3610531 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .C3 -|- dk  3400.300000 c0.300000 -|- zzz -|- DK340.3 .C3 -|- ignore"]
    }) }
    let(:test_doc4) { SolrDocument.new({
      id: '444',
      title_245a_display: 'title3',
      author_person_display: 'person1',
      title_sort: 'title3',
      shelfkey: ['dk  3400.300000 c0.300000'],
      reverse_shelfkey: ['zzz'],
      item_display: ["3610541 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .C3 -|- dk  3400.300000 c0.300000 -|- zzz -|- DK340.3 .C3 -|- ignore"]
    }) }

    let(:term1) { { 'dk  3400.300000 a0.100000' => 1 } }
    let(:term2) { { 'dk  3400.300000 b0.100000' => 2 } }
    let(:term3) { { 'dk  3400.300000 b0.200000' => 3 } }
    let(:desired_shelfkeys) { [term2.keys[0], term3.keys[0]] }
    # reverse shelfkey
    let(:rterm1) { { 'xxx' => 1 } }
    let(:rterm2) { { 'yyy' => 2 } }
    let(:rterm3) { { 'zzz' => 3 } }
    let(:desired_rev_shelfkeys) { [rterm2.keys[0], rterm3.keys[0]] }

    let(:shelfkey_array) { nearby_obj.send(:get_next_spines_from_field, term1.keys[0], shelfkey_field, 2, nil) }

    let(:reverse_shelfkey_array) { nearby_obj.send(:get_next_spines_from_field, rterm1.keys[0], reverse_shelfkey_field, 2, nil) }

    before do
      # SolrHelper (calls to Solr) stubs
      allow(nearby_obj).to receive(:get_next_terms).at_least(2).times { |start_val, field, how_many|
        result = []
        case field
          when shelfkey_field
            case start_val
              when term1.keys[0] then result = [term1, term2, term3]
              when 'zzzz' then result = []
            end
          when reverse_shelfkey_field
            case start_val
              when rterm1.keys[0] then result = [rterm1, rterm2, rterm3]
            end
        end
        result
      }

      allow(nearby_obj).to receive(:get_docs_for_field_values).at_least(3).times { |desired_vals, field|
        result = []
        case field
          when shelfkey_field
            result = case desired_vals
              when desired_shelfkeys then [test_doc1, test_doc2]
              when [] then []
            end
          when reverse_shelfkey_field
            result = case desired_vals
              when desired_rev_shelfkeys then [test_doc1, test_doc3, test_doc4]
            end
        end
        result
      }
    end # before each

    it "should return an Array" do
      expect(shelfkey_array).to be_an_instance_of(Array)
    end

    it "should return empty array if there are no next terms" do
      expect(nearby_obj.send(:get_next_spines_from_field, 'zzzz', shelfkey_field, 3, nil)).to eq []
    end
    it "should return spines for the requested number of field values" do
      shelfkey_array.each { |spine_text|
        expect(spine_text[:holding].callnumber).to match /(DK340\.3 \.B1|DK340\.3 \.B2)/
      }
      reverse_shelfkey_array.each { |spine_text|
        expect(spine_text[:holding].callnumber).to match /(DK340\.3 \.B2|DK340\.3 \.C3)/
      }
    end
    it "should get the expected spines for known shelfkey value (via stubbed Solr calls)" do
      skip('Test ported from old codebase needs to be fixed')
      expect(shelfkey_array.length).to eq 3
      expect(shelfkey_array[0][:holding].callnumber).to match /DK340\.3 \.B1/
      expect(shelfkey_array[1][:holding].callnumber).to match /DK340\.3 \.B1/
      expect(shelfkey_array[2][:holding].callnumber).to match /DK340\.3 \.B2/
    end
    it "should get the expected spines for known callnum_reverse sort value (via stubbed Solr calls)" do
      skip('Test ported from old codebase needs to be fixed')
      expect(reverse_shelfkey_array.length).to eq 3
      expect(reverse_shelfkey_array[0][:holding].callnumber).to match /DK340\.3 \.B2/
      # reverse shelfkeys messed up in mock data - this is the correct order for the test
      expect(reverse_shelfkey_array[1][:holding].callnumber).to match /^DK340\.3 \.C3?/
      expect(reverse_shelfkey_array[2][:holding].callnumber).to match /^DK340\.3 \.C3?/
    end
  end # get_next_spines_from_field

  describe "get_nearby_items" do
    let(:doc1) { SolrDocument.new({
      id: 'doc1',
      title_245a_display: 'title2',
      author_corp_display: 'corp2',
      pub_date: '2002',
      title_sort: 'something',
      shelfkey: ['dk  3400.300000 b0.100000', 'dk  3400.300000 b0.200000'],
      reverse_shelfkey: ['vvv', 'www'],
      preferred_barcode: "3610521",
      item_display: ["3610521 -|- SAL3 -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B2 -|- dk  3400.300000 b0.200000 -|- vvv -|- DK340.3 .B2 -|- ignore",
                        "3610522 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- www -|- DK340.3 .B1 -|- ignore"]
    }) }
    let(:doc2) { SolrDocument.new({
      id: 'doc2',
      title_245a_display: 'title1',
      author_person_display: 'person1',
      pub_date: '2001',
      title_sort: 'title1',
      shelfkey: ['dk  3400.300000 a0.100000', 'dk  3400.300000 b0.100000'],
      reverse_shelfkey: ['www', 'yyy'],
      preferred_barcode: "3610511",
      item_display: ["3610512 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- www -|- DK340.3 .B1 -|- ignore",
                        "3610511 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .A1 -|- dk  3400.300000 a0.100000 -|- yyy -|- DK340.3 .A1 -|- ignore",
                        "3610513 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .B1 -|- dk  3400.300000 b0.100000 -|- www -|- DK340.3 .B1 -|- ignore"]
    }) }
    let(:doc3) { SolrDocument.new({
      id: 'doc3',
      title_245a_display: 'title3',
      author_meeting_display: 'meeting3',
      pub_date: '2003',
      title_sort: 'something',
      shelfkey: ['dk  3400.300000 a0.200000 c0.400000', 'dk  3400.300000 c0.300000'],
      reverse_shelfkey: ['uuu', 'xxx'],
      preferred_barcode: "361032",
      item_display: ["361032 -|- SAL3 -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .A2 C4 -|- dk  3400.300000 a0.200000 c0.400000 -|- xxx -|- DK340.3 .A2 C4 -|- ignore",
                        "3610531 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .C3 -|- dk  3400.300000 c0.300000 -|- uuu -|- DK340.3 .C3 -|- ignore"]
    }) }
    let(:doc4) { SolrDocument.new({
      id: 'doc4',
      title_245a_display: 'title3',
      author_person_display: 'person1',
      title_sort: 'something',
      shelfkey: ['dk  3400.300000 c0.300000', 'dk  3400.200000 a0.100000', 'dk  3400.100000 a0.100000'],
      reverse_shelfkey: ['uuu', 'zzz', '~~~'],
      preferred_barcode: "3610542",
      item_display: ["3610541 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.3 .C3 -|- dk  3400.300000 c0.300000 -|- uuu -|- DK340.3 .C3 -|- ignore",
                        "3610542 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.2 .A1 -|- dk  3400.200000 a0.100000 -|- zzz -|- DK340.2 .A1 -|- ignore",
                        "3610543 -|- GREEN -|- STACKS -|- -|- STCKS-MONO -|- DK340.1 .A1 -|- dk  3400.100000 a0.100000 -|- ~~~ -|- DK340.1 .A1 -|- ignore"
                        ]
    }) }
    let(:doc1_set2) { SolrDocument.new({
      id: 'doc1_set2',
      title_245a_display: 'title1',
      author_person_display: 'person1',
      title_sort: 'something',
      shelfkey: ['aaa'],
      reverse_shelfkey: ['ppp'],
      preferred_barcode: "11",
      item_display: ["11 -|- GREEN -|- STACKS -|- -|- -|- AAA -|- aaa -|- ppp -|- AAA -|- ignore"]
    }) }
    let(:doc2_set2) { SolrDocument.new({
      id: 'doc2_set2',
      title_245a_display: 'title2',
      author_person_display: 'person2',
      title_sort: 'something',
      shelfkey: ['bbb'],
      reverse_shelfkey: ['nnn'],
      preferred_barcode: "21",
      item_display: ["21 -|- GREEN -|- STACKS -|- -|- -|- BBB -|- bbb -|- nnn -|- BBB -|- ignore"
                        ]
    }) }
    let(:doc3_set2) { SolrDocument.new({
      id: 'doc3_set2',
      title_245a_display: 'title3',
      author_person_display: 'person3',
      title_sort: 'something',
      shelfkey: ['ccc', 'ddd'],
      reverse_shelfkey: ['kkk', 'mmm'],
      preferred_barcode: "31",
      item_display: ["31 -|- GREEN -|- STACKS -|- -|- -|- CCC -|- ccc -|- mmm -|- CCC -|- ignore",
                        "33 -|- GREEN -|- STACKS -|- -|- -|- DDD -|- ddd -|- kkk -|- DDD -|- ignore"
                        ]
    }) }
    let(:doc1_multi_set1) { SolrDocument.new({
      id: 'doc1_multi_set1',
      title_245a_display: 'title1',
      author_person_display: 'person1',
      title_sort: 'something',
      shelfkey: ['eee'],
      reverse_shelfkey: ['ggg'],
      preferred_barcode: "111",
      item_display: ["111 -|- GREEN -|- STACKS -|- -|- -|- EEE -|- eee -|- ggg -|- EEE -|- ignore",
                        "112 -|- SAL3 -|- STACKS -|- -|- -|- EEE -|- eee -|- ggg -|- EEE -|- ignore"
                        ]
    }) }
    let(:doc2_multi_set1) { SolrDocument.new({
      id: 'doc2_multi_set1',
      title_245a_display: 'title2',
      author_person_display: 'person2',
      title_sort: 'something',
      shelfkey: ['fff'],
      reverse_shelfkey: ['fff'],
      preferred_barcode: "121",
      item_display: ["121 -|- GREEN -|- STACKS -|- -|- -|- FFF -|- fff -|- fff -|- FFF -|- ignore"
                        ]
    }) }
    let(:doc3_multi_set1) { SolrDocument.new({
      id: 'doc3_multi_set1',
      title_245a_display: 'title3',
      author_person_display: 'person3',
      title_sort: 'something',
      shelfkey: ['ggg', 'hhh'],
      reverse_shelfkey: ['eee', 'ddd'],
      preferred_barcode: "131",
      item_display: ["131 -|- GREEN -|- STACKS -|- -|- -|- GGG -|- ggg -|- eee -|- GGG -|- ignore",
                        "132 -|- SAL -|- STACKS -|- -|- -|- GGG -|- ggg -|- eee -|- GGG -|- ignore",
                        "133 -|- GREEN -|- STACKS -|- -|- -|- HHH -|- hhh -|- ddd -|- HHH -|- ignore"
                        ]
    }) }
    # given doc2 as the starting point and @doc2[:preferred_barcode], set up mocks for Solr calls
    let(:sk1) { "dk  3400.300000 b0.100000" }
    let(:sk2) { "dk  3400.300000 b0.200000" }
    let(:sk3) { "dk  3400.300000 c0.300000" }
    let(:term1) { { sk1 => 2 } }
    let(:term2) { { sk2 => 1 } }
    let(:term3) { { sk3 => 2 } }
    let(:auto_sel_sk) { sk1 }
    let(:auto_sel_shelfkeys) { [sk2, sk3] }
    let(:auto_sel_callnum) { "DK340.3 .A1" }
    let(:rev_sk1) { "www" }
    let(:rev_sk2) { "xxx" }
    let(:rev_sk3) { "yyy" }
    let(:rterm1) { { rev_sk1 => 2 } }
    let(:rterm2) { { rev_sk2 => 1 } }
    let(:rterm3) { { rev_sk3 => 1 } }
    let(:auto_sel_rev_sk) { rev_sk1 }
    let(:auto_sel_rev_shelfkeys) { [rev_sk2, rev_sk3] }

    # given doc4 with a doc4[:preferred_barcode], set up mocks for Solr calls
    let(:sk4) { "dk  3400.300000 a0.100000" }
    let(:sk5) { "dk  3400.300000 a0.200000 c0.400000" }
    let(:sk6) { "dk  3400.100000 a0.100000" }
    let(:term4) { { sk4 => 1 } }
    let(:term5) { { sk5 => 1 } }
    let(:term6) { { sk6 => 1 } }
    let(:chosen_sk) { sk4 }
    let(:chosen_callnum) { "DK340.3 .A1" }
    let(:chosen_shelfkeys) { [sk5, sk1] }
    let(:rev_sk4) { "yyy" }
    let(:rev_sk5) { "zzz" }
    let(:rev_sk6) { "~~~" }
    let(:rterm4) { { rev_sk4 => 1 } }
    let(:rterm5) { { rev_sk5 => 1 } }
    let(:rterm6) { { rev_sk6 => 1 } }
    let(:chosen_rev_sk) { rev_sk4 }
    let(:chosen_rev_shelfkeys) { [rev_sk5, rev_sk6] }

    # given doc2_set2 as the starting point, set up mocks for Solr calls
    let(:sk7) { "bbb" }
    let(:sk8) { "ccc" }
    let(:sk9) { "ddd" }
    let(:term7) { { sk7 => 1 } }
    let(:term8) { { sk8 => 1 } }
    let(:term9) { { sk9 => 1 } }
    let(:set2_sk) { sk7 }
    let(:set2_shelfkeys) { [sk8, sk9] }
    let(:set2_callnum) { "BBB" }
    let(:rev_sk7) { "nnn" }
    let(:rev_sk8) { "ppp" }
    let(:rterm7) { { rev_sk7 => 1 } }
    let(:rterm8) { { rev_sk8 => 1 } }
    let(:set2_rev_sk) { rev_sk7 }
    let(:set2_rev_shelfkeys) { [rev_sk8] }

    # given doc2_multi_set1 as the starting point, set up mocks for Solr calls
    let(:sk10) { "fff" }
    let(:sk11) { "ggg" }
    let(:sk12) { "hhh" }
    let(:term10) { { sk10 => 1 } }
    let(:term11) { { sk11 => 1 } }
    let(:term12) { { sk12 => 1 } }
    let(:multi_set1_sk) { sk10 }
    let(:multi_set1_shelfkeys) { [sk11, sk12] }
    let(:multi_set1_callnum) { "FFF" }
    let(:rev_sk10) { "fff" }
    let(:rev_sk11) { "ggg" }
    let(:rterm10) { { rev_sk10 => 1 } }
    let(:rterm11) { { rev_sk11 => 1 } }
    let(:multi_set1_rev_sk) { rev_sk10 }
    let(:multi_set1_rev_shelfkeys) { [rev_sk11] }

    let(:how_many_before) { 2 }
    let(:how_many_after) { 2 }
    let(:page) { 0 }
    let(:nearby_set1) { nearby_obj.send(:get_nearby_items, doc2[:item_display], doc2[:preferred_barcode], how_many_before, how_many_after, page) }
    let(:nearby_set2) { nearby_obj.send(:get_nearby_items, doc2_set2[:item_display], doc2_set2[:preferred_barcode], how_many_before, how_many_after, page) }
    let(:nearby_multi_set1) { nearby_obj.send(:get_nearby_items, doc2_multi_set1[:item_display], doc2_multi_set1[:preferred_barcode], how_many_before, how_many_after, page) }

    # arrays of callnums
    let(:auto_nearby_callnums) {
      nearby_set1.map do |spine|
        spine[:hodling].callnumber
      end
    }

    let(:set2_callnums) {
      nearby_set2.map do |spine|
        spine[:holding].callnumber
      end
    }

    # SolrHelper (calls to Solr) stubs
    before do
      # before(:each) or spec can't resolve solr_document_path
      allow(nearby_obj).to receive(:get_next_terms).at_least(3).times { |start_val, field, how_many|
        result = []
        case field
          when shelfkey_field
            case start_val
              when auto_sel_sk then result = [term1, term2, term3]
              when chosen_sk then result = [term4, term5, term1]
              when set2_sk then result = [term7, term8, term9]
              when multi_set1_sk then result = [term10, term11, term12]
            end
          when reverse_shelfkey_field
            case start_val
              when auto_sel_rev_sk then result = [rterm1, rterm2, rterm3]
              when chosen_rev_sk then result = [rterm4, rterm5, rterm6]
              when set2_rev_sk then result = [rterm7, rterm8]
              when multi_set1_rev_sk then result = [rterm10, rterm11]
            end
        end
        result
      }

      allow(nearby_obj).to receive(:get_docs_for_field_values).at_least(4).times { |desired_vals, field|
        result = []
        case field
          when shelfkey_field
            result = case desired_vals
              when [auto_sel_sk] then [doc1, doc2]
              when auto_sel_shelfkeys then [doc1, doc3, doc4]
              when [chosen_sk] then [doc2]
              when chosen_shelfkeys then [doc1, doc2, doc3]
              when [set2_sk] then [doc2_set2]
              when set2_shelfkeys then [doc2_set2, doc3_set2]
              when [multi_set1_sk] then [doc2_multi_set1]
              when multi_set1_shelfkeys then [doc2_multi_set1, doc3_multi_set1]
            end
          when reverse_shelfkey_field
            result = case desired_vals
              when auto_sel_rev_shelfkeys then [doc2, doc3]
              when chosen_rev_shelfkeys then [doc4]
              when set2_rev_shelfkeys then [doc1_set2]
              when multi_set1_rev_shelfkeys then [doc1_multi_set1]
            end
        end
        result
      }
    end

    it "should use the indicated item if there is one" do
      skip('Test ported from old codebase needs to be fixed')
      t = []
      nearby_set1.each { |spine| t << spine[:holding].callnumber }
      expect(t.to_s).to match /#{chosen_callnum}/
    end
    it "should have no duplicate spines" do
      array = nearby_set1
      expect(array.uniq!).to be_nil
    end
    it "should have no spines with value nil, or no visible text" do
      nearby_set1.each { |spine_text|
        expect(spine_text).to be_present
      }
    end
    it "should get spines on shelf before the indicated item" do
      skip('Test ported from old codebase needs to be fixed')
      t = ""
      nearby_set1.each { |spine| t << spine[:holding].callnumber }
      expect(t).to match /DK340\.2 \.A1/
    end
    it "should gets spines on shelf after the indicated item" do
      skip('Test ported from old codebase needs to be fixed')
      t = ""
      nearby_set1.each { |spine| t << spine[:holding].callnumber }
      expect(t).to match /DK340\.3 \.B1/
    end
    it "should return the requested number of call numbers before/after the selected item" do
      skip('Test ported from old codebase needs to be fixed')
      expect(auto_nearby_callnums.length).to eq how_many_before + how_many_after + 1
    end
    it "should return fewer call numbers before/after the selected one if they don't exist" do
      skip('Test ported from old codebase needs to be fixed')
      # there is only one preceding call number, so expect one less.
      expect(nearby_set2.length).to eq how_many_before + how_many_after
    end
    it "should collapse an item if everything is the same except for the library" do
      skip('Test ported from old codebase needs to be fixed')
      expect(nearby_multi_set1.length).to eq 4
      expect(nearby_multi_set1[0][:holding].callnumber).to eq "EEE"
      expect(nearby_multi_set1[2][:holding].callnumber).to "GGG"
    end

    it "should have spines sorted properly, with indicated item in the center" do
      skip('Test ported from old codebase needs to be fixed')
      # indicated callnum in center?
      expect(auto_nearby_callnums[how_many_before]).to eq auto_sel_callnum
      expect(auto_nearby_callnums[0]).to eq "DK340.1 .A1"
      expect(auto_nearby_callnums[1]).to eq "DK340.2 .A1"
      expect(auto_nearby_callnums[2]).to eq "DK340.3 .A1"
      expect(auto_nearby_callnums[3]).to eq "DK340.3 .A2 C4"
      expect(auto_nearby_callnums[4]).to eq "DK340.3 .B1"

      # chosen bumps the boundary and is less one preceding callnum
      expect(set2_callnums[0]).to eq "AAA"
      expect(set2_callnums[1]).to eq "BBB"
      expect(set2_callnums[2]).to eq "CCC"
      expect(set2_callnums[3]).to eq "DDD"
    end

    it "should return nil if there are no items or all items have blacklisted callnums" do
      _doc_no_items = {
        id: 'doc5',
        title_245a_display: 'title5',
        author_person_display: 'person5',
        item_display: []
      }
      _doc_no_good_callnums = {
        id: 'doc6',
        title_245a_display: 'title6',
        author_person_display: 'person6',
        shelfkey: ['whatever6'],
        reverse_shelfkey: ['zzz'],
        item_display: [nil, nil, nil, nil]
      }
      doc_no_items = SolrDocument.new(_doc_no_items)
      doc_no_good_callnums = SolrDocument.new(_doc_no_good_callnums)
      expect(nearby_obj.send(:get_nearby_items, doc_no_items[:item_display], "", how_many_before, how_many_after, page)).to be_nil
      expect(nearby_obj.send(:get_nearby_items, doc_no_good_callnums[:item_display], "", how_many_before, how_many_after, page)).to be_nil
    end
  end # get_nearby_items
end
