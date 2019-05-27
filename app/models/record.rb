class Record < ApplicationRecord
  attr_accessor :current_user, :source_url

  audited only: :updated_at

  def initialize(current_user: nil, source_url: nil)
    @current_user = current_user
    @source_url = source_url
    super
  end

  def load_rss_data
    result = ApiRequestService.new(source_url).get_request(false)

    return unless result.code == "200"
    return unless result.body.present?

    self.xml_data = result.body
  end

  def convert_to_json(hash_data)
    hash_data.to_json
  end

  def convert_rss_to_hash
    news_data = []
    @xml_doc = Nokogiri.XML(xml_data)
    @xml_doc.remove_namespaces!
    @xml_doc.xpath("//item").each do |xml_item|
      news_data << parse_single_news_from_xml(xml_item)
    end

    self.json_data = { news: news_data }
  end

  private

  def parse_single_news_from_xml(xml_item)
    {
      author: xml_item.xpath("creator").try(:text),
      full_version: false,
      news_type: "news",
      publication_date: publication_date(xml_item),
      published_at: publication_date(xml_item),
      source_url: {
        url: xml_item.at_xpath("link").try(:text),
        description: "source url of original article"
      },
      data_provider: data_provider,
      contentBlocks: [
        {
          title: xml_item.at_xpath("title").try(:text),
          body: xml_item.at_xpath("description").try(:text),
        }
      ]
    }
  end

  def publication_date(xml_item)
    xml_item.at_xpath("pubDate").try(:text)
  end

  def data_provider
    return {} if @current_user.blank?

    @current_user.fetch(:data_provider, {})
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
