# frozen_string_literal: true

class Record < ApplicationRecord
  attr_accessor :source_url

  audited only: :updated_at

  def initialize(source_url: nil)
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
        author: parse_author(xml_item),
        full_version: false,
        news_type: "news",
        publication_date: publication_date(xml_item),
        published_at: publication_date(xml_item),
        source_url: {
          url: xml_item.at_xpath("link").try(:text),
          description: "source url of original article"
        },
        contentBlocks: [
          {
            title: xml_item.at_xpath("title").try(:text),
            body: parse_content(xml_item)
          }
        ]
      }
    end

    def publication_date(xml_item)
      xml_item.at_xpath("pubDate").try(:text).presence || xml_item.at_xpath("date").try(:text)
    end

    def parse_content(xml_item)
    def parse_content(xml_item)
      content = xml_item.at_xpath("content:encoded") || xml_item.at_xpath("description")
      return unless content.present?

      content.try(:text)
    end

    def parse_author(xml_item)
      begin
        xml_item.at_xpath("creator").try(:text).presence || xml_item.at_xpath("owner").try(:text)
      rescue Nokogiri::XML::XPath::SyntaxError
        ""
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
