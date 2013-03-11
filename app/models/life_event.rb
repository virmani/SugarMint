class LifeEvent
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  SOURCE_SHORT_NAME = {
    :foursquare => "4sq"
  }

  attr_accessor :title, :sub_title, :source, :image_url, :venue_name,:latitude, :longitude, :venue_icon, :venue_category, :venue_url,:occured_at

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.from_foursquare_checkin(checkin)
    life_event = LifeEvent.new
    life_event.title = checkin.shout
    life_event.source = :foursquare
    life_event.occured_at = (DateTime.strptime(checkin.json["createdAt"].to_s, '%s') + checkin.json["timeZoneOffset"].minutes).to_f()*1000

    # Can get other sizes if needed
    life_event.image_url = checkin.json["photos"]["items"].first["url"] if (checkin.json["photos"] && checkin.json["photos"]["count"] > 0 && checkin.json["photos"]["items"])
    life_event.venue_name = checkin.venue.name
    life_event.latitude = checkin.venue.location.lat if checkin.venue.location
    life_event.longitude = checkin.venue.location.lng if checkin.venue.location
    #life_event.venue_url = checkin.venue.canonicalUrl

    if (checkin.venue.categories && checkin.venue.categories.first)
      life_event.venue_icon = checkin.venue.categories.first.icon
      life_event.venue_category = checkin.venue.categories.first.name
    end

    life_event
  end

  def short_summary
    "At #{venue_name}: #{title}"
  end

  def source_name
    SOURCE_SHORT_NAME[source]
  end

  def to_hash
    {
      :title 		=> title,
      :short_summary => short_summary,
      :source     => source,
      :source_name => source_name,
      :occured_at	=> occured_at,
      :image_url  => image_url,
      :venue_name => venue_name,
      :latitude   => latitude,
      :longitude  => longitude,
      :venue_icon => venue_icon,
      :venue_category => venue_category,
    }
  end

  def persisted?
    false
  end
end
