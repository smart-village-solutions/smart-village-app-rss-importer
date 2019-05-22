class Record < ApplicationRecord
  attr_accessor :current_user

  audited only: :updated_at

  def initialize(current_user: nil)
    @current_user = current_user
    super
  end

  def load_xml_data
    raise "Abstract Method"
  end

  def convert_to_json(hash_data)
    hash_data.to_json
  end

  def convert_xml_to_hash
    raise "Abstract Method"
  end

  # TODO: Diese Daten müssen aus den UserCredentials erzeugt werden,
  # die im current_user gespeichert sein sollen.
  def data_provider
    {
      name: "",
      address: {
        addition: "",
        street: "",
        zip: "",
        city: "",
        coordinates: {
          lat: "",
          lng: ""
        }
      },
      contact: {
        first_name: "",
        last_name: "",
        phone: "",
        fax: "",
        email: "",
        url: ""
      },
      logo: "",
      description: ""
    }
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
#  type        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
