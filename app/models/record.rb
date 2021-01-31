# frozen_string_literal: true

class Record < ApplicationRecord
  attr_accessor :source_url, :feed

  def load_rss_data(feed)
    @feed = feed
    source_url = feed[:url]
    result = ApiRequestService.new(source_url).get_request(false)

    return unless result.code == "200"
    return unless result.body.present?

    self.xml_data = result.body
  end

  def convert_to_json(hash_data)
    hash_data.to_json
  end

  def convert_rss_to_hash(feed)
    return convert_rss_to_news_hash(feed) if feed[:data_type].blank?
    return convert_rss_to_news_hash(feed) if feed[:data_type] == "news"

    convert_rss_to_events_hash(feed) if feed[:data_type] == "events"
  end

  def convert_rss_to_news_hash(feed)
    @feed = feed
    news_data = []
    @xml_doc = Nokogiri.XML(xml_data)
    @xml_doc.remove_namespaces!
    feed_item_path = feed.fetch(:feed_item_path, nil).presence || "//item"
    @xml_doc.xpath(feed_item_path).each do |xml_item|
      news_data << parse_single_news_from_xml(xml_item)
    end

    self.json_data = { news: news_data }
  end

  def convert_rss_to_events_hash(feed)
    @feed = feed
    news_data = []
    @xml_doc = Nokogiri.XML(xml_data)
    @xml_doc.remove_namespaces!
    feed_item_path = feed.fetch(:feed_item_path, nil).presence || "//item"
    @xml_doc.xpath(feed_item_path).each do |xml_item|
      news_data << parse_single_event_from_xml(xml_item)
    end

    self.json_data = { events: news_data }
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
            title: parse_content_title(xml_item),
            intro: parse_content_intro(xml_item),
            body: parse_content_body(xml_item),
            media_contents: media_contents(xml_item)
          }
        ]
      }
    end

    def parse_single_event_from_xml(xml_item)
      {
        title: parse_content_title(xml_item),
        external_id: parse_content_external_id(xml_item),
        description: parse_content_body(xml_item),
        category_name: xml_item.at_xpath("category").try(:text),
        dates: [
          {
            date_start: publication_date(xml_item),
            time_description: xml_item.at_xpath("encoded").try(:text).to_s[0,254],
            use_only_time_description: false
          }
        ],
        urls: [
          {
            url: xml_item.at_xpath("link").try(:text),
            description: "Details"
          }
        ],
        media_contents: media_contents(xml_item)
      }
    end

    def media_contents(xml_item)
      return [] if feed[:import][:images].blank?
      return [] if feed[:import][:images] == false

      media = []
      xml_item.xpath(feed[:import][:images][:image_tag]).each do |image_item|
        image_data = {
          content_type: "image",
          copyright: image_item.at_xpath(feed[:import][:images][:copyright]).try(:text),
          caption_text: image_item.at_xpath(feed[:import][:images][:caption_text]).try(:text),
          width: image_item.at_xpath(feed[:import][:images][:width]).try(:text).to_i,
          height: image_item.at_xpath(feed[:import][:images][:height]).try(:text).to_i,
          source_url: {
            url: image_item.at_xpath(feed[:import][:images][:source_url]).try(:text)
          }
        }
        media << image_data
      end

      media.compact.flatten
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
      return nil if feed[:import][:intro].blank?
      return nil if feed[:import][:intro] == false

      xml_item.at_xpath(feed[:import][:intro]).try(:text)
    end

    def parse_content_body(xml_item)
      return nil if feed[:import][:body].blank?
      return nil if feed[:import][:body] == false

      xml_item.at_xpath(feed[:import][:body]).try(:text)
    end

    def parse_content_external_id(xml_item)
      return nil if feed[:import][:external_id].blank?
      return nil if feed[:import][:external_id] == false

      xml_item.at_xpath(feed[:import][:external_id]).try(:text)
    end

    def parse_content_title(xml_item)
      return xml_item.at_xpath("title").try(:text) if feed[:import][:title].blank?

      xml_item.at_xpath(feed[:import][:title]).try(:text)
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
