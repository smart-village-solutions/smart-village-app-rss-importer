require 'rails_helper'

RSpec.describe Record, type: :model do
  describe "import" do
    let(:record) { Record.new(current_user: nil) }

    it "converts a xml from hash to json" do
      expect(record.convert_to_json({})).to eq("{}")
    end
  end
end

# == Schema Information
#
# Table name: records
#
#  id          :bigint           not null, primary key
#  external_id :string
#  json_data   :jsonb
#  xml_data    :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
