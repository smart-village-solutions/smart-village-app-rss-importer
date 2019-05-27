require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
