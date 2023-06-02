require "spec_helper"

describe LiveLookup::Sirsi do
  let(:response) { double('response') }
  let(:get) { double('get') }
  let(:body) { 'body' }

  before do
    expect(response).to receive(:get).and_return(get)
    expect(get).to receive(:body).and_return(body)
  end

  describe "url construction" do
    it "should construct the correct URL for single items" do
      expect(Faraday).to receive(:new).with({ url: "#{Settings.LIVE_LOOKUP_URL}?search=holding&id=123" }).and_return(response)
      LiveLookup::Sirsi.new(['123']).to_json
    end
    it "should construct the URL for multiple items properly" do
      expect(Faraday).to receive(:new).with({ url: "#{Settings.LIVE_LOOKUP_URL}?search=holdings&id0=123&id1=321" }).and_return(response)
      LiveLookup::Sirsi.new(['123', '321']).to_json
    end
  end

  describe "Record" do
    describe "#to_json" do
      let(:body) {
        <<-XML
          <titles>
            <record>
              <catalog>
                <item_record>
                  <item_id>123456</item_id>
                  <date_time_due>10/10/2014,10:32</date_time_due>
                  <current_location>BINDERY</current_location>
                </item_record>
              </catalog>
            </record>
          </titles>
        XML
      }

      before do
        expect(Faraday).to receive(:new).and_return(response)
      end

      it "should return a json representation w/ the barcode, due date, and current location" do
        json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
        expect(json.length).to eq 1
        expect(json.first).to eq({
                                   'item_id' => '123456',
                                   'barcode' => '123456',
                                   'due_date' => '10/10/2014,10:32',
                                   'is_available' => false,
                                   'status' => 'At bindery',
                                   'current_location' => 'At bindery'
                                 })
      end
    end

    describe "barcode" do
      let(:body) {
        <<-XML
          <titles>
            <record>
              <catalog>
                <item_record>
                  <item_id>123456</item_id>
                </item_record>
              </catalog>
            </record>
          </titles>
        XML
      }

      before do
        expect(Faraday).to receive(:new).and_return(response)
      end

      it "should get fetched correctly" do
        json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
        expect(json.length).to eq 1
        expect(json.first["item_id"]).to eq '123456'
      end
    end

    describe "due date" do
      before do
        expect(Faraday).to receive(:new).and_return(response)
      end

      describe "NEVER" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <date_time_due>NEVER</date_time_due>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should not be returned" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to be_nil
        end
      end

      describe 'current location that should hide the due date' do
        let(:body) do
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <date_time_due>Some due date</date_time_due>
                    <current_location>SEE-LOAN</current_location>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        end

        it 'should not be returned' do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to be_nil
        end
      end

      describe 'home location that should hide the due date' do
        let(:body) do
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <date_time_due>Some due date</date_time_due>
                    <home_location>CDL</home_location>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        end

        it 'should not be returned' do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to be_nil
        end
      end

      describe 'libraries that should hide the due date' do
        let(:body) do
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <library>RUMSEYMAP</library>
                    <date_time_due>Some due date</date_time_due>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        end

        it 'should not be returned' do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to be_nil
        end
      end

      describe "end of day" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <date_time_due>10/10/2014,23:59</date_time_due>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should truncate the time" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to eq '10/10/2014'
        end
      end

      describe "standard" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <date_time_due>10/10/2014,10:32</date_time_due>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should return the full due date" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to eq '10/10/2014,10:32'
        end
      end

      describe "multiple due dates" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <date_time_due>10/12/2014,10:32</date_time_due>
                    <date_time_due>10/10/2014,10:32</date_time_due>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should use the last due date available" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['due_date']).to eq '10/10/2014,10:32'
        end
      end
    end

    describe "current location" do
      before do
        expect(Faraday).to receive(:new).and_return(response)
      end

      describe "CHECKEDOUT" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <current_location>CHECKEDOUT</current_location>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should not be returned" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['status']).to be_nil
        end
      end

      describe "standard" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <current_location>BINDERY</current_location>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should return a translated value" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['status']).to eq 'At bindery'
        end
      end

      describe 'current locations that are identical to the home location' do
        let(:body) do
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <home_location>BINDERY</home_location>
                    <current_location>BINDERY</current_location>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        end

        it 'are not returned' do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['status']).to be_nil
        end
      end

      describe "multiple locations" do
        let(:body) {
          <<-XML
            <titles>
              <record>
                <catalog>
                  <item_record>
                    <current_location>SUL-BIND</current_location>
                    <current_location>BINDERY</current_location>
                  </item_record>
                </catalog>
              </record>
            </titles>
          XML
        }

        it "should return the last current location" do
          json = JSON.parse(LiveLookup::Sirsi.new(['123']).to_json)
          expect(json.length).to eq 1
          expect(json.first['status']).to eq 'At bindery'
        end
      end
    end
  end
end
