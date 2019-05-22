require 'rails_helper'

RSpec.describe PoiRecord, type: :model do
  describe "import" do
    let(:xml_raw_data) { File.read("doc/tmb_poi.xml") }
    let(:poi_hash) { JSON.parse(File.read("doc/tmb_poi.json")) }
    let(:poi) { PoiRecord.new(current_user: nil) }

    it "stores a xml in xml_data" do
      poi.xml_data = xml_raw_data

      expect(poi.xml_data).not_to be_empty
    end

    it "converts a hash to json" do
      hash_data = { foo: "bar" }

      expect(poi.convert_to_json(hash_data)).to eq("{\"foo\":\"bar\"}")
    end

    it "converts a xml to hash" do
      poi.xml_data = xml_raw_data
      result = poi.convert_xml_to_hash

      expect(result[:point_of_interests].present?).to eq(true)
      expect(result[:point_of_interests].count).to eq(241)
    end
  end
end
