require "rails_helper"

RSpec.describe Record, type: :model do
  describe "import" do
    let(:record) { Record.new }

    it "converts a xml from hash to json" do
      expect(record.convert_to_json({})).to eq("{}")
    end
  end

  describe "parse content title" do
    let(:record) { Record.new }
    let(:feed_with_prefixed_date) {
      {
        "url": "https://www.seelow.de/news/rss.xml?rubrik=13",
        "name": "Homepage Seelow",
        "import": {
          "intro": "description",
          "body": false,
          "external_id": "link",
          "title": "title",
          "images": false
        }
      }
    }
    let(:feed_without_prefixed_date) {
      {
        "url": "https://www.seelow.de/news/rss.xml?rubrik=13",
        "name": "Homepage Seelow",
        "remove_prefixed_date_in_title": true,
        "import": {
          "intro": "description",
          "body": false,
          "external_id": "link",
          "title": "title",
          "images": false
        }
      }
    }
    let(:xml_data) {
      # <?xml version="1.0"?>
      # <rss>
      #   <channel>
      #     <item>
      #       <title><![CDATA[19.10.2021: FACHFORUM "DASEINSVORSORGE" IM KREISKULTURHAUS]]></title>
      #       <link>https://www.seelow.de/news/index.php?news=683934</link>
      #       <description><![CDATA[<img src="https://vorschau.verwaltungsportal.de/news/6/8/3/9/3/4/3497999300.jpg" alt="FACHFORUM "DASEINSVORSORGE" IM KREISKULTURHAUS" /><br /><br /> Am 11.10.2021 kamen ca. 50 Referendare aus der ganzen Bundesrepublik zusammen und verständigten sich zum Thema &quot;Daseinsvorsorge im ländlichen Raum&quot;.
      #         Nach Vorträgen u.a. von ... <br /><br />[<a href="https://www.seelow.de/news/index.php?news=683934" aria-label="Zur Meldung" title="Zur Meldung">mehr</a>]]]></description>
      #       <pubDate>Tue, 19 Oct 2021 00:00:00 +0200</pubDate>
      #     </item>
      #   </channel>
      # </rss>
      Nokogiri::XML::Builder.new do |xml|
        xml.rss {
          xml.channel {
            xml.item {
              xml.title "19.10.2021: FACHFORUM \"DASEINSVORSORGE\" IM KREISKULTURHAUS"
              xml.link "https://www.seelow.de/news/index.php?news=683934"
              xml.description "<img src=\"https://vorschau.verwaltungsportal.de/news/6/8/3/9/3/4/3497999300.jpg\" alt=\"FACHFORUM \"DASEINSVORSORGE\" IM KREISKULTURHAUS\" /><br /><br /> Am 11.10.2021 kamen ca. 50 Referendare aus der ganzen Bundesrepublik zusammen und verständigten sich zum Thema &quot;Daseinsvorsorge im ländlichen Raum&quot;. Nach Vorträgen u.a. von ... <br /><br />[<a href=\"https://www.seelow.de/news/index.php?news=683934\" aria-label=\"Zur Meldung\" title=\"Zur Meldung\">mehr</a>"
              xml.pubDate "Tue, 19 Oct 2021 00:00:00 +0200"
            }
          }
        }
      end
    }

    it "converts a xml from hash to json" do
      xml_item = xml_data.doc.xpath("//item")
      allow_any_instance_of(Record).to receive(:feed) { feed_with_prefixed_date }
      expect(record.send(:parse_content_title, xml_item)).to eq("19.10.2021: FACHFORUM \"DASEINSVORSORGE\" IM KREISKULTURHAUS")
    end

    it "converts a xml from hash to json" do
      xml_item = xml_data.doc.xpath("//item")
      allow_any_instance_of(Record).to receive(:feed) { feed_without_prefixed_date }
      expect(record.send(:parse_content_title, xml_item)).to eq("FACHFORUM \"DASEINSVORSORGE\" IM KREISKULTURHAUS")
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
