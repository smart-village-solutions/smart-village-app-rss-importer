# frozen_string_literal: true

class Record < ApplicationRecord
  attr_accessor :source_url, :feed

  audited only: :updated_at

  def initialize(source_url: nil, feed: nil)
    @source_url = source_url
    @feed = feed
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
        external_id: parse_content_external_id(xml_item),
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
            intro: parse_content_intro(xml_item),
            body: parse_content_body(xml_item)
          }
        ]
      }
    end

    def publication_date(xml_item)
      xml_item.at_xpath("pubDate").try(:text).presence || xml_item.at_xpath("date").try(:text)
    end

    # Content ist meinst in folgenden Stellen im RSS,
    # wird nun aber dynamisch in den Settings pro Feed definiert
    #
    # xml_item.at_xpath("content").try(:text).presence ||
    # xml_item.at_xpath("encoded").try(:text).presence ||
    # xml_item.at_xpath("description").try(:text)
    def parse_content_intro(xml_item)
      return nil if feed[:import][:intro] == false
      return nil if feed[:import][:intro].blank?

      xml_item.at_xpath(feed[:import][:intro]).try(:text)
    end

    def parse_content_body(xml_item)
      return nil if feed[:import][:body] == false
      return nil if feed[:import][:body].blank?

      xml_item.at_xpath(feed[:import][:body]).try(:text)
    end

    def parse_content_external_id(xml_item)
      return nil if feed[:import][:external_id] == false
      return nil if feed[:import][:external_id].blank?

      xml_item.at_xpath(feed[:import][:external_id]).try(:text)
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
