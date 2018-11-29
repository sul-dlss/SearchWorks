xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.record {
  if @document.respond_to?(:to_marc)
    author_100 = get_data_from_marc_for_mobile(@document.to_marc, "100")
    author_110 = get_data_from_marc_for_mobile(@document.to_marc, "110")
    xml.author(!author_100.nil? ? author_100.first : !author_110.nil? ? author_110.first : nil) if (!author_100.nil? or !author_110.nil?)
    xml.title(get_data_from_marc_for_mobile(@document.to_marc, "245").first) unless get_data_from_marc_for_mobile(@document.to_marc, "245").nil?
    xml.pub_info(get_data_from_marc_for_mobile(@document.to_marc, "260").first) unless get_data_from_marc_for_mobile(@document.to_marc, "260").nil?
    xml.physical_description(get_data_from_marc_for_mobile(@document.to_marc, "300").first) unless get_data_from_marc_for_mobile(@document.to_marc, "300").nil?

    live_info = get_live_data_for_requests(@document, params[:lib])
    if live_info.blank?
      xml.item_details("Lookup either timed out or no item details were available")
    elsif live_info.has_key?(:item_details)
      xml.item_details {
        live_info[:item_details].each do |item|
          xml.item {
            xml.id(item[:id]) unless item[:id].nil?
            xml.shelfkey(item[:shelfkey]) unless item[:shelfkey].nil?
            xml.copy_number(item[:copy_number]) unless item[:copy_number].nil?
            xml.item_number(item[:item_number]) unless item[:item_number].nil?
            xml.library(item[:library]) unless item[:library].nil?
            xml.home_location(item[:home_location]) unless item[:home_location].nil?
            xml.date_item_due(item[:date_time_due]) unless item[:date_time_due].nil?
            xml.current_location(item[:current_location]) unless item[:current_location].nil?
          }
        end
      }
    elsif live_info.has_key?(:callnum_records)
      xml.callnum_records {
        xml.item_number(live_info[:callnum_records].first[:item_number])
        xml.library(live_info[:callnum_records].first[:library])
      }
    end
  end
}
